import 'package:app/i18n/index.dart';
import 'package:app/pages/ai/view.dart';
import 'package:app/pages/community/view.dart';
import 'package:app/pages/home/view.dart';
import 'package:app/pages/main/controller.dart';
import 'package:app/pages/painting/view.dart';
import 'package:app/pages/profile/view.dart';
import 'package:app/widgets/keepAliveWrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      init: MainController(),
      builder:
          (controller) => Scaffold(
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller.pageController,
              children: const [
                KeepAliveWrapper(child: HomePage()),
                KeepAliveWrapper(child: PaintingPage()),
                KeepAliveWrapper(child: CommunityPage()),
                KeepAliveWrapper(child: AIPage()),
                KeepAliveWrapper(child: ProfilePage()),
              ],
            ),
            bottomNavigationBar: GetBuilder<MainController>(
              id: 'navigation',
              builder:
                  (controller) => BottomNavigationBar(
                    backgroundColor: Colors.white,
                    currentIndex: controller.currentPage,
                    selectedItemColor: const Color(0xFF5D4037),
                    unselectedItemColor: Color(0xFF9DA4B0),
                    // backgroundColor: Colors.white,
                    type: BottomNavigationBarType.fixed,
                    onTap: (page) {
                      controller.changePage(page);
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_rounded),
                        label: LocaleKeys.tabbar_home.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.image_rounded),
                        label: LocaleKeys.tabbar_painting.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.forum_rounded),
                        label: LocaleKeys.tabbar_community.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.gesture_rounded),
                        label: LocaleKeys.tabbar_ai.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle),
                        label: LocaleKeys.tabbar_profile.tr,
                      ),
                    ],
                  ),
            ),
          ),
    );
  }
}
