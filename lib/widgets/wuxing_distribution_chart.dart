import 'package:flutter/material.dart';

import '../models/wu_xing.dart';

/// 오행 분포를 가로 막대로 보여준다. 외부 차트 패키지 없이, 각 오행의
/// 글자 수에 비례한 막대 길이만으로 표현하는 단순한 시각화.
class WuxingDistributionChart extends StatelessWidget {
  final Map<WuXing, int> counts;
  const WuxingDistributionChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold(0, (a, b) => a + b);
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final element in WuXing.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    element.label,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: element.colorFor(brightness)),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : (counts[element] ?? 0) / total,
                      minHeight: 14,
                      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      color: element.colorFor(brightness),
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                  child: Text(
                    '${counts[element] ?? 0}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
