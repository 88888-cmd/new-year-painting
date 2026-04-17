class GoodsCategoryModel {
  int id = 0;
  String name = '';

  GoodsCategoryModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
  }
}
