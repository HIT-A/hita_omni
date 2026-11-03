import 'dart:async';

import 'package:academic_api/academic_api.dart' show TermFilter;
import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/http_types.dart';
import '../../account/application/account_controller.dart';
import '../../account/domain/account_session.dart';
import '../data/timetable_cache.dart';
import '../data/timetable_repository.dart';
import '../domain/term.dart';
import '../domain/timetable_entry.dart';
import '../domain/timetable_snapshot.dart';

class TimetableController extends ChangeNotifier {
  TimetableController({required this.account, required this.repository}) {
    account.addListener(_handleAccountChanged);
    _sessionId = account.session?.sessionId;
    _providerId = account.session?.providerId;
    _loadCache(providerId: _providerId);
    if (snapshot == null && account.session != null) {
      unawaited(sync());
    }
  }

  final AccountController account;
  final TimetableRepository repository;

  List<Term> _allTerms = const <Term>[];
  List<Term> _terms = const <Term>[];
  List<TimetableEntry> _timetables = const <TimetableEntry>[];
  String? _activeTimetableId;
  String? _selectedTermId;
  String? _sessionId;
  String? _providerId;
  int _generation = 0;
  bool _busy = false;
  String? _error;

  List<Term> get terms => _terms;
  List<TimetableEntry> get timetables => _timetables;
  List<Term> get localTerms {
    final localIds = <String>{
      for (final entry in _timetables) entry.snapshot.term.id,
    };
    final seen = <String>{};
    final result = <Term>[];
    for (final term in _terms) {
      if (localIds.contains(term.id) && seen.add(term.id)) {
        result.add(term);
      }
    }
    for (final entry in _timetables) {
      final term = entry.snapshot.term;
      if (seen.add(term.id)) {
        result.add(term);
      }
    }
    return List<Term>.unmodifiable(result);
  }

  TimetableSnapshot? get snapshot => activeTimetable?.snapshot;
  String? get providerId => _providerId;
  bool get busy => _busy;
  String? get error => _error;

  TimetableEntry? get activeTimetable {
    final activeId = _activeTimetableId;
    if (activeId != null) {
      for (final entry in _timetables) {
        if (entry.id == activeId) {
          return entry;
        }
      }
    }
    return _timetables.isEmpty ? null : _timetables.first;
  }

  Term? get selectedTerm {
    final active = activeTimetable;
    if (active != null) {
      return active.snapshot.term;
    }
    final selectedId = _selectedTermId;
    if (selectedId != null) {
      for (final term in _terms) {
        if (term.id == selectedId) {
          return term;
        }
      }
    }
    return _terms.isEmpty ? null : _terms.first;
  }

  void _loadCache({String? providerId}) {
    final cached = providerId == null
        ? repository.loadActiveCache()
        : repository.loadCacheFor(providerId);
    if (cached == null) {
      return;
    }
    _providerId = cached.providerId;
    _timetables = cached.timetables;
    _activeTimetableId = cached.activeTimetable?.id;
    _allTerms = _mergeTerms(cached.terms, entries: cached.timetables);
    final activeTerm = cached.activeTimetable?.snapshot.term;
    _terms = _visibleTerms(_allTerms, include: activeTerm);
    _selectedTermId =
        activeTerm?.id ?? (_terms.isEmpty ? null : _terms.first.id);
  }

  void _handleAccountChanged() {
    final session = account.session;
    final nextSessionId = session?.sessionId;
    if (nextSessionId == _sessionId) {
      return;
    }
    _sessionId = nextSessionId;
    _generation++;
    _busy = false;
    if (session == null) {
      // The timetable is local data. Signing out only removes the ability to
      // sync with the academic service; it does not delete any timetable.
      _error = account.error;
      notifyListeners();
      return;
    }
    if (session.providerId != _providerId) {
      _providerId = session.providerId;
      _allTerms = const <Term>[];
      _terms = const <Term>[];
      _timetables = const <TimetableEntry>[];
      _activeTimetableId = null;
      _selectedTermId = null;
      _loadCache(providerId: session.providerId);
    } else {
      final activeTerm = activeTimetable?.snapshot.term;
      _terms = _visibleTerms(_allTerms, session: session, include: activeTerm);
    }
    _error = null;
    notifyListeners();
    unawaited(sync());
  }

