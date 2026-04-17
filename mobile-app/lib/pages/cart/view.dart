import 'package:app/i18n/index.dart';
import 'package:app/models/cart.dart';
import 'package:app/pages/cart/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ValueNotifier<bool> isSelectedAll = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<CartController>(
      init: CartController(),
      builder: (controller) => controller.isIniting
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(LocaleKeys.cart.tr),
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
                title: Text(LocaleKeys.cart.tr),
              ),
              body: ListView.builder(
                itemCount: controller.list.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  CartModel item = controller.list[index];
                  return Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.toggleItemSelect(
                              item.goods_id,
                              item.goods_sku_id,
                            );
                          },
                          child: Icon(
                            controller.selectedItems['${item.goods_id}_${item.goods_sku_id}'] ??
                                    false
                                ? Icons.check_circle_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 22,
                            color: Color(0xFF8d6e63),
                          ),
                        ),

                        SizedBox(width: 20),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            imageUrl: item.goods.image_urls.first,
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ).copyWith(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.goods.name,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  item.sku.sku_name,
                                  style: TextStyle(
                                    color: Color(0xFF6D7482),
                                    fontSize: 12,
                                  ),
                                ),

                                Spacer(),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '¥${item.sku.price}',
                                      style: TextStyle(
                                        color: Color(0xFFe57373),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Container(
                                      width: 92,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Color.fromRGBO(
                                          141,
                                          110,
                                          99,
                                          0.1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              controller.decreaseItemCount(
                                                item.goods_id,
                                                item.goods_sku_id,
                                              );
                                            },
                                            child: Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    spreadRadius: 0.5,
                                                    blurRadius: 1.5,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,

                                              child: Icon(
                                                Icons.remove_rounded,
                                                color: Color(0xFF5D4037),
                                                size: 18,
                                              ),
                                            ),
                                          ),

                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                item.buy_num.toString(),
                                                style: TextStyle(
                                                  color: Color(0xFF654941),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),

                                          GestureDetector(
                                            onTap: () {
                                              controller.increaseItemCount(
                                                item.goods_id,
                                                item.goods_sku_id,
                                              );
                                            },
                                            child: Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    spreadRadius: 0.5,
                                                    blurRadius: 1.5,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.add_rounded,
                                                color: Color(0xFF5D4037),
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              bottomNavigationBar: Container(
                width: double.infinity,
                height: kBottomNavigationBarHeight + additionalBottomPadding,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 10),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              controller.toggleAllSelect();
                              // isSelectedAll.value = !isSelectedAll.value;
                            },
                            child: Row(
                              children: [
                                Icon(
                                  controller.isSelectedAll
                                      ? Icons.check_circle_rounded
                                      : Icons.check_circle_outline_rounded,
                                  size: 22,
                                  color: Color(0xFF8d6e63),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  LocaleKeys.select_all.tr,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Spacer(),

                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Color(0xFF654941),
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: LocaleKeys.cart_total.tr),
                                TextSpan(
                                  text: '¥${controller.selectedTotalPrice}',
                                  style: TextStyle(
                                    color: Color(0xFFe57373),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 15),

                          GestureDetector(
                            onTap: () {
                              String ids = controller.getSelectedIds();
                              if (ids.isEmpty) return;
                              Get.toNamed(
                                Routes.submitOrder,
                                arguments: {'source': 'cart', 'cart_ids': ids},
                              );
                            },
                            child: Container(
                              width: 100,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFFe57373),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                LocaleKeys.submit.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
