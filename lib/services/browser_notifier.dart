import 'package:flutter/foundation.dart';

import 'browser_notifier_stub.dart' if (dart.library.html) 'browser_notifier_web.dart' as impl;

/// 브라우저 Notification API를 감싼 인터페이스. 웹이 아닌 빌드에서는
/// [isSupported]가 false인 no-op 구현으로 대체된다. 나중에 모바일 네이티브
/// 알림(`flutter_local_notifications`)으로 갈아끼울 때 이 인터페이스만
/// 새로 구현하면 되도록 스케줄러/상태 쪽은 이 타입에만 의존한다.
abstract class BrowserNotifier {
  factory BrowserNotifier() = impl.BrowserNotifierImpl;

  /// 현재 플랫폼(웹 브라우저)에서 알림 기능을 쓸 수 있는지.
  bool get isSupported;

  /// 알림 권한을 요청한다. 사용자가 허용하면 true.
  Future<bool> requestPermission();

  /// 알림을 표시한다. 클릭하면 [onClick]이 호출된다.
  void show({required String title, required String body, required VoidCallback onClick});
}
