// dart:html은 조건부 import(browser_notifier.dart)로 웹 빌드에서만 로드되는
// 이 파일에만 격리돼 있다 — 다른 코드는 전부 BrowserNotifier 인터페이스만
// 본다. package:web/dart:js_interop 전환은 스코프 밖이라 보류한다.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import 'browser_notifier.dart';

/// `dart:html`의 브라우저 Notification API를 감싼 웹 전용 구현.
class BrowserNotifierImpl implements BrowserNotifier {
  @override
  bool get isSupported => html.Notification.supported;

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }

  @override
  void show({required String title, required String body, required VoidCallback onClick}) {
    if (!isSupported) return;
    if (html.Notification.permission != 'granted') return;
    final notification = html.Notification(title, body: body);
    notification.onClick.listen((_) {
      // 대부분의 브라우저는 알림을 클릭하면 알림을 띄운 탭을 자동으로
      // 포그라운드로 가져온다. dart:html의 Window에는 focus()가 없어
      // (WindowClient.focus()만 있음, 서비스워커 전용) 별도 호출은 하지 않는다.
      onClick();
    });
  }
}
