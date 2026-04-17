import 'package:app/i18n/index.dart';
import 'package:app/pages/applyRefund/controller.dart';
import 'package:app/utils/assets_picker.dart';
import 'package:app/utils/constants.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/dashedPainter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ApplyRefundPage extends StatefulWidget {
  const ApplyRefundPage({super.key});

  @override
  State<ApplyRefundPage> createState() => _ApplyRefundPageState();
}

class _ApplyRefundPageState extends State<ApplyRefundPage> {
  List<String> imageList = [];

  void _showRefundRules() {
    int orderType = Get.find<ApplyRefundController>().orderType;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.refund_rule_description.tr,
              style: TextStyle(
                color: Color(0xFF654941),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            const Divider(height: 1, color: Color(0xFFEFE6E0)),
            const SizedBox(height: 15),

            if (orderType == 1) ...[
              const Text(
                '1. 优惠券退还规则',
                style: TextStyle(
                  color: Color(0xFF8d6e63),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Column(
                  children: [
                    _buildRuleItem('下单后未发货，用户申请退款整个订单（非部分商品），退优惠券'),
                    _buildRuleItem(
                      '下单后未发货，用户先申请退款部分商品，然后再申请退款剩余部分商品，全部商品都退款后关闭订单，退优惠券',
                    ),
                    _buildRuleItem('下单后未发货，用户只申请退款部分商品，不退优惠券'),
                    _buildRuleItem('下单后发货后，未确认收货时用户申请退款，不退优惠券'),
                    _buildRuleItem('确认收货后，用户申请退款，不退优惠券'),
                  ],
                ),
              ),
              const Text(
                '2. 积分抵扣退款规则',
                style: TextStyle(
                  color: Color(0xFF8d6e63),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Column(
                  children: [
                    _buildRuleItem('下单时使用积分抵扣金额，将在退款时按原抵扣比例退回对应积分'),
                    _buildRuleItem('下单后未发货，用户申请退款，退积分'),
                    _buildRuleItem('下单后发货后，未确认收货时用户申请退款，退积分'),
                    _buildRuleItem('确认收货后，用户申请退款，退积分'),
                  ],
                ),
              ),
            ] else if (orderType == 2) ...[
              const Text(
                '1. 积分退款规则',
                style: TextStyle(
                  color: Color(0xFF8d6e63),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Column(
                  children: [
                    _buildRuleItem('下单后未发货，用户申请退款，退积分'),
                    _buildRuleItem('下单后发货后，未确认收货时用户申请退款，退积分'),
                    _buildRuleItem('确认收货后，用户申请退款，退积分')
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF8d6e63),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF8d6e63),
                fontSize: 14,
                height: 1.4,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApplyRefundController>(
      init: ApplyRefundController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.apply_for_refund.tr),
          actions: [
            IconButton(
              onPressed: () {
                _showRefundRules();
              },
              icon: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF5D4037),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.question_mark,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFd7ccc8),
                    ),
                  ),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(6),
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        items: [
                          DropdownMenuItem(
                            child: Text(
                              LocaleKeys.only_refund.tr,
                              style: TextStyle(
                                color: Color(0xFF8d6e63),
                                fontSize: 15,
                              ),
                            ),
                            value: 1,
                          ),
                          if (controller.orderStatus == 3)
                            DropdownMenuItem(
                              child: Text(
                                LocaleKeys.return_and_refund.tr,
                                style: TextStyle(
                                  color: Color(0xFF8d6e63),
                                  fontSize: 15,
                                ),
                              ),
                              value: 2,
                            ),
                        ],
                        value: 1,
                        onChanged: (value) {
                          controller.refund_type = value!;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: controller.descController,
                  maxLength: 1000,
                  maxLines: 5,
                  style: const TextStyle(
                    color: Color(0xFF654941),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.enter_apply_reason.tr,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9DA4B0),
                      fontSize: 15,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(
                        width: 1,
                        color: const Color(0xFFd7ccc8),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                GridView.count(
                  // 屏蔽gridView滑动，防止与SingleChildScrollView冲突
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (int i = 0; i < controller.imageList.length; i++)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  Constants.mediaBaseUrl +
                                  controller.imageList[i].file_url,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    controller.imageList.removeAt(i);
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (controller.imageList.length < 9)
                      GestureDetector(
                        onTap: () async {
                          AssetsPicker.multiImage(
                            context: context,
                            limit: 9 - controller.imageList.length,
                          ).then((List<XFile> xfileList) async {
                            for (XFile xFile in xfileList) {
                              if ((await xFile.length()) >= 10 * 1024 * 1024) {
                                EasyLoading.showToast('最大文件大小为5mb');
                                return;
                              }
                            }

                            controller.upload(xfileList);
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_rounded,
                                      color: Color(0xFF9E9E9E),
                                      // color: Color(0xFF6B7280),
                                      size: 30,
                                    ),
                                    Text(
                                      LocaleKeys.upload_image.tr,
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
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 40),
                PrimaryButton(
                  width: double.infinity,
                  title: LocaleKeys.submit.tr,
                  onPressed: () {
                    controller.clickSubmit();
                  },
                ),

                // const SizedBox(height: 20),
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFFCF9F6),
                //     borderRadius: BorderRadius.circular(6),
                //     border: Border.all(
                //       width: 1,
                //       color: const Color(0xFFEFE6E0),
                //     ),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
