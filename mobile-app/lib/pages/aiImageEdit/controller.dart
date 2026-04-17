import 'package:app/models/file.dart';
import 'package:app/services/http.dart';
import 'package:app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AIImageEditController extends GetxController {
  UploadFileModel? uploadFileModel;
  int imageedit_type = 10;
  String generateResult = '';

  void clickGenerate() {
    if (uploadFileModel == null) return;

    HttpService.to
        .post(
          'ai/imageedit',
          data: {
            'imageedit_type': imageedit_type,
            'image_id': uploadFileModel!.id,
          },
          options: Options(
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
          ),
          showLoading: true,
        )
        .then((result) {
          generateResult = Constants.mediaBaseUrl + result.data['image_url'];
          update();
        });
  }

  void upload(XFile xfile) async {
    HttpService.to
        .upload('file/upload', path: xfile.path, showLoading: true)
        .then((result) {
          uploadFileModel = UploadFileModel.fromJson(result.data);
          update();
        });
  }
}
