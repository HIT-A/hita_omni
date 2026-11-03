import 'package:flutter/material.dart';

import '../storage/storage.dart';

const _themeKey = 'app.themeMode';

class ThemeController extends ChangeNotifier {
  ThemeController(this._store) : _mode = _read(_store);

  final KeyValueStore _store;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    _store.setString(_themeKey, mode.name);
    notifyListeners();
  }

  void cycle() {
    setMode(switch (_mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    });
  }

  static ThemeMode _read(KeyValueStore store) {
    return switch (store.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
