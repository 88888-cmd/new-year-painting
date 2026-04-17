class GoodsSkuModel {
  int id = 0;
  int goods_id = 0;
  String sku_name = 'Sku';
  double price = 99999;
  double line_price = 99999;

  GoodsSkuModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    goods_id = int.parse(json['goods_id'].toString());
    sku_name = json['sku_name'].toString();
    price = double.parse(json['price'].toString());
    line_price = double.parse(json['line_price'].toString());
  }
}
