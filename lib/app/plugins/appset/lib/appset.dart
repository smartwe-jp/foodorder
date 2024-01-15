import 'dart:async';

import 'package:flutter/services.dart';

class Appset {
  static const MethodChannel _channel = const MethodChannel('appset');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get showBullyScreen async {
    final String status = await _channel.invokeMethod('showBullyScreen');
    return status;
  }

  static Future<String> get hideBullyScreen async {
    final String status = await _channel.invokeMethod('hideBullyScreen');
    return status;
  }

  static Future<int> playAudio(String audioName) async {
    final int status = await _channel.invokeMethod('playAudio',  <String, dynamic>{
        'audio': audioName,
    });
    return status;
  }

}
