import 'package:app/i18n/index.dart';
import 'package:app/models/painting_summary.dart';
import 'package:app/pages/submitWish/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubmitWishPage extends StatefulWidget {
  const SubmitWishPage({super.key});

  @override
  State<SubmitWishPage> createState() => _SubmitWishPageState();
}

class _SubmitWishPageState extends State<SubmitWishPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubmitWishController>(
      init: SubmitWishController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.wish.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.select_painting.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.selectPainting)?.then((value) {
                          if (value != null) {
                            controller.updateSelectedPainting(
                              id: value['id'],
                              imageUrl: value['image_url'],
                              name: value['name'],
                            );
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            LocaleKeys.change_painting.tr,
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
                SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 90,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        controller.randomPaintingList.length,
                        (index) {
                          PaintingSummaryModel paintingSummaryModel =
                              controller.randomPaintingList[index];
                          return GestureDetector(
                            onTap: () {
                              controller.updateSelectedPainting(
                                id: paintingSummaryModel.id,
                                imageUrl: paintingSummaryModel.image_url,
                                name: paintingSummaryModel.name,
                              );
                            },
                            child: Container(
                              width: 150,
                              height: 90,
                              margin: const EdgeInsets.only(right: 10),
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
                                border:
                                    controller.paintingId ==
                                        paintingSummaryModel.id
                                    ? Border.all(
                                        width: 2,
                                        color: Color(0xFF8d6e63),
                                      )
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      imageUrl: paintingSummaryModel.image_url,
                                    ),

                                    if (controller.paintingId ==
                                        paintingSummaryModel.id)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black38,
                                              blurRadius: 1.5,
                                              offset: Offset(0, 1),
                                            ),
                                            
                                          ],
                                        ),
                                      ),

                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        height: 26,
                                        color: Colors.black.withOpacity(0.6),
                                        alignment: Alignment.center,
                                        child: Text(
                                          paintingSummaryModel.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),
                Text(
                  LocaleKeys.write_your_wish.tr,
                  style: TextStyle(
                    color: Color(0xFF654941),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                Container(
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
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: controller.contentController,
                        maxLength: 255,
                        maxLines: 5,
                        style: const TextStyle(
                          color: Color(0xFF654941),
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: '${LocaleKeys.write_your_wish.tr}...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9DA4B0),
                            fontSize: 15,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6),
                            ),
                            borderSide: BorderSide(
                              width: 1,
                              color: const Color(0xFFd7ccc8),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6),
                            ),
                            borderSide: BorderSide(
                              width: 1,
                              color: const Color(0xFFd7ccc8),
                            ),
                          ),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 13,
                          ),
                        ),
                      ),

                      // SizedBox(height: 24),

                      // Text(
                      //   '0/100',
                      //   style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                      // ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                PrimaryButton(
                  width: double.infinity,
                  title: LocaleKeys.submit_wish.tr,
                  onPressed: () {
                    controller.clickSubmit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
