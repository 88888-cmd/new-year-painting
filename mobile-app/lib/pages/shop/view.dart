import 'package:app/i18n/index.dart';
import 'package:app/pages/shop/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/categoryButton.dart';
import 'package:app/widgets/searchBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(
      init: ShopController(),
      builder: (controller) => controller.isIniting
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(LocaleKeys.shop.tr),
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
                title: Text(LocaleKeys.shop.tr),
                actionsIconTheme: IconThemeData(
                  color: Color(0xFF4B5563),
                  size: 22,
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed(Routes.searchGoods);
                    },
                    icon: Icon(Icons.search_rounded),
                  ),
                  if (controller.cartBadge > 0)
                    Badge(
                      label: Text(controller.cartBadge.toString()),
                      backgroundColor: Color(0xFFe57373),
                      offset: Offset(-6, 4),
                      textStyle: TextStyle(fontSize: 10),
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(Routes.cart);
                        },
                        icon: Icon(Icons.shopping_cart_rounded),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: () {
                        Get.toNamed(Routes.cart);
                      },
                      icon: Icon(Icons.shopping_cart_rounded),
                    ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.searchGoods);
                      },
                      child: CustomSearchBar(
                        readOnly: true,
                        hintText: LocaleKeys.shop_page_search_hint.tr,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          CategoryButtonItem(
                            borderRadius: 10,
                            title: LocaleKeys.all.tr,
                            value: 0,
                            isSelected: controller.selectedCategoryId == 0,
                            onPressed: () {
                              controller.selectedCategoryId = 0;
                              setState(() {});

                              controller.loadList();
                            },
                          ),
                          ...controller.categoryList.map((category) {
                            return Row(
                              children: [
                                const SizedBox(width: 12),
                                CategoryButtonItem(
                                  borderRadius: 10,
                                  title: category.name,
                                  value: category.id,
                                  isSelected:
                                      controller.selectedCategoryId ==
                                      category.id,
                                  onPressed: () {
                                    controller.selectedCategoryId = category.id;
                                    setState(() {});

                                    controller.loadList();
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),

                    Expanded(
                      child: GridView.builder(
                        itemCount: controller.list.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          // childAspectRatio: 0.8,
                          crossAxisSpacing: 13,
                          mainAxisSpacing: 13,
                        ),
                        padding: const EdgeInsets.only(top: 10, bottom: 16),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              Routes.goodsDetail,
                              arguments: {'id': controller.list[index].id},
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
                                      imageUrl: controller
                                          .list[index]
                                          .image_urls
                                          .first,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.list[index].name,
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
                                          Text(
                                            '¥${controller.list[index].sku_info!.price}',
                                            style: TextStyle(
                                              color: Color(0xFFe57373),
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF8D6E63),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 16,
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   currentIndex: 0,
      //   selectedItemColor: const Color(0xFF5D4037),
      //   unselectedItemColor: Color(0xFF9DA4B0),
      //   // backgroundColor: Colors.white,
      //   type: BottomNavigationBarType.fixed,
      //   onTap: (page) {},
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_bag_rounded),
      //       label: '商城',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart_rounded),
      //       label: '购物车',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.account_circle),
      //       label: '个人中心',
      //     ),
      //   ],
      // ),
    );
  }
}
