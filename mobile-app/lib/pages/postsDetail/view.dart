import 'package:app/i18n/index.dart';
import 'package:app/pages/postsDetail/controller.dart';
import 'package:app/pages/postsDetail/widgets/commentDialog.dart';
import 'package:app/store/user.dart';
import 'package:app/widgets/dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class PostsDetailPage extends StatefulWidget {
  const PostsDetailPage({super.key});

  @override
  State<PostsDetailPage> createState() => _PostsDetailPageState();
}

class _PostsDetailPageState extends State<PostsDetailPage> {
  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<PostsDetailController>(
      init: PostsDetailController(),
      global: false,
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
                actions: UserStore.to.id == controller.postsModel.user_id
                    ? [
                        PopupMenuButton(
                          icon: Icon(Icons.more_horiz_rounded),
                          color: Colors.white,
                          tooltip: 'Menu',
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(LocaleKeys.delete.tr),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            switch (value) {
                              case 'delete':
                                CustomDialog.show(
                                  context: context,
                                  builder: (context) => Text(
                                    LocaleKeys.dialog_title_delete.tr,
                                    style: TextStyle(
                                      color: Color(0xFF272624),
                                      fontSize: 17,
                                    ),
                                  ),
                                  onCancel: () => Navigator.of(context).pop(),
                                  onConfirm: () {
                                    Navigator.of(context).pop();
                                    controller.delete();
                                  },
                                );
                                break;
                            }
                          },
                        ),
                      ]
                    : null,
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      controller.postsModel.nickname,
                                      style: TextStyle(
                                        color: Color(0xFF654941),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      controller.postsModel.create_time,
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
                          SizedBox(height: 15),
                          if (controller.postsModel.painting_name.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFF8E9D1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                LocaleKeys.painting_story_posts_tag.trParams({
                                  'name': controller.postsModel.painting_name,
                                }),
                                style: TextStyle(
                                  color: Color(0xFF8B4513),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Text(
                            controller.postsModel.title,
                            style: TextStyle(
                              color: Color(0xFF654941),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (controller.postsModel.content.isNotEmpty) ...[
                            SizedBox(height: 10),
                            Text(
                              controller.postsModel.content,
                              style: TextStyle(
                                color: Color(0xFF555E69),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (controller.postsModel.type == 10 &&
                                  controller.postsModel.image_urls.isNotEmpty ||
                              controller.postsModel.type == 20 &&
                                  controller.postsModel.video_url.isNotEmpty)
                            SizedBox(height: 10),

                          if (controller.postsModel.type == 10 &&
                              controller.postsModel.image_urls.isNotEmpty)
                            GridView.count(
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              children: [
                                for (
                                  int i = 0;
                                  i < controller.postsModel.image_urls.length;
                                  i++
                                )
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          controller.postsModel.image_urls[i],
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            )
                          else if (controller.postsModel.type == 20 &&
                              controller.postsModel.video_url.isNotEmpty)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child:
                                  (controller.videoPlayerController != null &&
                                      controller
                                          .videoPlayerController!
                                          .value
                                          .isInitialized)
                                  ? VideoPlayer(
                                      controller.videoPlayerController!,
                                    )
                                  : Container(color: Colors.black),
                            ),

                          if (controller.postsModel.tags.isNotEmpty)
                            SizedBox(height: 15),
                          if (controller.postsModel.tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 5,
                              children: [
                                for (
                                  int i = 0;
                                  i < controller.postsModel.tags.length;
                                  i++
                                )
                                  IntrinsicWidth(
                                    child: Container(
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF4F0EF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '# ${controller.postsModel.tags[i]}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8d6e63),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          SizedBox(height: 25),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Color(0xFF654941),
                                    // color: Color.fromARGB(255, 137, 149, 163),
                                    size: 18,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    LocaleKeys.posts_view_count.trParams({
                                      'count': controller.postsModel.view_count
                                          .toString(),
                                    }),
                                    style: TextStyle(
                                      color: Color(0xFF654941),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: Color(0xFF654941),
                                    size: 18,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    LocaleKeys.posts_comment_count.trParams({
                                      'count': controller
                                          .postsModel
                                          .comment_count
                                          .toString(),
                                    }),
                                    style: TextStyle(
                                      color: Color(0xFF654941),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (controller.thumbed) {
                                    controller.cancelThumb();
                                  } else {
                                    controller.thumb();
                                  }
                                },
                                child: Row(
                                  children: [
                                    if (controller.thumbed)
                                      Icon(
                                        Icons.thumb_up_alt,
                                        color: Colors.pink,
                                        size: 18,
                                      )
                                    else
                                      Icon(
                                        Icons.thumb_up_alt_outlined,
                                        color: Color(0xFF654941),
                                        size: 18,
                                      ),
                                    SizedBox(width: 5),
                                    Text(
                                      LocaleKeys.thumb.tr,
                                      style: TextStyle(
                                        color: Color(0xFF654941),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ).copyWith(top: 16),
                      child: Text(
                        '${LocaleKeys.comment.tr}(${controller.commentList.length})',
                        style: TextStyle(
                          color: Color(0xFF654941),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    for (int i = 0; i < controller.commentList.length; i++)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ).copyWith(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.commentList[i].nickname,
                                        style: TextStyle(
                                          color: Color(0xFF654941),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        controller.commentList[i].create_time,
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
                            Text(
                              controller.commentList[i].content,
                              style: TextStyle(
                                color: Color(0xFF654941),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 16),
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
                      child: TextField(
                        readOnly: true,
                        style: const TextStyle(
                          color: Color(0xFF654941),
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: LocaleKeys.posts_comment_input_hint.tr,
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
                            vertical: 10,
                          ),
                        ),
                        onTap: () {
                          CommentDialog.show(
                            context: context,
                            onSend: (content) {
                              Navigator.of(context).pop();
                              controller.comment(content);
                            },
                          );
                        },
                      ),
                    ),
                    // SizedBox(width: 10),
                    // PrimaryButton(
                    //   width: 80,
                    //   height: 40,
                    //   // gbColor: Colors.grey.withOpacity(0.6),
                    //   title: '发送',
                    //   onPressed: () {
                    //     // controller.loginClick();
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
