/// 오행(五行) — 이 앱 전체에서 십성/한자 표기 대신 이 enum과 한글 라벨만 다룬다.
/// `lunar` 패키지는 한자(木火土金水)로 결과를 주므로, 계산기 경계에서 바로
/// 이 enum으로 변환해 그 이후 레이어(모델/화면/콘텐츠)는 한자를 몰라도 되게 한다.
enum WuXing { mok, hwa, to, geum, su }

extension WuXingLabel on WuXing {
  /// 화면에 쓰는 한글 이름 (목/화/토/금/수).
  String get label => switch (this) {
        WuXing.mok => '목',
        WuXing.hwa => '화',
        WuXing.to => '토',
        WuXing.geum => '금',
        WuXing.su => '수',
      };

  /// 원소가 상징하는 계절/성질 한 줄 — 만세력 표·프로필 화면의 보조 설명용.
  String get keyword => switch (this) {
        WuXing.mok => '성장과 확장',
        WuXing.hwa => '표현과 열기',
        WuXing.to => '중재와 안정',
        WuXing.geum => '결단과 정리',
        WuXing.su => '지혜와 저장',
      };
}

/// `lunar` 패키지가 돌려주는 오행 한자 한 글자를 [WuXing]으로 변환.
WuXing wuXingFromHanja(String hanja) => switch (hanja) {
      '木' => WuXing.mok,
      '火' => WuXing.hwa,
      '土' => WuXing.to,
      '金' => WuXing.geum,
      '水' => WuXing.su,
      _ => throw ArgumentError('알 수 없는 오행 한자: $hanja'),
    };

extension WuXingJson on WuXing {
  String toJson() => name;
}

WuXing wuXingFromJson(String name) =>
    WuXing.values.firstWhere((w) => w.name == name, orElse: () => WuXing.to);

/// 사주 여덟 글자(시간 모르면 여섯 글자) 안에서 한 오행이 얼마나 자주
/// 나오는지에 따른 세 단계 — 오행 단독 해석 문구를 고를 때 쓴다.
enum WuXingState { dominant, balanced, deficient }

/// [count]는 해당 오행이 나온 글자 수, [totalChars]는 8(시간 모름이면 6).
/// 평균은 총 글자 수/5이므로, 하나도 없으면 부족, 평균의 1.5배 이상이면
/// 왕성, 그 사이는 보통으로 본다.
///
/// 1.5배를 기준으로 잡은 이유: 오행이 다섯 종류뿐이라 평균 자체가 이미
/// 작은 값(8글자면 1.6, 6글자면 1.2)이라, "평균보다 조금만 많아도 왕성"으로
/// 치면 절반 가까운 케이스가 왕성으로 분류돼 버려 문구의 변별력이 없어진다.
/// 반대로 시간 모름(6글자, 평균 1.2)에서 한 오행이 2번만 나와도(평균의
/// 1.67배) 이미 여덟 글자 기준의 "3번"에 준하는 쏠림인데, 절대값 3을
/// 그대로 쓰면 이 케이스를 놓친다. 1.5배는 두 totalChars(6/8) 모두에서
/// "정수로 나오는 최소 등장 횟수"가 실제 체감상 뚜렷한 쏠림과 일치해
/// 골랐다: 8글자는 평균 1.6의 1.5배(2.4) → 3번 이상, 6글자는 평균 1.2의
/// 1.5배(1.8) → 2번 이상이 왕성이 된다.
/// 부동소수점 오차를 피하려고 `count/totalChars >= 1.5/5`를 정수 비교
/// (`count * 10 >= totalChars * 3`)로 바꿔서 계산한다.
WuXingState classifyWuXingState(int count, int totalChars) {
  if (count == 0) return WuXingState.deficient;
  if (count * 10 >= totalChars * 3) return WuXingState.dominant;
  return WuXingState.balanced;
}
