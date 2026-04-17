import 'package:app/models/banner.dart';
import 'package:app/models/painting.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<BannerModel> bannerList = [];
  List<PaintingModel> list = [];

  @override
  void onInit() {
    super.onInit();

    HttpService.to.get('banner/getList').then((result) {
      bannerList = (result.data as List<dynamic>)
          .map((item) => BannerModel.fromJson(item))
          .toList();
      update();
    });
    HttpService.to.get('painting/getRandomList').then((result) {
      list = (result.data as List<dynamic>)
          .map((item) => PaintingModel.fromJson(item))
          .toList();
      update();
    });
  }
}
