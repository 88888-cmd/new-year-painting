import 'package:app/i18n/index.dart';
import 'package:app/models/order_goods.dart';
import 'package:app/models/order_refund.dart';
import 'package:app/pages/orderRefundDetail/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/dialog.dart';
import 'package:app/widgets/my_steps.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderRefundDetailPage extends StatefulWidget {
  const OrderRefundDetailPage({super.key});

  @override
  State<OrderRefundDetailPage> createState() => _OrderRefundDetailPageState();
}

class _OrderRefundDetailPageState extends State<OrderRefundDetailPage> {
  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<OrderRefundDetailController>(
      init: OrderRefundDetailController(),
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
                        width: double.infinity,
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
                            Text(
                              controller.orderRefundModel.status_display,
                              style: TextStyle(
                                color: const Color(0xFF654941),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 20),

                            MySteps(
                              mode: StepsMode.number,
                              list: _buildStepItemList(
                                controller.orderRefundModel,
                              ),
                              current: _getStepActive(
                                controller.orderRefundModel,
                              ),
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
                                controller.orderRefundModel,
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
                              LocaleKeys.refund_info.tr,
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            Row(
                              children: [
                                Container(
                                  constraints: BoxConstraints(minWidth: 70),
                                  child: Text(
                                    LocaleKeys.order_no.tr,
                                    style: TextStyle(
                                      color: Color(0xFF555E69),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller.orderRefundModel.relation_order_no,
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),

                            Row(
                              children: [
                                Container(
                                  constraints: BoxConstraints(minWidth: 70),
                                  child: Text(
                                    LocaleKeys.refund_order_no.tr,
                                    style: TextStyle(
                                      color: Color(0xFF555E69),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller.orderRefundModel.refund_no,
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),

                            Row(
                              children: [
                                Container(
                                  constraints: BoxConstraints(minWidth: 70),
                                  child: Text(
                                    LocaleKeys.create_time.tr,
                                    style: TextStyle(
                                      color: Color(0xFF555E69),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller.orderRefundModel.create_time,
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            Row(
                              children: [
                                Container(
                                  constraints: BoxConstraints(minWidth: 70),
                                  child: Text(
                                    LocaleKeys.refund_type.tr,
                                    style: TextStyle(
                                      color: Color(0xFF555E69),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller
                                      .orderRefundModel
                                      .refund_type_display,
                                  style: TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            if (controller
                                .orderRefundModel
                                .apply_desc
                                .isNotEmpty) ...[
                              SizedBox(height: 10),

                              Row(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(minWidth: 70),
                                    child: Text(
                                      LocaleKeys.apply_reason.tr,
                                      style: TextStyle(
                                        color: Color(0xFF555E69),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    controller.orderRefundModel.apply_desc,
                                    style: TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (controller.orderRefundModel.status == 3) ...[
                              if (controller.orderRefundModel.refund_money >
                                  0) ...[
                                SizedBox(height: 10),

                                Row(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(minWidth: 70),
                                      child: Text(
                                        LocaleKeys.refund_amount.tr,
                                        style: TextStyle(
                                          color: Color(0xFF555E69),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '¥${controller.orderRefundModel.refund_money}',
                                      style: TextStyle(
                                        color: Color(0xFF5D4037),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              if (controller
                                      .orderRefundModel
                                      .refund_normal_points >
                                  0) ...[
                                SizedBox(height: 10),

                                Row(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: 100,
                                      ),
                                      child: Text(
                                        LocaleKeys.refund_normal_points.tr,
                                        style: TextStyle(
                                          color: Color(0xFF555E69),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '¥${controller.orderRefundModel.refund_normal_points}',
                                      style: TextStyle(
                                        color: Color(0xFF5D4037),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              if (controller
                                      .orderRefundModel
                                      .refund_cultural_points >
                                  0) ...[
                                SizedBox(height: 10),

                                Row(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: 100,
                                      ),
                                      child: Text(
                                        LocaleKeys.refund_cultural_points.tr,
                                        style: TextStyle(
                                          color: Color(0xFF555E69),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '¥${controller.orderRefundModel.refund_cultural_points}',
                                      style: TextStyle(
                                        color: Color(0xFF5D4037),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 13),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: controller.orderRefundModel.status == 1
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
                                // 显示填写退货快递条件：退货退款类型 且 平台首次审核通过 且 未填写过退货快递信息
                                if (controller.orderRefundModel.refund_type ==
                                        2 &&
                                    controller.orderRefundModel.audit_status ==
                                        2 &&
                                    controller.orderRefundModel.is_user_send ==
                                        0) ...[
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.orderRefundDelivery,
                                        arguments: {
                                          'order_id': controller
                                              .orderRefundModel
                                              .order_id,
                                          'order_refund_id':
                                              controller.orderRefundModel.id,
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
                                        LocaleKeys.return_delivery.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                ],
                                GestureDetector(
                                  onTap: () {
                                    CustomDialog.show(
                                      context: context,
                                      builder: (context) => Text(
                                        '确认取消吗？',
                                        style: TextStyle(
                                          color: Color(0xFF272624),
                                          fontSize: 17,
                                        ),
                                      ),
                                      onCancel: () =>
                                          Navigator.of(context).pop(),
                                      onConfirm: () {
                                        Navigator.of(context).pop();
                                        controller.clickCancel();
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
                                      LocaleKeys.cancel.tr,
                                      style: TextStyle(
                                        fontSize: 12,
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
                    )
                  : null,
            ),
    );
  }

  List<StepItem> _buildStepItemList(OrderRefundModel orderRefundModel) {
    List<StepItem> list = [
      StepItem(name: LocaleKeys.refund_status_apply.tr),
      StepItem(name: LocaleKeys.refund_status_pending_audit.tr),
    ];

    if (orderRefundModel.refund_type == 1) {
      switch (orderRefundModel.status) {
        case 1:
          list.add(StepItem(name: LocaleKeys.refund_status_complete.tr));
          break;
        case 2:
          list.add(StepItem(name: LocaleKeys.refund_status_rejected.tr));
          break;
        case 3:
          list.add(StepItem(name: LocaleKeys.refund_status_completed.tr));
          break;
        case 4:
          list.add(StepItem(name: LocaleKeys.refund_status_cancelled.tr));
          break;
      }
    } else if (orderRefundModel.refund_type == 2) {
      switch (orderRefundModel.audit_status) {
        case 1:
          list.add(StepItem(name: LocaleKeys.refund_status_return_goods.tr));
          list.add(StepItem(name: LocaleKeys.refund_status_receive.tr));
          list.add(StepItem(name: LocaleKeys.refund_status_complete.tr));
          break;
        case 2:
          list.add(StepItem(name: LocaleKeys.refund_status_return_goods.tr));
          list.add(StepItem(name: LocaleKeys.refund_status_receive.tr));

          switch (orderRefundModel.status) {
            case 1:
              list.add(StepItem(name: LocaleKeys.refund_status_complete.tr));
              break;
            case 2:
              list.add(StepItem(name: LocaleKeys.refund_status_rejected.tr));
              break;
            case 3:
              list.add(StepItem(name: LocaleKeys.refund_status_completed.tr));
              break;
            case 4:
              list.add(StepItem(name: LocaleKeys.refund_status_cancelled.tr));
              break;
          }
          break;
        case 3:
          list.add(StepItem(name: LocaleKeys.refund_status_rejected.tr));
          break;
      }
    }
    return list;
  }

  int _getStepActive(OrderRefundModel orderRefundModel) {
    int active = 1;
    if (orderRefundModel.refund_type == 1) {
      if (orderRefundModel.status != 1) {
        active++;
      }
      // if (orderRefundModel.audit_status != 1) {
      //   active++;
      // }
    } else if (orderRefundModel.refund_type == 2) {
      if (orderRefundModel.audit_status == 1) {
      } else if (orderRefundModel.audit_status == 2) {
        if (orderRefundModel.is_user_send == 0) {
          // 用户未填写退货快递信息
        } else {
          // 用户已填写退货快递信息
          active++;

          if (orderRefundModel.is_receipt == 0) {
            // 平台未收到退货
          } else {
            // 平台已收到退回
            active++;

            // 已最终确认退款单状态（用户取消或平台已确认状态 通过或拒绝）
            if (orderRefundModel.status != 1) {
              active++;
            }
          }
        }
      } else if (orderRefundModel.audit_status == 3) {
        active++;
      }
    }
    return active;
  }

  Widget _buildGoodsItem(
    OrderRefundModel orderRefundModel,
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

                if (orderRefundModel.relation_order_type == 1)
                  Text(
                    '¥${orderGoodsModel.goods_sku_price}',
                    style: TextStyle(color: Color(0xFFe57373), fontSize: 14),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
