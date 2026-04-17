import 'package:app/i18n/index.dart';
import 'package:app/pages/changePassword/controller.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
      init: ChangePasswordController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('编辑资料'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInputField(
                controller: controller.oldPasswordController,
                label: '旧密码',
                hintText: '请输入旧密码',
              ),
              SizedBox(height: 15),
              _buildInputField(
                controller: controller.newPasswordController,
                label: '新密码',
                hintText: '请输入新密码',
              ),
              SizedBox(height: 15),
              _buildInputField(
                controller: controller.rePasswordController,
                label: '重复新密码',
                hintText: '请再次输入新密码',
              ),

              SizedBox(height: 40),
              PrimaryButton(
                width: double.infinity,
                title: LocaleKeys.confirm.tr,
                onPressed: () {
                  controller.clickSubmit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF654941),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          obscureText: true,
          style: const TextStyle(color: Color(0xFF654941), fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9DA4B0), fontSize: 15),
            fillColor: Colors.white,
            filled: true,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 1, color: Color(0xFFd7ccc8)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 1, color: Color(0xFF8d6e63)),
            ),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
