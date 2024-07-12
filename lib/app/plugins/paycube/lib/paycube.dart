
import 'dart:async';

import 'package:flutter/services.dart';


class Paycube {
  static const MethodChannel _channel = const MethodChannel('paycube');

  static String putMoney = "0";
  static String putCurrency = "";
  static String currencyString = ""; //币种 截取0B 81的43位开始

  //监听几种状态
  static String payCubeStopCashStatus = "Error";
  static String payCubeOutMoneyStatus = "Error";
  static String payCubeEndTradeStatus = "Error";



  static void getPayCubeListener() {
    _channel.setMethodCallHandler((call) async {
      print(call.method+"======"+call.arguments);
    Map message = {};
    if (call.method == 'onGetPutMoneyStringChange') {
      //print(message);
      putMoney = call.arguments;
      //message = {"PutMoney":call.arguments};print(message);
    }else if (call.method == 'onGetPutMoneyCurrencyStringChange') {
      putCurrency = call.arguments;
      //message = {"PutMoneyString":call.arguments};
    }else if (call.method == 'onEndServiceChange') {
      payCubeStopCashStatus = call.arguments;
      //message = {"EndMoneyString":call.arguments};
    }else if (call.method == 'onPayOutServiceChange') {
      payCubeOutMoneyStatus = call.arguments;
      //message = {"PayOutServiceString":call.arguments};
    }else if (call.method == 'getPayOutMoneyServiceChange') {
      //print("出金统计字符串${call.arguments}");
      currencyString = call.arguments;
      //message = {"PayOutMoneyStringServiceString":call.arguments};
    }else if (call.method == 'onEndTradeServiceChange') {
      payCubeEndTradeStatus = call.arguments;
      //final String message = call.arguments;print(message);
      //message = {"EndTradeString":call.arguments};

    }
    //listener(message);
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
    putMoney = "0";
    putCurrency = "";
    currencyString = ""; //币种 截取0B 81的43位开始

    //监听几种状态
    payCubeStopCashStatus = "Error";
    payCubeOutMoneyStatus = "Error";
    payCubeEndTradeStatus = "Error";

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

  static Future<String> get sendPutCashDetail async {

    Map<String, Object> map = {'operEvent': 'sendPutCashDetail'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //入金禁止状态
  static Future<String> get getPayCubeStopCashStatus async {
    //print("这是返回插件更新后的static payCubeStopCashStatus${payCubeStopCashStatus}");
    return payCubeStopCashStatus;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeStopCashStatus'};
    final String stopstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return stopstatus;*/
  }

  //交易结束
  static Future<String> get endTrade async {
    Map<String, Object> map = {'operEvent': 'endTradePayCube'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //取引终了状态
  static Future<String> get getPayCubeEndTradeStatus async {
    //print("这是返回插件更新后的static payCubeEndTradeStatus${payCubeEndTradeStatus}");
    return payCubeEndTradeStatus;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeEndTradeStatus'};
    final String endstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return endstatus;*/
  }

  //关闭机器
  static Future<String> get closePayCube async {
    Map<String, Object> map = {'operEvent': 'closePayCube'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //获取入金金额
  static Future<String> get getPayCubeMoney async {
    //print("这是返回插件更新后的static pubmoney${putMoney}");
    return putMoney;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeMoney'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;*/
  }

  //获取出金金额
 static Future<String> get getPayCubeOutMoney async {
    Map<String, Object> map = {'operEvent': 'getPayCubeOutMoney'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //出金状态
  static Future<String> get getPayCubeOutMoneyStatus async {
    //print("这是返回插件更新后的static payCubeOutMoneyStatus${payCubeOutMoneyStatus}");
    return payCubeOutMoneyStatus;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeOutMoneyStatus'};
    final String outstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return outstatus;*/
  }

  //出金金额
  static Future<String> outPayCubeMoney(param) async {
    Map<String, Object> map = {'operEvent': 'outPayCubeMoney','outMoney': param};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //获取出金币种
  static Future<String> get getPayCubeOutMoneyCurrency async {
    //print("这是返回插件更新后的static1111111 currencyString${currencyString}");
    if(currencyString.length >= 70 ){
      currencyString = currencyString.substring(63);
    }
    //print("这是返回插件更新后的static currencyString${currencyString}");
    return currencyString;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeOutMoneyCurrency'};
    final String currencyString = await _channel.invokeMethod('startOpenPayCube',map);
    return currencyString;*/
  }

  //获取入金币种
  static Future<String> get getPayCubePutMoneyCurrency async {
    //print("这是返回插件更新后的static putCurrency${putCurrency}");
    return putCurrency;
    /*Map<String, Object> map = {'operEvent': 'getPayCubePutMoneyCurrency'};
    final String currencyString = await _channel.invokeMethod('startOpenPayCube',map);
    return currencyString;*/
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

  //开始入金
  static Future<String> get strartRefundPayCube async {print("退款开始出金");
    putMoney = "0";
    putCurrency = "";
    currencyString = ""; //币种 截取0B 81的43位开始

    //监听几种状态
    payCubeStopCashStatus = "Error";
    payCubeOutMoneyStatus = "Error";
    payCubeEndTradeStatus = "Error";

    return "Success";
  }

}
