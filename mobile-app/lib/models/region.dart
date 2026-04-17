class RegionModel {
  final String code;
  final String name;
  final String pinyin;
  final String? zipCode;
  final String? parentCode;
  final int type; // 0: 省份, 1: 城市, 2: 区县
  final String firstLetter;

  RegionModel({
    required this.code,
    required this.name,
    required this.pinyin,
    this.zipCode,
    this.parentCode,
    required this.type,
    required this.firstLetter,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      code: json['code'],
      name: json['name'],
      pinyin: json['pinyin'],
      zipCode: json['zip_code'],
      parentCode: json['parent_code'],
      type: json['type'],
      firstLetter: json['first_letter'],
    );
  }
}