import 'package:app/i18n/index.dart';
import 'package:app/models/user_coupon.dart';
import 'package:app/pages/myCounpon/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCouponPage extends StatefulWidget {
  const MyCouponPage({super.key});

  @override
  State<MyCouponPage> createState() => _MyCouponPageState();
}

class _MyCouponPageState extends State<MyCouponPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyCouponController>(
      init: MyCouponController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.my_coupon.tr),
        ),
        body: ListView.builder(
          itemCount: controller.list.length,
          itemBuilder: (context, index) {
            UserCouponModel userCouponModel = controller.list[index];

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
              child: Container(
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 100.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromARGB(255, 218, 92, 92),
                            Color.fromARGB(255, 235, 144, 144),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¥',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userCouponModel.reduce_price.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text(
                            LocaleKeys.available_for_purchase_over_x_yuan
                                .trParams({
                                  'price': controller.list[index].min_price
                                      .toString(),
                                }),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.list[index].coupon_name,
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              LocaleKeys.coupon_valid_period.trParams({
                                'start_time': userCouponModel.start_time
                                    .toString(),
                                'end_time': userCouponModel.end_time.toString(),
                              }),
                              // '${userCouponModel.start_time}至${userCouponModel.end_time}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF6D7482),
                              ),
                            ),

                            Text(
                              userCouponModel.getStatusText(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6D7482),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
