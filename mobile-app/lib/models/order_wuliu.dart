class OrderWuliuModel {
  String time = '';
  String status = '';

  OrderWuliuModel.fromJson(dynamic json) {
    time = json['time'].toString();
    status = json['status'].toString();
  }
}
