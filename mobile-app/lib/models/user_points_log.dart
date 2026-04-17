class UserPointsLogModel {
  int scene = 0;
  String scene_display = '';
  int integral_type = 0;
  int integral_num = 0;
  String create_time = '';

  UserPointsLogModel.fromJson(dynamic json) {
    scene = int.parse(json['scene'].toString());
    scene_display = json['scene_display'].toString();
    integral_type = int.parse(json['integral_type'].toString());
    integral_num = int.parse(json['integral_num'].toString());
    create_time = json['create_time'].toString();
  }
}
