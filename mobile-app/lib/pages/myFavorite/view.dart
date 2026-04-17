import 'package:app/i18n/index.dart';
import 'package:app/models/user_coupon.dart';
import 'package:app/pages/myCounpon/controller.dart';
import 'package:app/pages/myFavorite/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyFavoritedPage extends StatefulWidget {
  const MyFavoritedPage({super.key});

  @override
  State<MyFavoritedPage> createState() => _MyFavoritedPageState();
}

class _MyFavoritedPageState extends State<MyFavoritedPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyFavoritedController>(
      init: MyFavoritedController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.my_favorite.tr),
        ),
        body: GridView.builder(
          itemCount: controller.list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 13,
            mainAxisSpacing: 13,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: 10, bottom: 16),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              if (Get.arguments != null &&
                  Get.arguments.containsKey('task_id')) {
                Get.toNamed(
                  Routes.paintingDetail,
                  arguments: {
                    'id': controller.list[index].id,
                    'task_id': Get.arguments['task_id'],
                    'task_type': Get.arguments['task_type'],
                  },
                );
              } else {
                Get.toNamed(
                  Routes.paintingDetail,
                  arguments: {'id': controller.list[index].id},
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 1.5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: controller.list[index].image_url,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.list[index].name,
                          style: TextStyle(
                            color: Color(0xFF654941),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '${controller.list[index].dynasty}·${controller.list[index].author}',
                          style: TextStyle(
                            color: Color(0xFF4D5562),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
