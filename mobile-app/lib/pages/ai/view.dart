import 'package:app/i18n/index.dart';
import 'package:app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.tabbar_ai.tr)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.aiChat);
                },
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFF1E0CB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF5D4037).withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Color(0xFFC53F3F).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFFC53F3F).withOpacity(0.2),
                            width: 2,
                            // style: BorderStyle.dashed,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chat,
                            size: 30,
                            color: Color(0xFFC53F3F),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      Text(
                       LocaleKeys.ai_chat.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFC53F3F),
                        ),
                      ),
                      SizedBox(height: 5),

                      Text(
                        LocaleKeys.ai_chat_desc.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.aiText2Image);
                },
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFF1E0CB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF5D4037).withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Color(0xFFC53F3F).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFFC53F3F).withOpacity(0.2),
                            width: 2,
                            // style: BorderStyle.dashed,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.draw_rounded,
                            size: 30,
                            color: Color(0xFFC53F3F),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      Text(
                        LocaleKeys.ai_text_2_image.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFC53F3F),
                        ),
                      ),
                      SizedBox(height: 5),

                      Text(
                        LocaleKeys.ai_text_2_image_desc.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.aiImageEdit);
                },
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFF1E0CB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF5D4037).withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Color(0xFFC53F3F).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFFC53F3F).withOpacity(0.2),
                            width: 2,
                            // style: BorderStyle.dashed,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chat,
                            size: 30,
                            color: Color(0xFFC53F3F),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      Text(
                        LocaleKeys.ai_image_edit.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFC53F3F),
                        ),
                      ),
                      SizedBox(height: 5),

                      Text(
                        LocaleKeys.ai_image_edit_desc.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
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
