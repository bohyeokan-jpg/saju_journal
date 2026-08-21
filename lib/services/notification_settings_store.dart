import 'package:shared_preferences/shared_preferences.dart';

import '../utils/date_key.dart';

/// "오늘의 운세 알림" 켜짐 여부와 알림 시각을 저장한다.
class NotificationSettingsStore {
  static const _enabledKey = 'notif_enabled';
  static const _hourKey = 'notif_hour';
  static const _minuteKey = 'notif_minute';
  static const _lastFiredOnKey = 'notif_last_fired_on';

  Future<bool> loadEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<void> saveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  Future<int> loadHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_hourKey) ?? 9;
  }

  Future<int> loadMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_minuteKey) ?? 0;
  }

  Future<void> saveTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);
  }

  /// 알림을 마지막으로 발송한 날짜를 불러온다. 앱이 재시작돼도(탭 새로고침
  /// 포함) 스케줄러가 "오늘 이미 보냈다"를 기억할 수 있도록 인메모리
  /// 필드가 아니라 여기 저장해둔다.
  Future<DateTime?> loadLastFiredOn() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastFiredOnKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> saveLastFiredOn(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFiredOnKey, dateOnly(date).toIso8601String());
  }
}
