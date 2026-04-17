class OrderAddressModel {
  String name = '';
  String phone = '';
  String province = '';
  String province_code = '';
  String city = '';
  String city_code = '';
  String district = '';
  String district_code = '';
  String detail = '';

  OrderAddressModel.fromJson(dynamic json) {
    name = json['name'].toString();
    phone = json['phone'].toString();
    province = json['province'].toString();
    province_code = json['province_code'].toString();
    city = json['city'].toString();
    city_code = json['city_code'].toString();
    district = json['district'].toString();
    district_code = json['district_code'].toString();
    detail = json['detail'].toString();
  }
}