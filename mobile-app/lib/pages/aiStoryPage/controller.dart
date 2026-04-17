import 'package:app/services/http.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class AIStoryController extends GetxController {
  int paintingId = 0;
  String paintingImageUrl = '';
  String paintingName = '';
  String paintingAuthor = '';

  StoryGenerationState storyGenerationState = StoryGenerationState.initial;
  String sotryContent = '';

  @override
  void onInit() async {
    super.onInit();
    paintingId = Get.arguments['id'];
    paintingImageUrl = Get.arguments['image_url'];
    paintingName = Get.arguments['name'];
    paintingAuthor = Get.arguments['author'];
    print('onInit');
  }

  void generateStory(storyType) {
    if (storyGenerationState == StoryGenerationState.loading) return;

    storyGenerationState = StoryGenerationState.loading;
    update();
    HttpService.to
        .post(
          'painting/getAiStory',
          data: {'painting_id': paintingId, 'type': storyType},
          options: Options(
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
          ),
        )
        .then((result) {
          sotryContent = result.data;
          storyGenerationState = StoryGenerationState.success;
          update();
        })
        .catchError((err) {
          sotryContent = '';
          storyGenerationState = StoryGenerationState.failure;
          update();
        });
  }
}

enum StoryGenerationState { initial, loading, success, failure }
