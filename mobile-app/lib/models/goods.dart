import 'package:app/models/goods_sku.dart';
import 'package:app/utils/constants.dart';

class GoodsModel {
  int id = 0;
  int category_id = 0;
  List<String> image_urls = [];
  String name = '';
  String detail_url = '';
  String create_time = '';
  GoodsSkuModel? sku_info;

  GoodsModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    category_id = int.parse(json['category_id'].toString());

    image_urls =
        (json['image_urls'] as List<dynamic>?)
            ?.map((url) => '${Constants.mediaBaseUrl}${url.toString()}')
            .toList() ??
        [];

    name = json['name'].toString();
    detail_url = Constants.mediaBaseUrl + json['detail_url'].toString();
    create_time = json['create_time'].toString();

    if (json['sku_info'] != null) {
      sku_info = GoodsSkuModel.fromJson(json['sku_info']);
    }
  }
}
