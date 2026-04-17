import 'package:app/models/posts.dart';
import 'package:app/models/posts_comment.dart';
import 'package:app/services/event.dart';
import 'package:app/services/http.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class PostsDetailController extends GetxController {
  bool isIniting = true; // 是否初始化中

  late PostsModel postsModel;
  VideoPlayerController? videoPlayerController;

  bool thumbed = false;

  List<PostsCommentModel> commentList = [];

  @override
  void onInit() {
    super.onInit();

    isIniting = true;

    HttpService.to
        .get('posts/detail', params: {'posts_id': Get.arguments['id']})
        .then((result) async {
          postsModel = PostsModel.fromJson(result.data['posts']);

          if (postsModel.type == 20 && postsModel.video_url.isNotEmpty) {
            videoPlayerController = VideoPlayerController.networkUrl(
              Uri.parse(postsModel.video_url),
            );

            await videoPlayerController!.initialize();
          }

          thumbed = bool.parse(result.data['thumbed'].toString());

          commentList =
              (result.data['comments'] as List<dynamic>)
                  .map((item) => PostsCommentModel.fromJson(item))
                  .toList();

          isIniting = false;

          update();

          videoPlayerController?.play();
        });
  }

  void comment(String content) {
    HttpService.to
        .post(
          'posts/addComment',
          data: {'posts_id': postsModel.id, 'content': content},
          showLoading: true,
        )
        .then((result) {
          commentList.insert(0, PostsCommentModel.fromJson(result.data));

          update();
        });
  }

  void thumb() {
    HttpService.to
        .post(
          'posts/thumb',
          data: {'posts_id': postsModel.id},
          showLoading: true,
        )
        .then((result) {
          thumbed = true;
          update();
        });
  }

  void cancelThumb() {
    HttpService.to
        .post(
          'posts/cancelThumb',
          data: {'posts_id': postsModel.id},
          showLoading: true,
        )
        .then((result) {
          thumbed = false;
          update();
        });
  }

  void delete() {
    HttpService.to
        .post(
          'posts/delete',
          data: {'posts_id': postsModel.id},
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('deleted_post', {'posts_id': postsModel.id});
          Get.back();
        });
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    super.onClose();
  }
}
