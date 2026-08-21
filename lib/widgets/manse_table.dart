import 'package:flutter/material.dart';

import '../models/saju_profile.dart';

/// 만세력 표 — 년/월/일/시 네 기둥을 천간·지지 2행으로 보여준다.
/// 사주 앱임을 한눈에 알아볼 수 있게 의도적으로 남겨둔 시각 요소.
class ManseTable extends StatelessWidget {
  final SajuProfile profile;
  const ManseTable({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final columns = [
      ('시', profile.time),
      ('일', profile.day),
      ('월', profile.month),
      ('년', profile.year),
    ];

    return Table(
      border: TableBorder.all(color: scheme.outline, width: 1),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.4)),
          children: [
            for (final (label, _) in columns) _HeaderCell(label),
          ],
        ),
        TableRow(
          children: [
            for (final (_, pillar) in columns) _CharCell(pillar?.gan ?? '모름'),
          ],
        ),
        TableRow(
          children: [
            for (final (_, pillar) in columns) _CharCell(pillar?.zhi ?? '-'),
          ],
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(label, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}

class _CharCell extends StatelessWidget {
  final String text;
  const _CharCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: text.length == 1 ? 24 : 15,
              ),
        ),
      ),
    );
  }
}
