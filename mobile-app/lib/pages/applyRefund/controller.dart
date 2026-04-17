import 'package:app/models/file.dart';
import 'package:app/models/posts_category.dart';
import 'package:app/models/response.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ApplyRefundController extends GetxController {
  int orderId = 0;
  int orderGoodsId = 0;
  int orderType = 0;
  int orderStatus = 0;

  int refund_type = 1;
  final TextEditingController descController = TextEditingController(text: '');
  List<UploadFileModel> imageList = [];

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments['order_id'];
    orderGoodsId = Get.arguments['order_goods_id'] ?? 0;
    orderType = Get.arguments['order_type'];
    orderStatus = Get.arguments['order_status'];
  }

  void clickSubmit() {
    String desc = descController.text.trim();
    HttpService.to
        .post(
          'orderRefund/apply',
          data: {
            'order_id': orderId,
            'order_goods_id': orderGoodsId,
            'refund_type': refund_type,
            'apply_desc': desc,
            'file_ids': imageList.map((item) => item.id).toList(),
          },
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('notice_order', {
            'id': orderId
          });

          Get.back();
        });
  }

  void upload(List<XFile> xfileList) async {
    EasyLoading.show(status: 'Loading...');

    List<UploadFileModel> uploadedList = [];
    for (XFile xFile in xfileList) {
      try {
        ResponseModel result = await HttpService.to.upload(
          'file/upload',
          path: xFile.path,
        );
        uploadedList.add(UploadFileModel.fromJson(result.data));
      } catch (error) {
        print(error);
        break;
      }
    }

    if (uploadedList.length == xfileList.length) {
      imageList.addAll(uploadedList);
    }

    update();
    EasyLoading.dismiss();
  }

  @override
  void onClose() {
    descController.dispose();
    super.onClose();
  }
}
