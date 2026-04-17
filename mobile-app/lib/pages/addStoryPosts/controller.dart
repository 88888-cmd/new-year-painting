import 'package:app/i18n/index.dart';
import 'package:app/models/file.dart';
import 'package:app/models/response.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_cover/video_cover.dart';
import 'package:video_cover/video_cover_platform_interface.dart';

class AddStoryPostController extends GetxController {
  final TextEditingController titleController = TextEditingController(text: '');
  final TextEditingController contentController = TextEditingController(
    text: '',
  );
  int paintingId = 0;
  String paintingImageUrl = '';
  String paintingName = '';
  String paintingAuthor = '';

  UploadFileModel? uploadVideoModel;
  UploadFileModel? uploadVideoCoverModel;
  // String videoUrl = '';
  // String videoCoverUrl = '';

  @override
  void onInit() {
    super.onInit();

    paintingId = Get.arguments['id'];
    paintingImageUrl = Get.arguments['image_url'];
    paintingName = Get.arguments['name'];
    paintingAuthor = Get.arguments['author'];
  }

  void clickSubmit() {
    String title = titleController.text.trim();
    String content = contentController.text.trim();
    if (title.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_title.tr);
      return;
    }
    if (content.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_content.tr);
      return;
    }
    if (paintingId == 0) {
      EasyLoading.showToast(LocaleKeys.select_painting.tr);
      return;
    }

    HttpService.to
        .post(
          'posts/publish',
          data: {
            'post_type': 20,
            'category_id': 2,
            'title': title,
            'content': content,
            'video_id': uploadVideoModel?.id ?? 0,
            'video_cover_id': uploadVideoCoverModel?.id ?? 0,
            'painting_id': paintingId,
          },
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('created_post', null);

          Get.back();
        });
  }

  void upload(XFile xfile) async {
    EasyLoading.show(status: 'Loading...');

    try {
      ResponseModel videoUploadResult = await HttpService.to.upload(
        'file/upload',
        path: xfile.path,
      );

      // 上传视频成功，获取视频封面图片
      String? thumbnailPath = await VideoCover.thumbnailFile(
        video: xfile.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 512,
        quality: 75,
        timeMs: 1000,
      );

      if (thumbnailPath != null) {
        // 生成视频封面图片成功

        // 上传视频封面图片
        ResponseModel thumbnailUploadResult = await HttpService.to.upload(
          'file/upload',
          path: thumbnailPath,
        );
        uploadVideoModel = UploadFileModel.fromJson(videoUploadResult.data);
        uploadVideoCoverModel = UploadFileModel.fromJson(thumbnailUploadResult.data);

        // videoUrl = videoUploadResult.data['file_url'];

        // 上传视频封面图片成功
        // videoCoverUrl = thumbnailUploadResult.data['file_url'];

        update();

        EasyLoading.dismiss();
      } else {
        // 生成视频封面图片失败

        EasyLoading.dismiss();

        EasyLoading.showError('Upload Error');
      }
    } catch (e) {
      // EasyLoading.showError('Upload Error');
    }
  }
}
