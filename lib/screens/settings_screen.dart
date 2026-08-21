import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_theme_state.dart';
import '../models/journal_state.dart';
import '../models/profile_state.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
