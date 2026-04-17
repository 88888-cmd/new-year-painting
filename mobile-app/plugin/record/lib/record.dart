import 'dart:async';
import 'package:flutter/services.dart';

class AudioRecord {
  static const MethodChannel _channel = MethodChannel('voice_record_plugin');

  /// 开始录音
  static Future<bool> startRecord() async {
    try {
      final bool result = await _channel.invokeMethod('startRecord');
      return result;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// 停止录音
  static Future<String?> stopRecord() async {
    try {
      final String? result = await _channel.invokeMethod('stopRecord');
      return result;
    } catch (e) {
      return null;
    }
  }

  /// 检查是否正在录音
  static Future<bool> isRecording() async {
    try {
      final bool result = await _channel.invokeMethod('isRecording');
      return result;
    } catch (e) {
      return false;
    }
  }
}
