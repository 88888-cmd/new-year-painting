import 'package:app/i18n/index.dart';
import 'package:app/pages/aiImageEdit/controller.dart';
import 'package:app/utils/assets_picker.dart';
import 'package:app/utils/constants.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/dashedPainter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AIImageEditPage extends StatefulWidget {
  const AIImageEditPage({super.key});

  @override
  State<AIImageEditPage> createState() => _AIImageEditPageState();
}

class _AIImageEditPageState extends State<AIImageEditPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AIImageEditController>(
      init: AIImageEditController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.ai_image_edit.tr),
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
                    LocaleKeys.upload_photo_convert_style.tr,
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 25),

                  GestureDetector(
                    onTap: () {
                      AssetsPicker.image(context: context).then((
                        XFile? xfile,
                      ) async {
                        if (xfile != null) {
                          if ((await xfile.length()) >= 10 * 1024 * 1024) {
                            EasyLoading.showToast('最大文件大小为5mb');
                            return;
                          }
                          controller.upload(xfile);
                        }
                      });
                    },
                    child: controller.uploadFileModel == null
                        ? Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Stack(
                              fit: StackFit.loose,
                              children: [
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: DashedPainter(
                                        strokeWidth: 2,
                                        radius: Radius.circular(6),
                                        color: Color(0xFFd7ccc8),
                                        dashPattern: [8, 5],
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned.fill(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        color: Color(0xFF9E9E9E),
                                        // color: Color(0xFF6B7280),
                                        size: 35,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        LocaleKeys.upload_image.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              imageUrl:
                                  Constants.mediaBaseUrl +
                                  controller.uploadFileModel!.file_url,
                            ),
                          ),
                  ),

                  SizedBox(height: 25),
                  Text(
                    LocaleKeys.select_style.tr,
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.imageedit_type = 10;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: controller.imageedit_type == 10
                            ? Border.all(width: 2, color: Color(0xFF8b5a2b))
                            : Border.all(width: 1, color: Color(0xFFc0a080)),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        LocaleKeys.style_french_picture_book.tr,
                        style: TextStyle(
                          color: Color(0xFF654941),
                          fontSize: 15,
                          fontWeight: controller.imageedit_type == 10
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.imageedit_type = 20;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: controller.imageedit_type == 20
                            ? Border.all(width: 2, color: Color(0xFF8b5a2b))
                            : Border.all(width: 1, color: Color(0xFFc0a080)),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        LocaleKeys.style_gold_leaf_art.tr,
                        style: TextStyle(
                          color: Color(0xFF654941),
                          fontSize: 15,
                          fontWeight: controller.imageedit_type == 20
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          imageUrl: controller.generateResult,
                        ),
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
