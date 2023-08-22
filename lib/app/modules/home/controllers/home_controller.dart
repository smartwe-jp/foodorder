import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
import '../../TransitPage/views/transit_page_view.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  Timer allowtimer;
  Timer stoptimer;
  Timer stopChecktimer;
  Timer closetimer;

  //60秒内未接收现金机正确通知，则进行下一步操作
  Timer showCashTimer;
  RxInt seconds = 60.obs;
  RxBool _isCashState = true.obs;

  var _allowStatus;
  var _stopStatus;
  var _closeStatus;

  @override
  void onInit() {print("开始进来了");
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
    super.onClose();
  }


  Future requestPermission() async {
    //霸屏隐藏状态栏导航栏
    await Appset.hideBullyScreen;
    /// 权限检测
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus != PermissionStatus.granted) {
      storageStatus = await Permission.storage.request();
      if (storageStatus != PermissionStatus.granted) {
        //showToast("权限申请被拒绝");
        //print("权限申请被拒绝");
      }else{

        //第一步，链接现金机，并打开现金机
        OpenPayCube();
      }
    }else{

      OpenPayCube();
    }
  }

  //检测网络状态
  //セルフレジはインターネットに接続されてません。 ()弹出框提示语
  // 先に、インターネットの接続のご確認をお願いします。 （）提示的提示语
  checkInterNetStatus() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {print("mobile");
      // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {print("wifi");
      // I am connected to a wifi network.
    } else if (connectivityResult == ConnectivityResult.ethernet) {print("ethernet");
      // I am connected to a ethernet network.
    } else if (connectivityResult == ConnectivityResult.vpn) {print("vpn");
      // I am connected to a vpn network.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
    } else if (connectivityResult == ConnectivityResult.bluetooth) {print("bluetooth");
      // I am connected to a bluetooth.
    } else if (connectivityResult == ConnectivityResult.other) {print("other");
      // I am connected to a network which is not in the above mentioned networks.
    } else if (connectivityResult == ConnectivityResult.none) {print("没有网络");
      // I am not connected to any network.
    }
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
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(450),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("テスト中です、しばらくお待ちください。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                )),
            Text("1、釣銭機を開けています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("2、現金機を閉じています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(250),
              child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
    //倒计时，一定时间不开启现金机则继续执行下一步
    _countDownTimer();
    String checkStatus = await Paycube.CheckPayCubeStatus;

    //如果检测现金机打开错误，则重新打开一下
    if(checkStatus == "openError"){
      String openStatus = await Paycube.openPayCube;
      //print("机器未打开lib未null，重新打开并连接了");
    }else{
      await Paycube.setReceiveEvent;
    }

    Starttoubi();
  }

  //现金机开始 打开现金机，准备开始投币
  Starttoubi() async {
    EasyLoading.dismiss();
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(450),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("テスト中です、しばらくお待ちください。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("1、釣銭機を開けています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                )),
            Text("2、釣銭機を閉じています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),

            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(250),
              child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
    //入金开始
    int connectCount = 0;
    String strartPayCube = await Paycube.strartPayCube;
    await Paycube.setReceiveEvent;
    allowtimer?.cancel();
    allowtimer = Timer.periodic(Duration(milliseconds: 150), (Timer allowt) async {
      _allowStatus =  await Paycube.getPayCubeAllowCashStatus;
      connectCount++;
      if(connectCount > 50){
        //退出关闭
        //exit(0);
        getIsFirstOpen();
      }
      //print("链接次数${}");
      // 循环一定要记得设置取消条件，手动取消
      if (_allowStatus == "AllowSuccess") {
        seconds.value=60;
        _countDownTimer();

        stopPaycube();
        allowt.cancel();

      }else if (_allowStatus == "Error-F0--16") {
        await Paycube.endTrade;
        //sleep(Duration(milliseconds: 200));
        await Paycube.strartPayCube;
      }else if (_allowStatus == "Error-A0--02") {
        //sleep(Duration(milliseconds: 300));
      }else{

        await Paycube.strartPayCube;
        //print("_allowStatus:$_allowStatus");

      }

    });


  }
  stopPaycube() async {
    EasyLoading.dismiss();
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(450),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("テスト中です、しばらくお待ちください。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("1、釣銭機を開けています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("2、釣銭機を閉じています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                )),
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(250),
              child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stopChecktimer?.cancel();
    stopChecktimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopcheck) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
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
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    await Paycube.setReceiveEvent;
    closetimer?.cancel();
    closetimer = Timer.periodic(Duration(milliseconds: 500), (Timer closecheck) async {
      _closeStatus =  await Paycube.getPayCubeEndTradeStatus;
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

    EasyLoading.dismiss();

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
      Get.toNamed("/transit-page");
    });

  }

  void _goActivation() async {

    Future.delayed(Duration(milliseconds: 200), () {
      Get.toNamed("/activation");
    });

  }



}
