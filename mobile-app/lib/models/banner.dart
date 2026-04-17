import 'package:app/utils/constants.dart';

class BannerModel {
  int id = 0;
  String image_url = '';

  BannerModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    image_url = Constants.mediaBaseUrl +  json['image_url'].toString();
  }
}
