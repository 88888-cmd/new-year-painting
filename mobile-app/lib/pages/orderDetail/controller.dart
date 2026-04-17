import 'package:app/models/order.dart';
import 'package:app/models/order_address.dart';
import 'package:app/models/order_goods.dart';
import 'package:app/models/order_wuliu.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class OrderDetailController extends GetxController {
  bool isIniting = true; // 是否初始化中

  late OrderModel orderModel;
  late OrderAddressModel orderAddressModel;
  List<OrderGoodsModel> orderGoodsList = [];
  List<OrderWuliuModel> wuliuList = [];

  @override
  void onInit() {
    super.onInit();

    PageEventService.to.add('notice_order', (data) {
      loadData(id: data['id']);
    });
    loadData();
  }

  @override
  void onClose() {
    PageEventService.to.remove('notice_order', null);
    super.onClose();
  }

  void loadData({int? id}) {
    isIniting = true;
    update();

    HttpService.to
        .get('order/detail', params: {'order_id': id ?? Get.arguments['id']})
        .then((result) {
          orderModel = OrderModel.fromJson(result.data['order']);

          orderAddressModel = OrderAddressModel.fromJson(
            result.data['address'],
          );

          orderGoodsList = (result.data['order_goods_list'] as List<dynamic>)
              .map((item) => OrderGoodsModel.fromJson(item))
              .toList();

          wuliuList = (result.data['wuliu'] as List<dynamic>)
              .map((item) => OrderWuliuModel.fromJson(item))
              .toList();

          isIniting = false;
          update();
        });
  }

  void clickReceipt() {
    HttpService.to
        .post(
          'order/receive',
          data: {'order_id': orderModel.id},
          showLoading: true,
        )
        .then((result) {
          loadData(id: orderModel.id);
        });
  }
}
