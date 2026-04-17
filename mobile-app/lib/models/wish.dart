import 'package:app/utils/constants.dart';

class WishModel {
  int id = 0;
  int wish_type = 0;
  String wish_type_display = '';
  int painting_id = 0;
  String painting_image_url = '';
  String content = '';
  int user_id = 0;
  String create_time = '';

  String avatar_url = '';
  String nickname = '';

  WishModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    wish_type = int.parse(json['wish_type'].toString());
    wish_type_display = json['wish_type_display'].toString();
    painting_id = int.parse(json['painting_id'].toString());
    painting_image_url = Constants.mediaBaseUrl + json['painting_image_url'].toString();
    content = json['content'].toString();
    user_id = int.parse(json['user_id'].toString());
    create_time = json['create_time'].toString();

    avatar_url = json['avatar_url'].toString();
    nickname = json['nickname'].toString();
  }
}
