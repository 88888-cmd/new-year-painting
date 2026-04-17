import 'package:app/models/points_task.dart';
import 'package:app/models/user_points_log.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class PointsController extends GetxController {
  bool isIniting = true; // 是否初始化中

  int total_points = 0;
  int normal_points = 0;
  int cultural_points = 0;
  int cur_month_total_points = 0;
  List<PointsTaskModel> tasks = [];
  List<UserPointsLogModel> logs = [];

  @override
  void onInit() {
    super.onInit();

    loadData();

    PageEventService.to.add('completed_points_task', (data) {
      loadData();
    });
  }

  void loadData() {
    isIniting = true;
    update();

    HttpService.to.get('points/getMainData').then((result) {
      total_points = int.parse(result.data['total_points'].toString());
      normal_points = int.parse(result.data['normal_points'].toString());
      cultural_points = int.parse(result.data['cultural_points'].toString());
      cur_month_total_points = int.parse(
        result.data['cur_month_total_points'].toString(),
      );

      tasks = (result.data['tasks'] as List<dynamic>)
          .map((item) => PointsTaskModel.fromJson(item))
          .toList();

      logs = (result.data['logs'] as List<dynamic>)
          .map((item) => UserPointsLogModel.fromJson(item))
          .toList();

      isIniting = false;
      update();
    });
  }

  @override
  void onClose() {
    PageEventService.to.remove('completed_points_task', null);
    super.onClose();
  }
}
