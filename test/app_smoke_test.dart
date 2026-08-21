import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saju_journal/main.dart';
import 'package:saju_journal/models/app_theme_state.dart';
import 'package:saju_journal/models/journal_state.dart';
import 'package:saju_journal/models/profile_state.dart';
import 'package:saju_journal/services/journal_store.dart';
import 'package:saju_journal/services/profile_store.dart';
import 'package:saju_journal/services/theme_mode_store.dart';

/// 프로필이 없을 때는 온보딩이, 라이트/다크 모두 정상 렌더링되는지 확인하는
/// 전체 앱 스모크 테스트.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester tester, {required ThemeMode mode}) async {
    final profileState = ProfileState(ProfileStore());
    await profileState.load();
    final journalState = JournalState(JournalStore());
    await journalState.load();
    final themeState = AppThemeState(ThemeModeStore());
    await themeState.load();
    await themeState.setMode(mode);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileState),
          ChangeNotifierProvider.value(value: journalState),
          ChangeNotifierProvider.value(value: themeState),
        ],
        child: const SajuJournalApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('프로필이 없으면 온보딩 화면이 라이트 테마로 뜬다', (tester) async {
    await pumpApp(tester, mode: ThemeMode.light);
    expect(find.text('생년월일시 입력'), findsOneWidget);
  });

  testWidgets('다크 테마로도 크래시 없이 렌더링된다', (tester) async {
    await pumpApp(tester, mode: ThemeMode.dark);
    expect(find.text('생년월일시 입력'), findsOneWidget);
  });
}
