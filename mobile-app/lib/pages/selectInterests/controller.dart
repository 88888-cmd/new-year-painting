import 'package:app/models/tag_group_model.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class SelectInterestsController extends GetxController {
  List<TagGroupModel> tagGroupList = [];

  List<int> selectedTagIds = [];

  @override
  void onInit() {
    super.onInit();

    HttpService.to.get('getTagData').then((result) {
      tagGroupList = (result.data as List<dynamic>)
          .map((item) => TagGroupModel.fromJson(item))
          .toList();

      update();
    });
  }

  void clickSubmit() {
    HttpService.to
        .post(
          'submitTag',
          data: {'tags': selectedTagIds.toList()},
          showLoading: true,
        )
        .then((result) {
          Get.offAllNamed(Routes.main);
        });
  }

  void toggleTagSelection(int tagId) {
    if (selectedTagIds.contains(tagId)) {
      selectedTagIds.remove(tagId);
    } else {
      selectedTagIds.add(tagId);
    }
    update();
  }
}
