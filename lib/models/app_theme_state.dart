import 'package:flutter/material.dart';

import '../services/theme_mode_store.dart';

class AppThemeState extends ChangeNotifier {
  final ThemeModeStore _store;
  AppThemeState(this._store);

  ThemeMode current = ThemeMode.system;

  Future<void> load() async {
    current = await _store.load();
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (current == mode) return;
    current = mode;
    notifyListeners();
    await _store.save(mode);
  }
}
