import 'package:app/i18n/index.dart';
import 'package:app/models/user_coupon.dart';
import 'package:app/pages/submitOrder/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SubmitOrderPage extends StatefulWidget {
  const SubmitOrderPage({super.key});

  @override
  State<SubmitOrderPage> createState() => _SubmitOrderPageState();
}

class _SubmitOrderPageState extends State<SubmitOrderPage> {
  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<SubmitOrderController>(
      init: SubmitOrderController(),
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
                                  '选择地址',
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
                                              Text(
                                                '¥${controller.goodsList[i].sku_price}',
                                                style: TextStyle(
                                                  color: Color(0xFFe57373),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.coupon.tr,
                                    style: TextStyle(
                                      color: Color(0xFF654941),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _openCouponPopup();
                                    },
                                    child: Row(
                                      children: [
                                        if (controller.selectedCoupon == null)
                                          Text(
                                            LocaleKeys.select.tr,
                                            style: TextStyle(
                                              color: Color(0xFFe57373),
                                              fontSize: 13,
                                            ),
                                          )
                                        else
                                          Text(
                                            LocaleKeys.selected_coupon_price
                                                .trParams({
                                                  'price': controller
                                                      .selectedCoupon!
                                                      .reduce_price
                                                      .toString(),
                                                }),
                                            // '已选：¥${controller.selectedCoupon!.reduce_price}',
                                            style: TextStyle(
                                              color: Color(0xFFe57373),
                                              fontSize: 13,
                                            ),
                                          ),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 20,
                                          color: Color(0xFFe57373),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                LocaleKeys.points_deduct.tr,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          Text(
                                            '1积分=${controller.normalPointsPerYuan}元',
                                            style: TextStyle(
                                              color: Color(0xFFD97708),
                                              fontSize: 12,
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
                                  LocaleKeys.goods_price.tr,
                                  style: TextStyle(
                                    color: Color(0xFF555E69),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '¥${controller.totalPrice}',
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

                            SizedBox(height: 6),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.coupon_deduct.tr,
                                  style: TextStyle(
                                    color: Color(0xFF555E69),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '-¥${controller.couponDeduct}',
                                  style: TextStyle(
                                    color: Color(0xFFe57373),
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
                                  LocaleKeys.normal_points_deduct.tr,
                                  style: TextStyle(
                                    color: Color(0xFF555E69),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '-¥${controller.pointsDeduct}',
                                  style: TextStyle(
                                    color: Color(0xFFD97708),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            Divider(),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.pay_price.tr,
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '¥${controller.payPrice}',
                                  style: TextStyle(
                                    color: Color(0xFFe57373),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${LocaleKeys.pay_price.tr}: ',
                                    ),
                                    TextSpan(
                                      text: '¥${controller.payPrice}',
                                      style: TextStyle(
                                        color: Color(0xFFe57373),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                LocaleKeys.total_discount.trParams({
                                  'deduct':
                                      (controller.couponDeduct +
                                              controller.pointsDeduct)
                                          .toString(),
                                }),
                                // '已优惠：¥${controller.couponDeduct + controller.pointsDeduct}',
                                style: TextStyle(
                                  color: Color(0xFF555E69),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          GestureDetector(
                            onTap: () {
                              controller.clickSubmit();
                            },
                            child: Container(
                              width: 115,
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

  void _openCouponPopup() {
    SubmitOrderController controller = Get.find<SubmitOrderController>();
    UserCouponModel? tempSelectedCoupon = controller.selectedCoupon;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    LocaleKeys.select_coupon.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Color(0xFFF5F5F5),
                    child: ListView.builder(
                      itemCount: controller.coupons.length,
                      itemBuilder: (context, index) {
                        UserCouponModel userCouponModel =
                            controller.coupons[index];

                        bool isSelected =
                            tempSelectedCoupon?.id == userCouponModel.id;

                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              setState(() {
                                tempSelectedCoupon = null;
                              });
                            } else {
                              if (controller.totalPrice +
                                      controller.totalFreight <
                                  userCouponModel.min_price) {
                                return;
                              }
                              setState(() {
                                tempSelectedCoupon = userCouponModel;
                              });
                            }
                          },
                          child: Container(
                            height: 75,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 13,
                            ).copyWith(top: index == 0 ? 10 : 0, bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                    color: Color(0xFFFEF2F2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '¥${userCouponModel.reduce_price}',
                                        style: TextStyle(
                                          color: Color(0xFFe57373),
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        LocaleKeys
                                            .available_for_purchase_over_x_yuan
                                            .trParams({
                                              'price': userCouponModel.min_price
                                                  .toString(),
                                            }),
                                        // '满${userCouponModel.min_price}可用',
                                        style: TextStyle(
                                          color: Color(0xFF555E69),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 1.5,
                                              horizontal: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFe57373),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            child: Text(
                                              LocaleKeys.threshold_discount.tr,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),

                                          Text(
                                            userCouponModel.coupon_name,
                                            style: TextStyle(
                                              color: Color(0xFF5D4037),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        LocaleKeys.coupon_valid_period
                                            .trParams({
                                              'start_time': userCouponModel
                                                  .start_time
                                                  .toString(),
                                              'end_time': userCouponModel
                                                  .end_time
                                                  .toString(),
                                            }),
                                        style: TextStyle(
                                          color: Color(0xFF555E69),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 10),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.check_circle_outline_rounded,
                                  size: 20,
                                  color: Color(0xFF8d6e63),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    controller.clickSelectCoupon(tempSelectedCoupon);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ).copyWith(top: 10),
                    color: Colors.white,
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Color(0xFFe57373),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        LocaleKeys.confirm.tr,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
