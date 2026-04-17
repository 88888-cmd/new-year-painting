import 'package:app/i18n/index.dart';
import 'package:app/models/posts_category.dart';
import 'package:app/models/response.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddPostsController extends GetxController {
  List<PostsCategoryModel> categoryList = [];
  int selectedCategoryId = 0;

  final TextEditingController titleController = TextEditingController(text: '');
  final TextEditingController contentController = TextEditingController(
    text: '',
  );

  List<String> imageList = [];
  // List<UploadFileModel> imageList = [];
  List<String> selectedTags = [];

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments['title'] != null) {
      titleController.text = Get.arguments['title'];
    }
    if (Get.arguments['content'] != null) {
      contentController.text = Get.arguments['content'];
    }
    if (Get.arguments['image_urls'] != null) {
      imageList.addAll(Get.arguments['image_urls']);
    }

    if (Get.arguments['from_category_id'] != 1) {
      HttpService.to.get('posts/getCategoryList').then((result) {
        categoryList = (result.data as List<dynamic>)
            .map((item) => PostsCategoryModel.fromJson(item))
            .where((category) => category.id != 1 && category.id != 2)
            .toList();

        if (categoryList.isNotEmpty) {
          selectedCategoryId = categoryList[0].id;
        }

        update();
      });
    } else {
      selectedCategoryId = int.parse(
        Get.arguments['from_category_id'].toString(),
      );
    }
  }

  void clickSubmit() {
    String title = titleController.text.trim();
    String content = contentController.text.trim();
    if (title.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_title.tr);
      return;
    }
    // if (content.isEmpty) {
    //   EasyLoading.showToast('Input content');
    //   return;
    // }
    HttpService.to
        .post(
          'posts/publish',
          data: {
            'post_type': 10,
            'title': title,
            'content': content,
            'category_id': selectedCategoryId,
            // 'file_ids': imageList.map((item) => item.id).toList(),
            'image_urls': imageList.toList(),
            'tags': selectedTags.toList(),
          },
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('created_post', null);

          Get.back();
        });
  }

  void upload(List<XFile> xfileList) async {
    EasyLoading.show(status: 'Loading...');

    List<String> uploadedList = [];
    for (XFile xFile in xfileList) {
      try {
        ResponseModel result = await HttpService.to.upload(
          'file/upload',
          path: xFile.path,
        );
        uploadedList.add(result.data['file_url']);
        // imgUrlList.add(result.data['file_url']);
        // imgUrlList.add(Constants.mediaBaseUrl + result.data['file_url']);
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

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      if (selectedTags.length < 4) {
        selectedTags.add(tag);
      } else {
        EasyLoading.showToast('最多只能选择4个标签');
      }
    }
    update();
  }

  bool isTagSelected(String tag) {
    return selectedTags.contains(tag);
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
