import 'package:app/i18n/index.dart';
import 'package:app/routes/routes.dart';
import 'package:app/store/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(LocaleKeys.setting.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildMenuItem(LocaleKeys.update_profile.tr, () {
                Get.toNamed(Routes.updateProfile);
              }),
              buildMenuItem(LocaleKeys.change_password.tr, () {
                Get.toNamed(Routes.changePassword);
              }),
              buildMenuItem(LocaleKeys.language.tr, () {
                Get.toNamed(Routes.language);
              }),
              buildMenuItem(LocaleKeys.logout.tr, () {
                UserStore.to.logout();
                Get.offAllNamed(Routes.login);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, GestureTapCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF5d4037), fontSize: 15),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
