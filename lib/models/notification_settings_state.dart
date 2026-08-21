import 'package:flutter/material.dart';

import '../services/notification_settings_store.dart';

/// "오늘의 운세 알림" 켜짐 여부와 알림 시각을 들고 있는 상태.
class NotificationSettingsState extends ChangeNotifier {
  final NotificationSettingsStore _store;
  NotificationSettingsState(this._store);

  bool enabled = false;
  int hour = 9;
  int minute = 0;

  Future<void> load() async {
    enabled = await _store.loadEnabled();
    hour = await _store.loadHour();
    minute = await _store.loadMinute();
    notifyListeners();
  }

  Future<void> setTime(TimeOfDay time) async {
    hour = time.hour;
    minute = time.minute;
    notifyListeners();
    await _store.saveTime(hour, minute);
  }

  /// 알림 켜짐/꺼짐을 바꾼다. 권한 요청 등 실패할 수 있는 절차는 호출하는
  /// 쪽(설정 화면)에서 처리하고, 이 함수는 결정된 값을 저장만 한다.
  Future<bool> setEnabled(bool value) async {
    enabled = value;
    notifyListeners();
    await _store.saveEnabled(value);
    return enabled;
  }
}
