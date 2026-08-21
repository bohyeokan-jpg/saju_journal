/// 출생 도시 → 동경(East) 경도 매핑. 진태양시 보정에 쓰인다.
/// 값은 각 도시 시청/중심가 기준 대략적인 경도(공개된 지리 좌표).
class BirthCity {
  final String name;
  final double longitude;
  const BirthCity(this.name, this.longitude);
}

const List<BirthCity> koreanBirthCities = [
  BirthCity('서울', 126.9780),
  BirthCity('인천', 126.7052),
  BirthCity('수원', 127.0286),
  BirthCity('춘천', 127.7298),
  BirthCity('강릉', 128.8761),
  BirthCity('대전', 127.3845),
  BirthCity('세종', 127.2890),
  BirthCity('청주', 127.4890),
  BirthCity('전주', 127.1480),
  BirthCity('광주', 126.8526),
  BirthCity('목포', 126.3922),
  BirthCity('여수', 127.6622),
  BirthCity('대구', 128.6014),
  BirthCity('안동', 128.7294),
  BirthCity('포항', 129.3435),
  BirthCity('부산', 129.0756),
  BirthCity('울산', 129.3114),
  BirthCity('창원', 128.6811),
  BirthCity('진주', 128.1080),
  BirthCity('제주', 126.5312),
  BirthCity('서귀포', 126.5600),
];
