import 'package:app/i18n/index.dart';
import 'package:app/models/coupon.dart';
import 'package:app/services/http.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class CouponController extends GetxController {
  bool isIniting = true; // 是否初始化中

  List<CouponModel> list = [];

  // 金额最高的优惠券
  CouponModel? highestCoupon;

  @override
  void onInit() {
    super.onInit();

    isIniting = true;

    HttpService.to.get('coupon/getList').then((result) {
      list = (result.data as List<dynamic>)
          .map((item) => CouponModel.fromJson(item))
          .toList();

      if (list.isNotEmpty) {
        highestCoupon = list[0];
        for (var coupon in list) {
          if (coupon.reducePrice > highestCoupon!.reducePrice) {
            highestCoupon = coupon;
          }
        }
      }

      isIniting = false;

      update();
    });
  }

  void receive(int id) {
    HttpService.to
        .post('coupon/receive', data: {'coupon_id': id}, showLoading: true)
        .then((result) {
          EasyLoading.showSuccess(LocaleKeys.receive_success.tr);
          update();
        });
  }
}