  Future<void> sync({Term? term}) async {
    final session = account.session;
    if (session == null || _busy) {
      return;
    }
    final generation = _generation;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final allTerms = await repository.fetchTerms(session);
      if (!_isCurrent(generation, session)) {
        return;
      }
      final terms = _visibleTerms(allTerms, session: session);
      if (terms.isEmpty) {
        throw ApiException('未获取到学期列表');
      }
      final selected = _selectTerm(terms, preferred: term);
      final snapshot = await repository.fetchSnapshot(
        session: session,
        term: selected,
      );
      if (!_isCurrent(generation, session)) {
        return;
      }

      final now = DateTime.now();
      final nextEntries = List<TimetableEntry>.from(_timetables);
      final existingIndex = nextEntries.indexWhere(
        (entry) => entry.snapshot.term.id == snapshot.term.id,
      );
      final entry = existingIndex >= 0
          ? nextEntries[existingIndex].copyWith(
              snapshot: snapshot,
              updatedAt: now,
            )
          : TimetableEntry.fromSnapshot(
              id: timetableEntryId(session.providerId, selected.id),
              snapshot: snapshot,
              createdAt: now,
              updatedAt: now,
            );
      if (existingIndex >= 0) {
        nextEntries[existingIndex] = entry;
      } else {
        nextEntries.insert(0, entry);
      }

      final mergedTerms = _mergeTerms(
        allTerms,
        entries: nextEntries,
        extra: selected,
      );
      final visibleTerms = _visibleTerms(
        mergedTerms,
        session: session,
        include: selected,
      );
      await repository.save(
        TimetableCacheData(
          providerId: session.providerId,
          terms: mergedTerms,
          timetables: nextEntries,
          activeTimetableId: entry.id,
        ),
      );
      if (!_isCurrent(generation, session)) {
        return;
      }
      _providerId = session.providerId;
      _allTerms = mergedTerms;
      _terms = visibleTerms;
      _timetables = List<TimetableEntry>.unmodifiable(nextEntries);
      _activeTimetableId = entry.id;
      _selectedTermId = selected.id;
      _busy = false;
      notifyListeners();
    } on AuthExpiredException {
      if (!_isCurrent(generation, session)) {
        return;
      }
      _busy = false;
      final message = '登录已失效，请重新登录';
      _error = message;
      notifyListeners();
      account.expireSession(message);
    } on ApiException catch (error) {
      if (!_isCurrent(generation, session)) {
        return;
      }
      _busy = false;
      _error = error.message;
      notifyListeners();
    } on HttpTransportException catch (error) {
      if (!_isCurrent(generation, session)) {
        return;
      }
      _busy = false;
      _error = error.message;
      notifyListeners();
    } catch (_) {
      if (!_isCurrent(generation, session)) {
        return;
      }
      _busy = false;
      _error = '课表同步失败，请稍后重试';
      notifyListeners();
    }
  }

  Future<void> refresh() => sync(term: selectedTerm);

  /// Switches between already imported terms. Importing a new term is an
  /// explicit action from the timetable manager.
  Future<void> selectTerm(Term term) async {
    final local = _entryForTerm(term.id);
    if (local != null && !_busy) {
      await selectTimetable(local.id);
    }
  }

  /// Fetches the remote term list only for the management import sheet. It does
  /// not create or replace any local timetable.
  Future<List<Term>> loadTermsForImport() async {
    final session = account.session;
    if (session == null) {
      throw ApiException('登录教务账号后可导入课表');
    }
    final fetched = await repository.fetchTerms(session);
    final visible = _visibleTerms(fetched, session: session);
    if (visible.isEmpty) {
      throw ApiException('未获取到学期列表');
    }
    if (!_isCurrent(_generation, session)) {
      return visible;
    }
    _allTerms = _mergeTerms(fetched, entries: _timetables);
    _terms = _visibleTerms(
      _allTerms,
      session: session,
      include: activeTimetable?.snapshot.term,
    );
    notifyListeners();
    return visible;
  }

  /// Explicit import action from the timetable manager.
  Future<void> importTimetable(Term term) => sync(term: term);

  Future<void> selectTimetable(String id) async {
    if (_busy) {
      return;
    }
    final entry = _entryForId(id);
    if (entry == null || entry.id == activeTimetable?.id) {
      return;
    }
    final previousId = _activeTimetableId;
    final previousTermId = _selectedTermId;
    _activeTimetableId = entry.id;
    _selectedTermId = entry.snapshot.term.id;
    _error = null;
    notifyListeners();
    if (!await _persist()) {
      _activeTimetableId = previousId;
      _selectedTermId = previousTermId;
      notifyListeners();
    }
  }

  Future<bool> renameTimetable(String id, String name) async {
    if (_busy) {
      return false;
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final index = _timetables.indexWhere((entry) => entry.id == id);
    if (index < 0) {
      return false;
    }
    final next = List<TimetableEntry>.from(_timetables);
    next[index] = next[index].copyWith(
      name: trimmed,
      updatedAt: DateTime.now(),
    );
    if (!await _persist(timetables: next)) {
      return false;
    }
    _timetables = List<TimetableEntry>.unmodifiable(next);
    _error = null;
    notifyListeners();
    return true;
  }

  Future<bool> deleteTimetable(String id) async {
    if (_busy) {
      return false;
    }
    final index = _timetables.indexWhere((entry) => entry.id == id);
    if (index < 0) {
      return false;
    }
    final next = List<TimetableEntry>.from(_timetables)..removeAt(index);
    final deletedActive = id == activeTimetable?.id;
    final nextActive = deletedActive
        ? (next.isEmpty ? null : next.first.id)
        : _activeTimetableId;
    if (!await _persist(
      timetables: next,
      activeTimetableId: nextActive,
      explicitActive: true,
    )) {
      return false;
    }
    _timetables = List<TimetableEntry>.unmodifiable(next);
    _activeTimetableId = nextActive;
    _selectedTermId = nextActive == null
        ? null
        : _entryForId(nextActive)?.snapshot.term.id;
    _error = null;
    notifyListeners();
    return true;
  }

  Future<bool> _persist({
    List<TimetableEntry>? timetables,
    String? activeTimetableId,
    bool explicitActive = false,
  }) async {
    final providerId = _providerId;
    if (providerId == null) {
      return false;
    }
    try {
      await repository.save(
        TimetableCacheData(
          providerId: providerId,
          terms: _allTerms,
          timetables: timetables ?? _timetables,
          activeTimetableId: explicitActive
              ? activeTimetableId
              : activeTimetableId ?? _activeTimetableId,
        ),
      );
      return true;
    } catch (_) {
      _error = '课表管理数据保存失败';
      notifyListeners();
      return false;
    }
  }

  TimetableEntry? _entryForId(String id) {
    for (final entry in _timetables) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  TimetableEntry? _entryForTerm(String termId) {
    for (final entry in _timetables) {
      if (entry.snapshot.term.id == termId) {
        return entry;
      }
    }
    return null;
  }

  List<Term> _mergeTerms(
    Iterable<Term> remote, {
    Iterable<TimetableEntry> entries = const <TimetableEntry>[],
    Term? extra,
  }) {
    final byId = <String, Term>{};
    for (final term in remote) {
      byId[term.id] = term;
    }
    for (final entry in entries) {
      byId.putIfAbsent(entry.snapshot.term.id, () => entry.snapshot.term);
    }
    if (extra != null) {
      byId.putIfAbsent(extra.id, () => extra);
    }
    return byId.values.toList(growable: false);
  }

  List<Term> _visibleTerms(
    Iterable<Term> terms, {
    AccountSession? session,
    Term? include,
  }) {
    final activeSession = session ?? account.session;
    final visible = TermFilter.forTimetableAndAssessment(
      terms,
      grade: activeSession?.profile['grade'],
      studentId: activeSession?.studentId,
    );
    if (include != null && !visible.any((term) => term.id == include.id)) {
      return <Term>[include, ...visible];
    }
    return visible;
  }

  bool _isCurrent(int generation, AccountSession session) {
    return generation == _generation &&
        account.session?.sessionId == session.sessionId;
  }

  Term _selectTerm(List<Term> terms, {Term? preferred}) {
    final preferredId = preferred?.id ?? _selectedTermId;
    if (preferredId != null) {
      for (final term in terms) {
        if (term.id == preferredId) {
          return term;
        }
      }
    }
    for (final term in terms) {
      if (term.isCurrent) {
        return term;
      }
    }
    return terms.first;
  }

  @override
  void dispose() {
    account.removeListener(_handleAccountChanged);
    super.dispose();
  }
}
