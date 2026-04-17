import 'package:app/utils/constants.dart';

class PaintingCommentModel {
  int id = 0;
  int painting_id = 0;
  String content = '';
  int user_id = 0;
  String create_time = '';
  String avatar_url = '';
  String nickname = '';

  PaintingCommentModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    painting_id = int.parse(json['painting_id'].toString());
    content = json['content'].toString();
    user_id = int.parse(json['user_id'].toString());
    create_time = json['create_time'].toString();

    avatar_url = json['avatar_url'].toString();
    if (avatar_url.isNotEmpty) {
      avatar_url = Constants.mediaBaseUrl + avatar_url;
    }

    nickname = json['nickname'].toString();
  }
}
