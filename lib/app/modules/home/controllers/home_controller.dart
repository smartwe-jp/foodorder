import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:get/get.dart';
import 'package:appset/appset.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:paycube/paycube.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/HomeServices.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/Storage.dart';
import '../../../widget/DialogUtils.dart';
import '../../TransitPage/views/transit_page_view.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

   Timer? allowtimer;
   Timer? stoptimer;
   Timer? stopChecktimer;
   Timer? closetimer;

  //60秒内未接收现金机正确通知，则进行下一步操作
   Timer? showCashTimer;
  RxInt seconds = 60.obs;
  RxBool _isCashState = true.obs;
  RxInt checkSteeps = 1.obs; //自检步骤
   RxString _machineCode = "".obs;
  var _allowStatus;
  var _stopStatus;
  var _closeStatus;



  @override
  void onInit() {
  super.onInit();
    requestPermission();
  //getIsFirstOpen();
    //checkInterNetStatus();

    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..progressColor = Colors.grey
      ..backgroundColor = Colors.white
      ..indicatorColor = Colors.transparent
      ..textColor = Colors.transparent
      ..loadingStyle = EasyLoadingStyle.custom;


  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    Paycube.stopListening();
    super.onClose();
  }

   _getMachineInfo() async {
     var machineCode = await HomeServices.getMachineInfo();
     if (machineCode != "" && machineCode != null) {
       _machineCode.value = machineCode;
     }
   }


  Future requestPermission() async {

    //霸屏隐藏状态栏导航栏
    await Appset.hideBullyScreen;

    await _getMachineInfo();
    /// 权限检测
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus != PermissionStatus.granted) {
      storageStatus = await Permission.storage.request();
      if (storageStatus != PermissionStatus.granted) {
        //showToast("权限申请被拒绝");
        //print("权限申请被拒绝");
      }else{

        checkInterNetStatus();
        //第一步，链接现金机，并打开现金机
        //OpenPayCube();
      }
    }else{

      checkInterNetStatus();
      //OpenPayCube();
    }
  }

  //检测网络状态
  //セルフレジはインターネットに接続されてません。 ()弹出框提示语
  // 先に、インターネットの接続のご確認をお願いします。 （）提示的提示语
  checkInterNetStatus() async {
    checkSteeps.value = 1;
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile
    || connectivityResult == ConnectivityResult.wifi
    || connectivityResult == ConnectivityResult.ethernet) {
      OpenPayCube();
    } else {print("没有网络");
      // I am not connected to any network.
      Get.dialog(
          DialogUtils.alertOneButton("セルフレジはインターネットに接続されてません。\r\n先に、インターネットの接続のご確認をお願いします。",
              title: "お知らせ",
              confirmtitle: "ログアウト",
              confirm: () {
                Future.delayed(Duration(milliseconds: 200), () {
                  Get.back();
                  //退出关闭
                  exit(0);
                });

              })
      );
    }


  }


