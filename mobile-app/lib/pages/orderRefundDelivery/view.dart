import 'package:app/i18n/index.dart';
import 'package:app/pages/orderRefundDelivery/controller.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderRefundDeliveryPage extends StatefulWidget {
  const OrderRefundDeliveryPage({super.key});

  @override
  State<OrderRefundDeliveryPage> createState() =>
      _OrderRefundDeliveryPageState();
}

class _OrderRefundDeliveryPageState extends State<OrderRefundDeliveryPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderRefundDeliveryController>(
      init: OrderRefundDeliveryController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.return_delivery.tr),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller.expressNameController,
                  maxLength: 255,
                  style: const TextStyle(
                    color: Color(0xFF654941),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入快递公司',
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
                    counterText: '',
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: controller.expressNoController,
                  maxLength: 255,
                  style: const TextStyle(
                    color: Color(0xFF654941),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入快递单号',
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
                    counterText: '',
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
