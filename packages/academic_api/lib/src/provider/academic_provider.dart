import '../models/account_session.dart';
import '../models/term.dart';
import '../models/timetable_snapshot.dart';
import 'provider_info.dart';

/// One independently implemented academic system.
///
/// A provider owns authentication, term discovery, and timetable mapping. The
/// app only consumes [AccountSession] and the canonical [TimetableSnapshot].
abstract interface class AcademicProvider {
  String get id;

  AcademicProviderInfo get info;

  Future<AuthResult> login(AuthRequest request);

  /// Returns the provider's full term list. The host applies the shared
  /// timetable/assessment visibility policy before presenting it.
  Future<List<Term>> fetchTerms(AccountSession session);

  Future<TimetableSnapshot> fetchSnapshot({
    required AccountSession session,
    required Term term,
  });
}
