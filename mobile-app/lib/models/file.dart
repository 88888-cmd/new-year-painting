class UploadFileModel {
  int id = 0;
  String file_url = '';

  UploadFileModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    file_url = json['file_url'].toString();
  }
}
