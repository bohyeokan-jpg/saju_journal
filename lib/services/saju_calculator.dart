import 'package:lunar/lunar.dart';

import '../models/saju_profile.dart';
import '../models/sip_sin.dart';
import '../models/wu_xing.dart';

const Map<String, String> _ganHangul = {
  '甲': '갑', '乙': '을', '丙': '병', '丁': '정', '戊': '무',
  '己': '기', '庚': '경', '辛': '신', '壬': '임', '癸': '계',
};

const Map<String, String> _zhiHangul = {
  '子': '자', '丑': '축', '寅': '인', '卯': '묘', '辰': '진', '巳': '사',
  '午': '오', '未': '미', '申': '신', '酉': '유', '戌': '술', '亥': '해',
};

/// `lunar`(6tail lunar-java 포팅) 패키지를 감싸는 순수 계산기.
///
/// 이 클래스는 [DateTime.now]를 직접 호출하지 않는다 — 사주 계산은 항상
/// 사용자가 입력한 생년월일시로만 이뤄지고, "오늘의 기운"처럼 오늘 날짜가
/// 필요한 계산(성찰 프롬프트 선택 등)은 호출부가 날짜를 인자로 넘기도록
/// 별도 함수로 분리돼 있다 (테스트에서 임의의 날짜를 주입할 수 있게).
///
/// ## 진태양시(眞太陽時) 보정 — 경도 보정만 적용
/// 한국은 표준시(KST)로 동경 135도 기준 시각을 쓰지만, 실제 태양이 자오선을
/// 통과하는 시각(진태양시)은 출생지 경도에 따라 다르다. 경도 1도 차이는
/// 4분의 시차에 해당하므로, 아래 [applyLongitudeCorrection]에서
/// `(출생지 경도 - 135) * 4분`을 KST 시각에 더해 보정한다.
/// 균시차(equation of time, 최대 ±16분 수준의 계절적 편차)는 1차 구현에서는
/// 의도적으로 생략했다 — 계산이 더 복잡하고, 경도 보정만으로도 한반도
/// 전역(약 -44분~-12분)의 지역차를 충분히 잡아주기 때문에 다음 단계 과제로
/// 미룬다.
///
/// ## 자시(子時, 23:00~01:00) 처리 — 조자시/야자시 분리법 채택
/// `lunar` 패키지의 `EightChar`는 일주 계산에 두 유파를 지원한다
/// (`setSect`): sect=1은 자시 전체(23:00~01:00)를 다음날로 넘기는 유파,
/// sect=2(기본값)는 자정을 기준으로 그대로 나누는 유파 — 즉 23:00~23:59는
/// 당일 일주를 유지하고(조자시), 00:00~00:59는 다음날 일주로 넘어간다
/// (야자시). 이 앱은 sect=2, 조자시/야자시 분리법을 채택한다. 이는 여러
/// 국내 만세력 서비스가 기본값으로 쓰는 방식이자 패키지 자체의 기본값이기도
/// 해서, 별도 근거 없이 자시를 다음날로 통째로 넘기는 것보다 사용자 기대와
/// 어긋날 위험이 적다고 판단했다. (시주의 천간은 항상 그 시각이 속한
/// 날짜의 다음날 일간을 기준으로 오서둔시법을 적용하는 패키지 기본 동작을
/// 그대로 따른다 — 이는 일주 유파 선택과 별개로 명리학 표준 규칙이다.)
class SajuCalculator {
  static const double _kstMeridianLongitude = 135.0;

  /// KST 벽시계 시각 [kstWallClock]을 [longitude](동경, 도 단위) 기준
  /// 진태양시로 보정한다. 경도 보정만 적용(균시차 제외).
  static DateTime applyLongitudeCorrection(
    DateTime kstWallClock,
    double longitude,
  ) {
    final offsetMinutes = ((longitude - _kstMeridianLongitude) * 4).round();
    return kstWallClock.add(Duration(minutes: offsetMinutes));
  }

