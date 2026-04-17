class PostsCategoryModel {
  int id = 0;
  String name = '';

  PostsCategoryModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
  }
}
