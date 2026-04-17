import 'package:app/models/goods_comment.dart';
import 'package:app/models/points_goods_comment.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';

class PointsGoodsCommentController extends GetxController {
  List<PointsGoodsCommentModel> commentList = [];

  @override
  void onInit() {
    super.onInit();

    HttpService.to
        .get(
          'points/getGoodsCommentList',
          params: {'goods_id': Get.arguments['goods_id']},
        )
        .then((result) {
          commentList = (result.data as List<dynamic>)
              .map((item) => PointsGoodsCommentModel.fromJson(item))
              .toList();

          update();
        });
  }
}
