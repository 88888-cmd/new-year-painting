import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MainController extends GetxController {

  late final PageController pageController;

  int currentPage = 0;

  void changePage(int page) {
    pageController.jumpToPage(page);

    currentPage = page;

    update(['navigation']);
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentPage);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
