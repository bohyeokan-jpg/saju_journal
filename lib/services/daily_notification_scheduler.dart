import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_navigation_state.dart';
import '../models/notification_settings_state.dart';
import '../utils/date_key.dart';
import 'browser_notifier.dart';
import 'notification_settings_store.dart';

/// 설정된 시각에 브라우저 알림을 띄운다. 탭이 열려 있는 동안만 동작하는
/// 반쪽짜리 스케줄러 — 진짜 백그라운드 푸시가 아니다.
class DailyNotificationScheduler {
  final NotificationSettingsState settings;
  final BrowserNotifier notifier;
  final AppNavigationState navigation;
  final NotificationSettingsStore store;

  /// 현재 시각을 얻는 함수. 테스트에서 시각을 주입할 수 있게 한다
  /// (today_screen.dart의 시계 주입 패턴과 동일).
  final DateTime Function() now;

  DailyNotificationScheduler(
    this.settings,
    this.notifier,
    this.navigation,
    this.store, {
    this.now = DateTime.now,
  });

  Timer? _timer;
  DateTime? _lastFiredOn;

  /// 순수 함수 — 목표 시각(target)과 현재 시각(now)이 같은 시:분이고, 오늘
  /// 아직 발송한 적 없으면(lastFiredOn이 오늘이 아니면) true를 반환한다.
  ///
  /// 날짜만 비교하므로 "하루 최대 1회" 원칙이 목표 시각보다 우선한다 — 예를
  /// 들어 09:00에 이미 발송한 뒤 그날 알림 시각을 10:00으로 바꿔도 그날은
  /// 재발송하지 않고 다음날 10:00부터 적용된다. 이는 버그가 아니라 의도된
  /// 동작이다.
  static bool shouldFire(TimeOfDay target, DateTime now, DateTime? lastFiredOn) {
    final matchesTime = now.hour == target.hour && now.minute == target.minute;
    if (!matchesTime) return false;
    if (lastFiredOn != null && isSameDate(lastFiredOn, now)) return false;
    return true;
  }

  /// 마지막 발송 날짜를 shared_preferences에서 불러온 뒤 타이머를 시작한다.
  /// 탭 새로고침/앱 재시작으로 새 인스턴스가 만들어져도 "오늘 이미
  /// 보냈다"는 사실이 유지되도록, 인메모리 필드([_lastFiredOn])만으로는
  /// 부족해서 store에서 복원한다.
  Future<void> start() async {
    _lastFiredOn = await store.loadLastFiredOn();
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

  void _tick(Timer timer) => checkNow();

  /// 지금 발송 조건을 확인하고, 맞으면 알림을 보낸다. 30초 주기 타이머가
  /// 내부적으로 호출하는 로직이지만, 테스트에서 타이머를 기다리지 않고
  /// 바로 호출할 수 있도록 공개해둔다.
  @visibleForTesting
  void checkNow() {
    if (!settings.enabled) return;
    final current = now();
    final target = TimeOfDay(hour: settings.hour, minute: settings.minute);
    if (shouldFire(target, current, _lastFiredOn)) {
      _lastFiredOn = current;
      unawaited(store.saveLastFiredOn(current));
      notifier.show(
        title: '오늘의 운세가 왔어요',
        body: '지금 오늘의 성찰을 기록해보세요',
        onClick: navigation.goToToday,
      );
    }
  }
}
