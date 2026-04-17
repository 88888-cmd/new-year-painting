import 'package:app/i18n/index.dart';
import 'package:app/models/posts.dart';
import 'package:app/models/posts_category.dart';
import 'package:app/services/http.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityController extends GetxController
    with GetSingleTickerProviderStateMixin {
  bool isIniting = true; // 是否初始化中

  late TabController tabController;

  List<PostsCategoryModel> categoryList = [];
  int selectedCategoryId = 0;

  List<PostsModel> list = [];
  int last_id = -1;
  int data_v = 1;

  EasyRefreshController easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void onInit() {
    super.onInit();

    HttpService.to
        .get('posts/getCategoryList')
        .then((result) {
          categoryList =
              (result.data as List<dynamic>)
                  .map((item) => PostsCategoryModel.fromJson(item))
                  .toList();
          categoryList.insert(
            0,
            PostsCategoryModel.fromJson({'id': 0, 'name': LocaleKeys.all.tr}),
          );

          tabController = TabController(length: categoryList.length, vsync: this)
            ..addListener(() {
              if (!tabController.indexIsChanging) {
                if (tabController.index < categoryList.length) {
                  selectedCategoryId = categoryList[tabController.index].id;
                  refreshList();
                }
              }
            });

          return HttpService.to.get('posts/getList');
        })
        .then((result) {
          list.addAll(
            (result.data['list'] as List<dynamic>)
                .map((item) => PostsModel.fromJson(item))
                .toList(),
          );

          if (list.isNotEmpty) {
            last_id = list.last.id;
          }

          isIniting = false;

          update();
        });

        // todo 监听事件 created_post
  }

  void refreshList() {
    list.clear();
    last_id = -1;
    data_v++;

    update();

    HttpService.to
        .get(
          'posts/getList',
          params: {
            'category_id': selectedCategoryId,
            'last_id': last_id,
            'data_v': data_v,
          },
        )
        .then((result) {
          if (data_v == result.data['data_v']) {
            list.addAll(
              (result.data['list'] as List<dynamic>)
                  .map((item) => PostsModel.fromJson(item))
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
          'posts/getList',
          params: {
            'category_id': selectedCategoryId,
            'last_id': last_id,
            'data_v': data_v,
          },
        )
        .then((result) {
          if (data_v == result.data['data_v']) {
            list.addAll(
              (result.data['list'] as List<dynamic>)
                  .map((item) => PostsModel.fromJson(item))
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
