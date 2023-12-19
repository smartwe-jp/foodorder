import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/services/showToast.dart';
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
    //Paycube.stopListening();
    super.onClose();
  }

  Future requestPermission() async {
    debugPrint("requestPermission 0");
    //霸屏隐藏状态栏导航栏
    //await Appset.hideBullyScreen; //隐藏状态栏暂时不用
    //获取Windows版本
    String? windowsVersion = await CashChanger.getPlatformVersion;
    debugPrint("windowsVersion:$windowsVersion");

    /// 权限检测
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus != PermissionStatus.granted) {
      storageStatus = await Permission.storage.request();
      if (storageStatus != PermissionStatus.granted) {
        //showToast("权限申请被拒绝");
        //print("权限申请被拒绝");
      } else {
        debugPrint("requestPermission 1");
        checkInterNetStatus();
        //第一步，链接现金机，并打开现金机
        //OpenPayCube();
      }
    } else {
      debugPrint("requestPermission 2");
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
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet) {
      debugPrint("checkInterNetStatus有网络");
      OpenPayCube();
    } else {
      print("没有网络");
      // I am not connected to any network.
      Get.dialog(DialogUtils.alertOneButton(
          "セルフレジはインターネットに接続されてません。\r\n先に、インターネットの接続のご確認をお願いします。",
          title: "お知らせ",
          confirmtitle: "ログアウト", confirm: () {
        Future.delayed(Duration(milliseconds: 200), () {
          Get.back();
          //退出关闭
          exit(0);
        });
      }));
    }
  }

  void openCashChange() async {
    debugPrint("  openCashChange  ");
    int? resultCode = await CashChanger.openCashChanger;
    debugPrint("open CashChanger resultCode:  " + resultCode.toString());

    Get.dialog(
        DialogUtils.alert(
            "open CashChanger resultCode:  " + resultCode.toString(),
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void getPlatformVersion() async {
    debugPrint("  getPlatformVersion  ");
    String? version = await CashChanger.getPlatformVersion;
    debugPrint("windows version:" + version!);
    Get.dialog(
        DialogUtils.alert("windows version:" + version!, title: "CashChanger",
            confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void closeCashChange() async {
    debugPrint("  closeCashChange  ");
    int? resultCode = await CashChanger.closeCashChanger;
    debugPrint("close CashChanger resultCode:  " + resultCode.toString());
    Get.dialog(
        DialogUtils.alert(
            "close CashChanger resultCode:  " + resultCode.toString(),
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void GetCashBalanceInfo() async {
    debugPrint("  GetCashBalanceInfo  ");
    String? resultCode = await CashChanger.getCashBalance;
    debugPrint("GetCashBalanceInfo result:  " + resultCode!);
    Get.dialog(
        DialogUtils.alert("GetCashBalanceInfo result:  " + resultCode,
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void startDeposit() async {
    debugPrint("  StartDeposit  ");
    int? resultCode = await CashChanger.startDeposit;
    debugPrint("StartDeposit result:  " + resultCode.toString());
    Get.dialog(
        DialogUtils.alert("StartDeposit result:  " + resultCode.toString(),
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

//倒计时
  _countDownTimer() {
    showCashTimer?.cancel();
    showCashTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds.value--;

      if (this.seconds == 0) {
        //如果60秒未接收返回正确通知，则进行下一步操作
        _isCashState.value = false;
        getIsFirstOpen();

        showCashTimer?.cancel(); //清除定时器
      }
    });
  }

  //打开现金机
  OpenPayCube() async {
    debugPrint("OpenPayCube 1");
    checkSteeps.value = 2;
    //倒计时，一定时间不开启现金机则继续执行下一步
    _countDownTimer();
    //String checkStatus = await Paycube.CheckPayCubeStatus;
    // debugPrint("OpenPayCube 2");
    // //如果检测现金机打开错误，则重新打开一下
    // if (checkStatus == "openError") {
    //   String openStatus = await Paycube.openPayCube;
    //   //print("机器未打开lib未null，重新打开并连接了");
    // } else {
    //   await Paycube.setReceiveEvent;
    // }

    Starttoubi();
  }

  //现金机开始 打开现金机，准备开始投币
  Starttoubi() async {
    //入金开始
    debugPrint("Starttoubi 1");
    int connectCount = 0;

    prohibitOneCash();
    getIsFirstOpen();
    return;

    String strartPayCube = await Paycube.strartPayCube;
    //调用插件的监听
    Paycube.getPayCubeListener();

    await Paycube.setReceiveEvent;
    allowtimer?.cancel();
    allowtimer =
        Timer.periodic(Duration(milliseconds: 150), (Timer allowt) async {
      _allowStatus = await Paycube.getPayCubeAllowCashStatus;
      connectCount++;
      if (connectCount > 50) {
        //退出关闭
        //exit(0);
        getIsFirstOpen();
      }
      //print("链接次数${}");
      // 循环一定要记得设置取消条件，手动取消
      if (_allowStatus == "AllowSuccess") {
        seconds.value = 60;
        _countDownTimer();

        stopPaycube();
        allowt.cancel();
      } else if (_allowStatus == "Error-F0--16") {
        await Paycube.endTrade;
        //sleep(Duration(milliseconds: 200));
        await Paycube.strartPayCube;
      } else if (_allowStatus == "Error-A0--02") {
        //sleep(Duration(milliseconds: 300));
      } else {
        await Paycube.strartPayCube;
        //print("_allowStatus:$_allowStatus");
      }
    });
  }

  stopPaycube() async {
    checkSteeps.value = 3;
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stopChecktimer?.cancel();
    stopChecktimer =
        Timer.periodic(Duration(milliseconds: 500), (Timer stopcheck) async {
      _stopStatus = await Paycube.getPayCubeStopCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        //倒计时，一定时间不开启现金机则继续执行下一步
        seconds.value = 60;
        _countDownTimer();
        closePaycube();
        stopcheck.cancel();
      } else if (_stopStatus == "Error-A0--02") {
        //处理中
        sleep(Duration(milliseconds: 200));
        await Paycube.endPayCube;
      } else {
        await Paycube.endPayCube;
      }
    });
  }

  closePaycube() async {
    checkSteeps.value = 4;
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    await Paycube.setReceiveEvent;
    closetimer?.cancel();
    closetimer =
        Timer.periodic(Duration(milliseconds: 500), (Timer closecheck) async {
      _closeStatus = await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_closeStatus == "EndSuccess") {
        showCashTimer?.cancel();
        seconds.value = 60;

        //现金机打开一次后，判断是否第一次打开
        prohibitOneCash();

        closecheck.cancel();
      } else {
        await Paycube.endTrade;
      }
    });
  }

  //禁用一元入金和出金
  prohibitOneCash() async {
    //var prohibitOneCashStatus =  await Paycube.prohibitOneCash;

    var cashShowData = {
      "isCash": _isCashState.value,
    };
    Storage.setString('isCashState', json.encode(cashShowData));
    GetxStorage.setData('isCashState', json.encode(cashShowData));
    //判断是否第一次打开
    // Future.delayed(Duration(milliseconds: 300), () {
    //   getIsFirstOpen();
    // });
  }

  //判断是否第一次打开 true为以经激活,下载最新数据保存到本地数据库
  getIsFirstOpen() async {
    debugPrint("getIsFirstOpen 1");
    var isFirst = await HomeServices.getOpenFirstState();
    if (isFirst == true) {
      debugPrint("getIsFirstOpen 2");
      goMain();
    } else {
      _goActivation();
    }
  }

  goMain() async {
    Future.delayed(Duration(milliseconds: 200), () {
      //Get.off(() => TransitPageView());
      Get.toNamed("/transit-page");
    });
  }

  void _goActivation() async {
    Future.delayed(Duration(milliseconds: 200), () {
      Get.toNamed("/activation");
    });
  }
}
