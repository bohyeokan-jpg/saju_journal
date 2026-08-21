import 'sip_sin.dart';
import 'wu_xing.dart';

/// 사주의 네 기둥(년/월/일/시) 중 하나. 천간(gan)·지지(zhi)는 항상 한글로 저장한다.
class Pillar {
  final String gan; // 예: '갑'
  final String zhi; // 예: '자'
  final WuXing ganElement;
  final WuXing zhiElement;

  const Pillar({
    required this.gan,
    required this.zhi,
    required this.ganElement,
    required this.zhiElement,
  });

  /// 예: '갑자'
  String get label => '$gan$zhi';

  Map<String, dynamic> toJson() => {
        'gan': gan,
        'zhi': zhi,
        'ganElement': ganElement.toJson(),
        'zhiElement': zhiElement.toJson(),
      };

  factory Pillar.fromJson(Map<String, dynamic> json) => Pillar(
        gan: json['gan'] as String,
        zhi: json['zhi'] as String,
        ganElement: wuXingFromJson(json['ganElement'] as String),
        zhiElement: wuXingFromJson(json['zhiElement'] as String),
      );
}

/// 사주 계산 결과 + 계산에 사용한 원본 입력을 함께 보관한다. 원본 입력을
/// 같이 저장해두는 이유는 설정 화면의 "프로필 재입력"에서 이전에 입력했던
/// 값을 그대로 다시 보여주기 위해서다.
class SajuProfile {
  final DateTime birthDateTime; // 사용자가 입력한 시각 그대로(보정 전), 한국 표준시 기준 벽시계 시각
  final bool isLunar;
  final bool isLeapMonth;
  final bool timeUnknown;
  final String birthCityName;
  final double birthLongitude;

  /// 진태양시 보정(경도 보정만 적용, 균시차 미적용) 후 실제 계산에 쓰인 시각.
  /// 시간을 모르는 경우에도 정오(12:00)를 기준으로 채워져 있다 — 값 자체는
  /// 참고용이며 시주 계산에는 쓰이지 않는다.
  final DateTime correctedDateTime;

  final Pillar year;
  final Pillar month;
  final Pillar day;
  final Pillar? time; // timeUnknown이면 null

  final SipSin yearSipSin;
  final SipSin monthSipSin;
  final SipSin? timeSipSin; // timeUnknown이면 null

  /// 8글자(시간 모름이면 6글자)의 오행 분포.
  final Map<WuXing, int> wuxingCounts;

  const SajuProfile({
    required this.birthDateTime,
    required this.isLunar,
    required this.isLeapMonth,
    required this.timeUnknown,
    required this.birthCityName,
    required this.birthLongitude,
    required this.correctedDateTime,
    required this.year,
    required this.month,
    required this.day,
    required this.time,
    required this.yearSipSin,
    required this.monthSipSin,
    required this.timeSipSin,
    required this.wuxingCounts,
  });

  /// 일간(日干) — 명리학에서 '나 자신'을 상징하는 글자. 오늘의 성찰 프롬프트를
  /// 고를 때도 이 오행을 기준으로 삼는다.
  WuXing get dayMasterElement => day.ganElement;

  int get totalCharCount => time == null ? 6 : 8;

  Map<String, dynamic> toJson() => {
        'birthDateTime': birthDateTime.toIso8601String(),
        'isLunar': isLunar,
        'isLeapMonth': isLeapMonth,
        'timeUnknown': timeUnknown,
        'birthCityName': birthCityName,
        'birthLongitude': birthLongitude,
        'correctedDateTime': correctedDateTime.toIso8601String(),
        'year': year.toJson(),
        'month': month.toJson(),
        'day': day.toJson(),
        'time': time?.toJson(),
        'yearSipSin': yearSipSin.toJson(),
        'monthSipSin': monthSipSin.toJson(),
        'timeSipSin': timeSipSin?.toJson(),
        'wuxingCounts': wuxingCounts.map((k, v) => MapEntry(k.toJson(), v)),
      };

  factory SajuProfile.fromJson(Map<String, dynamic> json) {
    final rawCounts = (json['wuxingCounts'] as Map<String, dynamic>?) ?? {};
    return SajuProfile(
      birthDateTime: DateTime.parse(json['birthDateTime'] as String),
      isLunar: json['isLunar'] as bool,
      isLeapMonth: json['isLeapMonth'] as bool,
      timeUnknown: json['timeUnknown'] as bool,
      birthCityName: json['birthCityName'] as String,
      birthLongitude: (json['birthLongitude'] as num).toDouble(),
      correctedDateTime: DateTime.parse(json['correctedDateTime'] as String),
      year: Pillar.fromJson(json['year'] as Map<String, dynamic>),
      month: Pillar.fromJson(json['month'] as Map<String, dynamic>),
      day: Pillar.fromJson(json['day'] as Map<String, dynamic>),
      time: json['time'] == null
          ? null
          : Pillar.fromJson(json['time'] as Map<String, dynamic>),
      yearSipSin: sipSinFromJson(json['yearSipSin'] as String),
      monthSipSin: sipSinFromJson(json['monthSipSin'] as String),
      timeSipSin: json['timeSipSin'] == null
          ? null
          : sipSinFromJson(json['timeSipSin'] as String),
      wuxingCounts: {
        for (final w in WuXing.values)
          w: (rawCounts[w.toJson()] as num?)?.toInt() ?? 0,
      },
    );
  }
}
