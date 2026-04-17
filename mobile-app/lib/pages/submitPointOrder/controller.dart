import 'package:app/models/prepare_order_goods.dart';
import 'package:app/pages/myOrderList/view.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SubmitPointOrderController extends GetxController {
  bool isIniting = false;

  int addressId = 0;
  String addressName = '';
  String addressPhone = '';
  String addressContent = '';

  List<PrepareOrderGoodsModel> goodsList = [];

  int userNormalPoints = 0;
  int userCulturalPoints = 0;

  final TextEditingController useNormalPointsController = TextEditingController(
    text: '',
  );
  final TextEditingController useCulturalPointsController =
      TextEditingController(text: '');

  int get totalPoints {
    int points = 0;
    for (PrepareOrderGoodsModel goods in goodsList) {
      points += (goods.point_num * goods.buy_num);
    }
    return points;
  }

  double totalFreight = 0;

  @override
  void onInit() async {
    super.onInit();

    // useNormalPointsController.addListener(calculatePointsDiscount);

    loadData();
  }

  void loadData() {
    isIniting = true;
    update();

    HttpService.to
        .post(
          'order/prepareData',
          data: {
            'source': 'exchange',
            'address_id': addressId,
            'goods_id': Get.arguments['goods_id'],
            'goods_sku_id': Get.arguments['goods_sku_id'],
          },
        )
        .then((result) {
          userNormalPoints = int.parse(
            result.data['user_normal_points'].toString(),
          );
          userCulturalPoints = int.parse(
            result.data['user_cultural_points'].toString(),
          );

          goodsList = (result.data['goods_list'] as List<dynamic>)
              .map((item) => PrepareOrderGoodsModel.fromJson(item))
              .toList();

          totalFreight = double.parse(result.data['total_freight'].toString());

          isIniting = false;
          update();
        });
  }

  void clickSubmit() {
    if (addressId == 0) {
      EasyLoading.showError('请选择收货地址', maskType: EasyLoadingMaskType.none);
      return;
    }

    int useNormalPoints = int.parse(
      useNormalPointsController.text.isEmpty
          ? '0'
          : useNormalPointsController.text,
    );
    int useCulturalPoints = int.parse(
      useCulturalPointsController.text.isEmpty
          ? '0'
          : useCulturalPointsController.text,
    );

    if ((useNormalPoints + useCulturalPoints) > totalPoints) {
      EasyLoading.showError('请重新输入积分', maskType: EasyLoadingMaskType.none);
      return;
    }
    if ((useNormalPoints + useCulturalPoints) < totalPoints) {
      EasyLoading.showError('请重新输入积分', maskType: EasyLoadingMaskType.none);
      return;
    }

    HttpService.to
        .post(
          'order/exchange',
          data: {
            'address_id': addressId,
            'goods_id': Get.arguments['goods_id'],
            'goods_sku_id': Get.arguments['goods_sku_id'],
            'use_normal_points': useNormalPoints,
            'use_cultural_points': useCulturalPoints,
            'total_points': totalPoints,
            'pay_price': totalFreight,
          },
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('notice_profile', null);
          Get.off(MyOrderList());
        });
  }

  @override
  void onClose() {
    useNormalPointsController.dispose();
    useCulturalPointsController.dispose();
    super.onClose();
  }
}
