import 'package:app/i18n/index.dart';
import 'package:app/pages/commentOrderGoods/controller.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/star.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentOrderGoodsPage extends StatefulWidget {
  const CommentOrderGoodsPage({super.key});

  @override
  State<CommentOrderGoodsPage> createState() => _CommentOrderGoodsPageState();
}

class _CommentOrderGoodsPageState extends State<CommentOrderGoodsPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentOrderGoodsController>(
      init: CommentOrderGoodsController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.order_comment1.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.goods_review.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    StarRating(
                      isClickable: true,
                      rating: controller.starCount,
                      starSize: 25,
                      onRatingChanged: (int starCount) {
                        setState(() {
                          controller.starCount = starCount;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: controller.contentController,
                maxLength: 255,
                maxLines: 5,
                style: const TextStyle(color: Color(0xFF654941), fontSize: 15),
                decoration: InputDecoration(
                  hintText: LocaleKeys.enter_comment_with_limit.tr,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9DA4B0),
                    fontSize: 15,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(width: 1, color: Color(0xFFd7ccc8)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(width: 1, color: Color(0xFF8d6e63)),
                  ),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
                  ),
                  counterText: '',
                ),
              ),

              SizedBox(height: 40),
              PrimaryButton(
                width: double.infinity,
                title: LocaleKeys.confirm.tr,
                onPressed: () {
                  controller.clickSubmit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
