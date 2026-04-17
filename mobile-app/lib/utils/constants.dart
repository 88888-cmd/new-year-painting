import 'dart:io';

abstract class Constants {
  static String get serverUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/myapp/api/';
    } else {
      return 'http://localhost:8000/myapp/api/';
    }
  }

  static String get mediaBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  static const String localUserId = 'user_id';
  static const String localUserToken = 'user_token';
}
