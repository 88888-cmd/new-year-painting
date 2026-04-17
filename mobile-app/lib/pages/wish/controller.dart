import 'package:app/models/wish.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class WishController extends GetxController {
  List<WishModel> wishList = [];

  @override
  void onInit() {
    super.onInit();

    HttpService.to.get('wish/getList').then((result) {
      wishList = (result.data as List<dynamic>)
          .map((item) => WishModel.fromJson(item))
          .toList();
      update();
    });
  }
}
