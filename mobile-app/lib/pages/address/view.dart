import 'package:app/i18n/index.dart';
import 'package:app/models/user_address.dart';
import 'package:app/pages/address/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressController>(
      init: AddressController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.my_address.tr),
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed(Routes.addAddress);
              },
              icon: Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: controller.isIniting
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  itemCount: controller.list.length,
                  itemBuilder: (context, index) {
                    UserAddressModel userAddressModel = controller.list[index];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          Routes.editAddress,
                          arguments: {'id': userAddressModel.id},
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 13),
                        padding: const EdgeInsets.all(15),
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
                            Row(
                              children: [
                                Text(
                                  userAddressModel.name,
                                  style: TextStyle(
                                    color: const Color(0xFF654941),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  userAddressModel.phone,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF654941,
                                    ).withOpacity(0.8),
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${userAddressModel.province}${userAddressModel.city}${userAddressModel.district}${userAddressModel.detail}',
                              style: TextStyle(
                                color: const Color(0xFF555E69),
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
