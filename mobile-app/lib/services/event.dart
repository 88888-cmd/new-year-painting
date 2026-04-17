import 'package:get/get.dart';

class PageEventService extends GetxService {
  static PageEventService get to => Get.find();

  final Map<String, List<void Function(dynamic)>> eventMap = {};

  void add(String type, void Function(dynamic) listener) {
    if (eventMap.containsKey(type)) {
      eventMap[type]?.add(listener);
    } else {
      eventMap[type] = [listener];
    }
  }

  void remove(String type, void Function(dynamic)? listener) {
    if (listener != null) {
      eventMap[type]?.remove(listener);
    } else {
      eventMap.remove(type);
    }
  }

  void post(String type, dynamic data) {
    if (eventMap.containsKey(type)) {
      for (var element in eventMap[type]!) {
        element.call(data);
      }
    }
  }
}
