import 'package:app/i18n/index.dart';
import 'package:app/pages/myPosts/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyPostsController>(
      init: MyPostsController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.my_posts.tr),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Get.toNamed(
                  Routes.postsDetail,
                  arguments: {'id': controller.list[index].id},
                );
              },
              child: Container(
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
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 13, bottom: index == 9 ? 13 : 0),
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
                                controller.list[index].nickname,
                                style: TextStyle(
                                  color: Color(0xFF654941),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                controller.list[index].create_time,
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
                    SizedBox(height: 10),

                    if (controller.list[index].painting_name.isNotEmpty)
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
                            'name': controller.list[index].painting_name,
                          }),
                          style: TextStyle(
                            color: Color(0xFF8B4513),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    Text(
                      controller.list[index].title,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      controller.list[index].content,
                      style: TextStyle(color: Color(0xFF555E69), fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    if (controller.list[index].type == 10 &&
                        controller.list[index].image_urls.isNotEmpty)
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
                            i < controller.list[index].image_urls.length;
                            i++
                          )
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: controller.list[index].image_urls[i],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      )
                    else if (controller.list[index].type == 20 &&
                        controller.list[index].video_cover_url.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 18 / 9,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl:
                                    controller.list[index].video_cover_url,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.play_circle,
                                size: 42,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              color: Color(0xFF555E69),
                              // color: Color.fromARGB(255, 137, 149, 163),
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              LocaleKeys.posts_view_count.trParams({
                                'count': controller.list[index].view_count
                                    .toString(),
                              }),
                              style: TextStyle(
                                color: Color(0xFF555E69),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Color(0xFF555E69),
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              LocaleKeys.posts_comment_count.trParams({
                                'count': controller.list[index].comment_count
                                    .toString(),
                              }),
                              style: TextStyle(
                                color: Color(0xFF555E69),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              color: Color(0xFF555E69),
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              LocaleKeys.thumb.tr,
                              style: TextStyle(
                                color: Color(0xFF555E69),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: controller.list.length,
        ),
      ),
    );
  }
}
