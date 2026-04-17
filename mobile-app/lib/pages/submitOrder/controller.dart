import 'package:app/extension/decimalExtension.dart';
import 'package:app/models/prepare_order_goods.dart';
import 'package:app/models/user_coupon.dart';
import 'package:app/pages/myOrderList/view.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:decimal/decimal.dart';

class SubmitOrderController extends GetxController {
  bool isIniting = false;

  int addressId = 0;
  String addressName = '';
  String addressPhone = '';
  String addressContent = '';

  List<PrepareOrderGoodsModel> goodsList = [];

  List<UserCouponModel> coupons = [];
  UserCouponModel? selectedCoupon;
  int tempSelectedCouponId = 0;

  int userNormalPoints = 0;
  int userCulturalPoints = 0;
  double normalPointsPerYuan = 0;

  final TextEditingController useNormalPointsController = TextEditingController(
    text: '',
  );

  double get totalPrice {
    double price = 0;
    for (PrepareOrderGoodsModel item in goodsList) {
      price += item.sku_price * item.buy_num;
    }
    return price;
  }

  double totalFreight = 0;
  double get couponDeduct {
    return selectedCoupon?.reduce_price ?? 0;
  }

  double pointsDeduct = 0;
  double get payPrice {
    final total = Decimal.parse(totalPrice.toString());
    final freight = Decimal.parse(totalFreight.toString());
    final coupon = Decimal.parse(couponDeduct.toString());
    final points = Decimal.parse(pointsDeduct.toString());

    return (total + freight - coupon - points).toDoubleAsFixed(2);
  }

  @override
  void onInit() async {
    super.onInit();

    useNormalPointsController.addListener(calculatePointsDeduct);

    loadData();
  }

  void loadData() {
    isIniting = true;
    update();

    final args = Get.arguments;
    final requestData = {'source': args['source'], 'address_id': addressId};

    if (args['source'] == 'cart') {
      if (args['cart_ids'] != null) requestData['cart_ids'] = args['cart_ids'];
    } else {
      if (args['goods_id'] != null) requestData['goods_id'] = args['goods_id'];
      if (args['goods_sku_id'] != null) {
        requestData['goods_sku_id'] = args['goods_sku_id'];
      }
      if (args['buy_num'] != null) {
        requestData['buy_num'] = args['buy_num'];
      }
    }
    print(requestData);

    HttpService.to.post('order/prepareData', data: requestData).then((result) {
      userNormalPoints = int.parse(
        result.data['user_normal_points'].toString(),
      );
      userCulturalPoints = int.parse(
        result.data['user_cultural_points'].toString(),
      );

      normalPointsPerYuan = double.parse(
        result.data['normal_points_per_yuan'].toString(),
      );

      goodsList = (result.data['goods_list'] as List<dynamic>)
          .map((item) => PrepareOrderGoodsModel.fromJson(item))
          .toList();

      coupons = (result.data['user_coupons'] as List<dynamic>)
          .map((item) => UserCouponModel.fromJson(item))
          .toList();

      totalFreight = double.parse(result.data['total_freight'].toString());

      isIniting = false;
      update();
    });
  }

  void clickSelectCoupon(UserCouponModel? userCouponModel) {
    selectedCoupon = userCouponModel;
    calculatePointsDeduct();
    ();
    update();
  }

  void calculatePointsDeduct() {
    if (normalPointsPerYuan <= 0) {
      pointsDeduct = 0;
      update();
      return;
    }

    int usePoints;
    try {
      usePoints = int.parse(
        useNormalPointsController.text.isEmpty
            ? '0'
            : useNormalPointsController.text,
      );
    } catch (e) {
      usePoints = 0;
    }

    // if (usePoints > userNormalPoints) {
    //   useNormalPointsController.text = userNormalPoints.toString();
    //   usePoints = userNormalPoints;
    // }

    final pointsDecimal = Decimal.fromInt(usePoints);
    final valuePerPoint = Decimal.parse(normalPointsPerYuan.toString());
    // 计算抵扣金额（积分数量 * 1积分可抵扣金额）
    Decimal discount = pointsDecimal * valuePerPoint;

    // 校验抵扣金额是否超过可抵扣上限（商品总金额 - 优惠券抵扣）
    final maxDiscount = Decimal.parse(
      (totalPrice + totalFreight - couponDeduct).toString(),
    );
    if (discount > maxDiscount) {
      discount = maxDiscount;
      int maxPoints = (discount / valuePerPoint).toBigInt().toInt();
      useNormalPointsController.text = maxPoints.toString();
    }

    pointsDeduct = discount.toDoubleAsFixed(2);
    update();
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

    if (Get.arguments['source'] == 'buy_now') {
      HttpService.to
          .post(
            'order/buyNow',
            data: {
              'address_id': addressId,
              'goods_id': Get.arguments['goods_id'],
              'goods_sku_id': Get.arguments['goods_sku_id'],
              'coupon_id': selectedCoupon?.id ?? 0,
              'use_normal_points': useNormalPoints,
              'pay_price': payPrice,
            },
            showLoading: true,
          )
          .then((result) {
            PageEventService.to.post('notice_profile', null);
            Get.off(MyOrderList());
          });
    } else if (Get.arguments['source'] == 'cart') {
      HttpService.to
          .post(
            'order/cart',
            data: {
              'address_id': addressId,
              'cart_ids': Get.arguments['cart_ids'],
              'coupon_id': selectedCoupon?.id ?? 0,
              'use_normal_points': useNormalPoints,
              'pay_price': payPrice,
            },
            showLoading: true,
          )
          .then((result) {
            PageEventService.to.post('notice_cart_list', null);
            PageEventService.to.post('notice_profile', null);
            Get.off(MyOrderList());
          });
    }
  }

  @override
  void onClose() {
    useNormalPointsController.removeListener(calculatePointsDeduct);
    useNormalPointsController.dispose();
    super.onClose();
  }
}
