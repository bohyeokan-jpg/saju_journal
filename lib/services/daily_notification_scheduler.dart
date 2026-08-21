import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_navigation_state.dart';
import '../models/notification_settings_state.dart';
import '../utils/date_key.dart';
import 'browser_notifier.dart';

/// 설정된 시각에 브라우저 알림을 띄운다. 탭이 열려 있는 동안만 동작하는
/// 반쪽짜리 스케줄러 — 진짜 백그라운드 푸시가 아니다.
class DailyNotificationScheduler {
  final NotificationSettingsState settings;
  final BrowserNotifier notifier;
  final AppNavigationState navigation;

  /// 현재 시각을 얻는 함수. 테스트에서 시각을 주입할 수 있게 한다
  /// (today_screen.dart의 시계 주입 패턴과 동일).
  final DateTime Function() now;

  DailyNotificationScheduler(
    this.settings,
    this.notifier,
    this.navigation, {
    this.now = DateTime.now,
  });

  Timer? _timer;
  DateTime? _lastFiredOn;

  /// 순수 함수 — 목표 시각(target)과 현재 시각(now)이 같은 시:분이고, 오늘
  /// 아직 발송한 적 없으면(lastFiredOn이 오늘이 아니면) true를 반환한다.
  static bool shouldFire(TimeOfDay target, DateTime now, DateTime? lastFiredOn) {
    final matchesTime = now.hour == target.hour && now.minute == target.minute;
    if (!matchesTime) return false;
    if (lastFiredOn != null && isSameDate(lastFiredOn, now)) return false;
    return true;
  }

  void start() {
    settings.addListener(_onSettingsChanged);
    _onSettingsChanged();
  }

  void _onSettingsChanged() {
    if (settings.enabled) {
      _timer ??= Timer.periodic(const Duration(seconds: 30), _tick);
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _tick(Timer timer) {
    if (!settings.enabled) return;
    final current = now();
    final target = TimeOfDay(hour: settings.hour, minute: settings.minute);
    if (shouldFire(target, current, _lastFiredOn)) {
      _lastFiredOn = current;
      notifier.show(
        title: '오늘의 운세가 왔어요',
        body: '지금 오늘의 성찰을 기록해보세요',
        onClick: navigation.goToToday,
      );
    }
  }
}
