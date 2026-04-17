import 'package:app/models/festival.dart';
import 'package:app/models/painting.dart';
import 'package:app/models/week_days.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class PaintingCalendarController extends GetxController {
  String currentMonthName = '';
  List<WeekDayModel> weekDays = [];
  FestivalModel? festivalModel;
  PaintingModel? paintingModel;

  @override
  void onInit() {
    super.onInit();

    HttpService.to.get('paintingCalendar/getData').then((result) {
      currentMonthName = result.data['current_month_name'];

      weekDays = (result.data['week_days'] as List<dynamic>)
          .map((item) => WeekDayModel.fromJson(item))
          .toList();

      if (result.data['festival'] != null) {
        festivalModel = FestivalModel.fromJson(result.data['festival']);
      }
      if (result.data['painting'] != null) {
        paintingModel = PaintingModel.fromJson(result.data['painting']);
      }
      update();
    });
  }
}
