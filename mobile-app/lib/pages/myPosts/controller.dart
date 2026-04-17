import 'package:app/i18n/index.dart';
import 'package:app/models/posts.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class MyPostsController extends GetxController {
  List<PostsModel> list = [];

  @override
  void onInit() {
    super.onInit();

    HttpService.to.get('posts/getMyList').then((result) {
      list.addAll(
        (result.data['list'] as List<dynamic>)
            .map((item) => PostsModel.fromJson(item))
            .toList(),
      );
      update();
    });
  }
}
