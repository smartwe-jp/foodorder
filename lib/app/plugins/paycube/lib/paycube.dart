
import 'dart:async';

import 'package:flutter/services.dart';


class Paycube {
  static const MethodChannel _channel = const MethodChannel('paycube');

  static void getPutMoneyListener(Function(Map) listener) {
    _channel.setMethodCallHandler((call) async {print(call.method);
    Map message = {};
    if (call.method == 'onGetPutMoneyStringChange') {
      message = {"PutMoney":call.arguments};print(message);
      //listener(message);
    }else if (call.method == 'onGetPutMoneyCurrencyStringChange') {
      //final String message = call.arguments;print(message);
      message = {"PutMoneyString":call.arguments};
      //listener(message);
    }/*else if (call.method == 'getPayOutMoneyServiceChange') {
      //final String message = call.arguments;print(message);
      message = {"outMoneyString":call.arguments};

    }*/
    listener(message);
    });
  }

  static void getPayCubeListener(Function(Map) listener) {
    _channel.setMethodCallHandler((call) async {print(call.method);
    Map message = {};
    if (call.method == 'onGetPutMoneyStringChange') {
      message = {"PutMoney":call.arguments};print(message);
    }else if (call.method == 'onGetPutMoneyCurrencyStringChange') {
      message = {"PutMoneyString":call.arguments};
    }else if (call.method == 'onEndServiceChange') {
      message = {"EndMoneyString":call.arguments};
    }else if (call.method == 'onPayOutServiceChange') {
      message = {"PayOutServiceString":call.arguments};
    }else if (call.method == 'getPayOutMoneyServiceChange') {
      message = {"PayOutMoneyStringServiceString":call.arguments};
    }else if (call.method == 'onEndTradeServiceChange') {
      //final String message = call.arguments;print(message);
      message = {"EndTradeString":call.arguments};

    }
    listener(message);
    });
  }

  // 创建一个方法来停止监听
  static Future<void> stopListening() async {
    try {
      _channel.setMethodCallHandler(null);
    } catch (e) {
      print('停止监听失败: $e');
    }
  }

  static void setEndListener(Function(String) listener) {
    _channel.setMethodCallHandler((call) async {print(call.method);
      if (call.method == 'onEndServiceChange') {
        final String message = call.arguments;print(message);
        listener(message);
      }
    });
  }
  static void getPayOutListener(Function(String) listener) {
    _channel.setMethodCallHandler((call) async {print(call.method);
    if (call.method == 'onPayOutServiceChange') {
      final String message = call.arguments;print(message);
      listener(message);
    }
    });
  }

  static void getPayOutMoneyListener(Function(String) listener) {
    _channel.setMethodCallHandler((call) async {print(call.method);
    if (call.method == 'getPayOutMoneyServiceChange') {
      final String message = call.arguments;print(message);
      listener(message);
    }
    });
  }

  static void setEndTradeListener(Function(String) listener) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onEndTradeServiceChange') {
        final String message = call.arguments;print(message);
        listener(message);
      }
    });
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //打开现金机
  static Future<String> get openPayCube async {
    Map<String, Object> map = {'operEvent': 'openPayCube'};
    final String openstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return openstatus;
  }

  //检查现金机
  static Future<String> get CheckPayCubeStatus async {
    Map<String, Object> map = {'operEvent': 'CheckPayCubeStatus'};
    final String openstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return openstatus;
  }
  
  //开始入金
  static Future<String> get strartPayCube async {
    Map<String, Object> map = {'operEvent': 'StartPayCubeMoney'};
    final String openstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return openstatus;
  }

  //入金许可状态
  static Future<String> get getPayCubeAllowCashStatus async {
    Map<String, Object> map = {'operEvent': 'getPayCubeAllowCashStatus'};
    final String allowstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return allowstatus;
  }

  //入金结束
  static Future<String> get endPayCube async {
    Map<String, Object> map = {'operEvent': 'endPayCube'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //入金禁止状态
  static Future<String> get getPayCubeStopCashStatus async {
    Map<String, Object> map = {'operEvent': 'getPayCubeStopCashStatus'};
    final String stopstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return stopstatus;
  }

  //交易结束
  static Future<String> get endTrade async {
    Map<String, Object> map = {'operEvent': 'endTradePayCube'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //取引终了状态
  static Future<String> get getPayCubeEndTradeStatus async {
    Map<String, Object> map = {'operEvent': 'getPayCubeEndTradeStatus'};
    final String endstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return endstatus;
  }

  //关闭机器
  static Future<String> get closePayCube async {
    Map<String, Object> map = {'operEvent': 'closePayCube'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //获取入金金额
  static Future<String> get getPayCubeMoney async {
    Map<String, Object> map = {'operEvent': 'getPayCubeMoney'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //获取出金金额
 static Future<String> get getPayCubeOutMoney async {
    Map<String, Object> map = {'operEvent': 'getPayCubeOutMoney'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //出金状态
  static Future<String> get getPayCubeOutMoneyStatus async {
    Map<String, Object> map = {'operEvent': 'getPayCubeOutMoneyStatus'};
    final String outstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return outstatus;
  }

  //出金金额
  static Future<String> outPayCubeMoney(param) async {
    Map<String, Object> map = {'operEvent': 'outPayCubeMoney','outMoney': param};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //获取出金币种
  static Future<String> get getPayCubeOutMoneyCurrency async {
    Map<String, Object> map = {'operEvent': 'getPayCubeOutMoneyCurrency'};
    final String currencyString = await _channel.invokeMethod('startOpenPayCube',map);
    return currencyString;
  }

  //获取入金币种
  static Future<String> get getPayCubePutMoneyCurrency async {
    Map<String, Object> map = {'operEvent': 'getPayCubePutMoneyCurrency'};
    final String currencyString = await _channel.invokeMethod('startOpenPayCube',map);
    return currencyString;
  }

  //机器状态
  static Future<String> get getPayCubeMachineStatus async {
    Map<String, Object> map = {'operEvent': 'getPayCubeMachineStatus'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //机器Set
  static Future<String> get setReceiveEvent async {
    Map<String, Object> map = {'operEvent': 'setReceiveEventStatus'};
    final String inputStatus = await _channel.invokeMethod('startOpenPayCube',map);
    return inputStatus;
  }

  //禁止一块入金和出金
  static Future<String> get prohibitOneCash async {
    Map<String, Object> map = {'operEvent': 'prohibitOneCash'};
    final String prohibitOneCashString = await _channel.invokeMethod('startOpenPayCube',map);
    return prohibitOneCashString;
  }

  //允许一块入金和出金
  static Future<String> get allowOneCash async {
    Map<String, Object> map = {'operEvent': 'allowOneCash'};
    final String prohibitOneCashString = await _channel.invokeMethod('startOpenPayCube',map);
    return prohibitOneCashString;
  }

}
