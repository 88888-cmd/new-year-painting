import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BuildBanner extends StatelessWidget {
  final List<String> bannerList;

  const BuildBanner({super.key, this.bannerList = const []});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 1,
        // aspectRatio: 16 / 9,
        enlargeCenterPage: false,
        enableInfiniteScroll: bannerList.length > 1,
        autoPlay: bannerList.length > 1,
      ),
      items: bannerList.map((item) {
        return CachedNetworkImage(
          width: double.infinity,
          height: 260,
          fit: BoxFit.cover,
          imageUrl:
              item,
        );
      }).toList(),
    );
  }
}
