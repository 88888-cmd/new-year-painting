class FestivalModel {
  String festival_name = '';
  String description = '';

  FestivalModel.fromJson(dynamic json) {
    festival_name = json['festival_name'].toString();
    description = json['description'].toString();
  }
}