//倒计时
  _countDownTimer() {
    showCashTimer?.cancel();
    showCashTimer = Timer.periodic(Duration(seconds: 1), (timer) async {

      seconds.value--;

      if (this.seconds == 0) {
        //如果60秒未接收返回正确通知，则进行下一步操作
          _isCashState.value = false;
          showCashTimer?.cancel();
          await _sendFailureEmail();
          await prohibitOneCash();

         //清除定时器

      }
    });
  }

  //打开现金机
  OpenPayCube() async {
    checkSteeps.value = 2;
    //倒计时，一定时间不开启现金机则继续执行下一步
    _countDownTimer();
    String checkStatus = await Paycube.CheckPayCubeStatus;
    debugPrint("checkStatus:$checkStatus");

    //如果检测现金机打开错误，则重新打开一下
    if(checkStatus == "openError"){
      int _openCount = 0;
      for (var i = 0; i < 3; i++) {
        String openStatus = await Paycube.openPayCube;
        debugPrint("openStatus:$openStatus");
        _openCount++;
        debugPrint("打开次数$_openCount");
        if (openStatus == "openSuccess") {
          seconds.value=60;
          _countDownTimer();
          Starttoubi();
          return;
        }
      }
      //send failure email
      showCashTimer?.cancel();
      _isCashState.value = false;
      await _sendFailureEmail();
      await prohibitOneCash();
      //print("机器未打开lib未null，重新打开并连接了");
    }else{
      await Paycube.setReceiveEvent;
      Starttoubi();
    }

  }

  _sendFailureEmail() async {
    debugPrint("发送通知邮件");

    var formData = {
      "machineCode": _machineCode.value,
    };
    request("webBootTroubleNotify", method: "POST" ,parameters: formData).then((value) {
      var response = json.decode(value.toString());
      debugPrint("发送通知邮件 response:$response");
      if (response != null && response['code'] == 200) {
        FirebaseAnalytics.instance.logEvent(name: 'send_trouble_email', parameters: {'sendTroubleEmail': 'true'});
      } else {
        FirebaseAnalytics.instance.logEvent(name: 'send_trouble_email', parameters: {'sendTroubleEmail': 'false'});
      }
    });

  }

  //现金机开始 打开现金机，准备开始投币
  Starttoubi() async {

    //入金开始
    int connectCount = 0;
    String strartPayCube = await Paycube.strartPayCube;
    debugPrint("strartPayCube:$strartPayCube");
    //调用插件的监听
    Paycube.getPayCubeListener();

    await Paycube.setReceiveEvent;
    allowtimer?.cancel();
    allowtimer = Timer.periodic(Duration(milliseconds: 150), (Timer allowt) async {
      _allowStatus =  await Paycube.getPayCubeAllowCashStatus;
      debugPrint("_allowStatus:$_allowStatus");
      connectCount++;
      debugPrint("链接次数$connectCount");
      if(connectCount > 50){
        //退出关闭
        //exit(0);
        allowt.cancel();
        showCashTimer?.cancel();
        _isCashState.value = false;
        await _sendFailureEmail();
        await prohibitOneCash();

        //getIsFirstOpen();
      }
      //print("链接次数${}");
      // 循环一定要记得设置取消条件，手动取消
      if (_allowStatus == "AllowSuccess") {
        seconds.value=60;
        _countDownTimer();

        stopPaycube();
        allowt.cancel();

      }else if (_allowStatus == "Error-F0--16") {
        allowt.cancel();
        //await Paycube.endPayCube;

        await Paycube.endTrade;
        //await Future.delayed(Duration(milliseconds: 200));
        //sleep(Duration(milliseconds: 200));
        Starttoubi();
      }else if (_allowStatus == "Error-A0--02") {
        //sleep(Duration(milliseconds: 300));
      }else{
        await Paycube.strartPayCube;
        //print("_allowStatus:$_allowStatus");

      }

    });


  }
  stopPaycube() async {
    checkSteeps.value = 3;
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    debugPrint("endStatus:$endStatus");
    stopChecktimer?.cancel();
    stopChecktimer = Timer.periodic(Duration(milliseconds: 550), (Timer stopcheck) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      debugPrint("_stopStatus:$_stopStatus");
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        //倒计时，一定时间不开启现金机则继续执行下一步
        seconds.value=60;
        _countDownTimer();
        closePaycube();
        stopcheck.cancel();

      }else if(_stopStatus == "Error-A0--02"){
        //处理中
        sleep(Duration(milliseconds: 200));
        await Paycube.endPayCube;
      }else{
        await Paycube.endPayCube;
      }
    });
  }

  closePaycube() async {
    checkSteeps.value = 4;
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    debugPrint("endTrade:$endTrade");
    await Paycube.setReceiveEvent;
    closetimer?.cancel();
    closetimer = Timer.periodic(Duration(milliseconds: 550), (Timer closecheck) async {
      _closeStatus =  await Paycube.getPayCubeEndTradeStatus;
      debugPrint("_closeStatus:$_closeStatus");
      // 循环一定要记得设置取消条件，手动取消
      if (_closeStatus == "EndSuccess" ) {
        showCashTimer?.cancel();
        seconds.value=60;

        //现金机打开一次后，判断是否第一次打开
        prohibitOneCash();

        closecheck.cancel();
      }else{

        await Paycube.endTrade;
      }
    });
  }

  //禁用一元入金和出金
  prohibitOneCash() async {
    //var prohibitOneCashStatus =  await Paycube.prohibitOneCash;
    debugPrint("prohibitOneCashStatus _isCashState:${_isCashState.value}");
    var cashShowData = {
      "isCash": _isCashState.value,
    };
    Storage.setString('isCashState', json.encode(cashShowData));
    GetxStorage.setData('isCashState', json.encode(cashShowData));
    //判断是否第一次打开
    Future.delayed(Duration(milliseconds: 300), () {
      getIsFirstOpen();
    });
  }

  //判断是否第一次打开 true为以经激活,下载最新数据保存到本地数据库
  getIsFirstOpen() async {

    var isFirst = await HomeServices.getOpenFirstState();
    if(isFirst == true){
      _goMain();

    }else{
      _goActivation();
    }
  }

  void _goMain() async {

    Future.delayed(Duration(milliseconds: 200), () {
      //Get.off(() => TransitPageView());
      Get.toNamed("/transit-page", arguments: {"loadActive": true});
    });

  }

  void _goActivation() async {

    Future.delayed(Duration(milliseconds: 200), () {
      Get.toNamed("/activation");
    });

  }



}
