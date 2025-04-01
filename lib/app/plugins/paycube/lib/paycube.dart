
import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CashInfo {
  putMoney,
  putCurrency,
  currencyString,
}

class Paycube {

  static final Paycube _instance = Paycube._internal();

  factory Paycube() {
    return _instance;
  }

  Paycube._internal();

  final MethodChannel _channel = const MethodChannel('paycube');

  String putMoney = "0";
  String putCurrency = "";
  String currencyString = ""; //币种 截取0B 81的43位开始

  Function(CashInfo, String)? onCashInfoChange;

  //监听几种状态
  String payCubeStopCashStatus = "Error";
  String payCubeOutMoneyStatus = "Error";
  String payCubeEndTradeStatus = "Error";

  int _seqNo = 0;

  int getSeqNo() {
    _seqNo++;
    if (_seqNo == 0xFFFF) {
      _seqNo = 1;
    }
    return _seqNo;
  }



  void getPayCubeListener() {
    _channel.setMethodCallHandler((call) async {
      print(call.method+"======"+call.arguments);
    Map message = {};
    if (call.method == 'onGetPutMoneyStringChange') {
      //print(message);
      putMoney = call.arguments;
      onCashInfoChange?.call(CashInfo.putMoney, call.arguments);
      //message = {"PutMoney":call.arguments};print(message);
    }else if (call.method == 'onGetPutMoneyCurrencyStringChange') {
      putCurrency = call.arguments;
      onCashInfoChange?.call(CashInfo.putCurrency, call.arguments);
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
      onCashInfoChange?.call(CashInfo.currencyString, call.arguments);
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
  Future<void> stopListening() async {
    try {
      _channel.setMethodCallHandler(null);
    } catch (e) {
      print('停止监听失败: $e');
    }
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //打开现金机
  Future<String> get openPayCube async {

    Map<String, Object> map = {'operEvent': 'openPayCube'};
    final String openstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return openstatus;
  }

  //检查现金机
  Future<String> get CheckPayCubeStatus async {
    Map<String, Object> map = {'operEvent': 'CheckPayCubeStatus'};
    final String openstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return openstatus;
  }
  
  //开始入金
  Future<bool> startPayCube(
      {required Function onSuccess,
    required Function(String) catchError}) async {
    var ret = false;
    putMoney = "0";
    putCurrency = "";
    currencyString = ""; //币种 截取0B 81的43位开始

    //监听几种状态
    payCubeStopCashStatus = "Error";
    payCubeOutMoneyStatus = "Error";
    payCubeEndTradeStatus = "Error";
    int seqNo = getSeqNo();
    debugPrint("seqNo: $seqNo");
    await setReceiveEvent;
    final String openStatus = await startPayCubeAction(seqNo);
    if (openStatus == "AllowSuccess") {
      onSuccess();
      ret = true;
    } else {
      catchError(openStatus);
      ret = false;
    }
    return ret;
  }

  Future<String> startPayCubeAction(int seqNo, {int retryCount = 0}) async {
    debugPrint("startPayCubeAction called with seqNo: $seqNo " + "retryCount: $retryCount");
    Map<String, Object> map = {'operEvent': 'StartPayCubeMoney', 'seqNo': seqNo};
    String openStatus = "Error";
    try {
      openStatus = await _channel.invokeMethod('startOpenPayCube', map)
          .timeout(Duration(milliseconds: 3000));

      if (openStatus == "AllowSuccess") {
        return openStatus;
      }

    } catch (e) {
      print("Attempt $retryCount failed: $e");
    }

    if (openStatus == "Error-F0--16"){
      await endTrade(onSuccess: (){

      },catchError: (e){

      });

      if (retryCount < 12) {
        await Future.delayed(Duration(milliseconds: 550));
        return startPayCubeAction(seqNo, retryCount: retryCount + 1);
      } else {
        return "startPayCubeAction Failed after $retryCount retries";
      }

    } else {
      if (retryCount < 10) {
        await Future.delayed(Duration(milliseconds: 550));
        return startPayCubeAction(seqNo, retryCount: retryCount + 1);
      } else {
        return "startPayCubeAction Failed after $retryCount retries";
      }
    }

  }

  //入金许可状态
  Future<String> get getPayCubeAllowCashStatus async {
    Map<String, Object> map = {'operEvent': 'getPayCubeAllowCashStatus'};
    final String allowstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return allowstatus;
  }

  //入金结束
  Future<bool> endPayCube({required Function onSuccess, required Function(String) catchError}) async {
    var ret = false;
    await setReceiveEvent;
    int seqNo = getSeqNo();
    final String openStatus = await endPayCubeAction(seqNo);
    if (openStatus == "StopSuccess") {
      onSuccess();
      ret = true;
    } else {
      catchError(openStatus);
      ret = false;
    }
    return ret;
  }

  Future<String> endPayCubeAction(int seqNo, {int retryCount = 0}) async {
    debugPrint("endPayCubeAction called with seqNo: $seqNo + retryCount: $retryCount");
    Map<String, Object> map = {'operEvent': 'endPayCube', 'seqNo': seqNo};
    try {
      final String openStatus = await _channel.invokeMethod('startOpenPayCube', map)
          .timeout(Duration(milliseconds: 5000));

      if (openStatus == "StopSuccess") {
        return openStatus;
      }
    } catch (e) {
      print("EndPayCube Attempt $retryCount failed: $e");
    }

    if (retryCount < 10) {
      await Future.delayed(Duration(milliseconds: 550));
      return endPayCubeAction(seqNo, retryCount: retryCount + 1);
    } else {
      return "endPayCube Failed after $retryCount retries";
    }
  }

  Future<String> get sendPutCashDetail async {
    await setReceiveEvent;
    Map<String, Object> map = {'operEvent': 'sendPutCashDetail', 'seqNo': getSeqNo()};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //入金禁止状态
  Future<String> get getPayCubeStopCashStatus async {
    //print("这是返回插件更新后的payCubeStopCashStatus${payCubeStopCashStatus}");
    return payCubeStopCashStatus;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeStopCashStatus'};
    final String stopstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return stopstatus;*/
  }

  Future<bool> endTrade({required Function onSuccess, required Function(String) catchError}) async {
    var ret = false;
    await setReceiveEvent;
    int seqNo = getSeqNo();
    final String openStatus = await endTradePayCubeAction(seqNo);
    if (openStatus == "EndSuccess") {
      onSuccess();
      ret = true;
    } else {
      catchError(openStatus);
      ret = false;
    }
    return ret;
  }

  Future<String> endTradePayCubeAction(int seqNo, {int retryCount = 0}) async {
    debugPrint("endTradePayCubeAction called with seqNo: $seqNo + retryCount: $retryCount");
    Map<String, Object> map = {'operEvent': 'endTradePayCube', 'seqNo': seqNo};

    try {
      final String openStatus = await _channel.invokeMethod('startOpenPayCube', map)
          .timeout(Duration(milliseconds: 5000));

      if (openStatus == "EndSuccess") {
        return openStatus;
      }
    } catch (e) {
      print("EndTrade Attempt $retryCount failed: $e");
    }

    //if (retryCount < 5) {
      await Future.delayed(Duration(milliseconds: 550));
      return endTradePayCubeAction(seqNo, retryCount: retryCount + 1);
    //} else {
    //  return "endTradePayCube Failed after $retryCount retries";
    //}
  }

  //取引终了状态
  Future<String> get getPayCubeEndTradeStatus async {
    //print("这是返回插件更新后的payCubeEndTradeStatus${payCubeEndTradeStatus}");
    return payCubeEndTradeStatus;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeEndTradeStatus'};
    final String endstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return endstatus;*/
  }

  //关闭机器
  Future<String> get closePayCube async {
    Map<String, Object> map = {'operEvent': 'closePayCube'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //获取入金金额
  Future<String> get getPayCubeMoney async {
    //print("这是返回插件更新后的pubmoney${putMoney}");
    return putMoney;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeMoney'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;*/
  }

  //获取出金金额
 Future<String> get getPayCubeOutMoney async {
    Map<String, Object> map = {'operEvent': 'getPayCubeOutMoney'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //出金状态
  Future<String> get getPayCubeOutMoneyStatus async {
    //print("这是返回插件更新后的payCubeOutMoneyStatus${payCubeOutMoneyStatus}");
    return payCubeOutMoneyStatus;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeOutMoneyStatus'};
    final String outstatus = await _channel.invokeMethod('startOpenPayCube',map);
    return outstatus;*/
  }

  //出金金额

  Future<bool> outPayCubeMoney(param, {required Function onSuccess, required Function(String) catchError}) async {
    var ret = false;
    await setReceiveEvent;
    int seqNo = getSeqNo();
    final String openStatus = await outPayCubeAction(seqNo, param);
    if (openStatus == "OutSuccess") {
      onSuccess();
      ret = true;
    } else {
      catchError(openStatus);
      ret = false;
    }
    return ret;
  }

  Future<String> outPayCubeAction(int seqNo, param, {int retryCount = 0}) async {
    debugPrint("outPayCubeAction called with seqNo: $seqNo + retryCount: $retryCount");
    Map<String, Object> map = {'operEvent': 'outPayCubeMoney', 'seqNo': seqNo,'outMoney': param};

    try {
      final String openStatus = await _channel.invokeMethod('startOpenPayCube', map)
          .timeout(Duration(milliseconds: 10000));

      if (openStatus == "OutSuccess") {
        return openStatus;
      }
    } catch (e) {
      print("Attempt $retryCount failed: $e");
    }

    if (retryCount < 10) {
      await Future.delayed(Duration(milliseconds: 550));
      return outPayCubeAction(seqNo, param, retryCount: retryCount + 1);
    } else {
      return "outPayCubeAction Failed after $retryCount retries";
    }
  }

  //获取出金币种
  Future<String> get getPayCubeOutMoneyCurrency async {
    //print("这是返回插件更新后的static1111111 currencyString${currencyString}");
    if(currencyString.length >= 70 ){
      currencyString = currencyString.substring(63);
    }
    //print("这是返回插件更新后的currencyString${currencyString}");
    return currencyString;
    /*Map<String, Object> map = {'operEvent': 'getPayCubeOutMoneyCurrency'};
    final String currencyString = await _channel.invokeMethod('startOpenPayCube',map);
    return currencyString;*/
  }

  //获取入金币种
  Future<String> get getPayCubePutMoneyCurrency async {
    //print("这是返回插件更新后的putCurrency${putCurrency}");
    return putCurrency;
    /*Map<String, Object> map = {'operEvent': 'getPayCubePutMoneyCurrency'};
    final String currencyString = await _channel.invokeMethod('startOpenPayCube',map);
    return currencyString;*/
  }

  //机器状态
  Future<String> get getPayCubeMachineStatus async {
    Map<String, Object> map = {'operEvent': 'getPayCubeMachineStatus'};
    final String inputAmount = await _channel.invokeMethod('startOpenPayCube',map);
    return inputAmount;
  }

  //机器Set
  Future<String> get setReceiveEvent async {
    Map<String, Object> map = {'operEvent': 'setReceiveEventStatus'};
    final String inputStatus = await _channel.invokeMethod('startOpenPayCube',map);
    return inputStatus;
  }

  //禁止一块入金和出金
  Future<String> get prohibitOneCash async {
    Map<String, Object> map = {'operEvent': 'prohibitOneCash', 'seqNo': getSeqNo()};
    final String prohibitOneCashString = await _channel.invokeMethod('startOpenPayCube',map);
    return prohibitOneCashString;
  }

  //禁止入金和出金
  Future<bool> setAcceptCash(bool enable, int type, {required Function onSuccess, required Function(String) catchError}) async {
    int isEnable = enable ? 1:0;
    var ret = false;
    await setReceiveEvent;
    int seqNo = getSeqNo();
    final String openStatus = await setAcceptCashAction(isEnable, type, seqNo);
    if (openStatus == "SetSuccess") {
      onSuccess();
      ret = true;
    } else {
      catchError(openStatus);
      ret = false;
    }
    return ret;
  }

  Future<String> setAcceptCashAction(int enable, int type, int seqNo, {int retryCount = 0}) async {
    debugPrint("setAcceptCash called with seqNo: $seqNo + retryCount: $retryCount");
    Map<String, Object> map = {'operEvent': 'setAcceptCash', 'seqNo': getSeqNo(), 'enable': enable, 'type': type};

    try {
      final String openStatus = await _channel.invokeMethod('startOpenPayCube', map)
          .timeout(Duration(milliseconds: 2000));

      if (openStatus == "SetSuccess") {
        return openStatus;
      }
    } catch (e) {
      print("Attempt $retryCount failed: $e");
    }

    if (retryCount < 10) {
      await Future.delayed(Duration(milliseconds: 550));
      return setAcceptCashAction(enable, type, seqNo, retryCount: retryCount + 1);
    } else {
      return "setAcceptCash Failed after $retryCount retries";
    }
  }


  //允许一块入金和出金
  Future<String> get allowOneCash async {
    Map<String, Object> map = {'operEvent': 'allowOneCash', 'seqNo': getSeqNo()};
    final String prohibitOneCashString = await _channel.invokeMethod('startOpenPayCube',map);
    return prohibitOneCashString;
  }

  //开始入金
  Future<String> get strartRefundPayCube async {print("退款开始出金");
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
