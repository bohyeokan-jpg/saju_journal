import 'package:flutter/material.dart';

import 'journal_history_screen.dart';
import 'saju_profile_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

/// 온보딩을 마친 뒤의 메인 화면 — 하단 탭 4개(오늘/사주/기록/설정).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    SajuProfileScreen(),
    JournalHistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), label: '오늘'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: '사주'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: '기록'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: '설정'),
        ],
      ),
    );
  }
}
