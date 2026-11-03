import 'package:academic_api/academic_api.dart';

class AuthRepository {
  AuthRepository({required this.catalog, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AcademicProviderCatalog catalog;
  final DateTime Function() _now;

  Future<AccountSession> login({
    required String providerId,
    required String username,
    required String password,
  }) async {
    final provider = catalog.byId(providerId);
    if (provider == null) {
      throw AuthException('未注册的教务 provider: $providerId');
    }
    if (!provider.info.isAvailable) {
      throw AuthException(provider.info.note);
    }
    if (provider.info.authMode != ProviderAuthMode.password) {
      throw AuthException(provider.info.note);
    }
    final result = await provider.login(
      AuthRequest(
        fields: <String, String>{
          'username': username.trim(),
          'password': password,
        },
      ),
    );
    return AccountSession(
      providerId: provider.id,
      username: username.trim(),
      credentials: result.credentials,
      cookies: result.cookies,
      profile: result.profile,
      signedInAt: _now(),
    );
  }
}
