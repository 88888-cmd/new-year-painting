import 'dart:async';

import 'package:app/models/painting.dart';
import 'package:app/models/painting_comment.dart';
import 'package:app/models/points_task.dart';
import 'package:app/models/response.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class PaintingDetailController extends GetxController {
  bool isIniting = true; // 是否初始化中

  late PaintingModel paintingModel;
  int rating_count = 0;
  int avg_rating = 0;
  int user_rating = -1;
  bool favorited = false;

  List<PaintingCommentModel> commentList = [];

  // 浏览得积分
  int pointsTaskId = 0;
  PointsTaskType? pointsTaskType;
  int remainingSeconds = 15;
  Timer? pointsTaskTimer;
  bool pointsTaskCompleted = false;

  @override
  void onInit() {
    super.onInit();

    isIniting = true;

    HttpService.to
        .get('painting/detail', params: {'id': Get.arguments['id']})
        .then((result) {
          paintingModel = PaintingModel.fromJson(result.data['painting']);

          rating_count = int.parse(result.data['rating_count'].toString());
          avg_rating = int.parse(result.data['avg_rating'].toString());
          user_rating = int.parse(result.data['user_rating'].toString());
          favorited = bool.parse(result.data['favorited'].toString());

          commentList = (result.data['comments'] as List<dynamic>)
              .map((item) => PaintingCommentModel.fromJson(item))
              .toList();

          isIniting = false;

          if (Get.arguments.containsKey('task_id')) {
            pointsTaskId = Get.arguments['task_id'];
            pointsTaskType = Get.arguments['task_type'];

            if (pointsTaskType == PointsTaskType.browse) {
              _startTimer();
            }
          }

          update();
        });
  }

  void _startTimer() {
    pointsTaskTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
      } else {
        _completeTask();
        timer.cancel();
      }
      update(['pointsTaskProgressWidget']);
    });
  }

  void _completeTask() {
    pointsTaskCompleted = true;
    pointsTaskTimer?.cancel();

    HttpService.to
        .post(
          'points/completeTask',
          data: {'task_id': pointsTaskId, 'painting_id': paintingModel.id},
          showLoading: true,
        )
        .then((result) {
          EasyLoading.showSuccess('获得${result.data['point_reward']}积分～');

          PageEventService.to.post('completed_points_task', {
            'id': pointsTaskId,
          });

          update();
        });
  }

  void ratePainting(int starCount) {
    HttpService.to
        .post(
          'painting/ratePainting',
          data: {'painting_id': paintingModel.id, 'star_count': starCount},
          showLoading: true,
        )
        .then((result) {
          EasyLoading.showSuccess('评分成功～');

          user_rating = starCount;
          update();
        });
  }

  void comment(String content) async {
    EasyLoading.show(status: 'Loading...');

    try {
      ResponseModel result = await HttpService.to.post(
        'painting/addComment',
        data: {'painting_id': paintingModel.id, 'content': content},
      );

      commentList.insert(0, PaintingCommentModel.fromJson(result.data));

      if (pointsTaskType == PointsTaskType.comment && !pointsTaskCompleted) {
        pointsTaskCompleted = true;

        ResponseModel result = await HttpService.to.post(
          'points/completeTask',
          data: {'task_id': pointsTaskId, 'painting_id': paintingModel.id},
        );

        EasyLoading.dismiss();

        EasyLoading.showSuccess('获得${result.data['point_reward']}积分～');

        PageEventService.to.post('completed_points_task', {'id': pointsTaskId});
      } else {
        EasyLoading.dismiss();
      }
      update();
    } catch (e) {
      // EasyLoading.dismiss();
    }
  }

  void favorite() async {
    EasyLoading.show(status: 'Loading...');

    try {
      ResponseModel result = await HttpService.to.post(
        'painting/favoritePainting',
        data: {'painting_id': paintingModel.id},
      );

      favorited = true;

      if (pointsTaskType == PointsTaskType.favorite && !pointsTaskCompleted) {
        pointsTaskCompleted = true;

        ResponseModel result = await HttpService.to.post(
          'points/completeTask',
          data: {'task_id': pointsTaskId, 'painting_id': paintingModel.id},
        );

        EasyLoading.dismiss();

        EasyLoading.showSuccess('获得${result.data['point_reward']}积分～');

        PageEventService.to.post('completed_points_task', {'id': pointsTaskId});
      } else {
        EasyLoading.dismiss();
      }
      update();
    } catch (e) {
      // EasyLoading.dismiss();
    }
    // HttpService.to
    //     .post(
    //       'painting/favoritePainting',
    //       data: {'painting_id': paintingModel.id},
    //       showLoading: true,
    //     )
    //     .then((result) {
    //       favorited = true;
    //       update();
    //     });
  }

  void cancelFavorite() {
    HttpService.to
        .post(
          'painting/cancelFavoritePainting',
          data: {'painting_id': paintingModel.id},
          showLoading: true,
        )
        .then((result) {
          favorited = false;
          update();
        });
  }

  @override
  void onClose() {
    pointsTaskTimer?.cancel();
    super.onClose();
  }
}
