import 'package:shared_preferences/shared_preferences.dart';

/// "오늘의 운세 알림" 켜짐 여부와 알림 시각을 저장한다.
class NotificationSettingsStore {
  static const _enabledKey = 'notif_enabled';
  static const _hourKey = 'notif_hour';
  static const _minuteKey = 'notif_minute';

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
}
