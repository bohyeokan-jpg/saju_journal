import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_theme_state.dart';
import '../models/journal_state.dart';
import '../models/notification_settings_state.dart';
import '../models/profile_state.dart';
import '../services/browser_notifier.dart';
import '../utils/date_key.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  /// 웹이 아닌 플랫폼에서는 [BrowserNotifier]가 no-op이라 테스트에서
  /// permission 허용/거부 경로를 확인할 수 없다. 그래서 [today_screen.dart]의
  /// 시계 주입 패턴처럼 테스트에서 가짜 구현체를 넣을 수 있게 열어둔다.
  const SettingsScreen({super.key, this.notifier});

  final BrowserNotifier? notifier;

  Future<void> _onToggleNotification(
    BuildContext context,
    bool value,
    NotificationSettingsState notifState,
    BrowserNotifier notifier,
  ) async {
    if (!value) {
      await notifState.setEnabled(false);
      return;
    }
    final granted = await notifier.requestPermission();
    if (!granted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 권한이 거부되어 켤 수 없어요')),
      );
      return;
    }
    await notifState.setEnabled(true);
  }

  Future<void> _changeTime(BuildContext context, NotificationSettingsState notifState) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: notifState.hour, minute: notifState.minute),
    );
    if (picked == null) return;
    await notifState.setTime(picked);
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final profileState = context.read<ProfileState>();
    final journalState = context.read<JournalState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 데이터 삭제'),
        content: const Text('사주 프로필과 저널 기록이 모두 삭제돼요. 되돌릴 수 없어요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirmed != true) return;
    await profileState.clear();
    await journalState.clear();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<AppThemeState>();
    final notifState = context.watch<NotificationSettingsState>();
    final activeNotifier = notifier ?? BrowserNotifier();

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('테마', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('시스템')),
              ButtonSegment(value: ThemeMode.light, label: Text('라이트')),
              ButtonSegment(value: ThemeMode.dark, label: Text('다크')),
            ],
            selected: {themeState.current},
            onSelectionChanged: (s) => themeState.setMode(s.first),
          ),
          const SizedBox(height: 28),
          Text('알림', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (!activeNotifier.isSupported)
            const Text('이 기능은 웹 버전에서만 사용할 수 있어요')
          else ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('오늘의 운세 알림'),
              subtitle: const Text('설정한 시각에 오늘의 성찰을 기록하라고 알려드려요'),
              value: notifState.enabled,
              onChanged: (v) => _onToggleNotification(context, v, notifState, activeNotifier),
            ),
            if (notifState.enabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('알림 시각'),
                subtitle: Text(formatHm(DateTime(0, 1, 1, notifState.hour, notifState.minute))),
                trailing: TextButton(
                  onPressed: () => _changeTime(context, notifState),
                  child: const Text('변경'),
                ),
              ),
          ],
          const SizedBox(height: 28),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('프로필 재입력'),
            subtitle: const Text('생년월일시를 다시 입력해 사주를 새로 계산해요'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('전체 데이터 삭제', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            subtitle: const Text('사주 프로필과 저널 기록을 모두 지워요'),
            onTap: () => _confirmDeleteAll(context),
          ),
        ],
      ),
    );
  }
}
