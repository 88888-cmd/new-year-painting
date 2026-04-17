import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentOrderGoodsController extends GetxController {
  int starCount = 5;
  final TextEditingController contentController = TextEditingController(
    text: '',
  );

  @override
  void onInit() {
    super.onInit();
  }

  void clickSubmit() {
    String content = contentController.text.trim();
    HttpService.to
        .post(
          'order/commentGoods',
          data: {
            'order_id': Get.arguments['order_id'],
            'order_goods_id': Get.arguments['order_goods_id'],
            'star_num': starCount,
            'content': content,
          },
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('notice_order', {
            'id': Get.arguments['order_id'],
          });

          Get.back();
        });
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
