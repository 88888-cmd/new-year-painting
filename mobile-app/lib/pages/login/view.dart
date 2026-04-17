import 'package:app/i18n/index.dart';
import 'package:app/pages/login/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      builder: (controller) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '年画艺术',
                style: TextStyle(
                  color: Color(0xFF654941),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '传承民间艺术·连接当代生活',
                style: TextStyle(color: Color(0xFF654941), fontSize: 13),
              ),
              SizedBox(height: 45),

              TextField(
                controller: controller.usernameController,
                maxLength: 200,
                style: const TextStyle(color: Color(0xFF654941), fontSize: 15),
                decoration: InputDecoration(
                  hintText: LocaleKeys.enter_phone_or_email.tr,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9DA4B0),
                    fontSize: 15,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      width: 1,
                      color: const Color(0xFFd7ccc8),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      width: 1,
                      color: const Color(0xFF8d6e63),
                    ),
                  ),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
                  ),
                  counterText: '',
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: controller.passwordController,
                maxLength: 200,
                obscureText: true,
                style: const TextStyle(color: Color(0xFF654941), fontSize: 15),
                decoration: InputDecoration(
                  hintText: LocaleKeys.enter_password.tr,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9DA4B0),
                    fontSize: 15,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      width: 1,
                      color: const Color(0xFFd7ccc8),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      width: 1,
                      color: const Color(0xFF8d6e63),
                    ),
                  ),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
                  ),
                  counterText: '',
                ),
              ),
              SizedBox(height: 20),
              PrimaryButton(
                width: double.infinity,
                // gbColor: Colors.grey.withOpacity(0.6),
                title: LocaleKeys.login.tr,
                onPressed: () {
                  // Get.toNamed(Routes.main);
                  controller.loginClick();
                },
              ),
              SizedBox(height: 15),
              PrimaryButton(
                width: double.infinity,
                title: LocaleKeys.register.tr,
                fontColor: const Color(0xFF8d6e63),
                gbColor: Theme.of(context).scaffoldBackgroundColor,
                onPressed: () {
                  Get.toNamed(Routes.register);
                },
              ),
              // SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     Text(
              //       '忘记密码？',
              //       style: TextStyle(color: Color(0xFF654941), fontSize: 13),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
