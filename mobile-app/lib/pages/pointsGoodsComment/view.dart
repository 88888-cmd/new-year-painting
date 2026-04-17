import 'package:app/i18n/index.dart';
import 'package:app/models/points_goods_comment.dart';
import 'package:app/pages/pointsGoodsComment/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PointsGoodsCommentPage extends StatefulWidget {
  const PointsGoodsCommentPage({super.key});

  @override
  State<PointsGoodsCommentPage> createState() => _PointsGoodsCommentPageState();
}

class _PointsGoodsCommentPageState extends State<PointsGoodsCommentPage> {
  int goodsId = 0;

  @override
  void initState() {
    super.initState();
    goodsId = Get.arguments['goods_id'];
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PointsGoodsCommentController>(
      init: PointsGoodsCommentController(),
      tag: goodsId.toString(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.goods_reviews.tr),
        ),
        body: ListView.builder(
          itemCount: controller.commentList.length,
          itemBuilder: (context, index) {
            PointsGoodsCommentModel goodsCommentModel =
                controller.commentList[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goodsCommentModel.nickname,
                            style: TextStyle(
                              color: Color(0xFF654941),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            goodsCommentModel.create_time,
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
                  children: List.generate(goodsCommentModel.star_num, (index) {
                    return Icon(
                      Icons.star_rounded,
                      color: Color(0xFFffb74d),
                      size: 20,
                    );
                  }),
                ),
                SizedBox(height: 5),
                Text(
                  goodsCommentModel.content,
                  style: TextStyle(color: Color(0xFF654941), fontSize: 14),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
