import 'package:flutter/material.dart';

import '../models/saju_profile.dart';
import '../models/wu_xing.dart';

/// 만세력 표 — 년/월/일/시 네 기둥을 천간·지지 2행으로 보여준다.
/// 사주 앱임을 한눈에 알아볼 수 있게 의도적으로 남겨둔 시각 요소. 각 글자는
/// 자신이 속한 오행 색으로 살짝 틴트해서, 절제된 무채색 표 안에서도 오행별
/// 차이가 한눈에 들어오게 한다.
class ManseTable extends StatelessWidget {
  final SajuProfile profile;
  const ManseTable({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
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
            for (final (_, pillar) in columns)
              _CharCell(
                text: pillar?.gan ?? '모름',
                element: pillar?.ganElement,
                brightness: brightness,
              ),
          ],
        ),
        TableRow(
          children: [
            for (final (_, pillar) in columns)
              _CharCell(
                text: pillar?.zhi ?? '-',
                element: pillar?.zhiElement,
                brightness: brightness,
              ),
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
  final WuXing? element;
  final Brightness brightness;
  const _CharCell({required this.text, required this.element, required this.brightness});

  @override
  Widget build(BuildContext context) {
    final color = element?.colorFor(brightness);
    return Container(
      color: color?.withValues(alpha: brightness == Brightness.light ? 0.10 : 0.16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: text.length == 1 ? 24 : 15,
                  color: color,
                ),
          ),
          if (element != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                element!.label,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color, fontSize: 10.5, height: 1),
              ),
            ),
        ],
      ),
    );
  }
}
