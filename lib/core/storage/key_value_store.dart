/// A small synchronous-read, asynchronous-write store for app preferences.
///
/// The app keeps the whole document in memory after startup. This is enough
/// for the core (session, dashboard layout, timetable cache) and keeps the
/// initial dependency footprint small. A database-backed implementation can
/// replace it behind this interface without touching feature code.
abstract interface class KeyValueStore {
  String? getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);

  Future<void> flush();
}

/// In-memory implementation used by tests and as a last-resort fallback when
/// the platform store cannot be opened.
final class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> flush() async {}
}
