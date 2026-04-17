import 'package:app/i18n/index.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/http.dart';
import 'package:app/store/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController(
    text: '',
  );
  final TextEditingController passwordController = TextEditingController(
    text: '',
  );

  void loginClick() {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    if (username.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_phone_or_email.tr);
      return;
    }
    if (password.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_password.tr);
      return;
    }

    HttpService.to
        .post(
          'login',
          data: {
            if (username.isEmpty) 'email': username else 'phone': username,
            'password': password,
          },
          showLoading: true,
        )
        .then((result) async {
          await Future.wait([
            UserStore.to.setId(result.data['id']),
            UserStore.to.setToken(result.data['token']),
          ]);

          Get.offAllNamed(Routes.main);
        });
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
