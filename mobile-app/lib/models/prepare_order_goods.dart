import 'package:app/utils/constants.dart';

class PrepareOrderGoodsModel {
  int id = 0;
  String name = '';
  String image_url = '';
  int sku_id = 0;
  String sku_name = '';
  double sku_price = 0;
  int point_num = 0;
  int buy_num = 1;
  int freight_type = 0;
  int freight_temp_id = 0;

  PrepareOrderGoodsModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    name = json['name'].toString();
    image_url = Constants.mediaBaseUrl + json['image_url'].toString();
    buy_num = int.parse(json['buy_num'].toString());
    sku_id = int.parse(json['sku_id'].toString());
    sku_name = json['sku_name'].toString();
    if (json['sku_price'] != null) {
      sku_price = double.parse(json['sku_price'].toString());
    }
    if (json['point_num'] != null) {
      point_num = int.parse(json['point_num'].toString());
    }
    freight_type = int.parse(json['freight_type'].toString());
    freight_temp_id = int.parse(json['freight_temp_id'].toString());
  }
}
