import 'package:app/utils/constants.dart';

class PaintingSummaryModel {
  int id = 0;
  String image_url = '';
  String name = '';

  PaintingSummaryModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());

    final String rawUrl = json['image_url'].toString();
    if (rawUrl.startsWith('http') || rawUrl.startsWith('https')) {
      image_url = rawUrl;
    } else {
      image_url = Constants.mediaBaseUrl + rawUrl;
    }
    // image_url = Constants.mediaBaseUrl + json['image_url'].toString();
    name = json['name'].toString();
  }
}
