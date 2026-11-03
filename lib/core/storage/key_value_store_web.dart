import 'package:web/web.dart' as web;

import 'key_value_store.dart';

Future<KeyValueStore> createKeyValueStore() async {
  try {
    web.window.localStorage.length;
    return _LocalStorageStore();
  } catch (_) {
    return MemoryKeyValueStore();
  }
}

final class _LocalStorageStore implements KeyValueStore {
  web.Storage get _storage => web.window.localStorage;

  @override
  String? getString(String key) => _storage.getItem(key);

  @override
  Future<void> setString(String key, String value) async {
    _storage.setItem(key, value);
  }

  @override
  Future<void> remove(String key) async {
    _storage.removeItem(key);
  }

  @override
  Future<void> flush() async {}
}
