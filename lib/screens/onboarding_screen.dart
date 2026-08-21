import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import 'package:provider/provider.dart';

import '../content/birth_cities.dart';
import '../models/profile_state.dart';

/// 생년월일시 입력 화면. 양력/음력 선택, "시간 모름" 옵션, 출생 도시(경도
/// 매핑용) 선택을 받아 [ProfileState.calculateAndSave]를 호출한다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLunar = false;
  bool _isLeapMonth = false;
  bool _timeUnknown = false;

  int _year = 1995;
  int _month = 1;
  int _day = 1;
  int _hour = 12;
  int _minute = 0;
  BirthCity _city = koreanBirthCities.first;

  bool _submitting = false;

  final _nowYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    // 설정 화면의 "프로필 재입력"으로 들어온 경우(이미 프로필이 있는 경우)
    // 이전에 입력했던 원본 값(양력/음력, 연월일시, 시간모름 여부, 출생도시)을
    // 그대로 폼에 채워 넣는다. 최초 온보딩은 프로필이 없으므로 기본값 그대로 둔다.
    final existing = context.read<ProfileState>().profile;
    if (existing != null) {
      _isLunar = existing.isLunar;
      _isLeapMonth = existing.isLeapMonth;
      _timeUnknown = existing.timeUnknown;
      _year = existing.birthDateTime.year;
      _month = existing.birthDateTime.month;
      _day = existing.birthDateTime.day;
      _hour = existing.birthDateTime.hour;
      _minute = existing.birthDateTime.minute;
      _city = koreanBirthCities.firstWhere(
        (c) => c.name == existing.birthCityName,
        orElse: () => koreanBirthCities.first,
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await context.read<ProfileState>().calculateAndSave(
            birthDateTime: DateTime(_year, _month, _day, _hour, _minute),
            isLunar: _isLunar,
            isLeapMonth: _isLunar && _isLeapMonth,
            timeUnknown: _timeUnknown,
            birthCityName: _city.name,
            birthLongitude: _city.longitude,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('입력한 날짜를 사주로 바꿀 수 없어요. 날짜를 다시 확인해주세요.')),
      );
      return;
    }
    if (!mounted) return;
    // 설정 화면에서 "프로필 재입력"으로 들어온 경우(이 화면이 push된 경우)에는
    // 저장 후 이전 화면으로 돌아가고 성공 피드백을 보여준다. 최초 온보딩(루트
    // 화면이라 pop할 곳이 없는 경우)은 지금처럼 프로필 생성 시 루트가 자동으로
    // HomeShell로 다시 빌드되는 라우팅을 그대로 따른다.
    if (Navigator.of(context).canPop()) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('프로필을 새로 저장했어요.')),
      );
      return;
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    // 음력 연도에 실제로 윤달이 있고, 그 윤달이 지금 고른 월과 같을 때만
    // "윤달이에요" 체크를 허용한다 — 존재하지 않는 윤달 조합은 아예 선택
    // 못 하게 막는다.
    final leapMonthOfYear = _isLunar ? LunarYear.fromYear(_year).getLeapMonth() : 0;
    final canBeLeapMonth = _isLunar && leapMonthOfYear == _month;
    if (_isLeapMonth && !canBeLeapMonth) _isLeapMonth = false;

    final daysInMonth = _isLunar
        ? (LunarMonth.fromYm(_year, _isLeapMonth ? -_month : _month)?.getDayCount() ?? 29)
        : DateTime(_year, _month + 1, 0).day;
    if (_day > daysInMonth) _day = daysInMonth;

    return Scaffold(
      appBar: AppBar(title: const Text('생년월일시 입력')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '태어난 시각을 입력하면 사주 네 기둥을 계산해요.\n예측이 아니라 나를 이해하는 도구로 씁니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('양력')),
              ButtonSegment(value: true, label: Text('음력')),
            ],
            selected: {_isLunar},
            onSelectionChanged: (s) => setState(() => _isLunar = s.first),
          ),
          if (_isLunar)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _isLeapMonth,
              title: const Text('윤달이에요'),
              subtitle: canBeLeapMonth
                  ? null
                  : Text(
                      leapMonthOfYear == 0
                          ? '$_year년 음력에는 윤달이 없어요'
                          : '$_year년 음력은 $leapMonthOfYear월만 윤달이에요',
                    ),
              onChanged: canBeLeapMonth
                  ? (v) => setState(() => _isLeapMonth = v ?? false)
                  : null,
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _NumberDropdown(
                  label: '년',
                  value: _year,
                  items: [for (var y = _nowYear; y >= 1930; y--) y],
                  onChanged: (v) => setState(() => _year = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberDropdown(
                  label: '월',
                  value: _month,
                  items: [for (var m = 1; m <= 12; m++) m],
                  onChanged: (v) => setState(() => _month = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberDropdown(
                  label: '일',
                  value: _day,
                  items: [for (var d = 1; d <= daysInMonth; d++) d],
                  onChanged: (v) => setState(() => _day = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _timeUnknown,
            title: const Text('태어난 시간을 몰라요'),
            subtitle: const Text('시주 없이 년·월·일주만으로 프로필을 만들어요'),
            onChanged: (v) => setState(() => _timeUnknown = v ?? false),
          ),
          if (!_timeUnknown)
            Row(
              children: [
                Expanded(
                  child: _NumberDropdown(
                    label: '시',
                    value: _hour,
                    items: [for (var h = 0; h <= 23; h++) h],
                    onChanged: (v) => setState(() => _hour = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumberDropdown(
                    label: '분',
                    value: _minute,
                    items: [for (var m = 0; m <= 59; m++) m],
                    onChanged: (v) => setState(() => _minute = v),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BirthCity>(
            value: _city,
            isExpanded: true,
            decoration: const InputDecoration(labelText: '태어난 도시'),
            items: [
              for (final c in koreanBirthCities)
                DropdownMenuItem(value: c, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _city = v ?? _city),
          ),
          const SizedBox(height: 8),
          Text(
            '경도 차이를 시각 보정(진태양시)에 반영해요.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('사주 계산하기'),
          ),
        ],
      ),
    );
  }
}

class _NumberDropdown extends StatelessWidget {
  final String label;
  final int value;
  final List<int> items;
  final ValueChanged<int> onChanged;

  const _NumberDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value) ? value : items.first;
    return DropdownButtonFormField<int>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: [
        for (final i in items) DropdownMenuItem(value: i, child: Text('$i')),
      ],
      onChanged: (v) => onChanged(v ?? safeValue),
    );
  }
}
