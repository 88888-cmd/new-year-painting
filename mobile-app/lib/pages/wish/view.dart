import 'package:app/i18n/index.dart';
import 'package:app/models/wish.dart';
import 'package:app/pages/wish/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishPage extends StatefulWidget {
  const WishPage({super.key});

  @override
  State<WishPage> createState() => _WishPageState();
}

class _WishPageState extends State<WishPage> {
  // 愿望类型数据
  final List<WishType> wishTypes = [
    WishType(
      wish_type: 1,
      icon: Icons.favorite,
      color: Colors.red,
      title: LocaleKeys.wish_love.tr,
      description: LocaleKeys.wish_love_desc.tr,
    ),
    WishType(
      wish_type: 2,
      icon: Icons.attach_money,
      color: Colors.deepOrange,
      title: LocaleKeys.wish_wealth.tr,
      description: LocaleKeys.wish_wealth_desc.tr,
    ),
    WishType(
      wish_type: 3,
      icon: Icons.school,
      color: Colors.blue,
      title: LocaleKeys.wish_study.tr,
      description: LocaleKeys.wish_study_desc.tr,
    ),
    WishType(
      wish_type: 4,
      icon: Icons.favorite_outline_sharp,
      color: Colors.green,
      title: LocaleKeys.wish_health.tr,
      description: LocaleKeys.wish_health_desc.tr,
    ),
    WishType(
      wish_type: 5,
      icon: Icons.home,
      color: Colors.purple,
      title: LocaleKeys.wish_family.tr,
      description: LocaleKeys.wish_family_desc.tr,
    ),
    WishType(
      wish_type: 6,
      icon: Icons.business,
      color: Colors.blue,
      title: LocaleKeys.wish_career.tr,
      description: LocaleKeys.wish_career_desc.tr,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WishController>(
      init: WishController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.wish.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF8D6E63),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          LocaleKeys.select_wish_type.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF654941),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 13),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: wishTypes.length,
                  itemBuilder: (context, index) {
                    WishType wishType = wishTypes[index];

                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          Routes.submitWish,
                          arguments: {'type': wishType.wish_type},
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0.5,
                              blurRadius: 1.5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: wishType.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                wishType.icon,
                                color: wishType.color,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  wishType.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF654941),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  wishType.description,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25),

                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF8D6E63),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          LocaleKeys.wish_wall.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF654941),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 13),
                  ],
                ),
              ),

              SliverList.builder(
                itemCount: controller.wishList.length,
                itemBuilder: (context, index) {
                  WishModel wishModel = controller.wishList[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0.5,
                          blurRadius: 1.5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(bottom: 13),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 17,
                              ),
                              radius: 15,
                              backgroundColor: Colors.grey.shade300,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        wishModel.nickname,
                                        style: TextStyle(
                                          color: Color(0xFF654941),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          wishModel.wish_type_display,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    wishModel.create_time,
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          wishModel.content,
                          style: TextStyle(
                            color: Color(0xFF654941),
                            fontSize: 14,
                          ),
                        ),

                        if (wishModel.painting_image_url.isNotEmpty) ...[
                          SizedBox(height: 10),

                          CachedNetworkImage(
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            imageUrl: wishModel.painting_image_url,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        //   FloatingActionButtonLocation.endFloat,
        //   -5,
        //   -40,
        // ),
        // floatingActionButton: FloatingActionButton(
        //   mini: false,
        //   onPressed: () {
        //     Get.toNamed(Routes.addWish);
        //   },
        //   tooltip: 'Form',
        //   backgroundColor: const Color(0xFF8d6e63),
        //   child: const Icon(Icons.edit_rounded),
        // ),
      ),
    );
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  double offsetX;
  double offsetY;
  CustomFloatingActionButtonLocation(this.location, this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}

class WishType {
  final int wish_type;
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  WishType({
    required this.wish_type,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
