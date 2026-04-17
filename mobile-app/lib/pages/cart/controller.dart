import 'package:app/models/cart.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:app/services/storage.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  bool isIniting = true; // 是否初始化中

  List<CartModel> list = [];

  Map<String, bool> selectedItems = {};

  bool isSelectedAll = false; // 是否全选

  // 选中的商品的总金额
  double get selectedTotalPrice {
    double total = 0;
    for (CartModel item in list) {
      String key = '${item.goods_id}_${item.goods_sku_id}';
      if (selectedItems[key] ?? false) {
        total += item.sku.price * item.buy_num;
      }
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();

    PageEventService.to.add('notice_cart_list', (data) {
      loadData();
    });

    loadData();
  }

  @override
  void onClose() {
    PageEventService.to.remove('notice_cart_list', null);
    super.onClose();
  }

  void loadData() {
    isIniting = true;
    update();

    HttpService.to.get('cart/getList').then((result) {
      list = (result.data as List<dynamic>)
          .map((item) => CartModel.fromJson(item))
          .toList();

      loadSelectedState();

      isIniting = false;
      update();
    });
  }

  void increaseItemCount(int goodsId, int skuId) {
    HttpService.to
        .post(
          'cart/addToCart',
          data: {'goods_id': goodsId, 'goods_sku_id': skuId},
          showLoading: true,
        )
        .then((result) {
          int index = list.indexWhere(
            (item) => item.goods_id == goodsId && item.goods_sku_id == skuId,
          );
          list[index].buy_num++;
          update();
        });
  }

  void decreaseItemCount(int goodsId, int skuId) {
    HttpService.to
        .post(
          'cart/deleteItem',
          data: {'goods_id': goodsId, 'goods_sku_id': skuId},
          showLoading: true,
        )
        .then((result) {
          int index = list.indexWhere(
            (item) => item.goods_id == goodsId && item.goods_sku_id == skuId,
          );
          if ((list[index].buy_num - 1) <= 0) {
            list.removeAt(index);
          } else {
            list[index].buy_num--;
          }
          update();
        });
  }

  // 从缓存中加载选中状态
  void loadSelectedState() async {
    StorageService storage = StorageService.to;
    isSelectedAll = storage.getBool('cart_select_all');

    for (CartModel item in list) {
      String key = '${item.goods_id}_${item.goods_sku_id}';
      selectedItems[key] = storage.getBool(key);
    }
  }

  // 保存选中状态
  void saveSelectedState() async {
    StorageService storage = StorageService.to;
    await storage.setBool('cart_select_all', isSelectedAll);

    for (final entry in selectedItems.entries) {
      await storage.setBool(entry.key, entry.value);
    }
  }

  void toggleItemSelect(int goodsId, int skuId) {
    String key = '${goodsId}_${skuId}';
    selectedItems[key] = !(selectedItems[key] ?? true);
    updateAllSelectStatus();
    saveSelectedState();
    update();
  }

  void toggleAllSelect() {
    isSelectedAll = !isSelectedAll;
    for (CartModel item in list) {
      String key = '${item.goods_id}_${item.goods_sku_id}';
      selectedItems[key] = isSelectedAll;
    }
    saveSelectedState();
    update();
  }

  void updateAllSelectStatus() {
    if (list.isEmpty) {
      isSelectedAll = false;
      return;
    }
    isSelectedAll = list.every(
      (item) => selectedItems['${item.goods_id}_${item.goods_sku_id}'] ?? false,
    );
  }

  // 获取选中item的购物车ID列表
  String getSelectedIds() {
    return list
        .where((item) {
          String key = '${item.goods_id}_${item.goods_sku_id}';
          return selectedItems[key] ?? false;
        })
        .map((item) => item.id)
        .join(',');
  }
}
