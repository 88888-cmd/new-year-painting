import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController oldPasswordController = TextEditingController(
    text: '',
  );
  final TextEditingController newPasswordController = TextEditingController(
    text: '',
  );
  final TextEditingController rePasswordController = TextEditingController(
    text: '',
  );

  void clickSubmit() {
    String oldPassword = oldPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String rePassword = rePasswordController.text.trim();
    if (oldPassword.isEmpty) {
      EasyLoading.showToast('Input old password');
      return;
    }
    if (newPassword.isEmpty) {
      EasyLoading.showToast('Input new password');
      return;
    }
    if (rePassword != newPassword) {
      EasyLoading.showToast('两次输入密码不一致');
      return;
    }

    HttpService.to
        .post(
          'changePassword',
          data: {'old_password': oldPassword, 'new_password': newPassword},
          showLoading: true,
        )
        .then((result) async {
          Get.back();
        });
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    rePasswordController.dispose();
    super.onClose();
  }
}
