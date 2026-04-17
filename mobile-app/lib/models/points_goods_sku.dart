class PointsGoodsSkuModel {
  int id = 0;
  int goods_id = 0;
  String sku_name = 'Sku';
  int point_num = 99999;

  PointsGoodsSkuModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    goods_id = int.parse(json['goods_id'].toString());
    sku_name = json['sku_name'].toString();
    point_num = int.parse(json['point_num'].toString());
  }
}
