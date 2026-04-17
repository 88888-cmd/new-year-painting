import 'package:app/i18n/index.dart';
import 'package:app/pages/register/controller.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      init: RegisterController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.register.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
              SizedBox(height: 15),
              TextField(
                controller: controller.rePasswordController,
                maxLength: 200,
                obscureText: true,
                style: const TextStyle(color: Color(0xFF654941), fontSize: 15),
                decoration: InputDecoration(
                  hintText: LocaleKeys.reenter_password.tr,
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
                title: LocaleKeys.register.tr,
                onPressed: () {
                  // Get.toNamed(Routes.main);
                  controller.clickRegister();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
