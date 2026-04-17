import 'package:app/i18n/index.dart';
import 'package:app/models/painting.dart';
import 'package:app/models/painting_summary.dart';
import 'package:app/services/http.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SubmitWishController extends GetxController {
  int wishType = 0;

  List<PaintingSummaryModel> randomPaintingList = [];

  int paintingId = 0;
  String paintingImageUrl = '';
  String paintingName = '';

  final TextEditingController contentController = TextEditingController(
    text: '',
  );

  @override
  void onInit() {
    super.onInit();

    wishType = Get.arguments['type'];

    HttpService.to.get('wish/getPaintingList').then((result) {
      randomPaintingList = (result.data as List<dynamic>)
          .map((item) => PaintingSummaryModel.fromJson(item))
          .toList();
      update();
    });
  }

  void updateSelectedPainting({
    required int id,
    required String imageUrl,
    required String name,
  }) {
    if (!randomPaintingList.any((item) => item.id == id)) {
      randomPaintingList.insert(
        0,
        PaintingSummaryModel.fromJson({
          'id': id,
          'image_url': imageUrl,
          'name': name,
        }),
      );
    }
    paintingId = id;
    paintingImageUrl = imageUrl;
    paintingName = name;
    update();
  }

  void clickSubmit() {
    String content = contentController.text.trim();
    if (content.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_content.tr);
      return;
    }
    HttpService.to
        .post(
          'wish/submit',
          data: {
            'wish_type': wishType,
            'painting_id': paintingId,
            'content': content,
          },
          showLoading: true,
        )
        .then((result) {
          Get.back();
        });
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
