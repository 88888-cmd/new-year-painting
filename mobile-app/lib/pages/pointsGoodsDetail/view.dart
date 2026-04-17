import 'package:app/i18n/index.dart';
import 'package:app/pages/pointsGoodsDetail/controller.dart';
import 'package:app/pages/pointsGoodsDetail/widgets/banner.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PointsGoodsDetailPage extends StatefulWidget {
  const PointsGoodsDetailPage({super.key});

  @override
  State<PointsGoodsDetailPage> createState() => _PointsGoodsDetailPageState();
}

class _PointsGoodsDetailPageState extends State<PointsGoodsDetailPage> {
  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<PointsGoodsController>(
      init: PointsGoodsController(),
      tag: Get.arguments['id'].toString(),
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
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    BuildBanner(bannerList: controller.goodsModel.image_urls),

                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                controller.selectedSku.point_num.toString(),
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),
                          Text(
                            controller.goodsModel.name,
                            style: TextStyle(
                              color: Color(0xFF654941),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.select_sku.tr,
                            style: TextStyle(
                              color: Color(0xFF654941),
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.skuList.map((item) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    controller.selectedSkuId = item.id;
                                  });
                                },
                                child: IntrinsicWidth(
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      // color: Color(0xFF8d6e63),
                                      color: item.id == controller.selectedSkuId
                                          ? Color(0xFF8d6e63)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          item.id == controller.selectedSkuId
                                          ? null
                                          : Border.all(
                                              width: 1,
                                              color: Color(0xFF8d6e63),
                                            ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.sku_name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            item.id == controller.selectedSkuId
                                            ? Colors.white
                                            : Color(0xFF8d6e63),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    if (controller.commentList.isNotEmpty)
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocaleKeys.goods_reviews_x.trParams({
                                    'count': controller.commentList.length
                                        .toString(),
                                  }),
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.pointsGoodsComment, arguments: {
                                      'goods_id': controller.goodsModel.id
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        LocaleKeys.view_all.tr,
                                        style: TextStyle(
                                          color: Color(0xFF654941),
                                          fontSize: 13,
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

                            for (
                              int i = 0;
                              i < controller.commentList.length;
                              i++
                            )
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),
                                  SizedBox(height: 2),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
                                          size: 17,
                                        ),
                                        radius: 15,
                                        backgroundColor: Colors.grey.shade300,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller
                                                  .commentList[i]
                                                  .nickname,
                                              style: TextStyle(
                                                color: Color(0xFF654941),
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              controller
                                                  .commentList[i]
                                                  .create_time,
                                              style: TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: List.generate(
                                      controller.commentList[i].star_num,
                                      (index) {
                                        return Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFffb74d),
                                          size: 20,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    controller.commentList[i].content,
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

                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                              left: 16,
                              bottom: 10,
                            ),
                            child: Text(
                              LocaleKeys.goods_detail.tr,
                              style: TextStyle(
                                color: Color(0xFF654941),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // child: Text(
                            //   '- 商品详情 -',
                            //   style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                            // ),
                          ),
                          CachedNetworkImage(
                            width: double.infinity,
                            imageUrl: controller.goodsModel.detail_url,
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          Get.toNamed(
                            Routes.submitPointOrder,
                            arguments: {
                              'goods_id': controller.goodsModel.id,
                              'goods_sku_id': controller.selectedSkuId,
                            },
                          );
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFFB923C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            LocaleKeys.exchange.tr,
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
