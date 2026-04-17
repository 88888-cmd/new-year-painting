import 'package:app/models/week_days.dart';
import 'package:app/pages/paintingCalendar/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaintingCalendarPage extends StatefulWidget {
  const PaintingCalendarPage({super.key});

  @override
  State<PaintingCalendarPage> createState() => _PaintingCalendarPageState();
}

class _PaintingCalendarPageState extends State<PaintingCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaintingCalendarController>(
      init: PaintingCalendarController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('年画日历'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('每个节气、节日的传统年画与习俗', style: TextStyle(color: Color(0xFF555E69), fontSize: 14)),
                // SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // GestureDetector(
                      //   child: Icon(
                      //     Icons.chevron_left,
                      //     color: Color(0xFF5D4037),
                      //     size: 28,
                      //   ),
                      //   onTap: () {},
                      // ),
                      Expanded(
                        child: Center(
                          child: Text(
                            controller.currentMonthName,
                            style: TextStyle(
                              color: Color(0xFF654941),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // GestureDetector(
                      //   child: Icon(
                      //     Icons.chevron_right,
                      //     color: Color(0xFF5D4037),
                      //     size: 28,
                      //   ),
                      //   onTap: () {},
                      // ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(controller.weekDays.length, (
                      index,
                    ) {
                      WeekDayModel weekDayModel = controller.weekDays[index];
                      return Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: weekDayModel.is_today
                                  ? const Color(0xFF5D4037)
                                  : const Color(0xFF8D6E63),
                            ),
                            child: Center(
                              child: Text(
                                weekDayModel.day,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weekDayModel.weekday,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: weekDayModel.is_today
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                if (controller.festivalModel != null) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今日：${controller.festivalModel!.festival_name}',
                          style: TextStyle(
                            color: Color(0xFF654941),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          controller.festivalModel!.description,
                          style: TextStyle(
                            color: Color(0xFF654941),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (controller.paintingModel != null) ...[
                  SizedBox(height: 30),
                  Text(
                    '相关年画',
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 350,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0.5,
                          blurRadius: 1.5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl: controller.paintingModel!.image_url,
                            ),
                          ),
                        ),
                        SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.paintingModel!.name,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  '${controller.paintingModel!.dynasty}·${controller.paintingModel!.author}',
                                  style: TextStyle(
                                    color: Color(0xFF4D5562),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 20),
                                PrimaryButton(
                                  width: double.infinity,
                                  title: '查看详情',
                                  onPressed: () {
                                    Get.toNamed(
                                      Routes.paintingDetail,
                                      arguments: {
                                        'id': controller.paintingModel!.id,
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
