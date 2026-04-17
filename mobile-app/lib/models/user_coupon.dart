class UserCouponModel {
  int id = 0;
  int coupon_id = 0;
  String coupon_name = '';
  double reduce_price = 0.0;
  double min_price = 0.0;
  int expire_day = 0;
  String start_time = '';
  String end_time = '';
  int is_use = 0;
  String use_time = '';
  int user_id = 0;
  String create_time = '';

  UserCouponModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    coupon_id = int.parse(json['coupon_id'].toString());
    coupon_name = json['coupon_name'].toString();
    reduce_price = double.parse(json['reduce_price'].toString());
    min_price = double.parse(json['min_price'].toString());
    expire_day = int.parse(json['expire_day'].toString());
    start_time = json['start_time'].toString();
    end_time = json['end_time'].toString();
    is_use = int.parse(json['is_use'].toString());
    use_time = json['use_time'].toString();
    user_id = int.parse(json['user_id'].toString());
    create_time = json['create_time'].toString();
  }

  String getStatusText() {
    if (is_use == 1) {
      return '已使用';
    }

    DateTime now = DateTime.now();
    DateTime end = DateTime.parse(end_time);

    if (now.isAfter(end)) {
      return '已过期';
    }

    return '可使用';
  }
}
