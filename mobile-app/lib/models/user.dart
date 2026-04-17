import 'package:app/utils/constants.dart';

class UserModel {
  int id = 0;
  String phone = '';
  String email = '';
  String avatar_url = '';
  int avatar_file_id = 0;
  String nickname = '';
  int gender = 0;
  String birthday = '';
  String profession = '';
  int normal_points = 0;
  int cultural_points = 0;

  int coupon_count = 0;

  UserModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    phone = json['phone'].toString();
    email = json['email'].toString();
    avatar_url = json['avatar_url'].toString();
    avatar_file_id = int.parse(json['avatar_file_id'].toString());
    nickname = json['nickname'].toString();
    gender = int.parse(json['gender'].toString());
    birthday = json['birthday'].toString();
    profession = json['profession'].toString();
    normal_points = int.parse(json['normal_points'].toString());
    cultural_points = int.parse(json['cultural_points'].toString());
    coupon_count = int.parse(json['coupon_count'].toString());
  }
}
