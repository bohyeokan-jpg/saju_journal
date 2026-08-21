import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자가 고른 라이트/다크/시스템 모드를 저장한다.
class ThemeModeStore {
  static const _key = 'theme_mode';

  Future<ThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
