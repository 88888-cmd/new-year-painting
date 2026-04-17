import 'package:app/utils/constants.dart';

class PostsModel {
  int id = 0;
  int category_id = 0;
  String title = '';
  String content = '';
  List<String> image_urls = [];
  List<String> tags = [];
  int type = 0;
  int painting_id = 0;
  String painting_name = '';
  String painting_image_url = '';
  String video_url = '';
  String video_cover_url = '';
  int view_count = 0;
  int comment_count = 0;
  int thumb_count = 0;
  int user_id = 0;
  String create_time = '';

  String avatar_url = '';
  String nickname = '';

  PostsModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    category_id = int.parse(json['category_id'].toString());
    title = json['title'].toString();
    content = json['content'].toString();
    image_urls =
        (json['image_urls'] as List<dynamic>?)
            ?.map((url) => '${Constants.mediaBaseUrl}${url.toString()}')
            .toList() ??
        [];

    tags = List<String>.from(json['tags'] ?? []);
    type = int.parse(json['type'].toString());
    painting_id = int.parse(json['painting_id'].toString());
    painting_name = json['painting_name'].toString();
    painting_image_url = json['painting_image_url'].toString();
    video_url = json['video_url']?.toString().isNotEmpty == true
        ? '${Constants.mediaBaseUrl}${json['video_url'].toString()}'
        : '';
    video_cover_url = json['video_cover_url']?.toString().isNotEmpty == true
        ? '${Constants.mediaBaseUrl}${json['video_cover_url'].toString()}'
        : '';
    view_count = int.parse(json['view_count'].toString());
    comment_count = int.parse(json['comment_count'].toString());
    thumb_count = int.parse(json['thumb_count'].toString());
    user_id = int.parse(json['user_id'].toString());
    create_time = json['create_time'].toString();

    avatar_url = json['avatar_url'].toString();
    if (avatar_url.isNotEmpty) {
      avatar_url = Constants.mediaBaseUrl + avatar_url;
    }
    nickname = json['nickname'].toString();
  }
}
