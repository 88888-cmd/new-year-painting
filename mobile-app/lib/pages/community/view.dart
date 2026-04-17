import 'package:app/i18n/index.dart';
import 'package:app/pages/community/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommunityController>(
      init: CommunityController(),
      builder: (controller) => controller.isIniting
          ? Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.tabbar_community.tr),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search_rounded),
                  ),
                ],
              ),
              body: Center(child: CircularProgressIndicator()),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.tabbar_community.tr),
                actions: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed(Routes.searchPosts);
                    },
                    icon: Icon(Icons.search_rounded),
                  ),
                  // IconButton(onPressed: () {}, icon: Icon(Icons.add_rounded)),
                  PopupMenuButton(
                    icon: Icon(Icons.add_rounded),
                    color: Colors.white,
                    tooltip: 'Menu',
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (BuildContext context) {
                      return [
                        if (controller.selectedCategoryId != 2)
                          PopupMenuItem(
                            value: 'add_posts',
                            child: Text(LocaleKeys.publish_posts.tr),
                          ),
                        PopupMenuItem(
                          value: 'add_story_posts',
                          child: Text(LocaleKeys.publish_posts_my_story.tr),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      switch (value) {
                        case 'add_posts':
                          Get.toNamed(
                            Routes.addPosts,
                            arguments: {
                              'from_category_id': controller
                                  .categoryList[controller.selectedCategoryId]
                                  .id,
                            },
                          );
                          break;
                        case 'add_story_posts':
                          Get.toNamed(Routes.addStoryPostsFirst);
                          break;
                      }
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(46),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: controller.tabController,
                      isScrollable: true,
                      tabs: controller.categoryList
                          .map((item) => Tab(text: item.name))
                          .toList(),
                    ),
                  ),
                ),
              ),
              body: EasyRefresh(
                controller: controller.easyRefreshController,
                header: const ClassicHeader(
                  showText: false,
                  showMessage: false,
                  iconTheme: IconThemeData(size: 20),
                ),
                footer: const ClassicFooter(
                  showText: false,
                  showMessage: false,
                  iconTheme: IconThemeData(size: 20),
                ),
                onRefresh: () {
                  controller.refreshList();
                },
                onLoad: () {
                  controller.loadMoreList();
                },
                child: ListView.builder(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    'name':
                                        controller.list[index].painting_name,
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
                            if (controller.list[index].content.isNotEmpty) ...[
                              Text(
                                controller.list[index].content,
                                style: TextStyle(
                                  color: Color(0xFF555E69),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
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
                                    i <
                                        controller
                                            .list[index]
                                            .image_urls
                                            .length;
                                    i++
                                  )
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                        imageUrl: controller
                                            .list[index]
                                            .image_urls[i],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              )
                            else if (controller.list[index].type == 20 &&
                                controller
                                    .list[index]
                                    .video_cover_url
                                    .isNotEmpty)
                              AspectRatio(
                                aspectRatio: 18 / 9,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                        imageUrl: controller
                                            .list[index]
                                            .video_cover_url,
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
                                        'count': controller
                                            .list[index]
                                            .view_count
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
                                        'count': controller
                                            .list[index]
                                            .comment_count
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
              // floatingActionButtonLocation: CustomFloatingActionButtonLocation(
              //   FloatingActionButtonLocation.endFloat,
              //   -5,
              //   -40,
              // ),
              // floatingActionButton: FloatingActionButton(
              //   mini: true,
              //   onPressed: () {
              //     Get.toNamed(Routes.addPosts);
              //   },
              //   tooltip: 'Add',
              //   backgroundColor: const Color(0xFF8d6e63),
              //   child: const Icon(Icons.add),
              // ),
            ),
    );
  }
}

// class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
//   FloatingActionButtonLocation location;
//   double offsetX;
//   double offsetY;
//   CustomFloatingActionButtonLocation(this.location, this.offsetX, this.offsetY);

//   @override
//   Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
//     Offset offset = location.getOffset(scaffoldGeometry);
//     return Offset(offset.dx + offsetX, offset.dy + offsetY);
//   }
// }
