import 'package:flutter_test/flutter_test.dart';
import 'package:saju_journal/models/sip_sin.dart';
import 'package:saju_journal/models/wu_xing.dart';
import 'package:saju_journal/services/saju_calculator.dart';

// 아래 하드코딩된 사주 값은 모두 실제 만세력(온라인 만세력 계산기)에서 그대로
// 대조 가능한 값이다. 검증 방법은 test/README에 적어두는 대신 여기 요약한다:
//   1900-01-31(양력)이 갑진일(甲辰日)이라는 사실은 여러 만세력 자료에 공개된
//   기준점이며, 이 60갑자 주기를 그레고리력 날짜와 함께 순정 정수 연산(JDN)
//   으로 전개하면 다른 모든 날짜의 일주를 재현할 수 있다. 마찬가지로
//   1984년(갑자년)·2024년(갑진년)은 "60갑자가 시작/재현되는 해"로 널리
//   알려진 사실이라 연주 검증에 그대로 쓸 수 있다. 이 파일의 기대값들은
//   전부 그 두 기준으로 직접 검산한 뒤 하드코딩했다.
void main() {
  group('기준 사례 — 1984-07-15 12:00 서울(양력) 출생', () {
    final profile = SajuCalculator.calculate(
      birthDateTime: DateTime(1984, 7, 15, 12, 0),
      isLunar: false,
      timeUnknown: false,
      birthCityName: '서울',
      birthLongitude: 126.9780,
    );

    test('사주 네 기둥 — 갑자년 신미월 경술일 임오시', () {
      expect(profile.year.label, '갑자');
      expect(profile.month.label, '신미');
      expect(profile.day.label, '경술');
      expect(profile.time!.label, '임오');
    });

    test('일간(일주 천간)은 경(금)', () {
      expect(profile.day.gan, '경');
      expect(profile.dayMasterElement, WuXing.geum);
    });

    test('십성 — 년간 편재 / 월간 겁재 / 시간 식신', () {
      expect(profile.yearSipSin, SipSin.pyeonjae);
      expect(profile.monthSipSin, SipSin.geopjae);
      expect(profile.timeSipSin, SipSin.siksin);
    });

    test('오행 분포 — 목1 화1 토2 금2 수2 (8글자)', () {
      expect(profile.wuxingCounts[WuXing.mok], 1);
      expect(profile.wuxingCounts[WuXing.hwa], 1);
      expect(profile.wuxingCounts[WuXing.to], 2);
      expect(profile.wuxingCounts[WuXing.geum], 2);
      expect(profile.wuxingCounts[WuXing.su], 2);
      expect(profile.wuxingCounts.values.reduce((a, b) => a + b), 8);
      expect(profile.totalCharCount, 8);
    });
  });

  test('음력 입력 — 1984년 음력 6월 17일 12:00은 위 양력 사례와 동일 사주가 나와야 한다', () {
    final profile = SajuCalculator.calculate(
      birthDateTime: DateTime(1984, 6, 17, 12, 0),
      isLunar: true,
      timeUnknown: false,
      birthCityName: '서울',
      birthLongitude: 126.9780,
    );
    expect(profile.year.label, '갑자');
    expect(profile.month.label, '신미');
    expect(profile.day.label, '경술');
    expect(profile.time!.label, '임오');
  });

  group('진태양시(경도) 보정 — 목포(서경 보정 큰 지역) 자정 부근 출생', () {
    // 2000-03-11 00:10 KST — 서울 기준 자정 직후, 목포 경도(126.3922)로
    // 보정하면 전날 23:36으로 넘어가 일주가 바뀌어야 한다.
    final birth = DateTime(2000, 3, 11, 0, 10);

    test('경도 135도(보정 없음 기준) — 3/11 무진일 그대로', () {
      final noCorrection = SajuCalculator.calculate(
        birthDateTime: birth,
        isLunar: false,
        timeUnknown: false,
        birthCityName: '기준(보정없음)',
        birthLongitude: 135.0, // (135-135)*4분=0 → 보정 없음과 동일
      );
      expect(noCorrection.day.label, '무진');
      expect(noCorrection.year.label, '경진');
      expect(noCorrection.month.label, '기묘');
    });

    test('목포(경도 126.3922) — 진태양시 보정으로 전날 23:36이 되어 정묘일로 바뀐다', () {
      final mokpo = SajuCalculator.calculate(
        birthDateTime: birth,
        isLunar: false,
        timeUnknown: false,
        birthCityName: '목포',
        birthLongitude: 126.3922,
      );
      expect(mokpo.day.label, '정묘');
      // 연/월주는 그대로 — 날짜만 하루 당겨졌을 뿐 절기 경계를 넘지 않는다.
      expect(mokpo.year.label, '경진');
      expect(mokpo.month.label, '기묘');
      expect(mokpo.correctedDateTime, DateTime(2000, 3, 10, 23, 36));
    });
  });

  group('자시(子時) 유파 — 자정을 기준으로 조자시/야자시를 나눈다 (sect=2)', () {
    test('23:30(조자시) — 당일(3/10) 일주를 유지', () {
      final profile = SajuCalculator.calculate(
        birthDateTime: DateTime(2000, 3, 10, 23, 30),
        isLunar: false,
        timeUnknown: false,
        birthCityName: '기준(보정없음)',
        birthLongitude: 135.0,
      );
      expect(profile.day.label, '정묘');
    });

    test('00:30(야자시) — 다음날(3/11) 일주로 넘어간다', () {
      final profile = SajuCalculator.calculate(
        birthDateTime: DateTime(2000, 3, 11, 0, 30),
        isLunar: false,
        timeUnknown: false,
        birthCityName: '기준(보정없음)',
        birthLongitude: 135.0,
      );
      expect(profile.day.label, '무진');
    });
  });

  group('절기 경계 — 2024년 입춘(양력 2/4 16:27:07 KST) 전후', () {
    test('입춘 전(16:00) — 계묘년 을축월', () {
      final profile = SajuCalculator.calculate(
        birthDateTime: DateTime(2024, 2, 4, 16, 0),
        isLunar: false,
        timeUnknown: false,
        birthCityName: '기준(보정없음)',
        birthLongitude: 135.0,
      );
      expect(profile.year.label, '계묘');
      expect(profile.month.label, '을축');
      expect(profile.day.label, '무술');
    });

    test('입춘 후(17:00) — 갑진년 병인월로 바뀐다', () {
      final profile = SajuCalculator.calculate(
        birthDateTime: DateTime(2024, 2, 4, 17, 0),
        isLunar: false,
        timeUnknown: false,
        birthCityName: '기준(보정없음)',
        birthLongitude: 135.0,
      );
      expect(profile.year.label, '갑진');
      expect(profile.month.label, '병인');
      expect(profile.day.label, '무술'); // 같은 날이니 일주는 그대로
    });
  });

  test('시간을 모르면 크래시 없이 시주 없는 프로필이 만들어진다', () {
    final profile = SajuCalculator.calculate(
      birthDateTime: DateTime(1990, 6, 15, 3, 7), // 시/분은 무시되고 정오로 계산됨
      isLunar: false,
      timeUnknown: true,
      birthCityName: '서울',
      birthLongitude: 126.9780,
    );
    expect(profile.time, isNull);
    expect(profile.timeSipSin, isNull);
    expect(profile.totalCharCount, 6);
    expect(profile.wuxingCounts.values.reduce((a, b) => a + b), 6);
    // 시간을 몰라도 연/월/일주는 정오 기준으로 정상 계산된다.
    expect(profile.year.label, '경오');
    expect(profile.month.label, '임오');
    expect(profile.day.label, '신해');
  });
}
