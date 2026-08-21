import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/journal_entry.dart';
import '../models/journal_state.dart';
import '../models/wu_xing.dart';
import '../utils/date_key.dart';

/// 저널 히스토리 — 날짜순(최신순) 리스트.
class JournalHistoryScreen extends StatelessWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<JournalState>().sortedByDateDesc;

    return Scaffold(
      appBar: AppBar(title: const Text('기록')),
      body: entries.isEmpty
          ? const Center(child: Text('아직 기록이 없어요'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _EntryCard(entry: entries[index]),
            ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateLabel = formatYmd(entry.date);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(dateLabel, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${entry.promptElement.label} · 기분 ${entry.mood} · 에너지 ${entry.energy}',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(entry.prompt, style: Theme.of(context).textTheme.bodySmall),
            if (entry.memo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(entry.memo, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
