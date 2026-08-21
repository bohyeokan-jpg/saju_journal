import 'package:flutter/material.dart';

/// 앱 내부에서 "오늘" 탭으로 이동해야 함을 알리는 신호. 알림을 클릭했을 때
/// 처럼, 위젯 트리 바깥(스케줄러)에서 탭 전환을 요청할 때 쓴다.
class AppNavigationState extends ChangeNotifier {
  /// 값이 바뀔 때마다(증가할 때마다) "오늘" 탭으로 이동해야 함을 뜻한다.
  /// 목적지가 항상 같은 탭(오늘)이라 값 자체는 의미가 없고, 변화만 본다.
  int tabRequest = 0;

  void goToToday() {
    tabRequest++;
    notifyListeners();
  }
}
