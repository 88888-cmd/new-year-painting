import 'package:app/models/order_goods.dart';
import 'package:app/models/order_refund.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class OrderRefundDetailController extends GetxController {
  bool isIniting = true; // 是否初始化中

  late OrderRefundModel orderRefundModel;
  List<OrderGoodsModel> orderGoodsList = [];

  @override
  void onInit() {
    super.onInit();

    PageEventService.to.add('notice_order_refund_detail', (data) {
      loadData(id: data['id']);
    });
    loadData();
  }

  @override
  void onClose() {
    PageEventService.to.remove('notice_order_refund_detail', null);
    super.onClose();
  }

  void loadData({int? id}) {
    isIniting = true;
    update();

    HttpService.to
        .get(
          'orderRefund/detail',
          params: {'order_refund_id': id ?? Get.arguments['id']},
        )
        .then((result) {
          orderRefundModel = OrderRefundModel.fromJson(result.data['detail']);

          orderGoodsList = (result.data['order_goods_list'] as List<dynamic>)
              .map((item) => OrderGoodsModel.fromJson(item))
              .toList();

          isIniting = false;
          update();
        });
  }

  void clickCancel() {
    HttpService.to
        .post(
          'orderRefund/cancel',
          data: {'order_refund_id': orderRefundModel.id},
          showLoading: true,
        )
        .then((result) {
          loadData();
        });
  }
}
