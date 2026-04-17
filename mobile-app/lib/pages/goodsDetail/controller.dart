import 'package:app/models/goods.dart';
import 'package:app/models/goods_comment.dart';
import 'package:app/models/goods_sku.dart';
import 'package:app/services/http.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class GoodsDetailController extends GetxController {
  bool isIniting = true; // 是否初始化中

  late GoodsModel goodsModel;
  List<GoodsSkuModel> skuList = [];

  int selectedSkuId = 0;
  GoodsSkuModel get selectedSku {
    return skuList.firstWhereOrNull((o) => o.id == selectedSkuId)!;
  }

  List<GoodsCommentModel> commentList = [];

  @override
  void onInit() {
    super.onInit();

    isIniting = true;

    HttpService.to
        .get('goods/detail', params: {'goods_id': Get.arguments['id']})
        .then((result) {
          goodsModel = GoodsModel.fromJson(result.data['goods']);

          skuList = (result.data['skus'] as List<dynamic>)
              .map((item) => GoodsSkuModel.fromJson(item))
              .toList();
          selectedSkuId = skuList.first.id;

          commentList = (result.data['comments'] as List<dynamic>)
              .map((item) => GoodsCommentModel.fromJson(item))
              .toList();

          isIniting = false;
          update();
        });
  }

  void clickAddToCart({required int skuId ,required int buyNum}) {
    HttpService.to
        .post(
          'cart/addToCart',
          data: {
            'goods_id': goodsModel.id,
            'goods_sku_id': skuId,
            'buy_num': buyNum
          },
          showLoading: true,
        )
        .then((result) {
          EasyLoading.showSuccess('加入成功', maskType: EasyLoadingMaskType.none);

          update();
        });
  }
}
