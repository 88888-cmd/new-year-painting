class PaintingFilterOptionModel {
  int id = 0;
  String name = '';

  PaintingFilterOptionModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
  }
}
