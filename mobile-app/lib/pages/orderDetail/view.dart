import 'package:app/i18n/index.dart';
import 'package:app/models/order.dart';
import 'package:app/models/order_goods.dart';
import 'package:app/pages/orderDetail/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/dialog.dart';
import 'package:app/widgets/timeline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<OrderDetailController>(
      init: OrderDetailController(),
      builder: (controller) => controller.isIniting
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(LocaleKeys.detail.tr),
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
                title: Text(LocaleKeys.detail.tr),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 22,
                                  color: Colors.pink,
                                  // color: Color.fromARGB(255, 239, 68, 68),
                                ),

                                SizedBox(width: 5),

                                Text(
                                  LocaleKeys.order_address.tr,
                                  style: TextStyle(
                                    color: const Color(0xFF654941),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      controller.orderAddressModel.name,
                                      style: TextStyle(
                                        color: const Color(0xFF654941),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      controller.orderAddressModel.phone,
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
                                  '${controller.orderAddressModel.province}${controller.orderAddressModel.city}${controller.orderAddressModel.district}${controller.orderAddressModel.detail}',
                                  style: TextStyle(
                                    color: const Color(0xFF555E69),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (controller.orderModel.order_status == 2)
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
                          margin: const EdgeInsets.only(bottom: 13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  top: 15,
                                ),
                                child: Text(
                                  LocaleKeys.order_logistics.tr,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(height: 30),

                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ).copyWith(bottom: 15),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final bool isLastItem =
                                      index == controller.wuliuList.length;

                                  return IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!isLastItem)
                                          Stack(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: 5,
                                                  top: 14,
                                                  bottom: 4,
                                                ),
                                                width: 0.5,
                                                color: Color(0xFFd6ccc2),
                                              ),

                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF8d6e63),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF8d6e63),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),

                                        SizedBox(width: 10),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller
                                                    .wuliuList[index]
                                                    .status,
                                                style: TextStyle(
                                                  color: Color(0xFF5D4037),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              SizedBox(height: 5),
                                              Text(
                                                controller
                                                    .wuliuList[index]
                                                    .time,
                                                style: TextStyle(
                                                  color: Color(0xFF6D7482),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (!isLastItem)
                                                SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: controller.wuliuList.length,
                              ),
                            ],
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
                                  'count': controller.orderGoodsList.length
                                      .toString(),
                                }),
                                // '共${controller.orderGoodsList.length}件商品',
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            for (
                              int i = 0;
                              i < controller.orderGoodsList.length;
                              i++
                            ) ...[
                              Divider(height: 30),
                              _buildGoodsItem(
                                controller.orderModel,
                                controller.orderGoodsList[i],
                              ),
                            ],

                            SizedBox(height: 15),
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

                            if (controller.orderModel.order_type == 1)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.goods_price.tr,
                                    style: TextStyle(
                                      color: Color(0xFF555E69),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '¥${controller.orderModel.total_price}',
                                    style: TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.goods_points.tr,
                                    style: TextStyle(
                                      color: Color(0xFF555E69),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${controller.orderModel.total_points}',
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
                                  '¥${controller.orderModel.freight_price}',
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            if (controller.orderModel.coupon_id > 0) ...[
                              SizedBox(height: 6),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.coupon_deduct.tr,
                                    style: TextStyle(
                                      color: Color(0xFF555E69),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '-¥${controller.orderModel.coupon_money}',
                                    style: TextStyle(
                                      color: Color(0xFFe57373),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (controller.orderModel.normal_points_deduct >
                                0) ...[
                              SizedBox(height: 6),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.normal_points_deduct.tr,
                                    style: TextStyle(
                                      color: Color(0xFF555E69),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '-¥${controller.orderModel.normal_points_deduct}',
                                    style: TextStyle(
                                      color: Color(0xFFD97708),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (controller.orderModel.order_type == 1) ...[
                              Divider(),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.pay_price.tr,
                                    style: TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '¥${controller.orderModel.pay_price}',
                                    style: TextStyle(
                                      color: Color(0xFFe57373),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 13),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: controller.orderModel.order_status <= 3
                  ? Container(
                      width: double.infinity,
                      height:
                          kBottomNavigationBarHeight + additionalBottomPadding,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ).copyWith(top: 10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.applyRefund,
                                      arguments: {
                                        'source': 'order',
                                        'order_id': controller.orderModel.id,
                                        'order_type':
                                            controller.orderModel.order_type,
                                        'order_status':
                                            controller.orderModel.order_status,
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 90,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(17),
                                      color: Color(0xFF8d6e63),
                                    ),
                                    child: Text(
                                      LocaleKeys.apply_for_refund.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (controller.orderModel.order_status ==
                                    2) ...[
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      CustomDialog.show(
                                        context: context,
                                        builder: (context) => Text(
                                          '请收到货确认无误后，再确认收货',
                                          style: TextStyle(
                                            color: Color(0xFF272624),
                                            fontSize: 17,
                                          ),
                                        ),
                                        onCancel: () =>
                                            Navigator.of(context).pop(),
                                        onConfirm: () {
                                          Navigator.of(context).pop();
                                          controller.clickReceipt();
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 90,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(17),
                                        color: Color(0xFF8d6e63),
                                      ),
                                      child: Text(
                                        LocaleKeys.order_confirm_receive.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
    );
  }

  Widget _buildGoodsItem(
    OrderModel orderModel,
    OrderGoodsModel orderGoodsModel,
  ) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              imageUrl: orderGoodsModel.goods_image_url,
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderGoodsModel.goods_name,
                  style: TextStyle(
                    color: Color(0xFF654941),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      orderGoodsModel.goods_sku_name,
                      style: TextStyle(color: Color(0xFF6D7482), fontSize: 12),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '×${orderGoodsModel.buy_num}',
                      style: TextStyle(color: Color(0xFF6D7482), fontSize: 14),
                    ),
                  ],
                ),

                Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (orderModel.order_type == 1)
                      Text(
                        '¥${orderGoodsModel.goods_sku_price}',
                        style: TextStyle(
                          color: Color(0xFFe57373),
                          fontSize: 14,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Image.asset(
                            width: 14,
                            height: 14,
                            'assets/images/points.png',
                          ),
                          SizedBox(width: 2),
                          Text(
                            orderGoodsModel.goods_sku_point_num.toString(),
                            style: TextStyle(
                              color: Color(0xFF654941),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                    if (orderModel.order_status < 4) ...[
                      if (orderGoodsModel.status == 1)
                        if (orderGoodsModel.is_comment == 0 &&
                            orderModel.order_status == 3)
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                Routes.commentOrderGoods,
                                arguments: {
                                  'order_id': orderModel.id,
                                  'order_goods_id': orderGoodsModel.id,
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xFF8d6e63),
                                ),
                                // color: Color(0xFF8d6e63),
                              ),
                              child: Text(
                                orderGoodsModel.is_comment == 0
                                    ? LocaleKeys.order_comment.tr
                                    : LocaleKeys.apply_for_refund.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8d6e63),
                                ),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                Routes.applyRefund,
                                arguments: {
                                  'source': 'order_goods',
                                  'order_id': orderModel.id,
                                  'order_type': orderModel.order_type,
                                  'order_status': orderModel.order_status,
                                  'order_goods_id': orderGoodsModel.id,
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xFF8d6e63),
                                ),
                                // color: Color(0xFF8d6e63),
                              ),
                              child: Text(
                                orderGoodsModel.is_comment == 0
                                    ? LocaleKeys.order_comment.tr
                                    : LocaleKeys.apply_for_refund.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8d6e63),
                                ),
                              ),
                            ),
                          ),
                      if (orderGoodsModel.status == 2)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              width: 1,
                              color: Color(0xFF8d6e63).withOpacity(0.8),
                            ),
                            // color: Color(0xFF8d6e63),
                          ),
                          child: Text(
                            LocaleKeys.refunding.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8d6e63).withOpacity(0.8),
                            ),
                          ),
                        ),
                      // if (orderGoodsModel.status == 1)
                      //   GestureDetector(
                      //     onTap: () {
                      //       if (orderGoodsModel.is_comment == 0) {
                      // Get.toNamed(
                      //   Routes.commentOrderGoods,
                      //   arguments: {
                      //     'order_id': orderModel.id,
                      //     'order_goods_id': orderGoodsModel.id,
                      //   },
                      // );
                      //       } else {
                      // Get.toNamed(
                      //   Routes.applyRefund,
                      //   arguments: {
                      //     'source': 'order_goods',
                      //     'order_id': orderModel.id,
                      //     'order_type': orderModel.order_type,
                      //     'order_status': orderModel.order_status,
                      //     'order_goods_id': orderGoodsModel.id,
                      //   },
                      // );
                      //       }
                      //     },
                      // child: Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(16),
                      //     border: Border.all(
                      //       width: 1,
                      //       color: Color(0xFF8d6e63),
                      //     ),
                      //     // color: Color(0xFF8d6e63),
                      //   ),
                      //   child: Text(
                      //     orderGoodsModel.is_comment == 0
                      //         ? LocaleKeys.order_comment.tr
                      //         : LocaleKeys.apply_for_refund.tr,
                      //     style: TextStyle(
                      //       fontSize: 11,
                      //       color: Color(0xFF8d6e63),
                      //     ),
                      //   ),
                      // ),
                      //   )
                      // else if (orderGoodsModel.status == 2)
                      //   Container(
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: 10,
                      //       vertical: 4,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(16),
                      //       border: Border.all(
                      //         width: 1,
                      //         color: Color(0xFF8d6e63).withOpacity(0.8),
                      //       ),
                      //       // color: Color(0xFF8d6e63),
                      //     ),
                      //     child: Text(
                      //       LocaleKeys.refunding.tr,
                      //       style: TextStyle(
                      //         fontSize: 11,
                      //         color: Color(0xFF8d6e63).withOpacity(0.8),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
