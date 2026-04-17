import 'package:app/services/storage.dart';
import 'package:app/utils/constants.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

class UserStore extends GetxController {
  static UserStore get to => Get.find();

  int _id = 0;
  int get id => _id;

  String _token = '';
  String get token => _token;

  bool get isLogin => token.isNotEmpty;

  // ProfileModel _profileModel = ProfileModel();
  // ProfileModel get profileModel => _profileModel;

  @override
  void onInit() {
    super.onInit();
    _id = StorageService.to.getInt(Constants.localUserId);
    _token = StorageService.to.getString(Constants.localUserToken);
  }

  Future<void> setId(int id) async {
    _id = id;
    await StorageService.to.setInt(Constants.localUserId, id);
  }

  Future<void> setToken(String? value) async {
    _token = value?.toString() ?? '';
    await StorageService.to.setString(Constants.localUserToken, _token);
  }

  Future<void> logout() async {
    _id = 0;
    _token = '';
    await StorageService.to.remove(Constants.localUserId);
    await StorageService.to.remove(Constants.localUserToken);
  }
}
