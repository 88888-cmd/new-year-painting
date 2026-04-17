import 'package:app/i18n/index.dart';
import 'package:app/models/region.dart';
import 'package:app/pages/addAddress/controller.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddAddressController>(
      init: AddAddressController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.add_address.tr),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  controller: controller.nameController,
                  label: LocaleKeys.name.tr,
                  hintText: LocaleKeys.enter_name.tr,
                ),
                SizedBox(height: 15),
                _buildInputField(
                  controller: controller.phoneController,
                  label: LocaleKeys.phone.tr,
                  hintText: LocaleKeys.enter_phone.tr,
                ),
                SizedBox(height: 15),
                Text(
                  LocaleKeys.region.tr,
                  style: TextStyle(
                    color: Color(0xFF654941),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Color(0xFFd7ccc8), width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildRegionSelector(
                        label: LocaleKeys.select_province.tr,
                        value: controller.selectedProvince,
                        onTap: () => _showRegionPicker(controller, 0),
                      ),
                      if (controller.selectedProvince.isNotEmpty)
                        Divider(height: 1, color: Color(0xFFd7ccc8)),

                      if (controller.selectedProvince.isNotEmpty)
                        _buildRegionSelector(
                          label: LocaleKeys.select_city.tr,
                          value: controller.selectedCity,
                          onTap: () => _showRegionPicker(controller, 1),
                        ),
                      if (controller.selectedCity.isNotEmpty)
                        Divider(height: 1, color: Color(0xFFd7ccc8)),

                      if (controller.selectedCity.isNotEmpty)
                        _buildRegionSelector(
                          label: LocaleKeys.select_district.tr,
                          value: controller.selectedDistrict,
                          onTap: () => _showRegionPicker(controller, 2),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 15),
                _buildInputField(
                  controller: controller.detailController,
                  label: LocaleKeys.detail_address.tr,
                  hintText: LocaleKeys.enter_detail_address.tr,
                  maxLines: 3,
                  maxLength: 500,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF654941),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFF654941), fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9DA4B0), fontSize: 15),
            fillColor: Colors.white,
            filled: true,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 1, color: Color(0xFFd7ccc8)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 1, color: Color(0xFF8d6e63)),
            ),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildRegionSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? label : value,
                style: TextStyle(
                  color: value.isEmpty ? Color(0xFF9DA4B0) : Color(0xFF654941),
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: Color(0xFF9DA4B0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showRegionPicker(AddAddressController controller, int type) {
    List<RegionModel> regions;
    String title;

    switch (type) {
      case 0:
        regions = controller.provinces;
        title = LocaleKeys.select_province.tr;
        break;
      case 1:
        regions = controller.cities;
        title = LocaleKeys.select_city.tr;
        break;
      case 2:
        regions = controller.districts;
        title = LocaleKeys.select_district.tr;
        break;
      default:
        return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        LocaleKeys.cancel.tr,
                        style: TextStyle(
                          color: Color(0xFF9DA4B0),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF654941),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        LocaleKeys.confirm.tr,
                        style: TextStyle(
                          color: Color(0xFF8d6e63),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          switch (type) {
                            case 0:
                              controller.selectedProvince = region.name;
                              controller.selectedProvinceCode = region.code;
                              controller.selectedCity = '';
                              controller.selectedCityCode = '';
                              controller.selectedDistrict = '';
                              controller.selectedDistrictCode = '';
                              break;
                            case 1:
                              controller.selectedCity = region.name;
                              controller.selectedCityCode = region.code;
                              controller.selectedDistrict = '';
                              controller.selectedDistrictCode = '';
                              break;
                            case 2:
                              controller.selectedDistrict = region.name;
                              controller.selectedDistrictCode = region.code;
                              break;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFd7ccc8).withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          region.name,
                          style: TextStyle(
                            color: Color(0xFF654941),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
