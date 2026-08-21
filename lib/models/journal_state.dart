import 'package:flutter/material.dart';

import '../services/journal_store.dart';
import '../utils/date_key.dart';
import 'journal_entry.dart';
import 'wu_xing.dart';

class JournalState extends ChangeNotifier {
  final JournalStore _store;
  JournalState(this._store);

  List<JournalEntry> entries = [];
  bool isLoaded = false;

  /// 최신 기록이 먼저 오도록 정렬해서 보여준다 (히스토리 화면용).
  List<JournalEntry> get sortedByDateDesc =>
      [...entries]..sort((a, b) => b.date.compareTo(a.date));

  Future<void> load() async {
    entries = await _store.load();
    isLoaded = true;
    notifyListeners();
  }

  /// 같은 날짜에 이미 기록이 있으면 덮어쓴다 — 오늘 화면은 하루 한 건만
  /// 남기는 게 자연스럽다.
  Future<void> addOrUpdateEntry({
    required DateTime date,
    required WuXing promptElement,
    required String prompt,
    required int mood,
    required int energy,
    required String memo,
  }) async {
    final day = dateOnly(date);
    entries.removeWhere((e) => isSameDate(e.date, day));
    entries.add(JournalEntry(
      id: day.toIso8601String(),
      date: day,
      promptElement: promptElement,
      prompt: prompt,
      mood: mood,
      energy: energy,
      memo: memo,
    ));
    notifyListeners();
    await _store.save(entries);
  }

  JournalEntry? entryForDate(DateTime date) {
    for (final e in entries) {
      if (isSameDate(e.date, date)) return e;
    }
    return null;
  }

  Future<void> clear() async {
    entries = [];
    notifyListeners();
    await _store.clear();
  }
}
