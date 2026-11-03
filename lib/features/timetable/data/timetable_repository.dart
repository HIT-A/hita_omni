import 'package:academic_api/academic_api.dart';

import 'timetable_cache.dart';

class TimetableRepository {
  TimetableRepository({required this.catalog, required this.cache});

  final AcademicProviderCatalog catalog;
  final TimetableCache cache;

  TimetableCacheData? loadActiveCache() => cache.readActive();

  TimetableCacheData? loadCacheFor(String providerId) {
    return cache.readFor(providerId);
  }

  Future<List<Term>> fetchTerms(AccountSession session) {
    return _providerFor(session).fetchTerms(session);
  }

  Future<TimetableSnapshot> fetchSnapshot({
    required AccountSession session,
    required Term term,
  }) {
    return _providerFor(session).fetchSnapshot(session: session, term: term);
  }

  Future<void> save(TimetableCacheData data) => cache.save(data);

  AcademicProvider _providerFor(AccountSession session) {
    final provider = catalog.byId(session.providerId);
    if (provider == null) {
      throw ApiException('未注册的教务 provider: ${session.providerId}');
    }
    if (!provider.info.isAvailable) {
      throw ApiException(provider.info.note);
    }
    return provider;
  }
}
