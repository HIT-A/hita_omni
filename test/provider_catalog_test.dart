import 'package:academic_api/academic_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hita_omni/core/storage/key_value_store.dart';
import 'package:hita_omni/features/timetable/data/timetable_cache.dart';
import 'package:hita_omni/features/timetable/data/timetable_repository.dart';
import 'package:provider_hit/provider_hit.dart';

class _NoopTransport implements HttpTransport {
  @override
  Future<HttpResponseData> send(HttpRequestSpec request) {
    throw HttpTransportException('Unexpected network request in test');
  }
}

void main() {
  test('HIT providers expose stable IDs and auth metadata', () {
    final catalog = AcademicProviderCatalog(
      createHitProviders(transport: _NoopTransport()),
    );

    expect(catalog.ids, <String>['hit.shenzhen', 'hit.harbin', 'hit.weihai']);
    expect(catalog.require('hit.shenzhen').info.supportsPasswordLogin, isTrue);
    expect(
      catalog.require('hit.harbin').info.authMode,
      ProviderAuthMode.webVpn,
    );
    expect(catalog.require('hit.weihai').info.isAvailable, isFalse);
  });

  test('unavailable providers fail before making requests', () async {
    final catalog = AcademicProviderCatalog(
      createHitProviders(transport: _NoopTransport()),
    );
    final provider = catalog.require('hit.harbin');

    await expectLater(
      provider.login(const AuthRequest(fields: <String, String>{})),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          contains('WebVPN'),
        ),
      ),
    );
  });

  test('timetable repository routes by provider ID', () {
    final catalog = AcademicProviderCatalog(
      createHitProviders(transport: _NoopTransport()),
    );
    final repository = TimetableRepository(
      catalog: catalog,
      cache: TimetableCache(MemoryKeyValueStore()),
    );
    final session = AccountSession(
      providerId: 'hit.harbin',
      username: 'test',
      signedInAt: DateTime(2026, 9, 1),
    );
    const term = Term(
      yearCode: '2026-2027',
      termCode: '1',
      name: '2026-2027 秋季学期',
      isCurrent: true,
    );

    expect(() => repository.fetchTerms(session), throwsA(isA<ApiException>()));
    expect(
      () => repository.fetchSnapshot(session: session, term: term),
      throwsA(isA<ApiException>()),
    );
  });

  test('duplicate provider IDs are rejected', () {
    final provider = HitShenzhenProvider(_NoopTransport());

    expect(
      () => AcademicProviderCatalog(<AcademicProvider>[provider, provider]),
      throwsArgumentError,
    );
  });

  test('timetable cache is isolated by provider', () async {
    final store = MemoryKeyValueStore();
    final cache = TimetableCache(store);
    const termA = Term(
      yearCode: '2026-2027',
      termCode: '1',
      name: '2026-2027 秋季学期',
      isCurrent: true,
    );
    const termB = Term(
      yearCode: '2025-2026',
      termCode: '2',
      name: '2025-2026 春季学期',
      isCurrent: false,
    );

    await cache.save(
      TimetableCacheData(providerId: 'hit.shenzhen', terms: <Term>[termA]),
    );
    await cache.save(
      TimetableCacheData(providerId: 'hit.weihai', terms: <Term>[termB]),
    );

    expect(cache.readFor('hit.shenzhen')?.terms.single.id, termA.id);
    expect(cache.readFor('hit.weihai')?.terms.single.id, termB.id);
    expect(cache.readActive()?.providerId, 'hit.weihai');
  });
}
