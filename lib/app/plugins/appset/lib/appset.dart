
import 'dart:async';

import 'package:flutter/services.dart';

class Appset {
  static const MethodChannel _channel =
      const MethodChannel('appset');

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

  //restart
  static Future<String> get restartApp async {
    final String status = await _channel.invokeMethod('restartApp');
    return status;
  }
}
