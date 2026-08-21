import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saju_journal/main.dart';
import 'package:saju_journal/models/app_navigation_state.dart';
import 'package:saju_journal/models/app_theme_state.dart';
import 'package:saju_journal/models/journal_state.dart';
import 'package:saju_journal/models/notification_settings_state.dart';
import 'package:saju_journal/models/profile_state.dart';
import 'package:saju_journal/screens/home_shell.dart';
import 'package:saju_journal/screens/settings_screen.dart';
import 'package:saju_journal/services/journal_store.dart';
import 'package:saju_journal/services/notification_settings_store.dart';
import 'package:saju_journal/services/profile_store.dart';
import 'package:saju_journal/services/theme_mode_store.dart';

/// 온보딩 → 프로필 생성(시간 모름) → 오늘 기록 저장 → 히스토리 반영 →
/// 재시작해도 프로필이 유지되는지까지 이어지는 통합 플로우.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('시간 모름으로 온보딩 → 홈으로 전환 → 오늘 기록 저장 → 히스토리 반영', (tester) async {
    // 화면을 넉넉하게 키워서 오늘 화면의 메모 입력에 포커스가 갈 때
    // ListView가 스크롤되며 저장 버튼이 뷰포트 밖으로 밀려나 언마운트되는
    // 것을 방지한다.
    await tester.binding.setSurfaceSize(const Size(414, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final profileState = ProfileState(ProfileStore());
    await profileState.load();
    final journalState = JournalState(JournalStore());
    await journalState.load();
    final themeState = AppThemeState(ThemeModeStore());
    await themeState.load();
    final notifState = NotificationSettingsState(NotificationSettingsStore());
    await notifState.load();
    final navigationState = AppNavigationState();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileState),
          ChangeNotifierProvider.value(value: journalState),
          ChangeNotifierProvider.value(value: themeState),
          ChangeNotifierProvider.value(value: notifState),
          ChangeNotifierProvider.value(value: navigationState),
        ],
        child: const SajuJournalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('생년월일시 입력'), findsOneWidget);

    // "시간 모름" 체크 후 제출 — 크래시 없이 프로필이 만들어져야 한다.
    await tester.tap(find.text('태어난 시간을 몰라요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('사주 계산하기'));
    await tester.pumpAndSettle();

    // 프로필이 생기면 루트가 다시 빌드되며 HomeShell(하단 탭)로 전환된다.
    expect(find.byType(HomeShell), findsOneWidget);
    expect(profileState.hasProfile, isTrue);
    expect(profileState.profile!.timeUnknown, isTrue);
    expect(profileState.profile!.time, isNull);

    // 오늘 화면에서 메모를 남기고 저장.
    await tester.enterText(find.byType(TextField), '테스트 메모');
    await tester.pumpAndSettle();
    await tester.tap(find.text('오늘 기록 저장'));
    await tester.pumpAndSettle();

    // 기록 탭으로 이동하면 방금 저장한 메모가 즉시 보여야 한다.
    await tester.tap(find.widgetWithText(NavigationDestination, '기록'));
    await tester.pumpAndSettle();
    expect(find.text('테스트 메모'), findsOneWidget);
    expect(journalState.entries.length, 1);

    // 나머지 탭(사주/설정)도 좁은 화면에서 크래시·오버플로우 없이 렌더링되는지 확인.
    await tester.tap(find.widgetWithText(NavigationDestination, '사주'));
    await tester.pumpAndSettle();
    expect(find.text('만세력'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, '설정'));
    await tester.pumpAndSettle();
    expect(find.text('테마'), findsOneWidget);
  });

  testWidgets('앱을 재시작해도(새 상태 객체로 다시 로드) 프로필이 유지된다', (tester) async {
    final firstProfileState = ProfileState(ProfileStore());
    await firstProfileState.load();
    await firstProfileState.calculateAndSave(
      birthDateTime: DateTime(1990, 6, 15, 14, 30),
      isLunar: false,
      timeUnknown: false,
      birthCityName: '서울',
      birthLongitude: 126.9780,
    );

    // "재시작"을 새 ProfileStore/ProfileState 인스턴스로 흉내낸다 — 메모리
    // 상태가 아니라 shared_preferences에 실제로 저장됐는지 검증하는 게 핵심.
    final restartedProfileState = ProfileState(ProfileStore());
    await restartedProfileState.load();

    expect(restartedProfileState.hasProfile, isTrue);
    expect(restartedProfileState.profile!.birthCityName, '서울');
    expect(restartedProfileState.profile!.day.label, '신해');
  });

  testWidgets(
      '설정 화면에서 "프로필 재입력"으로 들어가면 기존 값이 폼에 채워지고, 저장하면 설정 화면으로 돌아오며 성공 스낵바가 뜬다',
      (tester) async {
    final profileState = ProfileState(ProfileStore());
    await profileState.load();
    await profileState.calculateAndSave(
      birthDateTime: DateTime(1990, 6, 15, 14, 30),
      isLunar: false,
      timeUnknown: false,
      birthCityName: '부산',
      birthLongitude: 129.0756,
    );
    final journalState = JournalState(JournalStore());
    await journalState.load();
    final themeState = AppThemeState(ThemeModeStore());
    await themeState.load();
    final notifState = NotificationSettingsState(NotificationSettingsStore());
    await notifState.load();
    final navigationState = AppNavigationState();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileState),
          ChangeNotifierProvider.value(value: journalState),
          ChangeNotifierProvider.value(value: themeState),
          ChangeNotifierProvider.value(value: notifState),
          ChangeNotifierProvider.value(value: navigationState),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('프로필 재입력'));
    await tester.pumpAndSettle();

    expect(find.text('생년월일시 입력'), findsOneWidget);
    // 이전에 저장했던 원본 입력값(양력, 1990/6/15, 부산)이 그대로 채워져 있어야 한다.
    expect(find.text('부산'), findsOneWidget);

    await tester.tap(find.text('사주 계산하기'));
    await tester.pumpAndSettle();

    // 저장 후 설정 화면으로 돌아오고 성공 스낵바가 보여야 한다 — 온보딩 폼에
    // 그대로 머무르며 저장됐는지 알 수 없던 기존 버그의 회귀 테스트.
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('프로필을 새로 저장했어요.'), findsOneWidget);
    expect(profileState.profile!.birthCityName, '부산');
  });
}
