import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saju_journal/models/journal_state.dart';
import 'package:saju_journal/models/profile_state.dart';
import 'package:saju_journal/screens/today_screen.dart';
import 'package:saju_journal/services/journal_store.dart';
import 'package:saju_journal/services/profile_store.dart';

/// 자정 롤오버 회귀 테스트 — 화면을 새로 만들지 않고 앱이 계속 떠 있는 채로
/// 자정을 넘긴 상황을 흉내낸다. [TodayScreen.now]에 주입한 시계를 바꿔가며
/// 저장이 매번 실제 "지금" 날짜로 기록되는지 확인한다.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('화면을 새로 만들지 않고 자정을 넘겨도, 저장 시점의 날짜로 각각 저장된다',
      (tester) async {
    final profileState = ProfileState(ProfileStore());
    await profileState.load();
    await profileState.calculateAndSave(
      birthDateTime: DateTime(1990, 6, 15, 14, 30),
      isLunar: false,
      timeUnknown: false,
      birthCityName: '서울',
      birthLongitude: 126.9780,
    );
    final journalState = JournalState(JournalStore());
    await journalState.load();

    // 자정 직전으로 시작 — TodayScreen이 생성되는 시점의 시각이다.
    DateTime current = DateTime(2024, 1, 1, 23, 59);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileState),
          ChangeNotifierProvider.value(value: journalState),
        ],
        child: MaterialApp(home: TodayScreen(now: () => current)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '자정 전 메모');
    await tester.pumpAndSettle();
    await tester.tap(find.text('오늘 기록 저장'));
    await tester.pumpAndSettle();

    expect(journalState.entries.length, 1);
    expect(journalState.entries.single.date, DateTime(2024, 1, 1));
    expect(journalState.entries.single.memo, '자정 전 메모');

    // 앱을 종료하지 않고 자정을 넘긴다 — 화면(State)은 그대로다.
    current = DateTime(2024, 1, 2, 0, 5);

    await tester.enterText(find.byType(TextField), '자정 후 메모');
    await tester.pumpAndSettle();
    await tester.tap(find.text('오늘 기록 저장'));
    await tester.pumpAndSettle();

    // 어제 날짜로 덮어써지지 않고, 새 날짜로 별도 저장돼야 한다.
    expect(journalState.entries.length, 2);
    final byDate = {for (final e in journalState.entries) e.date: e.memo};
    expect(byDate[DateTime(2024, 1, 1)], '자정 전 메모');
    expect(byDate[DateTime(2024, 1, 2)], '자정 후 메모');
  });

  testWidgets('앱이 백그라운드에 있다가 자정을 넘겨 돌아오면 화면의 "오늘" 표시도 갱신된다',
      (tester) async {
    final profileState = ProfileState(ProfileStore());
    await profileState.load();
    await profileState.calculateAndSave(
      birthDateTime: DateTime(1990, 6, 15, 14, 30),
      isLunar: false,
      timeUnknown: false,
      birthCityName: '서울',
      birthLongitude: 126.9780,
    );
    final journalState = JournalState(JournalStore());
    await journalState.load();

    DateTime current = DateTime(2024, 1, 1, 23, 59);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileState),
          ChangeNotifierProvider.value(value: journalState),
        ],
        child: MaterialApp(home: TodayScreen(now: () => current)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2024.01.01'), findsOneWidget);

    current = DateTime(2024, 1, 2, 0, 5);
    // 백그라운드로 갔다가(resumed → inactive → hidden → paused) 다시 돌아오는
    // (paused → hidden → inactive → resumed) 정상적인 전이 순서를 그대로 밟는다.
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();

    expect(find.text('2024.01.02'), findsOneWidget);
  });
}
