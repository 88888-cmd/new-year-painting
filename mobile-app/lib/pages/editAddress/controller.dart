import 'dart:convert';
import 'package:app/i18n/index.dart';
import 'package:app/models/response.dart';
import 'package:app/services/event.dart';
import 'package:app/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:app/models/region.dart';
import 'package:app/services/http.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class EditAddressController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  List<RegionModel> regions = [];

  String selectedProvince = '';
  String selectedCity = '';
  String selectedDistrict = '';
  String selectedProvinceCode = '';
  String selectedCityCode = '';
  String selectedDistrictCode = '';

  List<RegionModel> get provinces => regions.where((r) => r.type == 0).toList();
  List<RegionModel> get cities => regions
      .where((r) => r.type == 1 && r.parentCode == selectedProvinceCode)
      .toList();
  List<RegionModel> get districts => regions
      .where((r) => r.type == 2 && r.parentCode == selectedCityCode)
      .toList();

  @override
  void onInit() async {
    super.onInit();
    regions.addAll(await loadRegions());

    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
    try {
      ResponseModel result = await HttpService.to.get(
        '/address/detail',
        params: {'address_id': Get.arguments['id']},
        showLoading: true
      );
      nameController.text = result.data['name'];
      phoneController.text = result.data['phone'];
      detailController.text = result.data['detail'];
      selectedProvince = result.data['province'];
      selectedProvinceCode = result.data['province_code'];
      selectedCity = result.data['city'];
      selectedCityCode = result.data['city_code'];
      selectedDistrict = result.data['district'];
      selectedDistrictCode = result.data['district_code'];

      update();
    } catch (e) {
      print(e);
    }
  }

  Future<List<RegionModel>> loadRegions() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/region.json',
      );
      return parseRegions(jsonString);
    } catch (e) {
      return [];
    }
  }

  List<RegionModel> parseRegions(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => RegionModel.fromJson(json)).toList();
  }

  void clickSubmit() {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String detail = detailController.text.trim();
    if (name.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_name.tr);
      return;
    }
    if (phone.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_phone.tr);
      return;
    }
    if (selectedProvince.isEmpty) {
      EasyLoading.showToast(LocaleKeys.select_province.tr);
      return;
    }
    if (selectedCity.isEmpty) {
      EasyLoading.showToast(LocaleKeys.select_city.tr);
      return;
    }
    if (selectedDistrict.isEmpty) {
      EasyLoading.showToast(LocaleKeys.select_district.tr);
      return;
    }
    if (detail.isEmpty) {
      EasyLoading.showToast(LocaleKeys.enter_detail_address.tr);
      return;
    }

    HttpService.to
        .post(
          'address/edit',
          data: {
            'address_id': Get.arguments['id'],
            'name': name,
            'phone': phone,
            'province': selectedProvince,
            'province_code': selectedProvinceCode,
            'city': selectedCity,
            'city_code': selectedCityCode,
            'district': selectedDistrict,
            'district_code': selectedDistrictCode,
            'detail': detail,
          },
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('notice_address_list', null);

          Get.back();
        });
  }

  void clickDelete() {
    HttpService.to
        .post(
          'address/delete',
          data: {'address_id': Get.arguments['id']},
          showLoading: true,
        )
        .then((result) {
          PageEventService.to.post('notice_address_list', null);

          Get.back();
        });
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    detailController.dispose();
    super.onClose();
  }
}
