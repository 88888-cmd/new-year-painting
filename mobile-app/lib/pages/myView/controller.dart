import 'package:app/models/painting.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class MyViewController extends GetxController {
  List<PaintingModel> list = [];

  @override
  void onInit() {
    super.onInit();

    HttpService.to.get('painting/getMyView').then((result) {
      list = (result.data as List<dynamic>)
          .map((item) => PaintingModel.fromJson(item))
          .toList();

      update();
    });
  }
}
