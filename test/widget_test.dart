import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saju_journal/models/profile_state.dart';
import 'package:saju_journal/screens/onboarding_screen.dart';
import 'package:saju_journal/services/profile_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('온보딩 화면이 렌더링된다', (tester) async {
    final profileState = ProfileState(ProfileStore());
    await profileState.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: profileState,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(find.text('생년월일시 입력'), findsOneWidget);
    expect(find.text('사주 계산하기'), findsOneWidget);
  });
}
