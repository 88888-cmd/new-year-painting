class WeekDayModel {
  final String day;
  final String date;
  final String weekday;
  final bool is_today;

  WeekDayModel({
    required this.day,
    required this.date,
    required this.weekday,
    required this.is_today
  });

  factory WeekDayModel.fromJson(Map<String, dynamic> json) {
    return WeekDayModel(
      day: json['day'].toString(),
      date: json['date'].toString(),
      weekday: json['weekday'].toString(),
      is_today: bool.parse(json['is_today'].toString())
    );
  }
}