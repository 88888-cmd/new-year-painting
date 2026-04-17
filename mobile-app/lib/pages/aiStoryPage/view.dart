import 'package:app/i18n/index.dart';
import 'package:app/pages/aiStoryPage/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AIStoryPage extends StatefulWidget {
  const AIStoryPage({super.key});

  @override
  State<AIStoryPage> createState() => _AIStoryPageState();
}

class _AIStoryPageState extends State<AIStoryPage> {
  static Map<int, String> storyTypes = {
    10: LocaleKeys.story_type_folk_tales.tr,
    20: LocaleKeys.story_type_mythology.tr,
    30: LocaleKeys.story_type_history.tr,
    40: LocaleKeys.story_type_fable.tr,
    50: LocaleKeys.story_type_modern.tr,
  };
  int selectedStoryType = 10;

  @override
  Widget build(BuildContext context) {
    List<Widget> storyTypeWidgets = [];
    for (final entry in storyTypes.entries) {
      final typeId = entry.key;
      final typeName = entry.value;
      storyTypeWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedStoryType = typeId;
            });
          },
          child: IntrinsicWidth(
            child: Container(
              height: 22,
              decoration: BoxDecoration(
                color:
                    selectedStoryType == typeId
                        ? const Color(0xFF8D6E63)
                        : const Color(0xFFE8DCCD),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Text(
                typeName,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      selectedStoryType == typeId
                          ? Colors.white
                          : const Color(0xFF8D6E63),
                ),
              ),
            ),
          ),
        ),
      );
      storyTypeWidgets.add(SizedBox(width: 10));
    }

    return GetBuilder<AIStoryController>(
      init: AIStoryController(),
      global: false,
      builder:
          (controller) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(LocaleKeys.ai_story.tr),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Color(0xFF5a5a5a),
                        borderRadius: BorderRadius.circular(8),
                        // border: Border.all(
                        //   color: Color(0xFF5D4037),
                        //   width: 3
                        // )
                      ),
                      // color: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          imageUrl: controller.paintingImageUrl,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '《${controller.paintingName}》',
                          style: TextStyle(
                            color: Color(0xFF654941),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.selectPainting)?.then((value) {
                              if (value != null) {
                                setState(() {
                                  controller.paintingId = value['id'];
                                  controller.paintingImageUrl =
                                      value['image_url'];
                                  controller.paintingName = value['name'];
                                  controller.paintingAuthor = value['author'];
                                });
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
                              SizedBox(width: 5),
                              Icon(
                                Icons.refresh_rounded,
                                color: Color(0xFF654941),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),
                    Text(
                      LocaleKeys.select_story_type.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 22,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: storyTypeWidgets,
                      ),
                    ),
                    SizedBox(height: 25),
                    PrimaryButton(
                      width: double.infinity,
                      onPressed: () {
                        controller.generateStory(selectedStoryType);
                      },
                      iconAsset: 'assets/images/magic.png',
                      iconSize: 18,
                      title: LocaleKeys.generate_story.trParams({
                        'name': storyTypes[selectedStoryType]!,
                      }),
                      // title: '生成${storyTypes[selectedStoryType]}',
                    ),
                    SizedBox(height: 25),

                    if (controller.storyGenerationState !=
                        StoryGenerationState.initial)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.paintingName,
                              style: TextStyle(
                                color: Color(0xFF654941),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15),

                            // CupertinoActivityIndicator()
                            if (controller.storyGenerationState ==
                                StoryGenerationState.loading)
                              const AnimatedGenerationText()
                            else if (controller.storyGenerationState ==
                                    StoryGenerationState.success &&
                                controller.sotryContent.isNotEmpty)
                              Text(
                                controller.sotryContent,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555E69),
                                ),
                              )
                            else if (controller.storyGenerationState ==
                                StoryGenerationState.failure)
                              Text(
                                LocaleKeys.generation_failed.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555E69),
                                ),
                              ),
                          ],
                        ),
                      ),

                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

class AnimatedGenerationText extends StatefulWidget {
  const AnimatedGenerationText({super.key});

  @override
  State<AnimatedGenerationText> createState() => _AnimatedGenerationTextState();
}

class _AnimatedGenerationTextState extends State<AnimatedGenerationText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _dotsAnimation = IntTween(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        String dots = '';
        for (int i = 0; i < _dotsAnimation.value; i++) {
          dots += '.';
        }
        return Text(
          '${LocaleKeys.generating.tr}$dots',
          style: const TextStyle(fontSize: 14, color: Color(0xFF555E69)),
        );
      },
    );
  }
}
