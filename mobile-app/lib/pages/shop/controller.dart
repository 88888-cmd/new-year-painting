import 'package:app/i18n/index.dart';
import 'package:app/models/goods.dart';
import 'package:app/models/goods_category.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class ShopController extends GetxController {
  bool isIniting = true; // 是否初始化中

  List<GoodsCategoryModel> categoryList = [];
  int selectedCategoryId = 0;

  List<GoodsModel> list = [];
  int data_v = 1;

  int cartBadge = 0;

  @override
  void onInit() {
    super.onInit();

    HttpService.to
        .get('goods/getCategoryList')
        .then((result) {
          categoryList =
              (result.data as List<dynamic>)
                  .map((item) => GoodsCategoryModel.fromJson(item))
                  .toList();

          return HttpService.to.get('goods/getList');
        })
        .then((result) {
          list.addAll(
            (result.data['goods_list'] as List<dynamic>)
                .map((item) => GoodsModel.fromJson(item))
                .toList(),
          );

          isIniting = false;

          update();

          updateCartBadge();
        });
  }

  void loadList() {
    list.clear();
    data_v++;
    update();

    HttpService.to
        .get(
          'goods/getList',
          params: {'category_id': selectedCategoryId, 'data_v': data_v},
        )
        .then((result) {
          if (data_v == result.data['data_v']) {
            list.addAll(
              (result.data['goods_list'] as List<dynamic>)
                  .map((item) => GoodsModel.fromJson(item))
                  .toList(),
            );
            update();
          }
        });
  }

  void updateCartBadge() {
    HttpService.to.get('cart/getBadge').then((result) {
      cartBadge = int.parse(result.data.toString());
      update();
    });
  }
}