  /// [birthDateTime]은 사용자가 입력한 KST 벽시계 시각(양력이면 양력 그대로,
  /// 음력이면 음력 연/월/일 값을 담되 시/분만 실제 시각). [isLunar]가 true면
  /// [birthDateTime]의 year/month/day를 음력 날짜로 해석한다. [isLeapMonth]는
  /// 음력 입력에서 윤달을 선택했을 때만 의미가 있다.
  /// [timeUnknown]이면 시간을 정오(12:00)로 두고 계산하되(경도 보정으로도
  /// 자정을 넘지 않을 만큼 안전한 여유가 있는 시각), 결과의 시주는 null로
  /// 비워 두고 오행 집계에서도 제외한다.
  static SajuProfile calculate({
    required DateTime birthDateTime,
    required bool isLunar,
    bool isLeapMonth = false,
    required bool timeUnknown,
    required String birthCityName,
    required double birthLongitude,
  }) {
    final hour = timeUnknown ? 12 : birthDateTime.hour;
    final minute = timeUnknown ? 0 : birthDateTime.minute;

    // 1. 입력을 양력 연/월/일로 정규화.
    int solarYear;
    int solarMonth;
    int solarDay;
    if (isLunar) {
      final lunarMonth =
          isLeapMonth ? -birthDateTime.month : birthDateTime.month;
      final lunar = Lunar.fromYmdHms(
        birthDateTime.year,
        lunarMonth,
        birthDateTime.day,
        hour,
        minute,
        0,
      );
      final solar = lunar.getSolar();
      solarYear = solar.getYear();
      solarMonth = solar.getMonth();
      solarDay = solar.getDay();
    } else {
      solarYear = birthDateTime.year;
      solarMonth = birthDateTime.month;
      solarDay = birthDateTime.day;
    }

    final wallClock = DateTime(solarYear, solarMonth, solarDay, hour, minute);

    // 2. 진태양시 보정 후 최종 계산에 투입.
    final corrected = applyLongitudeCorrection(wallClock, birthLongitude);
    final solar = Solar.fromYmdHms(
      corrected.year,
      corrected.month,
      corrected.day,
      corrected.hour,
      corrected.minute,
      0,
    );
    final eightChar = EightChar.fromLunar(solar.getLunar())..setSect(2);

    final year = _pillarOf(eightChar.getYearGan(), eightChar.getYearZhi());
    final month = _pillarOf(eightChar.getMonthGan(), eightChar.getMonthZhi());
    final day = _pillarOf(eightChar.getDayGan(), eightChar.getDayZhi());
    final yearSipSin = sipSinFromHanja(eightChar.getYearShiShenGan());
    final monthSipSin = sipSinFromHanja(eightChar.getMonthShiShenGan());

    Pillar? time;
    SipSin? timeSipSin;
    if (!timeUnknown) {
      time = _pillarOf(eightChar.getTimeGan(), eightChar.getTimeZhi());
      timeSipSin = sipSinFromHanja(eightChar.getTimeShiShenGan());
    }

    final counts = <WuXing, int>{for (final w in WuXing.values) w: 0};
    void tally(Pillar p) {
      counts[p.ganElement] = counts[p.ganElement]! + 1;
      counts[p.zhiElement] = counts[p.zhiElement]! + 1;
    }

    tally(year);
    tally(month);
    tally(day);
    if (time != null) tally(time);

    return SajuProfile(
      birthDateTime: birthDateTime,
      isLunar: isLunar,
      isLeapMonth: isLeapMonth,
      timeUnknown: timeUnknown,
      birthCityName: birthCityName,
      birthLongitude: birthLongitude,
      correctedDateTime: corrected,
      year: year,
      month: month,
      day: day,
      time: time,
      yearSipSin: yearSipSin,
      monthSipSin: monthSipSin,
      timeSipSin: timeSipSin,
      wuxingCounts: counts,
    );
  }

  static Pillar _pillarOf(String ganHanja, String zhiHanja) => Pillar(
        gan: _ganHangul[ganHanja]!,
        zhi: _zhiHangul[zhiHanja]!,
        ganElement: wuXingFromHanja(_wuXingOfGan(ganHanja)),
        zhiElement: wuXingFromHanja(_wuXingOfZhi(zhiHanja)),
      );

  // `lunar` 패키지가 이미 공개 제공하는 표를 그대로 쓴다(LunarUtil.WU_XING_GAN/
  // WU_XING_ZHI) — 직접 유지하는 표를 하나 줄여서 패키지 표와 어긋날 여지를
  // 없앤다.
  static String _wuXingOfGan(String ganHanja) => LunarUtil.WU_XING_GAN[ganHanja]!;

  static String _wuXingOfZhi(String zhiHanja) => LunarUtil.WU_XING_ZHI[zhiHanja]!;
}
