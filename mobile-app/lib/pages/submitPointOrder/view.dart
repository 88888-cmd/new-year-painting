import 'package:app/i18n/index.dart';
import 'package:app/models/user_coupon.dart';
import 'package:app/pages/submitOrder/controller.dart';
import 'package:app/pages/submitPointOrder/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SubmitPointOrderPage extends StatefulWidget {
  const SubmitPointOrderPage({super.key});

  @override
  State<SubmitPointOrderPage> createState() => _SubmitPointOrderPageState();
}

class _SubmitPointOrderPageState extends State<SubmitPointOrderPage> {
  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<SubmitPointOrderController>(
      init: SubmitPointOrderController(),
      builder: (controller) => controller.isIniting
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(LocaleKeys.submit_order.tr),
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
                title: Text(LocaleKeys.submit_order.tr),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.selectAddress)?.then((value) {
                            if (value != null) {
                              setState(() {
                                controller.addressId = value['id'];
                                controller.addressName = value['name'];
                                controller.addressPhone = value['phone'];
                                controller.addressContent = value['content'];
                              });

                              controller.loadData();
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 13),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  size: 22,
                                  color: Color(0xFF654941),
                                ),
                              ),
                              const SizedBox(width: 15),

                              if (controller.addressId == 0) ...[
                                Text(
                                  LocaleKeys.select_address.tr,
                                  style: TextStyle(
                                    color: const Color(0xFF654941),
                                    // fontSize: 17,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Spacer(),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ] else ...[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            controller.addressName,
                                            style: TextStyle(
                                              color: const Color(0xFF654941),
                                              // fontSize: 17,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            controller.addressPhone,
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF654941,
                                              ).withOpacity(0.8),
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        controller.addressContent,
                                        style: TextStyle(
                                          color: const Color(0xFF555E69),
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0.5,
                              blurRadius: 1.5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        // padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 15),
                              child: Text(
                                LocaleKeys.total_goods_count.trParams({
                                  'count': controller.goodsList.length
                                      .toString(),
                                }),
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            for (
                              int i = 0;
                              i < controller.goodsList.length;
                              i++
                            ) ...[
                              Divider(height: 30),
                              Container(
                                height: 70,
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            controller.goodsList[i].image_url,
                                      ),
                                    ),

                                    SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.goodsList[i].name,
                                            style: TextStyle(
                                              color: Color(0xFF654941),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            controller.goodsList[i].sku_name,
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
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    width: 14,
                                                    height: 14,
                                                    'assets/images/points.png',
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    controller
                                                        .goodsList[i]
                                                        .point_num
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Color(0xFF654941),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              Text(
                                                '×${controller.goodsList[i].buy_num}',
                                                style: TextStyle(
                                                  color: Color(0xFF6D7482),
                                                  fontSize: 14,
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
                            ],

                            SizedBox(height: 15),
                          ],
                        ),
                      ),

                      SizedBox(height: 13),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0.5,
                              blurRadius: 1.5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        // padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 15),
                              child: Text(
                                LocaleKeys.enter_points.tr,
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Divider(height: 1),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        LocaleKeys.normal_points.tr,
                                        style: TextStyle(
                                          color: Color(0xFF654941),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            child: TextField(
                                              controller: controller
                                                  .useNormalPointsController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Color(0xFF654941),
                                                fontSize: 15,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                hintStyle: const TextStyle(
                                                  color: Color(0xFF9DA4B0),
                                                  fontSize: 14,
                                                ),
                                                fillColor: Colors.white,
                                                filled: true,
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(6),
                                                          ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: const Color(
                                                          0xFFd7ccc8,
                                                        ),
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(6),
                                                          ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: const Color(
                                                          0xFF8d6e63,
                                                        ),
                                                      ),
                                                    ),
                                                isCollapsed: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        LocaleKeys.cultural_points.tr,
                                        style: TextStyle(
                                          color: Color(0xFF654941),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            child: TextField(
                                              controller: controller
                                                  .useCulturalPointsController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Color(0xFF654941),
                                                fontSize: 15,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                hintStyle: const TextStyle(
                                                  color: Color(0xFF9DA4B0),
                                                  fontSize: 14,
                                                ),
                                                fillColor: Colors.white,
                                                filled: true,
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(6),
                                                          ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: const Color(
                                                          0xFFd7ccc8,
                                                        ),
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(6),
                                                          ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: const Color(
                                                          0xFF8d6e63,
                                                        ),
                                                      ),
                                                    ),
                                                isCollapsed: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 13),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0.5,
                              blurRadius: 1.5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.order_info.tr,
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.goods_points.tr,
                                  style: TextStyle(
                                    color: Color(0xFF555E69),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  controller.totalPoints.toString(),
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 6),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.freight_price.tr,
                                  style: TextStyle(
                                    color: Color(0xFF555E69),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '¥${controller.totalFreight}',
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 13),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                width: double.infinity,
                height: kBottomNavigationBarHeight + additionalBottomPadding,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.clickSubmit();
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFFB923C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            LocaleKeys.submit.tr,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
