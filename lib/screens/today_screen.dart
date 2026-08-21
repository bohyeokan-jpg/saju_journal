import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/daily_prompts.dart';
import '../models/journal_state.dart';
import '../models/profile_state.dart';
import '../models/wu_xing.dart';
import '../utils/date_key.dart';

/// 오늘 화면(홈) — 일간 오행 기반 성찰 프롬프트 + 기분/에너지 + 짧은 메모.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key, this.now = DateTime.now});

  /// 현재 시각을 얻는 함수. [DateTime.now]를 화면 곳곳에서 직접 호출하는
  /// 대신 이 함수를 거치게 해서, 테스트에서 자정 전/후 시각을 주입할 수
  /// 있게 한다.
  final DateTime Function() now;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  late DateTime _today = widget.now();
  int _mood = 3;
  int _energy = 3;
  final _memoController = TextEditingController();
  DateTime? _loadedForDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _memoController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱을 종료하지 않고 자정을 넘긴 채 백그라운드에 있다가 돌아왔을 때
    // 화면에 "오늘"로 표시되는 날짜를 갱신한다. 실시간 타이머는 두지 않는다.
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _today = widget.now());
    }
  }

  /// 표시 중인 날짜가 실제 오늘과 다르면(자정이 지났으면) 갱신한다. build()
  /// 도중 직접 대입하므로 setState는 필요 없다.
  void _syncToday() {
    final now = widget.now();
    if (!isSameDate(now, _today)) {
      _today = now;
    }
  }

  void _loadExistingEntry(JournalState journalState) {
    if (_loadedForDate != null && isSameDate(_loadedForDate!, _today)) return;
    _loadedForDate = _today;
    final existing = journalState.entryForDate(_today);
    _mood = existing?.mood ?? 3;
    _energy = existing?.energy ?? 3;
    _memoController.text = existing?.memo ?? '';
  }

  Future<void> _save(String prompt, WuXing element) async {
    // 화면이 만들어진 뒤 자정을 넘겼을 수 있으니, 저장 시점에 시각을 다시
    // 읽어서 그 날짜로 저장한다(화면 생성 시점의 _today를 그대로 쓰지 않는다).
    final now = widget.now();
    await context.read<JournalState>().addOrUpdateEntry(
          date: now,
          promptElement: element,
          prompt: prompt,
          mood: _mood,
          energy: _energy,
          memo: _memoController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _today = now);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('오늘의 기록을 저장했어요')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileState>().profile;
    final journalState = context.watch<JournalState>();
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('먼저 사주 프로필을 만들어주세요')));
    }
    _syncToday();
    _loadExistingEntry(journalState);

    final element = profile.dayMasterElement;
    final prompt = promptForDate(element, _today);
    final dateLabel = formatYmd(_today);

    return Scaffold(
      appBar: AppBar(title: const Text('오늘')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(dateLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            '오늘, ${element.label}(${element.keyword})의 기운으로 묻습니다',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(prompt, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
          const SizedBox(height: 24),
          Text('오늘의 기분', style: Theme.of(context).textTheme.titleSmall),
          _FiveStepSlider(value: _mood, onChanged: (v) => setState(() => _mood = v)),
          const SizedBox(height: 16),
          Text('오늘의 에너지', style: Theme.of(context).textTheme.titleSmall),
          _FiveStepSlider(value: _energy, onChanged: (v) => setState(() => _energy = v)),
          const SizedBox(height: 16),
          TextField(
            controller: _memoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '짧은 메모',
              hintText: '오늘 이 기운을 어떻게 느꼈나요?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => _save(prompt, element),
            child: const Text('오늘 기록 저장'),
          ),
        ],
      ),
    );
  }
}

class _FiveStepSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _FiveStepSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: i == value
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(
                    '$i',
                    style: TextStyle(
                      color: i == value
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
