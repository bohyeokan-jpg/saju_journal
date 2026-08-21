/// 십성(十神) — 일간(나)과 다른 천간의 관계를 나타내는 10가지 유형.
/// `lunar` 패키지는 한자(간체)로 값을 주므로 [sipSinFromHanja]에서 바로 변환한다.
/// 패키지는 편관을 '七杀(칠살)'로 표기하는데, 이 앱에서는 더 널리 쓰이는
/// '편관'을 대표 라벨로 쓰고 칠살은 별칭으로만 붙인다.
enum SipSin {
  bigyeon, // 비견
  geopjae, // 겁재
  siksin, // 식신
  sangkwan, // 상관
  pyeonjae, // 편재
  jeongjae, // 정재
  pyeongwan, // 편관(칠살)
  jeonggwan, // 정관
  pyeonin, // 편인
  jeongin, // 정인
}

extension SipSinLabel on SipSin {
  String get label => switch (this) {
        SipSin.bigyeon => '비견',
        SipSin.geopjae => '겁재',
        SipSin.siksin => '식신',
        SipSin.sangkwan => '상관',
        SipSin.pyeonjae => '편재',
        SipSin.jeongjae => '정재',
        SipSin.pyeongwan => '편관',
        SipSin.jeonggwan => '정관',
        SipSin.pyeonin => '편인',
        SipSin.jeongin => '정인',
      };
}

SipSin sipSinFromHanja(String hanja) => switch (hanja) {
      '比肩' => SipSin.bigyeon,
      '劫财' => SipSin.geopjae,
      '食神' => SipSin.siksin,
      '伤官' => SipSin.sangkwan,
      '偏财' => SipSin.pyeonjae,
      '正财' => SipSin.jeongjae,
      '七杀' => SipSin.pyeongwan,
      '正官' => SipSin.jeonggwan,
      '偏印' => SipSin.pyeonin,
      '正印' => SipSin.jeongin,
      _ => throw ArgumentError('알 수 없는 십성 한자: $hanja'),
    };

extension SipSinJson on SipSin {
  String toJson() => name;
}

SipSin sipSinFromJson(String name) =>
    SipSin.values.firstWhere((s) => s.name == name, orElse: () => SipSin.bigyeon);
