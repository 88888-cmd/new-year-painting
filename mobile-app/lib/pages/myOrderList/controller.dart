import 'package:app/i18n/index.dart';
import 'package:app/models/order.dart';
import 'package:app/models/order_refund.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyOrderController extends GetxController
    with GetSingleTickerProviderStateMixin {
  bool isIniting = true; // 是否初始化中

  late TabController tabController;

  List<OrderModel> orderList = [];
  int order_v = 1;

  List<OrderRefundModel> refundList = [];
  int refund_v = 1;

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: 5, vsync: this)
      ..addListener(() {
        if (!tabController.indexIsChanging) {
          if ([0, 1, 2, 3].contains(tabController.index)) {
            loadList(tabController.index);
          } else {
            loadRefundList();
          }
        }
      });

    loadList(0);
  }

  void loadList(int status) {
    orderList.clear();
    order_v++;

    update();

    HttpService.to
        .get('order/getList', params: {'status': status, 'data_v': order_v})
        .then((result) {
          if (order_v == result.data['data_v']) {
            orderList.addAll(
              (result.data['list'] as List<dynamic>)
                  .map((item) => OrderModel.fromJson(item))
                  .toList(),
            );
            update();
          }
        });
  }

  void loadRefundList() {
    refundList.clear();
    refund_v++;

    update();

    HttpService.to
        .get('orderRefund/getList', params: {'data_v': refund_v})
        .then((result) {
          if (order_v == result.data['data_v']) {
            refundList.addAll(
              (result.data['list'] as List<dynamic>)
                  .map((item) => OrderRefundModel.fromJson(item))
                  .toList(),
            );
            update();
          }
        });
  }
}
