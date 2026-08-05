import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:get/get.dart';
import 'package:appset/appset.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:paycube/paycube.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../plugins/paycube_old/lib/paycube.dart';
import '../../../services/CustomLogerHandler.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/services/print_failed_service.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/HomeServices.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/Storage.dart';
import '../../../widget/DialogUtils.dart';
import '../../TransitPage/views/transit_page_view.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  Timer? printRetryTimer;
  bool _retryingPrint = false;

  AppConfig appConfig = Get.find();
  get payCube => appConfig.payCube;

   // Timer? allowtimer;
   // Timer? stoptimer;
   // Timer? stopChecktimer;
   // Timer? closetimer;

  //60秒内未接收现金机正确通知，则进行下一步操作
   Timer? showCashTimer;
  RxInt seconds = 60.obs;
  RxBool _isCashState = true.obs;
  RxInt checkSteeps = 1.obs; //自检步骤
   RxString _machineCode = "".obs;
  // var _allowStatus;
  // var _stopStatus;
  // var _closeStatus;



  final printerController = printerPlus.PrinterJobController();

  @override
  void onInit() {
  super.onInit();
  logI('--- App Start ---');
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
    _startPrintRetryLoop();
  }

  @override
  void onClose() {
    debugPrint("home onClose");
    if (Platform.isAndroid) payCube.stopListening();
    printRetryTimer?.cancel();
    super.onClose();
  }

  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "" && machineCode != null) {
      _machineCode.value = machineCode;
    }
  }

  void _startPrintRetryLoop() {
    printRetryTimer?.cancel();
    printRetryTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _retryFailedOrders();
    });
  }

  Future<void> _retryFailedOrders() async {
    if (_retryingPrint) return;
    if (!Get.isRegistered<PrintFailedService>()) return;
    _retryingPrint = true;
    try {
      final service = Get.find<PrintFailedService>();
      await service.pruneExpired();
      final records = service.getRetryCandidates();
      for (final record in records) {
        if (record.printerIp.isEmpty) {
          // await service.markFailed(record.uuid, error: 'printerIp empty');
          continue;
        }
        final printerInfo = PrinterInfo(
          ip: record.printerIp,
          printerType: record.printerType,
          printInfo: record.printInfo,
        );
        final printData = record.printData.map((e) => e.toList()).toList();
        await printTask(printerInfo, printData);
      }
    } finally {
      _retryingPrint = false;
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
    update();
    List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      if (appConfig.isFx){
        _isCashState.value = false;
        prohibitOneCash();
      } else {
        openPayCube();
      }

    } else {
      logI("没有网络");
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
  openPayCube() async {
    checkSteeps.value = 2;
    update();
    //倒计时，一定时间不开启现金机则继续执行下一步
    _countDownTimer();
    String checkStatus = await payCube.CheckPayCubeStatus;
    logI("checkStatus:$checkStatus");

    //如果检测现金机打开错误，则重新打开一下
    if(checkStatus == "openError"){
      int _openCount = 0;
      for (var i = 0; i < 3; i++) {
        String openStatus = await payCube.openPayCube;
        logI("openStatus:$openStatus");
        _openCount++;
        logI("打开次数$_openCount");
        if (openStatus == "openSuccess") {
          seconds.value=60;
          _countDownTimer();
          startToubi();
          return;
        }
      }
      //send failure email
      showCashTimer?.cancel();
      _isCashState.value = false;
      _sendFailureEmail();
      prohibitOneCash();
      //print("机器未打开lib未null，重新打开并连接了");
    }else{
      //await Paycube.setReceiveEvent;
      startToubi();
    }

  }

  _sendFailureEmail() async {
    logI("发送通知邮件");

    if (kDebugMode) {
      return;
    }

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
  startToubi({int connectCount = 1}) async {

    //入金开始

    // Paycube.getPayCubeListener();
    // await Paycube.setReceiveEvent;
    logI("--startToubi--");
    await Future.delayed(Duration(milliseconds: 500));
    await payCube.startPayCube(onSuccess: () {
      logI("---onSuccess---");
      seconds.value=60;
      _countDownTimer();
       stopPayCube();
    }, catchError: (error) {
      showCashTimer?.cancel();
      _isCashState.value = false;
      _sendFailureEmail();
      prohibitOneCash();
      logI("startToubi catchError:$error");
    });


    // if(connectCount > 10){
    //   showCashTimer?.cancel();
    //   _isCashState.value = false;
    //   await _sendFailureEmail();
    //   await prohibitOneCash();
    //   //getIsFirstOpen();
    // }
    // //print("链接次数${}");
    // // 循环一定要记得设置取消条件，手动取消
    // if (startPayCube == "AllowSuccess") {
    //   seconds.value=60;
    //   _countDownTimer();
    //
    //   await stopPayCube();
    //
    // }else if (startPayCube == "Error-F0--16") {
    //   //await Paycube.endTrade;
    //   //await Future.delayed(Duration(milliseconds: 200));
    //   //sleep(Duration(milliseconds: 200));
    //   //startToubi(connectCount: connectCount + 1);
    // }else if (startPayCube == "Error-A0--02") {
    //   //sleep(Duration(milliseconds: 300));
    // }else{
    //   //startToubi(connectCount: connectCount + 1);
    // }

  }

  stopPayCube() async {
    logI("--stopPayCube--");
    checkSteeps.value = 3;
    update();
    //await Paycube.setReceiveEvent;
    await Future.delayed(Duration(milliseconds: 500));
    bool endStatus = await payCube.endPayCube(onSuccess: () {
      logI("endPayCube");
    }, catchError: (error) {
      logI("endPayCube catchError:$error");
    });
    logI("endStatus:$endStatus");
    if (endStatus) {
      //倒计时，一定时间不开启现金机则继续执行下一步
      seconds.value=60;
      _countDownTimer();
      closePayCube();
    }
  }

  closePayCube() async {
    checkSteeps.value = 4;
    update();
    //取引终了结束交易
    //await Paycube.setReceiveEvent;
    await Future.delayed(Duration(milliseconds: 500));
    bool endTrade = await payCube.endTrade(onSuccess: () {
      logI("endTrade");
    }, catchError: (error) {
      logI("endTrade catchError:$error");
    });
    logI("endTrade:$endTrade");
    if (endTrade) {
      showCashTimer?.cancel();
      seconds.value=60;

      //现金机打开一次后，判断是否第一次打开
      prohibitOneCash();
    }else{
      logI("endTrade失败");
      //await Paycube.endTrade;
    }
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


    //打印图层生成成功
  Future<void> onPictureGenerated(PicGenerateResult imgData) async {
    //final imageBytes = imgdata.data;
      final task = imgData.taskItem;

    //指定的打印机
      final printerInfo = task.params as PrinterInfo;
      //print('printerInfo: $printerInfo');
      //打印票据类型（标签、小票）
      final printTypeEnum = task.printTypeEnum;

      final imageBytes =
          await imgData.convertUint8List(imageByteFormat: ImageByteFormat.rawRgba);
      //也可以使用 ImageByteFormat.png
      final argbWidth = imgData.imageWidth;
      final argbHeight = imgData.imageHeight;
      if (imageBytes == null) {
        return;
      }

      final printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
        imgData: imageBytes,
        printType: printTypeEnum,
        argbWidthPx: argbWidth,
        argbHeightPx: argbHeight,
      );

      await printTask(printerInfo, printData);

    }


    Future<void> printTask(PrinterInfo printerInfo, printData) async {
      if (printerInfo.isUsbPrinter) {
        // usb 打印
        logI('usb 打印');
        final conn = printerPlus.UsbConn(printerInfo.usbDevice!);
        conn.writeMultiBytes(printData, 1024 * 8);
      } else if (printerInfo.isNetPrinter) {
        // 网络 打印
        logI('网络 打印 ${printerInfo.ip!}');
        // final conn = printerPlus.NetConn(printerInfo.ip!);
        // conn.writeMultiBytes(printData);
        //1.插入打印数据 状态pending

        String uuid = printerInfo.printInfo['uuid'] ?? '';
        logI('Try Adding new pending print record $uuid');
        if (Get.isRegistered<PrintFailedService>() && uuid.isNotEmpty) {
          await Get.find<PrintFailedService>().addPending(
            uuid: uuid,
            printerType: printerInfo.printerType,
            printerIp: printerInfo.ip ?? '',
            printData: printData,
            printInfo: printerInfo.printInfo,
          );
        }

        try {
          await printerController.enqueue(printerInfo.ip!, printData);
          //2.打印成功 更新状态 success
          if (Get.isRegistered<PrintFailedService>() && uuid.isNotEmpty) {
            await Get.find<PrintFailedService>().markSuccess(uuid);
          }
        } catch (e) {
          // handle/report failure for diagnostics
          //3.打印失败 更新状态 failed
          logE('打印失败: ${e.toString()} printerInfo.ip = ${printerInfo.ip!}, printerInfo = ${printerInfo.printInfo}');
          //存储 打印失败记录
          if (Get.isRegistered<PrintFailedService>()) {
              await Get.find<PrintFailedService>().markFailed(uuid, error: e.toString());
          }
        }
      }
    }

}
