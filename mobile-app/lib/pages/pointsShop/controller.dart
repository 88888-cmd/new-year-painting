import 'package:app/i18n/index.dart';
import 'package:app/models/points_goods.dart';
import 'package:app/models/points_goods_category.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PointsShopController extends GetxController
    with GetSingleTickerProviderStateMixin {
  bool isIniting = true; // 是否初始化中

  late TabController tabController;

  List<PointsGoodsCategoryModel> categoryList = [];
  int selectedCategoryId = 0;

  List<PointsGoodsModel> list = [];
  int data_v = 1;

  @override
  void onInit() {
    super.onInit();

    HttpService.to
        .get('points/getGoodsCategoryList')
        .then((result) {
          categoryList = (result.data as List<dynamic>)
              .map((item) => PointsGoodsCategoryModel.fromJson(item))
              .toList();

          categoryList.insert(
            0,
            PointsGoodsCategoryModel.fromJson({
              'id': 0,
              'name': LocaleKeys.all.tr,
            }),
          );

          tabController =
              TabController(length: categoryList.length, vsync: this)
                ..addListener(() {
                  if (!tabController.indexIsChanging) {}
                });

          return HttpService.to.get('points/getGoodsList');
        })
        .then((result) {
          list.addAll(
            (result.data['goods_list'] as List<dynamic>)
                .map((item) => PointsGoodsModel.fromJson(item))
                .toList(),
          );

          isIniting = false;

          update();
        });
  }

  void loadList() {
    list.clear();
    data_v++;
    update();

    HttpService.to
        .get(
          'points/getGoodsList',
          params: {'category_id': selectedCategoryId, 'data_v': data_v},
        )
        .then((result) {
          if (data_v == result.data['data_v']) {
            list.addAll(
              (result.data['goods_list'] as List<dynamic>)
                  .map((item) => PointsGoodsModel.fromJson(item))
                  .toList(),
            );
            update();
          }
        });
  }
}
