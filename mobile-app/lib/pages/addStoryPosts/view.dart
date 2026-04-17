import 'dart:ui' as ui;

import 'package:app/i18n/index.dart';
import 'package:app/pages/addStoryPosts/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/utils/assets_picker.dart';
import 'package:app/utils/constants.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/dashedPainter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class AddStoryPostsPage extends StatefulWidget {
  const AddStoryPostsPage({super.key});

  @override
  State<AddStoryPostsPage> createState() => _AddStoryPostPagesState();
}

class _AddStoryPostPagesState extends State<AddStoryPostsPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddStoryPostController>(
      init: AddStoryPostController(),
      builder:
          (controller) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(LocaleKeys.publish_posts_my_story.tr),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 90,
                      child: Row(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Color(0xFFf3e8d9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(0xFF8b5a2b),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF8b5a2b).withOpacity(0.2),
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                imageUrl: controller.paintingImageUrl,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.paintingName,
                                      style: TextStyle(
                                        color: Color(0xFF654941),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '${LocaleKeys.author.tr}：${controller.paintingAuthor}',
                                      style: TextStyle(
                                        color: Color(0xFF4D5562),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.selectPainting)?.then((
                                      value,
                                    ) {
                                      if (value != null) {
                                        setState(() {
                                          controller.paintingId = value['id'];
                                          controller.paintingImageUrl =
                                              value['image_url'];
                                          controller.paintingName =
                                              value['name'];
                                          controller.paintingAuthor =
                                              value['author'];
                                        });
                                      }
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.change_circle_outlined,
                                        size: 15,
                                        color: Color(0xFF8b5a2b),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        LocaleKeys.change_painting.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8b5a2b),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      LocaleKeys.share_your_story.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: controller.titleController,
                      maxLength: 255,
                      style: const TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: LocaleKeys.enter_title.tr,
                        hintStyle: const TextStyle(
                          color: Color(0xFF9DA4B0),
                          fontSize: 15,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color: const Color(0xFFd7ccc8),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color: const Color(0xFF8d6e63),
                          ),
                        ),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 13,
                        ),
                        counterText: '',
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: controller.contentController,
                      maxLength: 1000,
                      maxLines: 8,
                      style: const TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: LocaleKeys.share_your_story.tr,
                        hintStyle: const TextStyle(
                          color: Color(0xFF9DA4B0),
                          fontSize: 15,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color: const Color(0xFFd7ccc8),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color: const Color(0xFF8d6e63),
                          ),
                        ),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 13,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () async {
                        AssetsPicker.video(context: context).then((
                          xfile,
                        ) async {
                          if (xfile != null) {
                            if ((await xfile.length()) >= 50 * 1024 * 1024) {
                              EasyLoading.showToast('最大文件大小为50mb');
                              return;
                            }

                            final String extension =
                                xfile.path.split('.').last.toLowerCase();
                            if (extension != 'mp4' && extension != 'mov') {
                              EasyLoading.showToast('请上传 MP4 或 MOV');
                              return;
                            }

                            controller.upload(xfile);
                          }
                        });
                      },
                      child:
                          controller.uploadVideoCoverModel == null
                              ? Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Stack(
                                  fit: StackFit.loose,
                                  children: [
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: CustomPaint(
                                          painter: DashedPainter(
                                            strokeWidth: 2,
                                            radius: Radius.circular(6),
                                            color: Color(0xFFd7ccc8),
                                            dashPattern: [8, 5],
                                          ),
                                        ),
                                      ),
                                    ),

                                    Positioned.fill(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_rounded,
                                            color: Color(0xFF9E9E9E),
                                            // color: Color(0xFF6B7280),
                                            size: 30,
                                          ),
                                          Text(
                                            LocaleKeys.upload_video.tr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF9E9E9E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      Constants.mediaBaseUrl +
                                      controller.uploadVideoCoverModel!.file_url,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                    ),

                    SizedBox(height: 40),
                    PrimaryButton(
                      width: double.infinity,
                      title: LocaleKeys.confirm.tr,
                      onPressed: () {
                        controller.clickSubmit();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

// class DashedPainter extends CustomPainter {
//   final double strokeWidth;
//   final List<double> dashPattern;
//   final Color color;
//   final Radius radius;
//   final StrokeCap strokeCap;

//   DashedPainter({
//     this.strokeWidth = 2,
//     this.dashPattern = const <double>[3, 1],
//     this.color = Colors.black,
//     this.radius = const Radius.circular(0),
//     this.strokeCap = StrokeCap.butt,
//   });

//   @override
//   void paint(Canvas canvas, Size originalSize) {
//     final Size size = originalSize;

//     Paint paint =
//         Paint()
//           ..strokeWidth = strokeWidth
//           ..strokeCap = strokeCap
//           ..style = PaintingStyle.stroke
//           ..color = color;

//     Path path = dashPath(
//       getRRectPath(size, radius),
//       dashArray: CircularIntervalList(dashPattern),
//     );

//     canvas.drawPath(path, paint);
//   }

//   Path getRRectPath(Size size, Radius radius) {
//     return Path()..addRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(0, 0, size.width, size.height),
//         radius,
//       ),
//     );
//   }

//   Path dashPath(
//     Path source, {
//     required CircularIntervalList<double> dashArray,
//     DashOffset? dashOffset,
//   }) {
//     dashOffset = dashOffset ?? const DashOffset.absolute(0.0);

//     final Path dest = Path();
//     for (final ui.PathMetric metric in source.computeMetrics()) {
//       double distance = dashOffset._calculate(metric.length);
//       bool draw = true;
//       while (distance < metric.length) {
//         final double len = dashArray.next;
//         if (draw) {
//           dest.addPath(
//             metric.extractPath(distance, distance + len),
//             Offset.zero,
//           );
//         }
//         distance += len;
//         draw = !draw;
//       }
//     }

//     return dest;
//   }

//   @override
//   bool shouldRepaint(DashedPainter oldDelegate) {
//     return oldDelegate.strokeWidth != strokeWidth ||
//         oldDelegate.color != color ||
//         oldDelegate.dashPattern != dashPattern;
//   }
// }

// class CircularIntervalList<T> {
//   CircularIntervalList(this._vals);

//   final List<T> _vals;
//   int _idx = 0;

//   T get next {
//     if (_idx >= _vals.length) {
//       _idx = 0;
//     }
//     return _vals[_idx++];
//   }
// }

// enum _DashOffsetType { Absolute, Percentage }

// class DashOffset {
//   /// Create a DashOffset that will be measured as a percentage of the length
//   /// of the segment being dashed.
//   ///
//   /// `percentage` will be clamped between 0.0 and 1.0.
//   DashOffset.percentage(double percentage)
//     : _rawVal = percentage.clamp(0.0, 1.0),
//       _dashOffsetType = _DashOffsetType.Percentage;

//   /// Create a DashOffset that will be measured in terms of absolute pixels
//   /// along the length of a [Path] segment.
//   const DashOffset.absolute(double start)
//     : _rawVal = start,
//       _dashOffsetType = _DashOffsetType.Absolute;

//   final double _rawVal;
//   final _DashOffsetType _dashOffsetType;

//   double _calculate(double length) {
//     return _dashOffsetType == _DashOffsetType.Absolute
//         ? _rawVal
//         : length * _rawVal;
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) {
//       return true;
//     }

//     return other is DashOffset &&
//         other._rawVal == _rawVal &&
//         other._dashOffsetType == _dashOffsetType;
//   }

//   @override
//   int get hashCode => Object.hash(_rawVal, _dashOffsetType);
// }
