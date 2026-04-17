import 'package:app/i18n/index.dart';
import 'package:app/pages/addPosts/controller.dart';
import 'package:app/utils/assets_picker.dart';
import 'package:app/utils/constants.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/dashedPainter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddPostsPage extends StatefulWidget {
  const AddPostsPage({super.key});

  @override
  State<AddPostsPage> createState() => _AddPostsPageState();
}

class _AddPostsPageState extends State<AddPostsPage> {
  List<String> tags = ['门神文化', '节日风俗', '非遗传承', '年画收藏', '创作灵感', '鉴别技巧'];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddPostsController>(
      init: AddPostsController(),
      builder:
          (controller) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(LocaleKeys.publish_posts.tr),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.categoryList.isNotEmpty)
                      SizedBox(
                        height: 30,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              controller.categoryList
                                  .map(
                                    (item) => Row(
                                      children: [
                                        CategoryButtonItem(
                                          title: item.name,
                                          value: item.id,
                                          isSelected:
                                              item.id ==
                                              controller.selectedCategoryId,
                                          onPressed: () {
                                            setState(() {
                                              controller.selectedCategoryId =
                                                  item.id;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 12),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    if (controller.categoryList.isNotEmpty)
                      SizedBox(height: 25),
                    TextField(
                      controller: controller.titleController,
                      maxLength: 255,
                      style: const TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: LocaleKeys.enter_title.tr,
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
                    SizedBox(height: 15),
                    TextField(
                      controller: controller.contentController,
                      maxLength: 1000,
                      maxLines: 8,
                      style: const TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: LocaleKeys.enter_content.tr,
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
                      ),
                    ),
                    SizedBox(height: 15),
                    GridView.count(
                      // 屏蔽gridView滑动，防止与SingleChildScrollView冲突
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        for (int i = 0; i < controller.imageList.length; i++)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      Constants.mediaBaseUrl +
                                      controller.imageList[i],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        controller.imageList.removeAt(i);
                                      });
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (controller.imageList.length < 9)
                          GestureDetector(
                            onTap: () async {
                              AssetsPicker.multiImage(
                                context: context,
                                limit: 9 - controller.imageList.length,
                              ).then((List<XFile> xfileList) async {
                                for (XFile xFile in xfileList) {
                                  if ((await xFile.length()) >=
                                      10 * 1024 * 1024) {
                                    EasyLoading.showToast('最大文件大小为5mb');
                                    return;
                                  }
                                }

                                controller.upload(xfileList);
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_rounded,
                                          color: Color(0xFF9E9E9E),
                                          // color: Color(0xFF6B7280),
                                          size: 30,
                                        ),
                                        Text(
                                          LocaleKeys.upload_image.tr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      LocaleKeys.select_tag.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < tags.length; i++)
                          GestureDetector(
                            onTap: () => controller.toggleTag(tags[i]),
                            child: IntrinsicWidth(
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8DCCD),
                                  border: Border.all(
                                    color:
                                        controller.isTagSelected(tags[i])
                                            ? Color(0xFF6d4c41)
                                            : Color(0xFFE8DCCD),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '# ${tags[i]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8d6e63),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // IntrinsicWidth(
                        //   child: Container(
                        //     height: 24,
                        //     decoration: BoxDecoration(
                        //       color: Color(0xFF8d6e63),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     padding: const EdgeInsets.symmetric(horizontal: 12),
                        //     alignment: Alignment.center,
                        //     child: Text(
                        //       '# 传统工艺',
                        //       style: TextStyle(
                        //         fontSize: 12,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // for (int i = 0; i < tags.length; i++)
                        //   IntrinsicWidth(
                        //     child: Container(
                        //       height: 24,
                        //       decoration: BoxDecoration(
                        //         color: Color(0xFFE8DCCD),
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 10,
                        //       ),
                        //       alignment: Alignment.center,
                        //       child: Text(
                        //         '# ${tags[i]}',
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           color: Color(0xFF8d6e63),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                      ],
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
          ),
    );
  }
}

class CategoryButtonItem extends StatelessWidget {
  final String title;
  final int value;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryButtonItem({
    super.key,
    required this.title,
    required this.value,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF8D6E63) : Color(0xFFFAF6F0),
            border: Border.all(
              color: isSelected ? Color(0xFF6d4c41) : Color(0xFFDBD0CB),
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Color(0xFF654941),
              // color: isSelected ? Colors.white : Color(0xFF987B5A),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
