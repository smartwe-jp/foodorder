import 'dart:async';
import 'dart:io';

//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
//import 'package:foodorder/app/controllers/machine_info_controller.dart';
import 'package:foodorder/app/plugins/appset/lib/appset.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:foodorder/app/services/sse_subscription_manager.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../controllers/app_config.dart';
import '../../../controllers/machine_info.dart';
import '../../../services/HomeServices.dart';
import '../../../services/Storage.dart';
import '../../../services/machine_runtime_service.dart';
import '../../../widget/DialogUtils.dart';

class TransitPageController extends GetxController {
  //TODO: Implement TransitPageController
  RxString _machineCode = "".obs;
  //var _machineMode = "1"; //1 券卖机  2 精算机 3 自助收银
  //RxBool _isCashState = true.obs;
  RxBool _actuarial = false.obs;
  RxString local_version = "".obs; //本appversion
  RxBool _loadActiveInfo = false.obs;
  AppConfig appConfig = Get.find();
  get payCube => appConfig.payCube;
  final MachineRuntimeService _machineRuntime = Get.find();

  String languageCode = "JP";
  final logger = Logger('TransitPageController');

  final RxBool showStartButton = false.obs;
  String? heroImageUrl;
  bool hasStart = false;

  @override
  void onInit() {
    //languageCode = Get.locale?.languageCode.toUpperCase() ?? "JP";
    getIsShowCashInfo();
    super.onInit();
    logger.info('--- TransitPageController onInit ---');
  }

  @override
  void onReady() {
    debugPrint("transit onReady");
    super.onReady();
    logger.info('--- TransitPageController onReady ---');
  }

  @override
  void onClose() {
    debugPrint("transit onClose");
    hasStart = false;
    super.onClose();
    logger.info('--- TransitPageController onClose ---');
  }

  getIsShowCashInfo() async {
    if (hasStart) {
      logger.info('-- hasStart true, no need to run again --');
      return;
    }

    hasStart = true;
    logger.info("transit getIsShowCashInfo");
    //Map systemSettingInfo = await HomeServices.getIsShowCash();
    if (Get.arguments != null && Get.arguments.containsKey('loadActive')) {
      _loadActiveInfo.value = Get.arguments['loadActive'] ?? false;
      _machineCode.value = Get.arguments['machineCode'] ?? "";
    }

    // if (_machineCode.isNotEmpty) {
    //   firstActive();
    // } else {
      _getMachineInfo(machineCode: _machineCode.value);
    //}
  }

  // firstActive() async {
  //   debugPrint('---firstActive---');
  //   if (Platform.isWindows) {
  //    _getMachineActivate(isFirst: true);
  //   } else {
  //    _getPackageInfo();
  //   }
  // }

  _getMachineInfo({String machineCode = ""}) async {
    debugPrint("transit  getMachineInfo");

    await _machineRuntime.hydrate(machineCode: machineCode);
    _machineCode.value = _machineRuntime.machineCode;
    _getPackageInfo();

  }

  //获取版本号
  _getPackageInfo() async {
    debugPrint("transit  getPackageInfo");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version; //+"+"+packageInfo.buildNumber

    _getMachineActivate(isFirst: _loadActiveInfo.value);
  }


  Future<void> _getMachineActivate({
    bool isFirst = false,
    int retryCount = 0,
  }) async {
    try {
      final shouldActive = await _checkShouldActive();
      if (_loadActiveInfo.value == false && !shouldActive) {
        logger.info('-- getMachineActivate with loadActive no need --');
        final cachedActivation = _machineRuntime.activation;
        _actuarial.value = cachedActivation?.actuarial ?? true;
        await _getSmartweSystemSettingInfo();
        return;
      }

      logI(
          '-- getMachineActivate with loadActive -- machineCode: ${_machineCode.value}, version: ${local_version.value} --');
      final activation = await _machineRuntime.activate(
        machineCode: _machineCode.value,
        version: local_version.value,
      );
      if (activation == null) {
        _showErrorDialog(isActive: true);
        return;
      }

      logger
          .info('-- server cash state = ${activation.paymentChannels.cash} --');
      _actuarial.value = activation.actuarial;

      if (isFirst) {
        await _saveActiveCode(_machineCode.value);
      } else {
        await _getSmartweSystemSettingInfo();
      }
    } catch (e) {
      logW('getMachineActivate error: $e');
      if (Platform.isAndroid) {
        // FirebaseAnalytics.instance.logEvent(
        //     name: 'machine_activate_error',
        //     parameters: {'machine_activate_error': '${_machineCode.value}'});
      }
      if (retryCount < 3) {
        // 如果失败，重试
        Future.delayed(const Duration(seconds: 2), () {
          _getMachineActivate(isFirst: isFirst, retryCount: retryCount + 1);
        });
      } else {
        // 如果重试次数超过3次，显示错误对话框
        _showErrorDialog(error: e);
      }
    } finally {
      logI('activation finished');
      //_activating = false;
    }
  }

