import 'dart:async';
import 'package:flutter/services.dart';

class AudioPlayer {
  static const MethodChannel _channel = MethodChannel('audio_player');

  AudioPlayer() {
    init();
  }

  Future<void> init() async {
    await _channel.invokeMethod('init');
  }

  Future<void> play(String url) async {
    await _channel.invokeMethod('play', {'url': url});
  }

  Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  Future<void> resume() async {
    await _channel.invokeMethod('resume');
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  Future<void> seekTo(int position) async {
    await _channel.invokeMethod('seekTo', {'position': position});
  }

  Future<int> getDuration() async {
    final result = await _channel.invokeMethod('getDuration');
    return result ?? 0;
  }

  Future<int> getCurrentPosition() async {
    final result = await _channel.invokeMethod('getCurrentPosition');
    return result ?? 0;
  }

  void dispose() {
    stop();
  }
}