import 'package:app/utils/constants.dart';

class PaintingModel {
  int id = 0;
  String image_url = '';
  String bg_mp3_url = '';
  String name = '';
  int style_id = 0;
  String style = '';
  int theme_id = 0;
  String theme = '';
  int dynasty_id = 0;
  String dynasty = '';
  int author_id = 0;
  String author = '';
  String content = '';
  String create_time = '';

  PaintingModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    image_url = Constants.mediaBaseUrl + json['image_url'].toString();

    final String rawMp3Url = json['bg_mp3_url'].toString();
    if (rawMp3Url.isNotEmpty) {
      if (rawMp3Url.startsWith('http') || rawMp3Url.startsWith('https')) {
        bg_mp3_url = rawMp3Url;
      } else {
        bg_mp3_url = Constants.mediaBaseUrl + rawMp3Url;
      }
    }
    name = json['name'].toString();
    style_id = int.parse(json['style_id'].toString());
    style = json['style'].toString();
    theme_id = int.parse(json['theme_id'].toString());
    theme = json['theme'].toString();
    dynasty_id = int.parse(json['dynasty_id'].toString());
    dynasty = json['dynasty'].toString();
    author_id = int.parse(json['author_id'].toString());
    author = json['author'].toString();
    content = json['content'].toString();
    create_time = json['create_time'].toString();
  }
}
