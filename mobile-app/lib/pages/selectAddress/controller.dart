import 'package:app/models/user_address.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class SelectAddressController extends GetxController {
  bool isIniting = false;

  List<UserAddressModel> list = [];

  @override
  void onInit() {
    super.onInit();

    loadData();

    PageEventService.to.add('notice_address_list', (data) {
      loadData();
    });
  }

  void loadData() {
    isIniting = true;
    update();

    HttpService.to.get('address/getList').then((result) {
      list = (result.data as List<dynamic>)
          .map((item) => UserAddressModel.fromJson(item))
          .toList();

      isIniting = false;
      update();
    });
  }

  @override
  void onClose() {
    PageEventService.to.remove('notice_address_list', null);
    super.onClose();
  }
}
