import 'package:app/i18n/index.dart';
import 'package:app/models/painting_filter_option.dart';
import 'package:app/pages/painting/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/widgets/categoryButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class PaintingPage extends StatefulWidget {
  const PaintingPage({super.key});

  @override
  State<PaintingPage> createState() => _PaintingPageState();
}

class _PaintingPageState extends State<PaintingPage> {
  void _showFilterDialog(
    String type,
    List<PaintingFilterOptionModel> options,
    int currentId,
    Function(int) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            type == 'style'
                ? LocaleKeys.filter_style.tr
                : type == 'theme'
                ? LocaleKeys.filter_theme.tr
                : type == 'dynasty'
                ? LocaleKeys.filter_dynasty.tr
                : LocaleKeys.filter_author.tr,
            style: TextStyle(
              color: Color(0xFF654941),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                bool isSelected = option.id == currentId;
                return ListTile(
                  title: Text(
                    option.name,
                    style: TextStyle(
                      color: isSelected ? Color(0xFF654941) : Color(0xFF4D5562),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Color(0xFF654941))
                      : null,
                  onTap: () {
                    onSelect(option.id);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LocaleKeys.cancel.tr,
                style: TextStyle(color: Color(0xFF654941)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAllFiltersDialog(PaintingController controller) {
    int tempSelectedThemeId = controller.selectedThemeId;
    int tempSelectedDynastyId = controller.selectedDynastyId;
    int tempSelectedAuthorId = controller.selectedAuthorId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                LocaleKeys.filter_conditions.tr,
                style: TextStyle(
                  color: Color(0xFF654941),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.theme.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.themes.map((item) {
                        bool isSelected = item.id == tempSelectedThemeId;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              tempSelectedThemeId = item.id;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF654941)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Color(0xFF555E69),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      LocaleKeys.dynasty.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.dynasties.map((item) {
                        bool isSelected = item.id == tempSelectedDynastyId;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              tempSelectedDynastyId = item.id;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF654941)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Color(0xFF555E69),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      LocaleKeys.author.tr,
                      style: TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.authors.map((item) {
                        bool isSelected = item.id == tempSelectedAuthorId;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              tempSelectedAuthorId = item.id;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF654941)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Color(0xFF555E69),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempSelectedThemeId = 0;
                      tempSelectedDynastyId = 0;
                      tempSelectedAuthorId = 0;
                    });
                  },
                  child: Text(
                    LocaleKeys.reset.tr,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    LocaleKeys.cancel.tr,
                    style: TextStyle(color: Color(0xFF654941)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.resetEasyRefreshController();

                    controller.selectedThemeId = tempSelectedThemeId;
                    controller.selectedDynastyId = tempSelectedDynastyId;
                    controller.selectedAuthorId = tempSelectedAuthorId;
                    Navigator.of(context).pop();
                    setState(() {});

                    controller.refreshList();
                  },
                  child: Text(
                    LocaleKeys.confirm.tr,
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _hasActiveFilters(PaintingController controller) {
    return controller.selectedThemeId > 0 ||
        controller.selectedDynastyId > 0 ||
        controller.selectedAuthorId > 0;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaintingController>(
      init: PaintingController(),
      global: false,
      builder: (controller) => controller.isIniting
          ? Scaffold(
              appBar: AppBar(
                leading:
                    (Get.arguments != null &&
                        Get.arguments.containsKey('task_id'))
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : null,
                title: Text(LocaleKeys.tabbar_painting.tr),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search_rounded),
                  ),
                ],
              ),
              body: Center(child: CircularProgressIndicator()),
            )
          : Scaffold(
              appBar: AppBar(
                leading:
                    (Get.arguments != null &&
                        Get.arguments.containsKey('task_id'))
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : null,
                title: Text(LocaleKeys.tabbar_painting.tr),
                actions: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed(Routes.searchPainting);
                    },
                    icon: Icon(Icons.search_rounded),
                  ),
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CategoryButtonItem(
                          title: LocaleKeys.all.tr,
                          value: 0,
                          isSelected: controller.selectedStyleId == 0,
                          onPressed: () {
                            controller.resetEasyRefreshController();

                            controller.selectedStyleId = 0;
                            setState(() {});

                            controller.refreshList();
                          },
                        ),
                        ...controller.styles.map((style) {
                          return Row(
                            children: [
                              const SizedBox(width: 12),
                              CategoryButtonItem(
                                title: style.name,
                                value: style.id,
                                isSelected:
                                    controller.selectedStyleId == style.id,
                                onPressed: () {
                                  controller.resetEasyRefreshController();

                                  controller.selectedStyleId = style.id;
                                  setState(() {});

                                  controller.refreshList();
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              _showFilterDialog(
                                'theme',
                                controller.themes,
                                controller.selectedThemeId,
                                (id) {
                                  controller.resetEasyRefreshController();
                                  controller.selectedThemeId = id;
                                  setState(() {});

                                  controller.refreshList();
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  controller.selectedThemeText,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF654941),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              _showFilterDialog(
                                'dynasty',
                                controller.dynasties,
                                controller.selectedDynastyId,
                                (id) {
                                  controller.resetEasyRefreshController();
                                  controller.selectedDynastyId = id;
                                  setState(() {});

                                  controller.refreshList();
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  controller.selectedDynastyText,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF654941),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              _showFilterDialog(
                                'author',
                                controller.authors,
                                controller.selectedAuthorId,
                                (id) {
                                  controller.resetEasyRefreshController();
                                  controller.selectedAuthorId = id;
                                  setState(() {});

                                  controller.refreshList();
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  controller.selectedAuthorText,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF654941),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              _showAllFiltersDialog(controller);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleKeys.filter.tr,
                                  style: TextStyle(
                                    color: Color(0xFF654941),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Stack(
                                  children: [
                                    Icon(
                                      Icons.filter_list_alt,
                                      color: Color(0xFF654941),
                                      size: 17,
                                    ),
                                    if (_hasActiveFilters(controller))
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: EasyRefresh(
                      controller: controller.easyRefreshController,
                      header: const ClassicHeader(
                        showText: false,
                        showMessage: false,
                        iconTheme: IconThemeData(size: 20),
                      ),
                      footer: const ClassicFooter(
                        showText: false,
                        showMessage: false,
                        iconTheme: IconThemeData(size: 20),
                      ),
                      onRefresh: () {
                        controller.refreshList();
                      },
                      onLoad: () {
                        controller.loadMoreList();
                      },
                      child: GridView.builder(
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
                                      imageUrl:
                                          controller.list[index].image_url,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                  ),
                ],
              ),
            ),
    );
  }
}
