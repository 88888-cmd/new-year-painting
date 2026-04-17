import 'package:app/i18n/index.dart';
import 'package:app/models/points_task.dart';
import 'package:app/pages/paintingDetail/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/star.dart';
import 'package:audio_player/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/pages/paintingDetail/widgets/commentDialog.dart';
import 'package:get/get.dart';

class PaintingDetailPage extends StatefulWidget {
  const PaintingDetailPage({super.key});

  @override
  State<PaintingDetailPage> createState() => _PaintingDetailPageState();
}

class _PaintingDetailPageState extends State<PaintingDetailPage> {
  int paintingId = 0;

  AudioPlayer? player;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    paintingId = Get.arguments['id'];

    player = AudioPlayer();
  }

  @override
  void dispose() {
    player?.stop();
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(
      context,
    ).bottom;

    return GetBuilder<PaintingDetailController>(
      init: PaintingDetailController(),
      tag: paintingId.toString(),
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
                actions: [
                  IconButton(
                    onPressed: () {
                      if (controller.paintingModel.bg_mp3_url.isNotEmpty) {
                        if (isPlaying) {
                          player?.stop();
                          setState(() => isPlaying = false);
                        } else {
                          player?.play(controller.paintingModel.bg_mp3_url);
                          setState(() => isPlaying = true);
                        }
                      }
                    },
                    icon: Icon(Icons.my_library_music_rounded),
                  ),
                  if (controller.favorited)
                    IconButton(
                      onPressed: () {
                        controller.cancelFavorite();
                      },
                      icon: Icon(Icons.favorite_outlined, color: Colors.pink),
                      // icon: Icon(Icons.favorite_border_outlined),
                      // icon: Icon(Icons.bookmark_border_rounded),
                    )
                  else
                    IconButton(
                      onPressed: () {
                        controller.favorite();
                      },
                      icon: Icon(Icons.favorite_border_outlined),
                    ),
                ],
              ),
              body: SafeArea(
                maintainBottomViewPadding: true,
                child: Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            width: double.infinity,
                            height: 340,
                            decoration: BoxDecoration(
                              // color: Color.fromARGB(255, 199, 185, 181),
                              // color: Color(0xFFE5E5E5),
                              color: Color(0xFF5a5a5a),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black.withOpacity(0.6),
                              //     blurRadius: 8,
                              //     spreadRadius: -2,
                              //     offset: Offset(0, 0),
                              //   ),
                              // ],
                            ),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              height: 340,
                              imageUrl: controller.paintingModel.image_url,
                              fit: BoxFit.contain,
                            ),
                          ),
                          // child: Container(
                          //   width: double.infinity,
                          //   height: 300,
                          //   color: Colors.blueGrey,
                          //   alignment: Alignment.center,
                          //   child: Text('年画图片', style: TextStyle(color: Colors.white)),
                          // ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ).copyWith(top: 16, bottom: 13),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              controller.paintingModel.name,
                              style: TextStyle(
                                color: Color(0xFF654941),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              '${LocaleKeys.author.tr}：${controller.paintingModel.author}',
                              style: TextStyle(
                                color: Color(0xFF4D5562),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              '${LocaleKeys.dynasty.tr}：${controller.paintingModel.dynasty}',
                              style: TextStyle(
                                color: Color(0xFF4D5562),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ).copyWith(top: 25),
                          sliver: SliverToBoxAdapter(
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  Routes.aiStory,
                                  arguments: {
                                    'id': controller.paintingModel.id,
                                    'image_url':
                                        controller.paintingModel.image_url,
                                    'name': controller.paintingModel.name,
                                    'author': controller.paintingModel.author,
                                  },
                                );
                              },
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8d6e63),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      width: 18,
                                      height: 18,
                                      'assets/images/robot.png',
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      LocaleKeys.listen_to_ai_explain.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ).copyWith(top: 16),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.grey.withOpacity(0.00),
                                //     spreadRadius: 0.5,
                                //     blurRadius: 1.5,
                                //     offset: Offset(0, 1),
                                //   ),
                                // ],
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        LocaleKeys.my_rating.tr,
                                        style: TextStyle(
                                          color: Color(0xFF654941),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        LocaleKeys.rating_info.trParams({
                                          'avg_rating': controller.avg_rating
                                              .toString(),
                                          'count': controller.rating_count
                                              .toString(),
                                        }),
                                        // '${controller.avg_rating}分(${controller.rating_count}人评分)',
                                        style: TextStyle(
                                          color: Color(0xFF654941),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  StarRating(
                                    isClickable: controller.user_rating == -1,
                                    rating: controller.user_rating,
                                    onRatingChanged: (int starCount) {
                                      controller.ratePainting(starCount);
                                    },
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    controller.user_rating == -1
                                        ? LocaleKeys.rate_work_by_stars.tr
                                        : LocaleKeys.you_have_rated.tr,
                                    style: TextStyle(
                                      color: Color(0xFF654941),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ).copyWith(top: 20, bottom: 25),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKeys.detail_introduction.tr,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  controller.paintingModel.content,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (controller.commentList.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ).copyWith(bottom: 15),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${LocaleKeys.comment.tr}(${controller.commentList.length})',
                                    style: TextStyle(
                                      color: Color(0xFF654941),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  for (
                                    int i = 0;
                                    i < controller.commentList.length;
                                    i++
                                  )
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                child: Icon(
                                                  Icons.person_rounded,
                                                  color: Colors.white,
                                                  size: 17,
                                                ),
                                                radius: 15,
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      controller
                                                          .commentList[i]
                                                          .nickname,
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF654941,
                                                        ),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      controller
                                                          .commentList[i]
                                                          .create_time,
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF6B7280,
                                                        ),
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
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    GetBuilder<PaintingDetailController>(
                      id: 'pointsTaskProgressWidget',
                      tag: paintingId.toString(),
                      builder: (controller) =>
                          controller.pointsTaskType == PointsTaskType.browse &&
                              !controller.pointsTaskCompleted
                          ? Positioned(
                              top: MediaQuery.of(context).padding.top + 16,
                              right: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: CircularProgressIndicator(
                                        value:
                                            1 -
                                            (controller.remainingSeconds / 15),
                                        strokeWidth: 2,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),

                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${controller.remainingSeconds}",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              "s",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
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
                          hintText: LocaleKeys.comment_input_hint.tr,
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
