import 'package:app/models/file.dart';
import 'package:app/models/response.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SearchPaintingController extends GetxController {
  final TextEditingController textController = TextEditingController(text: '');

  @override
  void onInit() {
    super.onInit();
  }

  void uploadVoice(String path) async {
    EasyLoading.show(status: 'Loading...');

    try {
      ResponseModel result = await HttpService.to.upload(
        'file/upload',
        path: path,
      );
      UploadFileModel uploadFileModel = UploadFileModel.fromJson(result.data);
      print(uploadFileModel.file_url);

      ResponseModel voiceToTextResult = await HttpService.to.post(
        'ai/voiceToText',
        data: {'file_id': uploadFileModel.id},
      );
      textController.text = voiceToTextResult.data;

      EasyLoading.dismiss();
    } catch (e) {}
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
