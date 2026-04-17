import 'package:app/models/banner.dart';
import 'package:app/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildBanner extends StatelessWidget {
  final List<BannerModel> bannerList;

  const BuildBanner({Key? key, this.bannerList = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 1,
        aspectRatio: 16 / 9,
        enlargeCenterPage: false,
        enableInfiniteScroll: bannerList.length > 1,
        autoPlay: bannerList.length > 1,
      ),
      items: bannerList.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: 15, bottom: 20),
          child: GestureDetector(
            onTap: () {
              Get.toNamed(Routes.articleContent, arguments: {
                'id': item.id
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                width: double.infinity,
                height: double.infinity,
                imageUrl: item.image_url,
                fit: BoxFit.cover,
              ),
              // child: Image.asset(
              //   width: double.infinity,
              //   height: double.infinity,
              //   fit: BoxFit.cover,
              //   'assets/images/banner1.png',
              // ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
