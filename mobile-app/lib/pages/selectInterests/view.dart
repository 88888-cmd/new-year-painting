import 'package:app/pages/selectInterests/controller.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/categoryButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectInterestsPage extends StatefulWidget {
  const SelectInterestsPage({super.key});

  @override
  State<SelectInterestsPage> createState() => _SelectInterestsPageState();
}

class _SelectInterestsPageState extends State<SelectInterestsPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectInterestsController>(
      init: SelectInterestsController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(leading: null),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '选择你的兴趣',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '我们会根据兴趣为你推荐年画内容',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF5D4037).withOpacity(0.8),
                          ),
                        ),

                        const SizedBox(height: 40),

                        for (int i = 0; i < controller.tagGroupList.length; i++)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.tagGroupList[i].cn_name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(
                                      0xFF5D4037,
                                    ).withOpacity(0.8),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: controller.tagGroupList[i].tags.map(
                                    (tag) {
                                      bool isSelected = controller
                                          .selectedTagIds
                                          .contains(tag.id);
                                      return CategoryButtonItem(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 8,
                                        ),
                                        title: tag.cn_name,
                                        value: tag.id,
                                        isSelected: isSelected,
                                        onPressed: () {
                                          controller.toggleTagSelection(tag.id);
                                        },
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                PrimaryButton(
                  width: double.infinity,
                  title: '完成',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
