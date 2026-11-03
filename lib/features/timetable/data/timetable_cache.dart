import 'dart:convert';

import '../../../core/storage/storage.dart';
import '../domain/term.dart';
import '../domain/timetable_entry.dart';
import '../domain/timetable_snapshot.dart';

const _cacheKey = 'timetable.cache.v3';
const _legacyCacheKey = 'timetable.cache.v2';
const _legacyV1CacheKey = 'timetable.cache.v1';
const _legacyProviderId = 'hit.shenzhen';

class TimetableCacheData {
  TimetableCacheData({
    required this.providerId,
    required List<Term> terms,
    List<TimetableEntry> timetables = const <TimetableEntry>[],
    String? activeTimetableId,
  }) : terms = List<Term>.unmodifiable(terms),
       timetables = List<TimetableEntry>.unmodifiable(timetables),
       activeTimetableId =
           activeTimetableId ??
           (timetables.isEmpty ? null : timetables.first.id);

  factory TimetableCacheData.single({
    required String providerId,
    required List<Term> terms,
    required TimetableSnapshot snapshot,
    String? id,
    String? name,
  }) {
    final entry = TimetableEntry.fromSnapshot(
      id: id ?? timetableEntryId(providerId, snapshot.term.id),
      snapshot: snapshot,
      name: name,
    );
    return TimetableCacheData(
      providerId: providerId,
      terms: terms,
      timetables: <TimetableEntry>[entry],
      activeTimetableId: entry.id,
    );
  }

  final String providerId;
  final List<Term> terms;
  final List<TimetableEntry> timetables;
  final String? activeTimetableId;

  TimetableEntry? get activeTimetable {
    final id = activeTimetableId;
    if (id != null) {
      for (final entry in timetables) {
        if (entry.id == id) {
          return entry;
        }
      }
    }
    return timetables.isEmpty ? null : timetables.first;
  }

  TimetableSnapshot? get snapshot => activeTimetable?.snapshot;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'terms': <Map<String, dynamic>>[for (final term in terms) term.toJson()],
    'timetables': <Map<String, dynamic>>[
      for (final entry in timetables) entry.toJson(),
    ],
    'activeTimetableId': activeTimetableId,
  };

  factory TimetableCacheData.fromJson(
    Map<String, dynamic> json, {
    required String providerId,
  }) {
    final rawTerms = json['terms'];
    final rawTimetables = json['timetables'];
    final entries = <TimetableEntry>[];
    if (rawTimetables is List) {
      for (final item in rawTimetables) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final entry = TimetableEntry.tryFromJson(item, providerId: providerId);
        if (entry != null) {
          entries.add(entry);
        }
      }
    }

    // v2 stored one active snapshot per provider. Convert it in memory so the
    // first read after upgrade keeps working without a forced network sync.
    if (entries.isEmpty) {
      final rawSnapshot = json['snapshot'];
      if (rawSnapshot is Map<String, dynamic>) {
        final snapshot = TimetableSnapshot.fromJson(rawSnapshot);
        entries.add(
          TimetableEntry.fromSnapshot(
            id: timetableEntryId(providerId, snapshot.term.id),
            snapshot: snapshot,
          ),
        );
      }
    }

    return TimetableCacheData(
      providerId: providerId,
      terms: rawTerms is List
          ? <Term>[
              for (final item in rawTerms)
                if (item is Map<String, dynamic>) Term.fromJson(item),
            ]
          : const <Term>[],
      timetables: entries,
      activeTimetableId: json['activeTimetableId'] as String?,
    );
  }
}

class TimetableCache {
  const TimetableCache(this._store);

  final KeyValueStore _store;

  TimetableCacheData? readActive() {
    final document = _readDocument();
    if (document != null) {
      final activeId = document['activeProviderId'] as String?;
      if (activeId != null && activeId.isNotEmpty) {
        final data = _readProvider(document, activeId);
        if (data != null) {
          return data;
        }
      }
      final providers = document['providers'];
      if (providers is Map) {
        for (final entry in providers.entries) {
          if (entry.key is String) {
            final data = _readProvider(document, entry.key as String);
            if (data != null) {
              return data;
            }
          }
        }
      }
    }
    return _readLegacyV1();
  }

  TimetableCacheData? readFor(String providerId) {
    final document = _readDocument();
    if (document != null) {
      final data = _readProvider(document, providerId);
      if (data != null) {
        return data;
      }
    }
    if (providerId == _legacyProviderId) {
      return _readLegacyV1();
    }
    return null;
  }

  Future<void> save(TimetableCacheData data) async {
    final document = _readDocument() ?? <String, dynamic>{};
    final rawProviders = document['providers'];
    final providers = rawProviders is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawProviders)
        : <String, dynamic>{};
    providers[data.providerId] = data.toJson();
    document['activeProviderId'] = data.providerId;
    document['providers'] = providers;
    await _store.setString(_cacheKey, jsonEncode(document));
    await _store.remove(_legacyCacheKey);
    await _store.remove(_legacyV1CacheKey);
  }

  TimetableCacheData? _readProvider(
    Map<String, dynamic> document,
    String providerId,
  ) {
    final providers = document['providers'];
    if (providers is! Map) {
      return null;
    }
    final raw = providers[providerId];
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    return TimetableCacheData.fromJson(raw, providerId: providerId);
  }

  TimetableCacheData? _readLegacyV1() {
    final raw = _store.getString(_legacyV1CacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = _decode(raw);
    if (decoded == null) {
      return null;
    }
    return TimetableCacheData.fromJson(decoded, providerId: _legacyProviderId);
  }

  /// Reads v3 first, then the v2 provider document. Legacy data is not rewritten
  /// until the next save; reads remain side-effect free.
  Map<String, dynamic>? _readDocument() {
    for (final key in <String>[_cacheKey, _legacyCacheKey]) {
      final raw = _store.getString(key);
      if (raw == null || raw.isEmpty) {
        continue;
      }
      final decoded = _decode(raw);
      if (decoded != null) {
        return decoded;
      }
    }
    return null;
  }

  Map<String, dynamic>? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
