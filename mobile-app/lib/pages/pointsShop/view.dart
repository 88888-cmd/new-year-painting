import 'package:app/i18n/index.dart';
import 'package:app/models/points_goods.dart';
import 'package:app/pages/pointsShop/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PointsShopPage extends StatefulWidget {
  const PointsShopPage({super.key});

  @override
  State<PointsShopPage> createState() => _PointsShopPageState();
}

class _PointsShopPageState extends State<PointsShopPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PointsShopController>(
      init: PointsShopController(),
      builder: (controller) => controller.isIniting
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(LocaleKeys.points_shop.tr),
              ),
              body: Center(child: CircularProgressIndicator()),
            )
          : Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(LocaleKeys.points_shop.tr),
                actions: [
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(46),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: controller.tabController,
                      isScrollable: true,
                      tabs: controller.categoryList
                          .map((item) => Tab(text: item.name))
                          .toList(),
                    ),
                  ),
                ),
              ),
              body: GridView.builder(
                itemCount: controller.list.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  // childAspectRatio: 0.8,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                ),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  PointsGoodsModel pointsGoodsModel = controller.list[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.pointsGoodsDetail,
                        arguments: {'id': pointsGoodsModel.id},
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
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
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: CachedNetworkImage(
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                imageUrl: pointsGoodsModel.image_urls.first,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pointsGoodsModel.name,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          width: 17,
                                          height: 17,
                                          'assets/images/points.png',
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          pointsGoodsModel.sku_info!.point_num
                                              .toString(),
                                          style: TextStyle(
                                            color: Color(0xFF654941),
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF8D6E63),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 13,
                                      ),
                                      child: Text(
                                        LocaleKeys.exchange1.tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          // color: isSelected ? Colors.white : Color(0xFF987B5A),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
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
    );
  }
}
