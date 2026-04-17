import 'package:app/i18n/index.dart';
import 'package:app/models/goods_sku.dart';
import 'package:app/pages/goodsDetail/controller.dart';
import 'package:app/pages/goodsDetail/widgets/banner.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoodsDetailPage extends StatefulWidget {
  const GoodsDetailPage({super.key});

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  int goodsId = 0;

  @override
  void initState() {
    super.initState();
    goodsId = Get.arguments['id'];
  }

  void _showSkuSelectionDialog(String actionType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GetBuilder<GoodsDetailController>(
          tag: goodsId.toString(),
          builder: (controller) {
            GoodsSkuModel tempSelectedSku = controller.skuList.first;
            int tempSelectedNum = 1;

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                actionType == 'cart'
                                    ? LocaleKeys.add_to_cart.tr
                                    : LocaleKeys.buy_now.tr,
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.close,
                                  color: Color(0xFF654941),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1),

                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      controller
                                          .goodsModel
                                          .image_urls
                                          .isNotEmpty
                                      ? controller.goodsModel.image_urls.first
                                      : '',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¥${tempSelectedSku.price}',
                                      style: TextStyle(
                                        color: Color(0xFFe57373),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (tempSelectedSku.line_price > 0)
                                      Text(
                                        '¥${tempSelectedSku.line_price}',
                                        style: TextStyle(
                                          color: Color(0xFF6D7482),
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    SizedBox(height: 4),
                                    Text(
                                      controller.goodsModel.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFF654941),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.select_sku.tr,
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: controller.skuList.map((item) {
                                  return GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        tempSelectedSku = item;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.id == tempSelectedSku.id
                                            ? Color(0xFF8d6e63)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          width: 1,
                                          color: item.id == tempSelectedSku.id
                                              ? Color(0xFF8d6e63)
                                              : Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Text(
                                        item.sku_name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: item.id == tempSelectedSku.id
                                              ? Colors.white
                                              : Color(0xFF654941),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.quantity.tr,
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (tempSelectedNum > 1) {
                                        setDialogState(() {
                                          tempSelectedNum--;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFFE5E7EB),
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        size: 16,
                                        color: tempSelectedNum > 1
                                            ? Color(0xFF654941)
                                            : Color(0xFFE5E7EB),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Text(
                                      tempSelectedNum.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF654941),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        tempSelectedNum++;
                                      });
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFFE5E7EB),
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Color(0xFF654941),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);

                            if (actionType == 'cart') {
                              controller.clickAddToCart(
                                skuId: tempSelectedSku.id,
                                buyNum: tempSelectedNum,
                              );
                            } else {
                              Get.toNamed(
                                Routes.submitOrder,
                                arguments: {
                                  'source': 'buy_now',
                                  'goods_id': controller.goodsModel.id,
                                  'goods_sku_id': tempSelectedSku.id,
                                  'buy_num': tempSelectedNum
                                },
                              );
                            }
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
                                color: actionType == 'cart'
                                    ? Color(0xFF8d6e63)
                                    : Color(0xFFe57373),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                actionType == 'cart'
                                    ? LocaleKeys.add_to_cart.tr
                                    : LocaleKeys.buy_now.tr,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<GoodsDetailController>(
      init: GoodsDetailController(),
      tag: goodsId.toString(),
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
                              Text(
                                '¥${controller.selectedSku.price}',
                                style: TextStyle(
                                  color: Color(0xFFe57373),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),

                              if (controller.selectedSku.line_price > 0)
                                Text(
                                  '¥${controller.selectedSku.line_price}',
                                  style: TextStyle(
                                    color: Color(0xFF6D7482),
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
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
                                  // '用户评价(${controller.commentList.length})',
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.goodsComment, arguments: {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_circle_left_outlined,
                                  color: Color(0xFF4B5563),
                                  size: 22,
                                ),
                                Text(
                                  LocaleKeys.back.tr,
                                  style: TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.cart);
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Color(0xFF4B5563),
                                  size: 22,
                                ),
                                Text(
                                  LocaleKeys.cart.tr,
                                  style: TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showSkuSelectionDialog('cart');
                        // controller.clickAddToCart();
                      },
                      child: Container(
                        width: 140,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8d6e63),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          LocaleKeys.add_to_cart.tr,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showSkuSelectionDialog('buy_now');
                        // Get.toNamed(
                        //   Routes.submitOrder,
                        //   arguments: {
                        //     'source': 'buy_now',
                        //     'goods_id': controller.goodsModel.id,
                        //     'goods_sku_id': controller.selectedSkuId,
                        //   },
                        // );
                      },
                      child: Container(
                        width: 140,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFe57373),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          LocaleKeys.buy_now.tr,
                          style: TextStyle(color: Colors.white, fontSize: 14),
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
