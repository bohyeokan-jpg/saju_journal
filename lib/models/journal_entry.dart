import 'wu_xing.dart';

/// 하루치 저널 기록 — "오늘 화면"에서 프롬프트에 답하며 남기는 짧은 성찰.
class JournalEntry {
  final String id;
  final DateTime date;

  /// 그날의 성찰 프롬프트를 고를 때 쓴 오행(일간 기준) — 기록 화면에서
  /// "그날 어떤 기운으로 성찰했는지" 다시 보여줄 때 쓴다.
  final WuXing promptElement;
  final String prompt;

  /// 기분/에너지는 1(낮음)~5(높음) 5단계.
  final int mood;
  final int energy;
  final String memo;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.promptElement,
    required this.prompt,
    required this.mood,
    required this.energy,
    required this.memo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'promptElement': promptElement.toJson(),
        'prompt': prompt,
        'mood': mood,
        'energy': energy,
        'memo': memo,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        promptElement: wuXingFromJson(json['promptElement'] as String),
        prompt: json['prompt'] as String,
        mood: json['mood'] as int,
        energy: json['energy'] as int,
        memo: json['memo'] as String,
      );
}