  _showErrorDialog({error, bool isActive = false}) => Get.dialog(DialogUtils.alertOneButton(
      isActive
          ? 'activation_error_tips'.tr
          : 'インターネットが接続していません。ネット環境及び機器の接続状況をご確認の上、券売君アプリを再起動してください。',

      title: "tag_title".tr,
      confirmtitle: "reboot_app".tr,
      confirm: () {
        Future.delayed(Duration(milliseconds: 200), () async {
          if (isActive)
          Storage.clearAll();
          Get.back();
          //_getMachineActivate();
          Appset.restartApp;
          //exit(0);
        });
      })
  );

  Future<bool> _checkShouldActive() async {
    var now = DateTime.now();
    var lastActiveTime = await HomeServices.getActiveTimeInfo();
    if (lastActiveTime != null && lastActiveTime != "") {
      var last = DateTime.parse(lastActiveTime);
      var diff = now.difference(last).inDays;
      if (diff > 1) {//超过一天 重新激活
        await Storage.setString('activeTimeInfo', now.toString());
        return true;
      } else {
        return false;
      }
    } else {
      //存储当前时间
      await Storage.setString('activeTimeInfo', now.toString());
      return true;
    }
  }

  Future<void> _saveActiveCode(String code) async {
    //保存机器信息
    await Future.wait([
      _machineRuntime.updateMachineCode(code),
      Storage.setBool('homeOpen', true),
    ]);

    await _getSmartweSystemSettingInfo();
  }

  Future<void> _getSmartweSystemSettingInfo() async {
    logI("getSmartweSystemSettingInfo");
    try {
      await _injectControllers();
    } catch (e) {
      logW("getSmartweSystemSettingInfo error: $e");
      
    }
  }

  Future<void> _injectControllers() async {

    if (!Get.isRegistered<MachineInfoController>()) {
      final controller = MachineInfoController();
      await Get.putAsync<MachineInfoController>(() async {
        await controller.loadMachineSettingInfo(); // 确保初始化完成
        return controller;
      }, permanent: true);
      debugPrint('put MachineInfoController done');
    } else {
      await Get.find<MachineInfoController>().updateMachineSettingInfo();
      debugPrint('update MachineInfoController done');
    }

    MachineInfoController machineInfo = Get.find<MachineInfoController>();
    Get.lazyPut(() => PrintService(machineInfo));
  

    await Get.find<SseSubscriptionManager>().startEnabledSubscriptions();

    if (machineInfo.is_allow_oneyen == "0") {
      try {
        if (Platform.isAndroid) {
         payCube.prohibitOneCash.timeout(
              Duration(seconds: 10));
        }
      } on TimeoutException catch (e) {
        print('Timeout: $e');
      } catch (e) {
        print('error: $e');
      }
    }

    final list = machineInfo.homeList;
    if (list.isNotEmpty) {
      heroImageUrl = list.first;
    } else {
      heroImageUrl = null;
    }
    showStartButton.value = true;
     

     goNext();
  }

  void startOrder() {
    goNext();
  }

  Future goNext() async {
    Get.updateLocale(Locale('jp', 'JP'));
    _goCheckOut();
  }

  void _goMain() async {
    debugPrint("transit  goMain");
    Future.delayed(Duration(milliseconds: 200), () {
      Get.toNamed("/order-home", arguments: {'initLaunch': _loadActiveInfo.value});
    });
  }

  Future _goCheckOut() async {
    //Future.delayed(Duration(milliseconds: 200), () {
    hasStart = false;
      Get.toNamed("/checkout-page", arguments: {'initLaunch': _loadActiveInfo.value});
    //});
  }

  Future _goSelfService() async {
    Future.delayed(Duration(milliseconds: 200), () {
      Get.toNamed("/selfservice-page", arguments: {'initLaunch': _loadActiveInfo.value});
    });
  }
}
