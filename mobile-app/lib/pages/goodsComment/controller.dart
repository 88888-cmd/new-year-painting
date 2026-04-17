import 'package:app/models/goods_comment.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class GoodsCommentController extends GetxController {
  List<GoodsCommentModel> commentList = [];

  @override
  void onInit() {
    super.onInit();

    HttpService.to
        .get(
          'goods/getCommentList',
          params: {'goods_id': Get.arguments['goods_id']},
        )
        .then((result) {
          commentList = (result.data as List<dynamic>)
              .map((item) => GoodsCommentModel.fromJson(item))
              .toList();

          update();
        });
  }
}
