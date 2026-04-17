class PointsGoodsCategoryModel {
  int id = 0;
  String name = '';

  PointsGoodsCategoryModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
  }
}
