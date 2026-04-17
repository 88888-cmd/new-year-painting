import 'package:app/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfigStore extends GetxController {
  static ConfigStore get to => Get.find();

  late Locale _locale;
  Locale get locale {
    return _locale;
  }

  List<Locale> languages = [const Locale('en', 'US'), const Locale('zh', 'CN')];

  Future<ConfigStore> init() async {
    String savedLanguage = StorageService.to.getString('setting_language');
    if (savedLanguage.isEmpty) {
      // 默认中文
      _locale = const Locale('zh', 'CN');
    } else {
      String languageCode = savedLanguage.split('_')[0];
      String countryCode = savedLanguage.split('_')[1];
      _locale = Locale(languageCode, countryCode);
    }
    return this;
  }

  Future<void> changeLanguage(Locale newLocale) async {
    _locale = newLocale;

    await StorageService.to.setString('setting_language', _locale.toString());

    await Get.updateLocale(newLocale);
  }
}
