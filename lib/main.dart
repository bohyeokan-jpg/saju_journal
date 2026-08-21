import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_theme.dart';
import 'models/app_theme_state.dart';
import 'models/journal_state.dart';
import 'models/profile_state.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/journal_store.dart';
import 'services/profile_store.dart';
import 'services/theme_mode_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final profileState = ProfileState(ProfileStore());
  await profileState.load();

  final journalState = JournalState(JournalStore());
  await journalState.load();

  final themeState = AppThemeState(ThemeModeStore());
  await themeState.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profileState),
        ChangeNotifierProvider.value(value: journalState),
        ChangeNotifierProvider.value(value: themeState),
      ],
      child: const SajuJournalApp(),
    ),
  );
}

class SajuJournalApp extends StatelessWidget {
  const SajuJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppThemeState>().current;
    final hasProfile = context.watch<ProfileState>().hasProfile;

    return MaterialApp(
      title: '사주 자기이해 저널',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      home: hasProfile ? const HomeShell() : const OnboardingScreen(),
    );
  }
}
