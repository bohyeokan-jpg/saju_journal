import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saju_journal/models/app_navigation_state.dart';
import 'package:saju_journal/models/notification_settings_state.dart';
import 'package:saju_journal/services/browser_notifier.dart';
import 'package:saju_journal/services/daily_notification_scheduler.dart';
import 'package:saju_journal/services/notification_settings_store.dart';

/// show() 호출 횟수만 세는 가짜 알림기. 실제 발송 여부를 확인하는 용도라
/// settings_notification_toggle_test.dart의 FakeBrowserNotifier처럼 권한
/// 관련 로직은 없다.
class _CountingNotifier implements BrowserNotifier {
  int showCount = 0;

  @override
  bool get isSupported => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  void show({required String title, required String body, required VoidCallback onClick}) {
    showCount++;
  }
}

/// [DailyNotificationScheduler.shouldFire]는 브라우저 API와 완전히 분리된
/// 순수 함수라 위젯/Timer 없이 바로 검증할 수 있다.
void main() {
  const target = TimeOfDay(hour: 9, minute: 0);

  test('목표 시각 직전(08:59)에는 발송하지 않는다', () {
    final now = DateTime(2024, 1, 1, 8, 59);
    expect(DailyNotificationScheduler.shouldFire(target, now, null), isFalse);
  });

  test('목표 시각 직후(09:00, 아직 발송한 적 없음)에는 발송한다', () {
    final now = DateTime(2024, 1, 1, 9, 0);
    expect(DailyNotificationScheduler.shouldFire(target, now, null), isTrue);
  });

  test('같은 분 안에 다시 호출되면(이미 오늘 발송함) 중복 발송하지 않는다', () {
    final firstFire = DateTime(2024, 1, 1, 9, 0);
    final secondCheck = DateTime(2024, 1, 1, 9, 0, 30);
    expect(DailyNotificationScheduler.shouldFire(target, secondCheck, firstFire), isFalse);
  });

  test('목표 시각을 지나(09:01) 확인해도, 오늘 이미 발송했다면 발송하지 않는다', () {
    final firstFire = DateTime(2024, 1, 1, 9, 0);
    final later = DateTime(2024, 1, 1, 9, 1);
    expect(DailyNotificationScheduler.shouldFire(target, later, firstFire), isFalse);
  });

  test('날짜가 바뀌면 같은 시각이어도 다시 발송한다', () {
    final firstFire = DateTime(2024, 1, 1, 9, 0);
    final nextDay = DateTime(2024, 1, 2, 9, 0);
    expect(DailyNotificationScheduler.shouldFire(target, nextDay, firstFire), isTrue);
  });

  group('마지막 발송 날짜 영속화 (재시작 후 중복 발송 방지)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('발송 직후 스케줄러를 재생성해도(=탭 새로고침/앱 재시작 흉내) 같은 날 재발송하지 않는다', () async {
      final store = NotificationSettingsStore();
      final settings = NotificationSettingsState(store);
      await settings.load();
      await settings.setEnabled(true);

      final current = DateTime(2024, 1, 1, 9, 0);
      final navigation = AppNavigationState();

      // 1. 첫 스케줄러 인스턴스 — 09:00에 발송한다.
      final firstNotifier = _CountingNotifier();
      final firstScheduler = DailyNotificationScheduler(
        settings,
        firstNotifier,
        navigation,
        store,
        now: () => current,
      );
      await firstScheduler.start();
      firstScheduler.checkNow();
      expect(firstNotifier.showCount, 1);

      // shared_preferences 저장(비동기, fire-and-forget)이 끝날 때까지 기다린다.
      await pumpEventQueue();

      // 2. 같은 날 안에 새 스케줄러 인스턴스가 만들어진다(탭 새로고침/앱 재시작).
      //    메모리 필드는 초기화됐지만, store에서 마지막 발송 날짜를 복원해야 한다.
      final secondNotifier = _CountingNotifier();
      final secondScheduler = DailyNotificationScheduler(
        settings,
        secondNotifier,
        navigation,
        store,
        now: () => current,
      );
      await secondScheduler.start();
      secondScheduler.checkNow();

      expect(secondNotifier.showCount, 0);

      // 두 스케줄러 모두 settings를 구독해 30초 주기 Timer를 갖고 있으니,
      // 테스트가 "pending timer" 오류 없이 끝나도록 꺼서 정리한다.
      await settings.setEnabled(false);
    });
  });
}
