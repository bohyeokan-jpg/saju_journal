import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saju_profile.dart';

/// 사주 프로필(1인용, 단일 레코드)을 shared_preferences에 JSON으로 저장한다.
/// medication_store.dart와 동일한 패턴.
class ProfileStore {
  static const _key = 'saju_profile';

  Future<SajuProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return SajuProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(SajuProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
