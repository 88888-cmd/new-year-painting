import 'package:app/i18n/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final taskTexts = {
  1: (String name) => name.isEmpty
      ? LocaleKeys.task_browse_any.tr
      : LocaleKeys.task_browse_any.trParams({'name': name}),
  2: (String name) => name.isEmpty
      ? LocaleKeys.task_favorite_any.tr
      : LocaleKeys.task_favorite_specific.trParams({'name': name}),
  3: (String name) => name.isEmpty
      ? LocaleKeys.task_comment_any.tr
      : LocaleKeys.task_comment_specific.trParams({'name': name}),
  // 1: (String name) => name.isEmpty ? '浏览任意年画15秒' : '浏览年画【$name】15秒',
  // 2: (String name) => name.isEmpty ? '收藏任意年画' : '收藏年画【$name】',
  // 3: (String name) => name.isEmpty ? '评论任意年画' : '评论年画【$name】',
};
final taskIcons = {
  1: Icons.remove_red_eye_rounded,
  2: Icons.favorite_rounded,
  3: Icons.add_comment_rounded,
};

final taskEnums = {
  1: PointsTaskType.browse,
  2: PointsTaskType.favorite,
  3: PointsTaskType.comment,
};

class PointsTaskModel {
  int id = 0;
  int task_type = 0;
  int painting_id = 0;
  String painting_name = '';
  int daily_limit = 0;
  int point_reward = 0;
  int progress = 0;

  PointsTaskModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    task_type = int.parse(json['task_type'].toString());
    painting_id = int.parse(json['painting_id'].toString());
    painting_name = json['painting_name'].toString();
    daily_limit = int.parse(json['daily_limit'].toString());
    point_reward = int.parse(json['point_reward'].toString());
    progress = int.parse(json['progress'].toString());
  }

  IconData? getTaskIcon() {
    return taskIcons[task_type];
  }

  String getTaskNameText() {
    return taskTexts[task_type]?.call(painting_name) ?? '';
  }

  PointsTaskType? getTaskEnum() {
    return taskEnums[task_type];
  }

  bool get isCompleted => progress >= daily_limit;
}

enum PointsTaskType {
  browse, // 浏览任务
  comment, // 评价任务
  favorite, // 收藏任务
}
