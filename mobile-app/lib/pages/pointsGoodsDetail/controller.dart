import 'package:app/models/points_goods.dart';
import 'package:app/models/points_goods_comment.dart';
import 'package:app/models/points_goods_sku.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class PointsGoodsController extends GetxController {
  bool isIniting = true; // 是否初始化中

  late PointsGoodsModel goodsModel;
  List<PointsGoodsSkuModel> skuList = [];

  int selectedSkuId = 0;
  PointsGoodsSkuModel get selectedSku {
    return skuList.firstWhereOrNull((o) => o.id == selectedSkuId)!;
  }

  List<PointsGoodsCommentModel> commentList = [];

  @override
  void onInit() {
    super.onInit();

    isIniting = true;

    HttpService.to
        .get('points/goodsDetail', params: {'goods_id': Get.arguments['id']})
        .then((result) {
          goodsModel = PointsGoodsModel.fromJson(result.data['goods']);

          skuList = (result.data['skus'] as List<dynamic>)
              .map((item) => PointsGoodsSkuModel.fromJson(item))
              .toList();
          selectedSkuId = skuList.first.id;

          commentList = (result.data['comments'] as List<dynamic>)
              .map((item) => PointsGoodsCommentModel.fromJson(item))
              .toList();

          isIniting = false;
          update();
        });
  }
}
