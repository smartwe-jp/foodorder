
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterPluginMsprinter {
  static const MethodChannel _channel =
      const MethodChannel('flutter_plugin_msprinter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> getPrintStatus() async {
    debugPrint("getPrintStatus");
    final String printStatus = await _channel.invokeMethod('getPrintStatus');
    return printStatus;
  }

  static Future<String> sendPrint(printdata,shopInfo,print_paper_size,is_query_receipt,machineMode) async {
    Map<String, String> map = {'operdata': printdata,'shopInfo':shopInfo,'printPaperSize':print_paper_size,'isQueryReceipt':is_query_receipt,'machineMode':machineMode};
    final String printStatus = await _channel.invokeMethod('sendPrint',map);
    return printStatus;
  }

  static Future<String> sendPrintReserve(printdata,shopInfo) async {
    Map<String, String> map = {'operdata': printdata,'shopInfo':shopInfo};
    final String printStatus = await _channel.invokeMethod('sendPrintReserve',map);
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

  static Future<String> sendPrintImg(printdata,cutMode,shopInfo,isTop) async {
    Map<String, String> map = {'operdata': printdata,"cutMode":cutMode,'shopInfo':shopInfo,'isTop':isTop};
    final String printStatus = await _channel.invokeMethod('sendPrintImg',map);
    return printStatus;
  }

  static Future<String> sendPrintImgNew(printdata,cutMode,isTop,topImage) async {
    Map<String, String> map = {'operdata': printdata,"cutMode":cutMode,'isTop':isTop,'topImage':topImage};
    final String printStatus = await _channel.invokeMethod('sendPrintImgNew',map);
    return printStatus;
  }

  static Future<String> sendPrintCut(cutMode) async {
    Map<String, String> map = {"cutMode":cutMode};
    final String printStatus = await _channel.invokeMethod('sendPrintCut',map);
    return printStatus;
  }
}
