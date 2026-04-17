import 'package:app/models/goods.dart';
import 'package:app/models/goods_sku.dart';

class CartModel {
  int id = 0;
  int goods_id = 0;
  int goods_sku_id = 0;
  int buy_num = 0;
  late GoodsModel goods;
  late GoodsSkuModel sku;

  CartModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    goods_id = int.parse(json['goods_id'].toString());
    goods_sku_id = int.parse(json['goods_sku_id'].toString());
    buy_num = int.parse(json['buy_num'].toString());
    goods = GoodsModel.fromJson(json['goods']);
    sku = GoodsSkuModel.fromJson(json['sku']);
  }
}
