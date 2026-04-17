import 'package:app/i18n/index.dart';
import 'package:app/models/order.dart';
import 'package:app/models/order_refund.dart';
import 'package:app/pages/myOrderList/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyOrderList extends StatefulWidget {
  const MyOrderList({super.key});

  @override
  State<MyOrderList> createState() => _MyOrderListState();
}

class _MyOrderListState extends State<MyOrderList> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyOrderController>(
      init: MyOrderController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.my_order.tr),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(46),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: controller.tabController,
                isScrollable: true,
                tabs: [
                  Tab(text: LocaleKeys.all.tr),
                  Tab(text: LocaleKeys.order_status_to_ship.tr),
                  Tab(text: LocaleKeys.order_status_to_receive.tr),
                  Tab(text: LocaleKeys.order_status_completed.tr),
                  Tab(text: LocaleKeys.order_status_refund.tr),
                ],
              ),
            ),
          ),
        ),
        body: controller.tabController.index < 4
            ? ListView.builder(
                itemCount: controller.orderList.length,
                itemBuilder: (context, index) {
                  OrderModel orderModel = controller.orderList[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0.5,
                          blurRadius: 1.5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ).copyWith(top: 13),
                    // padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ).copyWith(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${LocaleKeys.order_no.tr}：${orderModel.order_no}',
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text(
                                orderModel.order_status_display,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 30),

                        for (
                          int i = 0;
                          i < orderModel.order_goods_list.length;
                          i++
                        ) ...[
                          Container(
                            height: 70,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    imageUrl: orderModel
                                        .order_goods_list[i]
                                        .goods_image_url,
                                  ),
                                ),

                                SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        orderModel
                                            .order_goods_list[i]
                                            .goods_name,
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
                                            orderModel
                                                .order_goods_list[i]
                                                .goods_sku_name,
                                            style: TextStyle(
                                              color: Color(0xFF6D7482),
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '×${orderModel.order_goods_list[i].buy_num}',
                                            style: TextStyle(
                                              color: Color(0xFF6D7482),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Spacer(),

                                      if (orderModel.order_type == 1)
                                        Text(
                                          '¥${orderModel.order_goods_list[i].goods_sku_price}',
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
                                              orderModel
                                                  .order_goods_list[i]
                                                  .goods_sku_point_num
                                                  .toString(),
                                              style: TextStyle(
                                                color: Color(0xFF654941),
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
                          if (i < orderModel.order_goods_list.length - 1)
                            SizedBox(height: 15),
                        ],

                        // SizedBox(height: 5),
                        Divider(height: 30),

                        // SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ).copyWith(bottom: 15),
                          child: Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Color(0xFF6D7482),
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '共${orderModel.order_goods_list.length}件商品 实付：',
                                    ),
                                    TextSpan(
                                      text: '¥${orderModel.pay_price}',
                                      style: TextStyle(
                                        color: Color(0xFFe57373),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Spacer(),

                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    Routes.orderDetail,
                                    arguments: {'id': orderModel.id},
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Color(0xFF8d6e63),
                                  ),
                                  child: Text(
                                    LocaleKeys.view_detail.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : ListView.builder(
                itemCount: controller.refundList.length,
                itemBuilder: (context, index) {
                  OrderRefundModel orderRefundModel =
                      controller.refundList[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0.5,
                          blurRadius: 1.5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ).copyWith(top: 13),
                    // padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ).copyWith(top: 15),
                          child: Text(
                            '${LocaleKeys.refund_order_no.tr}：${orderRefundModel.refund_no}',
                            style: TextStyle(
                              color: Color(0xFF654941),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Divider(height: 30),

                        for (
                          int i = 0;
                          i < orderRefundModel.order_goods_list.length;
                          i++
                        ) ...[
                          Container(
                            height: 70,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    imageUrl: orderRefundModel
                                        .order_goods_list[i]
                                        .goods_image_url,
                                  ),
                                ),

                                SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        orderRefundModel
                                            .order_goods_list[i]
                                            .goods_name,
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
                                            orderRefundModel
                                                .order_goods_list[i]
                                                .goods_sku_name,
                                            style: TextStyle(
                                              color: Color(0xFF6D7482),
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '×${orderRefundModel.order_goods_list[i].buy_num}',
                                            style: TextStyle(
                                              color: Color(0xFF6D7482),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Spacer(),

                                      if (orderRefundModel
                                              .relation_order_type ==
                                          1)
                                        Text(
                                          '¥${orderRefundModel.order_goods_list[i].goods_sku_price}',
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
                                              orderRefundModel
                                                  .order_goods_list[i]
                                                  .goods_sku_point_num
                                                  .toString(),
                                              style: TextStyle(
                                                color: Color(0xFF654941),
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
                          if (i < orderRefundModel.order_goods_list.length - 1)
                            SizedBox(height: 15),
                        ],

                        Divider(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ).copyWith(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    Routes.orderRefundDetail,
                                    arguments: {'id': orderRefundModel.id},
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Color(0xFF8d6e63),
                                  ),
                                  child: Text(
                                    LocaleKeys.view_detail.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
