import 'dart:convert';

import '../../../core/storage/storage.dart';
import '../domain/account_session.dart';

const _sessionKey = 'account.session.v2';
const _legacySessionKey = 'account.session.v1';

class SessionStore {
  const SessionStore(this._store);

  final KeyValueStore _store;

  AccountSession? read() {
    return _read(_sessionKey) ?? _read(_legacySessionKey);
  }

  AccountSession? _read(String key) {
    final raw = _store.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return AccountSession.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(AccountSession session) async {
    await _store.setString(_sessionKey, jsonEncode(session.toJson()));
    await _store.remove(_legacySessionKey);
  }

  Future<void> clear() async {
    await _store.remove(_sessionKey);
    await _store.remove(_legacySessionKey);
  }
}
