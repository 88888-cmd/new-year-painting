class CouponModel {
  int id = 0;
  String name = '';
  String reduce_price = '0.00';
  String min_price = '0.00';
  int total_num = 0;
  int receive_num = 0;
  int expire_day = 0;
  String create_time = '';

  CouponModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
    reduce_price = json['reduce_price'].toString();
    min_price = json['min_price'].toString();
    total_num = int.parse(json['total_num'].toString());
    receive_num = int.parse(json['receive_num'].toString());
    expire_day = int.parse(json['expire_day'].toString());
    create_time = json['create_time'].toString();
  }

  double get reducePrice => double.tryParse(reduce_price) ?? 0.0;
}
