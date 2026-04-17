import 'package:app/models/order_goods.dart';
import 'package:app/models/order_wuliu.dart';

class OrderModel {
  int id = 0;
  int order_type = 0;
  String order_no = '';
  double total_price = 0.0;
  int total_points = 0;
  int coupon_id = 0;
  double coupon_money = 0.0;
  int normal_points = 0;
  double normal_points_deduct = 0.0;
  int cultural_points = 0;
  // double cultural_points_yuan = 0.0;
  double freight_price = 0.0;
  double pay_price = 0.0;
  int give_normal_points = 0;
  int give_normal_points_granted = 0;
  String delivery_time = '';
  String express_name = '';
  String express_no = '';
  int refund_coupon = 0;
  int refund_normal_points = 0;
  int refund_cultural_points = 0;
  int order_status = 1;
  String order_status_display = '';
  // int is_comment = 0;
  int user_id = 0;
  String create_time = '';

  List<OrderGoodsModel> order_goods_list = [];

  OrderModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    order_type = int.parse(json['order_type'].toString());
    order_no = json['order_no'].toString();
    total_price = double.parse(json['total_price'].toString());
    total_points = int.parse(json['total_points'].toString());
    coupon_id = int.parse(json['coupon_id'].toString());
    coupon_money = double.parse(json['coupon_money'].toString());
    normal_points = int.parse(json['normal_points'].toString());
    normal_points_deduct = double.parse(
      json['normal_points_deduct'].toString(),
    );
    cultural_points = int.parse(json['cultural_points'].toString());
    // cultural_points_yuan = double.parse(
    //   json['cultural_points_yuan'].toString(),
    // );
    freight_price = double.parse(json['freight_price'].toString());
    pay_price = double.parse(json['pay_price'].toString());
    give_normal_points = int.parse(json['give_normal_points'].toString());
    give_normal_points_granted = int.parse(
      json['give_normal_points_granted'].toString(),
    );
    delivery_time = json['delivery_time'].toString();
    express_name = json['express_name'].toString();
    express_no = json['express_no'].toString();
    refund_coupon = int.parse(json['refund_coupon'].toString());
    refund_normal_points = int.parse(json['refund_normal_points'].toString());
    refund_cultural_points = int.parse(
      json['refund_cultural_points'].toString(),
    );
    order_status = int.parse(json['order_status'].toString());
    order_status_display = json['order_status_display'].toString();
    // is_comment = int.parse(json['is_comment'].toString());
    user_id = int.parse(json['user_id'].toString());
    create_time = json['create_time'].toString();

    order_goods_list =
        (json['order_goods_list'] as List<dynamic>?)
            ?.map((item) => OrderGoodsModel.fromJson(item))
            .toList() ??
        [];
  }
}
