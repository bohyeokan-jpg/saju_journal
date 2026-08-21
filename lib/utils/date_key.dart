/// 시각 정보를 뺀 날짜만 남긴다 — 하루 단위 비교용.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _pad2(int n) => n.toString().padLeft(2, '0');

/// 'yyyy.MM.dd' 형식 — 화면 곳곳의 날짜 표시에 공통으로 쓴다.
String formatYmd(DateTime d) => '${d.year}.${_pad2(d.month)}.${_pad2(d.day)}';

/// 'HH:mm' 형식.
String formatHm(DateTime d) => '${_pad2(d.hour)}:${_pad2(d.minute)}';
