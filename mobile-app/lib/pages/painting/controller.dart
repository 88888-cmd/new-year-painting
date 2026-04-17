import 'package:app/i18n/index.dart';
import 'package:app/models/painting.dart';
import 'package:app/models/painting_filter_option.dart';
import 'package:app/services/http.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class PaintingController extends GetxController {
  bool isIniting = true; // 是否初始化中

  List<PaintingFilterOptionModel> styles = [];
  List<PaintingFilterOptionModel> themes = [];
  List<PaintingFilterOptionModel> dynasties = [];
  List<PaintingFilterOptionModel> authors = [];
  List<PaintingModel> list = [];
  int last_id = -1;
  int data_v = 1;

  int selectedStyleId = 0;
  int selectedThemeId = 0;
  int selectedDynastyId = 0;
  int selectedAuthorId = 0;

  String get selectedStyleText {
    if (selectedStyleId == 0) return LocaleKeys.theme.tr;

    return styles.firstWhereOrNull((o) => o.id == selectedStyleId)?.name ??
        LocaleKeys.style.tr;
  }

  String get selectedThemeText {
    if (selectedThemeId == 0) return LocaleKeys.theme.tr;

    return themes.firstWhereOrNull((o) => o.id == selectedThemeId)?.name ??
        LocaleKeys.theme.tr;
  }

  String get selectedDynastyText {
    if (selectedDynastyId == 0) return LocaleKeys.dynasty.tr;

    return dynasties.firstWhereOrNull((o) => o.id == selectedDynastyId)?.name ??
        LocaleKeys.dynasty.tr;
  }

  String get selectedAuthorText {
    if (selectedAuthorId == 0) return LocaleKeys.author.tr;

    return authors.firstWhereOrNull((o) => o.id == selectedAuthorId)?.name ??
        LocaleKeys.author.tr;
  }

  EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void onInit() {
    super.onInit();

    // isIniting = true;
    // HttpService.to
    //     .get('painting/getFilterOptions')
    //     .then((result) {
    //       styles =
    //           (result.data['styles'] as List<dynamic>)
    //               .map((item) => PaintingFilterOptionModel.fromJson(item))
    //               .toList();

    //       themes =
    //           (result.data['themes'] as List<dynamic>)
    //               .map((item) => PaintingFilterOptionModel.fromJson(item))
    //               .toList();

    //       dynasties =
    //           (result.data['dynasties'] as List<dynamic>)
    //               .map((item) => PaintingFilterOptionModel.fromJson(item))
    //               .toList();

    //       authors =
    //           (result.data['authors'] as List<dynamic>)
    //               .map((item) => PaintingFilterOptionModel.fromJson(item))
    //               .toList();

    //       return HttpService.to.get('painting/getList');
    //     })
    //     .then((result) {
    //       list.addAll(
    //         (result.data['painting_list'] as List<dynamic>)
    //             .map((item) => PaintingModel.fromJson(item))
    //             .toList(),
    //       );

    //       if (list.isNotEmpty) {
    //         last_id = list.last.id;
    //       }

    //       isIniting = false;
    //       update();
    //     });
    fetchData();
  }

  Future<void> fetchData() async {
    isIniting = true;
    try {
      final filterOptionsFuture = HttpService.to.get(
        'painting/getFilterOptions',
      );
      final paintingListFuture = HttpService.to.get('painting/getList');

      final results = await Future.wait([
        filterOptionsFuture,
        paintingListFuture,
      ]);

      final filterOptionsResult = results[0];
      styles =
          (filterOptionsResult.data['styles'] as List<dynamic>)
              .map((item) => PaintingFilterOptionModel.fromJson(item))
              .toList();

      themes =
          (filterOptionsResult.data['themes'] as List<dynamic>)
              .map((item) => PaintingFilterOptionModel.fromJson(item))
              .toList();

      dynasties =
          (filterOptionsResult.data['dynasties'] as List<dynamic>)
              .map((item) => PaintingFilterOptionModel.fromJson(item))
              .toList();

      authors =
          (filterOptionsResult.data['authors'] as List<dynamic>)
              .map((item) => PaintingFilterOptionModel.fromJson(item))
              .toList();

      final paintingListResult = results[1];
      list.addAll(
        (paintingListResult.data['painting_list'] as List<dynamic>)
            .map((item) => PaintingModel.fromJson(item))
            .toList(),
      );

      if (list.isNotEmpty) {
        last_id = list.last.id;
      }

      isIniting = false;
      update();
    } catch (e) {
      isIniting = false;
      update();
    }
  }

  void refreshList() {
    list.clear();
    last_id = -1;
    data_v++;
    update();

    HttpService.to
        .get(
          'painting/getList',
          params: {
            'style_id': selectedStyleId,
            'theme_id': selectedThemeId,
            'dynasty_id': selectedDynastyId,
            'author_id': selectedAuthorId,
            'last_id': last_id,
            'data_v': data_v,
          },
        )
        .then((result) {
          if (data_v == result.data['data_v']) {
            list.addAll(
              (result.data['painting_list'] as List<dynamic>)
                  .map((item) => PaintingModel.fromJson(item))
                  .toList(),
            );

            if (list.isNotEmpty) {
              last_id = list.last.id;
            }

            easyRefreshController.finishRefresh();
            easyRefreshController.resetFooter();

            update();
          }
        });
  }

  void loadMoreList() {
    data_v++;

    HttpService.to
        .get(
          'painting/getList',
          params: {
            'style_id': selectedStyleId,
            'theme_id': selectedThemeId,
            'dynasty_id': selectedDynastyId,
            'author_id': selectedAuthorId,
            'last_id': last_id,
            'data_v': data_v,
          },
        )
        .then((result) {
          if (data_v == result.data['data_v']) {
            list.addAll(
              (result.data['painting_list'] as List<dynamic>)
                  .map((item) => PaintingModel.fromJson(item))
                  .toList(),
            );

            if (list.isNotEmpty) {
              last_id = list.last.id;
            }

            easyRefreshController.finishLoad();

            update();
          }
        });
  }

  void resetEasyRefreshController() {
    easyRefreshController.resetHeader();
    easyRefreshController.resetFooter();
  }
}
