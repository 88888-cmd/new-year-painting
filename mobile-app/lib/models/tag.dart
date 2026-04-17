class TagModel {
  int id = 0;
  String cn_name = '';
  String en_name = '';

  TagModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    cn_name = json['cn_name'].toString();
    en_name = json['en_name'].toString();
  }
}
