import 'package:flutter/foundation.dart';

import 'browser_notifier.dart';

/// 웹이 아닌 빌드(안드로이드/iOS/데스크톱)에서 쓰이는 no-op 구현.
class BrowserNotifierImpl implements BrowserNotifier {
  @override
  bool get isSupported => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  void show({required String title, required String body, required VoidCallback onClick}) {}
}
