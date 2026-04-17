import 'package:app/models/tag.dart';

class TagGroupModel {
  int id = 0;
  String cn_name = '';
  String en_name = '';
  List<TagModel> tags = [];

  TagGroupModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    cn_name = json['cn_name'].toString();
    en_name = json['en_name'].toString();
    tags = (json['tags'] as List).map((e) => TagModel.fromJson(e)).toList();
  }
}
