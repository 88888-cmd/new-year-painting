import 'package:app/services/http.dart';
import 'package:app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AIText2ImageController extends GetxController {
  final TextEditingController promptController = TextEditingController(
    text: '',
  );

  int selectedCount = 1;
  // String generateResult = '';
  List<String> generateResult = [];

  void clickGenerate() {
    String prompt = promptController.text.trim();
    if (prompt.isEmpty) return;

    HttpService.to
        .post(
          'ai/text2image',
          data: {'prompt': prompt, 'n': selectedCount},
          options: Options(
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
          ),
          showLoading: true,
        )
        .then((result) {
          generateResult =
              (result.data as List<dynamic>?)
                  ?.map((url) => url.toString())
                  .toList() ??
              [];
          // generateResult = result.data['image_urls'];
          update();
        });
  }

  @override
  void onClose() {
    promptController.dispose();
    super.onClose();
  }
}
