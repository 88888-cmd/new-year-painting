class ResponseModel {
  ResponseModel({this.code, this.msg, this.data});

  ResponseModel.fromJson(dynamic json) {
    code = int.tryParse(json['code'].toString());
    msg = json['msg']?.toString();
    data = json['data'];
  }

  int? code;
  String? msg;
  dynamic data;

  ResponseModel copyWith({int? code, String? msg, dynamic data}) =>
      ResponseModel(
        code: code ?? this.code,
        msg: msg ?? this.msg,
        data: data ?? this.data,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['msg'] = msg;
    map['data'] = data;
    return map;
  }
}
