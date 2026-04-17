import 'package:app/i18n/index.dart';
import 'package:app/services/storage.dart';
import 'package:app/store/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    String savedLanguage = StorageService.to.getString('setting_language');
    if (savedLanguage.isEmpty) {
      savedLanguage = 'zh_CN';
    }
    _selectedLanguage = savedLanguage;
    // _selectedLanguage = Get.locale?.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(LocaleKeys.language.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLanguageItem('简体中文', 'zh_CN', () {
                ConfigStore.to.changeLanguage(Locale('zh', 'CN'));
                setState(() {
                  _selectedLanguage = 'zh_CN';
                });
              }),
              buildLanguageItem('English', 'en_US', () {
                ConfigStore.to.changeLanguage(Locale('en', 'US'));
                setState(() {
                  _selectedLanguage = 'en_US';
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLanguageItem(
    String title,
    String code,
    GestureTapCallback onTap,
  ) {
    final isSelected = _selectedLanguage == code;
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
              if (isSelected) const Icon(Icons.check, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
