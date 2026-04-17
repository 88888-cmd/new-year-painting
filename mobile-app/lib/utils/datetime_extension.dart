extension DateTimeFormat on DateTime {
  String toFormattedString() {
    String yearStr = year.toString();
    String monthStr = month.toString().padLeft(2, '0');
    String dayStr = day.toString().padLeft(2, '0');
    String hourStr = hour.toString().padLeft(2, '0');
    String minuteStr = minute.toString().padLeft(2, '0');

    return '$yearStr-$monthStr-$dayStr $hourStr:$minuteStr';
  }
}
