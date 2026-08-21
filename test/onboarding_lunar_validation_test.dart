import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saju_journal/models/profile_state.dart';
import 'package:saju_journal/screens/onboarding_screen.dart';
import 'package:saju_journal/services/profile_store.dart';

/// 음력 선택 시 실제로 존재하지 않는 날짜(예: 29일짜리 달의 30일, 윤달이
/// 아닌 달의 윤달 체크)를 고를 수 없어야 한다는 회귀 테스트.
///
/// `DropdownButtonFormField`는 열려 있지 않아도 내부에 항상
/// `DropdownButton`을 하나 그리고 있고, 그 위젯의 [DropdownButton.items]로
/// "지금 고를 수 있는 값 목록"을 오버레이를 열지 않고도 그대로 확인할 수
/// 있다 — 메뉴를 실제로 열면 선택된 값 근처만 빌드돼(가상 스크롤) 끝 쪽
/// 항목이 트리에 없을 수 있어 이 방식이 더 안정적이다.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // OnboardingScreen이 initState에서 기존 프로필을 읽으므로(재입력 시
  // 이전 값 프리필), 이 화면을 단독으로 pump할 때도 ProfileState를 함께
  // 제공해야 한다. 이 테스트들은 프로필이 없는 최초 온보딩 상태만 다룬다.
  Future<void> pumpOnboarding(WidgetTester tester) async {
    final profileState = ProfileState(ProfileStore());
    await profileState.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: profileState,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
  }

  Finder dropdownField(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byType(DropdownButtonFormField<int>),
      );

  List<int> dropdownValues(WidgetTester tester, String label) {
    final button = tester.widget<DropdownButton<int>>(
      find.descendant(
        of: dropdownField(label),
        matching: find.byType(DropdownButton<int>),
      ),
    );
    return [for (final item in button.items!) item.value!];
  }

  void selectValue(WidgetTester tester, String label, int value) {
    final button = tester.widget<DropdownButton<int>>(
      find.descendant(
        of: dropdownField(label),
        matching: find.byType(DropdownButton<int>),
      ),
    );
    button.onChanged!(value);
  }

  testWidgets('29일짜리 음력 달에는 일 드롭다운에 30일이 없다', (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('음력'));
    await tester.pumpAndSettle();

    // 기본값 음력 1995년 1월은 29일까지만 있다(윤달 아님).
    expect(dropdownValues(tester, '일'), [for (var d = 1; d <= 29; d++) d]);
  });

  testWidgets('윤달이 아닌 달에서는 "윤달이에요" 체크가 비활성화된다', (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('음력'));
    await tester.pumpAndSettle();

    // 음력 1995년의 윤달은 8월뿐이다 — 기본값인 1월에서는 선택 불가.
    final checkboxTile = find.widgetWithText(CheckboxListTile, '윤달이에요');
    expect(checkboxTile, findsOneWidget);
    expect(tester.widget<CheckboxListTile>(checkboxTile).onChanged, isNull);
    expect(find.text('1995년 음력은 8월만 윤달이에요'), findsOneWidget);
  });

  testWidgets('윤달이 있는 달로 옮기면 체크가 활성화되고, 체크하면 그 달의 실제 일수로 제한된다',
      (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('음력'));
    await tester.pumpAndSettle();

    // 월을 8월로 변경 — 음력 1995년의 실제 윤달.
    selectValue(tester, '월', 8);
    await tester.pumpAndSettle();

    // 평달 8월은 30일까지 있다.
    expect(dropdownValues(tester, '일'), [for (var d = 1; d <= 30; d++) d]);

    // 이제 윤달 체크가 가능해야 한다.
    final checkboxTile = find.widgetWithText(CheckboxListTile, '윤달이에요');
    expect(tester.widget<CheckboxListTile>(checkboxTile).onChanged, isNotNull);

    await tester.tap(checkboxTile);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(checkboxTile).value, isTrue);

    // 윤8월은 29일까지만 있다 — 30일은 더 이상 선택할 수 없다.
    expect(dropdownValues(tester, '일'), [for (var d = 1; d <= 29; d++) d]);
  });
}
