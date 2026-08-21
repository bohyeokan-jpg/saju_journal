import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saju_journal/services/daily_notification_scheduler.dart';

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
}
