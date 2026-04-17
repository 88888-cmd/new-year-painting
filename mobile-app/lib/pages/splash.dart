import 'dart:async';

import 'package:app/routes/routes.dart';
import 'package:app/store/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      if (UserStore.to.isLogin) {
        Get.offAllNamed(Routes.main);
      } else {
        Get.offAllNamed(Routes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build SplashPage');
    return Scaffold(appBar: AppBar(), body: Column(children: [
      
        ],
      ));
  }
}
