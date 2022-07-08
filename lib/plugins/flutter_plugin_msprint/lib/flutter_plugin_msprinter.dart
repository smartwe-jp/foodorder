
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

  static Future<String> sendPrint(printdata,shopInfo,print_paper_size,is_query_receipt) async {
    Map<String, String> map = {'operdata': printdata,'shopInfo':shopInfo,'printPaperSize':print_paper_size,'isQueryReceipt':is_query_receipt};
    final String printStatus = await _channel.invokeMethod('sendPrint',map);
    return printStatus;
  }

  static Future<String> setPrintPaperSizefiftyeight() async {
    final String printStatus = await _channel.invokeMethod('setPrintPaperSizefiftyeight');
    return printStatus;
  }

  static Future<String> setPrintPaperSizeeighty() async {
    final String printStatus = await _channel.invokeMethod('setPrintPaperSizeeighty');
    return printStatus;
  }

  static Future<String> setPrintPaperSizePrintTest() async {
    final String printStatus = await _channel.invokeMethod('setPrintPaperSizePrintTest');
    return printStatus;
  }
}
