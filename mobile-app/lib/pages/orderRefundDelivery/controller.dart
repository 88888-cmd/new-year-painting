import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class OrderRefundDeliveryController extends GetxController {
  final TextEditingController expressNameController = TextEditingController(
    text: '',
  );
  final TextEditingController expressNoController = TextEditingController(
    text: '',
  );

  void clickSubmit() {
    String express_name = expressNameController.text.trim();
    String express_no = expressNoController.text.trim();
    if (express_name.isEmpty) {
      EasyLoading.showToast('Input Express Name');
      return;
    }
    if (express_no.isEmpty) {
      EasyLoading.showToast('Input Express No');
      return;
    }
    HttpService.to
        .post(
          'orderRefund/submitExpress',
          data: {
            'order_refund_id': Get.arguments['order_refund_id'],
            'express_name': express_name,
            'express_no': express_no,
          },
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('notice_order_refund_detail', null);

          Get.back();
        });
  }

  @override
  void onClose() {
    expressNameController.dispose();
    expressNoController.dispose();
    super.onClose();
  }
}
