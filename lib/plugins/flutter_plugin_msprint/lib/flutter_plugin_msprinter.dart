
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPluginMsprinter {
  static const MethodChannel _channel =
      const MethodChannel('flutter_plugin_msprinter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> getPrintStatus() async {
    final String printStatus = await _channel.invokeMethod('getPrintStatus');
    return printStatus;
  }

  static Future<String> sendPrint(printdata,shopInfo) async {
    Map<String, String> map = {'operdata': printdata,'shopInfo':shopInfo};
    final String printStatus = await _channel.invokeMethod('sendPrint',map);
    return printStatus;
  }
}
