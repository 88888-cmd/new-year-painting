import 'package:app/i18n/index.dart';
import 'package:app/models/painting.dart';
import 'package:app/pages/home/controller.dart';
import 'package:app/pages/home/widgets/banner.dart';
import 'package:app/pages/main/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/searchBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.tabbar_home.tr),
          // actions: [
          //   IconButton(onPressed: () {}, icon: Icon(Icons.search_rounded)),
          // ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.searchPainting);
                  },
                  child: CustomSearchBar(
                    enabled: false,
                    readOnly: true,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BuildBanner(bannerList: controller.bannerList),
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.shop);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8d6e63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(22.5),
                          ),
                          child: Icon(
                            Icons.local_mall_rounded,
                            color: const Color(0xFF8d6e63),
                            size: 22,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          LocaleKeys.home_nav_1.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.wish);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8d6e63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(22.5),
                          ),
                          child: Icon(
                            Icons.local_florist_rounded,
                            color: const Color(0xFF8d6e63),
                            size: 22,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          LocaleKeys.home_nav_2.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.paintingCalendar);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8d6e63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(22.5),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: const Color(0xFF8d6e63),
                            size: 22,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          LocaleKeys.home_nav_3.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.coupon);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8d6e63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(22.5),
                          ),
                          child: Icon(
                            Icons.local_activity_rounded,
                            color: const Color(0xFF8d6e63),
                            size: 22,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          LocaleKeys.home_nav_4.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: 25),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.recommend.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        MainController mainController =
                            Get.find<MainController>();
                        mainController.changePage(1);
                      },
                      child: Row(
                        children: [
                          Text(
                            LocaleKeys.home_more.tr,
                            style: TextStyle(
                              color: Color(0xFF654941),
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Color(0xFF654941),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.builder(
                itemCount: controller.list.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // childAspectRatio: 0.75,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                ),
                itemBuilder: (context, index) {
                  PaintingModel paintingModel = controller.list[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.paintingDetail,
                        arguments: {'id': paintingModel.id},
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 0.5,
                            blurRadius: 1.5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: CachedNetworkImage(
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                imageUrl: paintingModel.image_url,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paintingModel.name,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),

                                Text(
                                  '${controller.list[index].dynasty}·${controller.list[index].author}',
                                  style: TextStyle(
                                    color: Color(0xFF4D5562),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  IconMenuItem({required this.icon, required this.label, this.onTap});
}

class IconMenuItemWidget extends StatelessWidget {
  final IconMenuItem item;
  final VoidCallback onTap;

  const IconMenuItemWidget({Key? key, required this.item, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0E1D3).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFF0E1D3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(item.icon, color: Color(0xFFB56B45), size: 20),
              ),
            ),
            SizedBox(height: 6),
            Text(
              item.label,
              style: TextStyle(fontSize: 10, color: Color(0xFF5D4037)),
            ),
          ],
        ),
      ),
    );
  }
}
