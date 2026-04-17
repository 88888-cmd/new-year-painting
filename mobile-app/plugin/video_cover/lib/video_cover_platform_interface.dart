import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_cover/video_cover_method_channel.dart';

enum ImageFormat { JPEG, PNG }

abstract class VideoCoverPlatform extends PlatformInterface {
  VideoCoverPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoCoverPlatform _instance = MethodChannelVideoCover();

  static VideoCoverPlatform get instance => _instance;

  static set instance(VideoCoverPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> thumbnailFile({
    required String video,
    Map<String, String>? headers,
    String? thumbnailPath,
    ImageFormat imageFormat = ImageFormat.PNG,
    int maxHeight = 0,
    int maxWidth = 0,
    int timeMs = 0,
    int quality = 10,
  });

  Future<Uint8List?> thumbnailData({
    required String video,
    Map<String, String>? headers,
    ImageFormat imageFormat = ImageFormat.PNG,
    int maxHeight = 0,
    int maxWidth = 0,
    int timeMs = 0,
    int quality = 10,
  });
}
