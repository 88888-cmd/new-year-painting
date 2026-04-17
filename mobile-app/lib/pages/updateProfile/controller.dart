import 'package:app/i18n/index.dart';
import 'package:app/models/file.dart';
import 'package:app/models/user.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UpdateProfileController extends GetxController {
  UploadFileModel? avatar;
  final TextEditingController nicknameController = TextEditingController(
    text: '',
  );
  DateTime? selectedDate;
  int gender = 0;
  final TextEditingController professionController = TextEditingController(
    text: '',
  );

  @override
  void onInit() {
    super.onInit();

    HttpService.to.get('profile', showLoading: true).then((result) {
      UserModel userModel = UserModel.fromJson(result.data);
      if (userModel.avatar_url.isNotEmpty) {
        avatar = UploadFileModel.fromJson({
          'id': userModel.avatar_file_id,
          'file_url': userModel.avatar_url,
        });
      }
      nicknameController.text = userModel.nickname;
      selectedDate = DateFormat('yyyy-M-d').parse(userModel.birthday);
      gender = userModel.gender;
      professionController.text = userModel.profession;
      update();
    });
  }

  void upload(XFile xfile) async {
    HttpService.to
        .upload('file/upload', path: xfile.path, showLoading: true)
        .then((result) {
          avatar = UploadFileModel.fromJson(result.data);
          update();
        });
  }

  void clickSubmit() {
    String nickname = nicknameController.text.trim();
    String profession = professionController.text.trim();
    if (avatar == null) {
      EasyLoading.showToast(LocaleKeys.upload_avatar.tr);
      return;
    }
    if (nickname.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_nickname.tr);
      return;
    }
    if (selectedDate == null) {
      EasyLoading.showToast(LocaleKeys.select_date.tr);
      return;
    }
    // if (profession.isEmpty) {
    //   EasyLoading.showToast('Input profession');
    //   return;
    // }

    HttpService.to
        .post(
          'updateProfile',
          data: {
            'image_id': avatar!.id,
            'nickname': nickname,
            'birthday':
                '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
            'gender': gender,
            'profession': profession,
          },
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('notice_profile', null);

          Get.back();
        });
  }

  @override
  void onClose() {
    nicknameController.dispose();
    professionController.dispose();
    super.onClose();
  }
}
