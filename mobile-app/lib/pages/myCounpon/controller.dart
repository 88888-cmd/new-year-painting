import 'package:app/models/user_coupon.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class MyCouponController extends GetxController {
  List<UserCouponModel> list = [];

  @override
  void onInit() {
    super.onInit();

    HttpService.to.get('coupon/getMyList').then((result) {
      list = (result.data as List<dynamic>)
          .map((item) => UserCouponModel.fromJson(item))
          .toList();

      update();
    });
  }
}
