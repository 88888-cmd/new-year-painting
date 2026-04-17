import 'package:app/utils/constants.dart';

class OrderGoodsModel {
  int id = 0;
  int order_id = 0;
  // int goods_id = 0;
  String goods_image_url = '';
  String goods_name = '';
  // int goods_sku_id = 0;
  String goods_sku_name = '';
  double goods_sku_price = 0.0;
  int goods_sku_point_num = 0;
  int buy_num = 1;
  int status = 1;
  int is_comment = 0;

  OrderGoodsModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    order_id = int.parse(json['order_id'].toString());
    // goods_id = int.parse(json['goods_id'].toString());
    goods_image_url = Constants.mediaBaseUrl + json['goods_image_url'].toString();
    goods_name = json['goods_name'].toString();
    // goods_sku_id = int.parse(json['goods_sku_id'].toString());
    goods_sku_name = json['goods_sku_name'].toString();
    goods_sku_price = double.parse(json['goods_sku_price'].toString());
    goods_sku_point_num = int.parse(json['goods_sku_point_num'].toString());
    buy_num = int.parse(json['buy_num'].toString());
    status = int.parse(json['status'].toString());
    is_comment = int.parse(json['is_comment'].toString());
  }
}