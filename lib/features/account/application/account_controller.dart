import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/http_types.dart';
import '../data/auth_repository.dart';
import '../data/session_store.dart';
import '../domain/account_session.dart';

class AccountController extends ChangeNotifier {
  AccountController({
    required this.sessionStore,
    required this.authRepository,
  }) {
    _restore();
  }

  final SessionStore sessionStore;
  final AuthRepository authRepository;

  AccountSession? _session;
  bool _busy = false;
  String? _error;

  AccountSession? get session => _session;
  bool get busy => _busy;
  String? get error => _error;
  bool get isSignedIn => _session != null;

  void _restore() {
    try {
      _session = sessionStore.read();
    } catch (_) {
      _session = null;
    }
    notifyListeners();
  }

  Future<bool> signIn({
    required String providerId,
    required String username,
    required String password,
  }) async {
    if (_busy) {
      return false;
    }
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final session = await authRepository.login(
        providerId: providerId,
        username: username,
        password: password,
      );
      await sessionStore.save(session);
      _session = session;
      _busy = false;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _error = error.message;
    } on HttpTransportException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = '登录失败，请稍后重试';
    }
    _busy = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    _session = null;
    _error = null;
    notifyListeners();
    await sessionStore.clear();
  }

  void expireSession([String message = '登录状态已失效，请重新登录']) {
    if (_session == null) {
      return;
    }
    _session = null;
    _error = message;
    sessionStore.clear();
    notifyListeners();
  }

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }
}
