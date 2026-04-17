import 'package:app/i18n/index.dart';
import 'package:app/pages/aiText2Image/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/utils/constants.dart';
import 'package:app/widgets/button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AIText2ImagePage extends StatefulWidget {
  const AIText2ImagePage({super.key});

  @override
  State<AIText2ImagePage> createState() => _AIText2ImagePageState();
}

class _AIText2ImagePageState extends State<AIText2ImagePage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AIText2ImageController>(
      init: AIText2ImageController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.ai_text_2_image.tr),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    LocaleKeys
                        .enter_keyword_combination_custom_new_year_painting
                        .tr,
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    LocaleKeys
                        .combine_traditional_elements_and_preferences_ai_create_blessing
                        .tr,
                    style: TextStyle(color: Color(0xFF555E69), fontSize: 14),
                  ),
                  SizedBox(height: 25),
                  Text(
                    LocaleKeys.custom_keywords.tr,
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: controller.promptController,
                    maxLength: 255,
                    style: const TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: LocaleKeys.enter_keywords_example.tr,
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
                          color: const Color(0xFF8d6e63),
                        ),
                      ),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 13,
                      ),
                      counterText: '',
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    LocaleKeys.multiple_keywords_connected_by_plus.tr,
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),

                  SizedBox(height: 30),

                  PrimaryButton(
                    width: double.infinity,
                    title: LocaleKeys.confirm.tr,
                    onPressed: () {
                      controller.clickGenerate();
                    },
                  ),

                  if (controller.generateResult.isNotEmpty) ...[
                    SizedBox(height: 30),
                    Text(
                      LocaleKeys.generate_result_preview.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              imageUrl:
                                  Constants.mediaBaseUrl +
                                  controller.generateResult[0],
                            ),
                          ),

                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.black.withOpacity(0.6),
                              ),
                              child: Text(
                                LocaleKeys.image_preview.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            right: 15,
                            child: Row(
                              children: [
                                FloatingActionButton.small(
                                  heroTag: 'shareBtn',
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  onPressed: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoActionSheet(
                                          title: Text(LocaleKeys.share.tr),
                                          actions: [
                                            CupertinoActionSheetAction(
                                              child: Text(
                                                LocaleKeys
                                                    .share_to_community
                                                    .tr,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Get.toNamed(
                                                  Routes.addPosts,
                                                  arguments: {
                                                    'from_category_id': 0,
                                                    'title': '我使用AI生成了一幅年画～',
                                                    'content': '',
                                                    'image_url': controller
                                                        .generateResult,
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Icon(Icons.share),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
