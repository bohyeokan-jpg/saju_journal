import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/sipsin_content.dart';
import '../content/wuxing_content.dart';
import '../models/profile_state.dart';
import '../models/saju_profile.dart';
import '../models/wu_xing.dart';
import '../utils/date_key.dart';
import '../widgets/manse_table.dart';
import '../widgets/wuxing_distribution_chart.dart';

/// 사주 프로필 결과 화면 — 만세력 표 + 오행 분포 + 십성 요약.
class SajuProfileScreen extends StatelessWidget {
  const SajuProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileState>().profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('아직 사주 프로필이 없어요')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('내 사주')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionCard(
            title: '만세력',
            child: ManseTable(profile: profile),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: '일간(나)',
            child: Row(
              children: [
                Text(
                  profile.day.gan,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    wuxingContent[profile.dayMasterElement]![
                        classifyWuXingState(
                            profile.wuxingCounts[profile.dayMasterElement] ?? 0,
                            profile.totalCharCount)]!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: '오행 분포',
            child: WuxingDistributionChart(counts: profile.wuxingCounts),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: '오행 풀이',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final element in WuXing.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      wuxingContent[element]![classifyWuXingState(
                          profile.wuxingCounts[element] ?? 0, profile.totalCharCount)]!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: '십성 요약',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sipsinContent[profile.yearSipSin]!,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                Text(sipsinContent[profile.monthSipSin]!,
                    style: Theme.of(context).textTheme.bodyMedium),
                if (profile.timeSipSin != null) ...[
                  const SizedBox(height: 10),
                  Text(sipsinContent[profile.timeSipSin]!,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _BirthInfoCard(profile: profile),
        ],
      ),
    );
  }
}

class _BirthInfoCard extends StatelessWidget {
  final SajuProfile profile;
  const _BirthInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final b = profile.birthDateTime;
    final calendarLabel = profile.isLunar ? '음력${profile.isLeapMonth ? '(윤달)' : ''}' : '양력';
    final timeLabel = profile.timeUnknown ? '시간 모름' : formatHm(b);
    return _SectionCard(
      title: '입력한 정보',
      child: Text(
        '$calendarLabel ${formatYmd(b)} $timeLabel · ${profile.birthCityName}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
