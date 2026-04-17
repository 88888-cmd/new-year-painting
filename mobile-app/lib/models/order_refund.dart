import 'package:app/models/order_goods.dart';

class OrderRefundModel {
  int id = 0;
  int order_id = 0;
  int order_goods_id = 0;
  int refund_type = 0;
  String refund_type_display = '';
  String refund_no = '';
  String apply_desc = '';
  int audit_status = 0;
  String audit_status_display = '';
  int is_user_send = 0;
  String send_time = '';
  String express_name = '';
  String express_no = '';
  int is_receipt = 0;
  double refund_money = 0.0;
  int refund_coupon = 0;
  int refund_normal_points = 0;
  int refund_cultural_points = 0;
  int status = 0;
  String status_display = '';
  String create_time = '';

  String relation_order_no = '';
  int relation_order_type = 0;
  List<OrderGoodsModel> order_goods_list = [];

  OrderRefundModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    order_id = int.parse(json['order_id'].toString());
    order_goods_id = int.parse(json['order_goods_id'].toString());
    refund_type = int.parse(json['refund_type'].toString());
    refund_type_display = json['refund_type_display'].toString();
    refund_no = json['refund_no'].toString();
    apply_desc = json['apply_desc'].toString();
    audit_status = int.parse(json['audit_status'].toString());
    audit_status_display = json['audit_status_display'].toString();
    is_user_send = int.parse(json['is_user_send'].toString());
    send_time = json['send_time'].toString();
    express_name = json['express_name'].toString();
    express_no = json['express_no'].toString();
    is_receipt = int.parse(json['is_receipt'].toString());
    refund_money = double.parse(json['refund_money'].toString());
    refund_coupon = int.parse(json['refund_coupon'].toString());
    refund_normal_points = int.parse(json['refund_normal_points'].toString());
    refund_cultural_points = int.parse(
      json['refund_cultural_points'].toString(),
    );
    status = int.parse(json['status'].toString());
    status_display = json['status_display'].toString();
    create_time = json['create_time'].toString();

    relation_order_no = json['relation_order_no'].toString();
    relation_order_type = int.parse(json['relation_order_type'].toString());
    order_goods_list =
        (json['order_goods_list'] as List<dynamic>?)
            ?.map((item) => OrderGoodsModel.fromJson(item))
            .toList() ??
        [];
  }
}
