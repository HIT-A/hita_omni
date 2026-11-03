import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'key_value_store.dart';

const _storeFileName = 'hita_omni_store.json';

Future<KeyValueStore> createKeyValueStore() async {
  try {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}${Platform.pathSeparator}$_storeFileName',
    );
    final store = _JsonFileStore(file);
    await store.load();
    return store;
  } catch (_) {
    return MemoryKeyValueStore();
  }
}

final class _JsonFileStore implements KeyValueStore {
  _JsonFileStore(this._file);

  final File _file;
  final Map<String, String> _values = <String, String>{};
  Future<void> _pendingWrite = Future<void>.value();

  Future<void> load() async {
    if (!await _file.exists()) {
      return;
    }
    try {
      final decoded = jsonDecode(await _file.readAsString());
      if (decoded is! Map) {
        return;
      }
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (entry.key is String && value is String) {
          _values[entry.key as String] = value;
        }
      }
    } on FormatException {
      // A damaged store must not prevent the app from starting.
    } on FileSystemException {
      // Unreadable storage behaves like an empty store.
    }
  }

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) {
    _values[key] = value;
    return _scheduleWrite();
  }

  @override
  Future<void> remove(String key) {
    _values.remove(key);
    return _scheduleWrite();
  }

  @override
  Future<void> flush() => _pendingWrite;

  Future<void> _scheduleWrite() {
    final document = jsonEncode(<String, String>{..._values});
    _pendingWrite = _pendingWrite.then((_) => _write(document)).catchError((
      Object _,
    ) {
      // Persistence failures are non-fatal; the in-memory state remains
      // usable for the current session.
    });
    return _pendingWrite;
  }

  Future<void> _write(String document) async {
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(document, flush: true);
    try {
      await temporary.rename(_file.path);
    } on FileSystemException {
      // Windows refuses to rename over an existing file.
      if (await _file.exists()) {
        await _file.delete();
      }
      await temporary.rename(_file.path);
    }
  }
}
