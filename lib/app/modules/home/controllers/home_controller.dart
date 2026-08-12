import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:get/get.dart';
import 'package:appset/appset.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/services/print_failed_service.dart';
import 'package:foodorder/app/services/machine_runtime_service.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import '../../../services/HomeServices.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  // Timer? allowtimer;
  // Timer? stoptimer;
  // Timer? stopChecktimer;
  // Timer? closetimer;
  Timer? printRetryTimer;
  bool _retryingPrint = false;
  final MachineRuntimeService _machineRuntime = Get.find();

  final printerController = printerPlus.PrinterJobController();

  @override
  void onInit() {
    debugPrint("home onInit");
    super.onInit();
    logI('--- App Start ---');
    requestPermission();

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
    debugPrint("home onReady");
    super.onReady();
    _startPrintRetryLoop();
  }

  @override
  void onClose() {
    //Paycube.stopListening();
    debugPrint("home onClose");
    printRetryTimer?.cancel();
    super.onClose();
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
    debugPrint("requestPermission 0");
    //霸屏隐藏状态栏导航栏

    await Appset.hideBullyScreen; //隐藏状态栏

    await _machineRuntime.hydrate();

    /// 权限检测
    PermissionStatus storageStatus = await Permission.storage.status;
    debugPrint("storageStatus:$storageStatus");
    if (storageStatus != PermissionStatus.granted) {
      storageStatus = await Permission.storage.request();
      if (storageStatus != PermissionStatus.granted) {
        //showToast("权限申请被拒绝");
        //print("权限申请被拒绝");
      } else {
        debugPrint("requestPermission 1");
      }
    } else {
      debugPrint("requestPermission 2");
    }
    getIsFirstOpen();
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
    debugPrint("goMain 1");
    Future.delayed(Duration(milliseconds: 200), () {
      //Get.off(() => TransitPageView());
      Get.toNamed("/transit-page", arguments: {"loadActive": false});
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

    final imageBytes = await imgData.convertUint8List(
        imageByteFormat: ImageByteFormat.rawRgba);
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
        logE(
            '打印失败: ${e.toString()} printerInfo.ip = ${printerInfo.ip!}, printerInfo = ${printerInfo.printInfo}');
        //存储 打印失败记录
        if (Get.isRegistered<PrintFailedService>()) {
          await Get.find<PrintFailedService>()
              .markFailed(uuid, error: e.toString());
        }
      }
    }
  }
}
