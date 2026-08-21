import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saju_journal/models/app_theme_state.dart';
import 'package:saju_journal/models/notification_settings_state.dart';
import 'package:saju_journal/screens/settings_screen.dart';
import 'package:saju_journal/services/browser_notifier.dart';
import 'package:saju_journal/services/notification_settings_store.dart';
import 'package:saju_journal/services/theme_mode_store.dart';

/// 웹이 아닌 테스트 환경에서는 진짜 [BrowserNotifier]가 항상 no-op이라,
/// 권한 허용/거부 두 경로를 확인하려면 가짜 구현체를 주입해야 한다.
class FakeBrowserNotifier implements BrowserNotifier {
  FakeBrowserNotifier({required this.permissionGranted});

  final bool permissionGranted;
  bool requestPermissionCalled = false;

  @override
  bool get isSupported => true;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalled = true;
    return permissionGranted;
  }

  @override
  void show({required String title, required String body, required VoidCallback onClick}) {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSettings(WidgetTester tester, {required BrowserNotifier notifier}) async {
    final themeState = AppThemeState(ThemeModeStore());
    await themeState.load();
    final notifState = NotificationSettingsState(NotificationSettingsStore());
    await notifState.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeState),
          ChangeNotifierProvider.value(value: notifState),
        ],
        child: MaterialApp(home: SettingsScreen(notifier: notifier)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('권한을 허용하면 알림이 켜지고 저장된다', (tester) async {
    final fakeNotifier = FakeBrowserNotifier(permissionGranted: true);
    await pumpSettings(tester, notifier: fakeNotifier);

    expect(find.text('오늘의 운세 알림'), findsOneWidget);
    final switchFinder = find.byType(Switch);
    expect(tester.widget<Switch>(switchFinder).value, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(fakeNotifier.requestPermissionCalled, isTrue);
    expect(tester.widget<Switch>(switchFinder).value, isTrue);
    // 알림이 켜졌으니 시각 표시/변경 UI도 나타나야 한다.
    expect(find.text('알림 시각'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('notif_enabled'), isTrue);
  });

  testWidgets('권한을 거부하면 알림이 켜지지 않고 안내 스낵바가 뜬다', (tester) async {
    final fakeNotifier = FakeBrowserNotifier(permissionGranted: false);
    await pumpSettings(tester, notifier: fakeNotifier);

    final switchFinder = find.byType(Switch);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(fakeNotifier.requestPermissionCalled, isTrue);
    expect(tester.widget<Switch>(switchFinder).value, isFalse);
    expect(find.text('알림 권한이 거부되어 켤 수 없어요'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('notif_enabled'), isNot(true));
  });

  testWidgets('웹이 아닌 빌드(isSupported == false)에서는 안내 문구만 뜨고 스위치는 없다', (tester) async {
    // notifier를 주입하지 않으면 SettingsScreen이 실제 BrowserNotifier()를
    // 쓴다 — flutter test 환경(비웹)에서는 항상 isSupported == false인
    // no-op 구현(browser_notifier_stub.dart)으로 해석된다.
    await pumpSettings(tester, notifier: BrowserNotifier());

    expect(find.text('이 기능은 웹 버전에서만 사용할 수 있어요'), findsOneWidget);
    expect(find.text('오늘의 운세 알림'), findsNothing);
    expect(find.byType(Switch), findsNothing);
  });
}
