class GoodsCommentModel {
  int id = 0;
  int goods_id = 0;
  int star_num = 5;
  String content = '';
  int user_id = 0;
  String create_time = '';
  String avatar_url = '';
  String nickname = '';

  GoodsCommentModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    goods_id = int.parse(json['goods_id'].toString());
    star_num = int.parse(json['star_num'].toString());
    content = json['content'].toString();
    user_id = int.parse(json['user_id'].toString());
    create_time = json['create_time'].toString();
    avatar_url = json['avatar_url'].toString();
    nickname = json['nickname'].toString();
  }
}
