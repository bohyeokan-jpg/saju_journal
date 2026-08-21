import 'package:flutter_test/flutter_test.dart';
import 'package:saju_journal/models/wu_xing.dart';

/// [classifyWuXingState]가 절대 등장 횟수가 아니라 `totalChars`(8글자/6글자)
/// 대비 상대 기준으로 판정하는지에 대한 회귀 테스트.
///
/// 시간을 아는 경우(8글자, 평균 1.6)와 모르는 경우(6글자, 평균 1.2)는
/// 같은 등장 횟수라도 평균 대비 비중이 다르므로 다르게 판정돼야 한다.
void main() {
  group('timeUnknown=false (8글자, 평균 1.6)', () {
    test('0번 등장 — 부족', () {
      expect(classifyWuXingState(0, 8), WuXingState.deficient);
    });

    test('1~2번 등장 — 보통 (평균의 1.5배인 2.4 미만)', () {
      expect(classifyWuXingState(1, 8), WuXingState.balanced);
      expect(classifyWuXingState(2, 8), WuXingState.balanced);
    });

    test('3번 이상 등장 — 왕성 (평균의 1.5배인 2.4 이상)', () {
      expect(classifyWuXingState(3, 8), WuXingState.dominant);
      expect(classifyWuXingState(4, 8), WuXingState.dominant);
    });
  });

  group('timeUnknown=true (6글자, 평균 1.2)', () {
    test('0번 등장 — 부족', () {
      expect(classifyWuXingState(0, 6), WuXingState.deficient);
    });

    test('1번 등장 — 보통 (평균의 1.5배인 1.8 미만)', () {
      expect(classifyWuXingState(1, 6), WuXingState.balanced);
    });

    test('2번 등장 — 왕성 (평균의 1.67배로, 평균의 1.5배인 1.8 이상이라 8글자 기준 3번과 동급으로 취급)', () {
      expect(classifyWuXingState(2, 6), WuXingState.dominant);
    });

    test('3번 이상 등장 — 왕성', () {
      expect(classifyWuXingState(3, 6), WuXingState.dominant);
    });
  });
}
