import 'package:app/i18n/index.dart';
import 'package:app/models/points_task.dart';
import 'package:app/models/user_points_log.dart';
import 'package:app/pages/ponits/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PointsController>(
      init: PointsController(),
      builder: (controller) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(LocaleKeys.my_points.tr),
          ),
          body: controller.isIniting
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color(0xFF8d6e63),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.current_points.tr,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.total_points.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.pointsShop);
                                  },
                                  child: Text(
                                    LocaleKeys.go_to_shop.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.white.withOpacity(0.8)),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      LocaleKeys.normal_points.tr,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      controller.normal_points.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      LocaleKeys.cultural_points.tr,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      controller.cultural_points.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      LocaleKeys.points_obtained_this_month.tr,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '+${controller.cur_month_total_points.toString()}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      TabBar(
                        tabs: [
                          Tab(text: LocaleKeys.points_task.tr),
                          Tab(text: LocaleKeys.points_record.tr),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            ListView.builder(
                              itemCount: controller.tasks.length,
                              // padding: const EdgeInsets.symmetric(vertical: 16),
                              itemBuilder: (context, index) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 13),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Icon(
                                          controller.tasks[index].getTaskIcon(),
                                          color: Color(0xFF654941),
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.tasks[index]
                                                  .getTaskNameText(),
                                              style: TextStyle(
                                                color: Color(0xFF654941),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            // SizedBox(height: 5),
                                            // Text(
                                            //   '${controller.tasks[index].getTaskName()}，获得积分奖励',
                                            //   style: TextStyle(
                                            //     fontSize: 12,
                                            //     color: Color(0xFF6D7482),
                                            //   ),
                                            //   overflow: TextOverflow.ellipsis,
                                            //   maxLines: 1,
                                            // ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  LocaleKeys.task_progress
                                                      .trParams({
                                                        'progress': controller
                                                            .tasks[index]
                                                            .progress
                                                            .toString(),
                                                        'daily_limit':
                                                            controller
                                                                .tasks[index]
                                                                .daily_limit
                                                                .toString(),
                                                      }),
                                                  // '完成 ${controller.tasks[index].progress}/${controller.tasks[index].daily_limit}',
                                                  // controller
                                                  //         .tasks[index]
                                                  //         .isCompleted
                                                  //     ? '已完成'
                                                  //     : controller
                                                  //               .tasks[index]
                                                  //               .daily_limit >
                                                  //           1
                                                  //     ? '进度 ${controller.tasks[index].progress}/${controller.tasks[index].daily_limit}'
                                                  //     : '尚未完成',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF6D7482),
                                                  ),
                                                ),
                                                Text(
                                                  '+${controller.tasks[index].point_reward}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      GestureDetector(
                                        onTap: () {
                                          PointsTaskModel task =
                                              controller.tasks[index];
                                          if (task.isCompleted) return;

                                          if (task.painting_id == 0) {
                                            Get.toNamed(
                                              Routes.painting,
                                              arguments: {
                                                'task_id': task.id,
                                                'task_type': task.getTaskEnum(),
                                              },
                                            );
                                          } else {
                                            Get.toNamed(
                                              Routes.paintingDetail,
                                              arguments: {
                                                'id': task.painting_id,
                                                'task_id': task.id,
                                                'task_type': task.getTaskEnum(),
                                              },
                                            );
                                          }
                                          // Get.toNamed(Routes.paintingDetail, arguments: {
                                          //   'id': 1
                                          // });
                                        },
                                        child: Container(
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF8D6E63),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                            controller.tasks[index].isCompleted
                                                ? LocaleKeys.completed.tr
                                                : LocaleKeys.to_complete.tr,
                                            style: TextStyle(
                                              color: Colors.white,
                                              // color: isSelected ? Colors.white : Color(0xFF987B5A),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            ListView.builder(
                              itemCount: controller.logs.length,
                              itemBuilder: (context, index) {
                                UserPointsLogModel logModel =
                                    controller.logs[index];
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 13),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              logModel.scene_display,
                                              style: TextStyle(
                                                color: Color(0xFF654941),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              logModel.create_time,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6D7482),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          '${logModel.scene > 30 ? '-' : '+'}${controller.logs[index].integral_num}',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
