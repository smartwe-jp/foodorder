import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/localString.dart';
import 'package:foodorder/app/config/string.dart';
//import 'package:foodorder/app/controllers/machine_info_controller.dart';
import 'package:foodorder/app/plugins/appset/lib/appset.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:foodorder/app/config/http_conf.dart';
import 'package:foodorder/app/modules/TransitPage/controllers/sse_service.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../controllers/app_config.dart';
import '../../../controllers/machine_info.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/logUtil.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/Storage.dart';
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

    if (_machineCode.isNotEmpty) {
      firstActive();
    } else {
      _getMachineInfo();
    }
  }

  firstActive() async {
    debugPrint('---firstActive---');
    if (Platform.isWindows) {
     _getMachineActivate(isFirst: true);
    } else {
     _getPackageInfo();
    }
  }

  _getMachineInfo() async {
    debugPrint("transit  getMachineInfo");
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      _machineCode.value = machineCode;

      //_getSystemSettingInfo();

      if (Platform.isWindows) {
         _getMachineActivate();
      } else {
         _getPackageInfo();
      }
    } else {
      LogUtil.d("transit getMachineInfo error: machineCode is empty");
    }
  }

  //获取版本号
  _getPackageInfo() async {
    debugPrint("transit  getPackageInfo");
    //PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value =
        "2.6.0"; //packageInfo.version; //+"+"+packageInfo.buildNumber

    _getMachineActivate();
  }


  _getMachineActivate({isFirst = false, int retryCount = 0}) async {
    try {

      bool shouldActive = await _checkShouldActive();
      if (_loadActiveInfo.value == false && !shouldActive) {
        logger.info('-- getMachineActivate with loadActive no need --');
        _actuarial.value = true;
        _getSmartweSystemSettingInfo();
        return;
      }
      logger.info('-- getMachineActivate with loadActive --');
      var formData = {
        "machineCode": _machineCode.value,
        "version": local_version.value
      };
      request('webBootActivatev3', method: 'POST', parameters: formData)
          .then((val) async {
        var response = json.decode(val.toString());
        LogUtil.d("getMachineActivate response: $response");
        if (response != null &&
            response['code'] == 200 &&
            response['data'] != null) {
          var shopData = response['data'];
          var _shopCode = "";
          if (shopData["shopCode"] != null) {
            _shopCode = shopData["shopCode"];
          }
          var _showCash = shopData["linePayChannelMap"]["Cash"] != null
              ? shopData["linePayChannelMap"]["Cash"]
              : false;
          debugPrint("showCash: $_showCash");
          var _showWechat = shopData["linePayChannelMap"]["Wechat"] != null
              ? shopData["linePayChannelMap"]["Wechat"]
              : false;
          var _showAlipay = shopData["linePayChannelMap"]["Alipay"] != null
              ? shopData["linePayChannelMap"]["Alipay"]
              : false;
          var _showPayPay = shopData["linePayChannelMap"]["PayPay"] != null
              ? shopData["linePayChannelMap"]["PayPay"]
              : false;
          var _showCreditCard = shopData["linePayChannelMap"]["POS"] != null
              ? shopData["linePayChannelMap"]["POS"]
              : false;
          var _auPay = shopData["linePayChannelMap"]["au_Pay"] != null
              ? shopData["linePayChannelMap"]["au_Pay"]
              : false;
          var _dPay = shopData["linePayChannelMap"]["d_Pay"] != null
              ? shopData["linePayChannelMap"]["d_Pay"]
              : false;
          var _rPay = shopData["linePayChannelMap"]["R_Pay"] != null
              ? shopData["linePayChannelMap"]["R_Pay"]
              : false;
          var _mPay = shopData["linePayChannelMap"]["m_Pay"] != null
              ? shopData["linePayChannelMap"]["m_Pay"]
              : false;

          var _posEdy = shopData["linePayChannelMap"]["Edy"] != null
              ? shopData["linePayChannelMap"]["Edy"]
              : false;
          var _posiD = shopData["linePayChannelMap"]["iD"] != null
              ? shopData["linePayChannelMap"]["iD"]
              : false;
          var _posIC = shopData["linePayChannelMap"]["IC"] != null
              ? shopData["linePayChannelMap"]["IC"]
              : false;
          var _posQUICPay = shopData["linePayChannelMap"]["QUICPay"] != null
              ? shopData["linePayChannelMap"]["QUICPay"]
              : false;
          var _posWAON = shopData["linePayChannelMap"]["WAON"] != null
              ? shopData["linePayChannelMap"]["WAON"]
              : false;
          var _posnanaco = shopData["linePayChannelMap"]["nanaco"] != null
              ? shopData["linePayChannelMap"]["nanaco"]
              : false;
          var _visa = shopData["linePayChannelMap"]["VISA"] != null
              ? shopData["linePayChannelMap"]["VISA"]
              : false;
          var _master = shopData["linePayChannelMap"]["MASTER"] != null
              ? shopData["linePayChannelMap"]["MASTER"]
              : false;
          var _jcb = shopData["linePayChannelMap"]["JCB"] != null
              ? shopData["linePayChannelMap"]["JCB"]
              : false;
          var _unionPay = shopData["linePayChannelMap"]["UnionPay"] != null
              ? shopData["linePayChannelMap"]["UnionPay"]
              : false;
          var _americanExpress =
              shopData["linePayChannelMap"]["AMERICAN_EXPRESS"] != null
                  ? shopData["linePayChannelMap"]["AMERICAN_EXPRESS"]
                  : false;
          var _dinersClub = shopData["linePayChannelMap"]["Diners_Club"] != null
              ? shopData["linePayChannelMap"]["Diners_Club"]
              : false;
          var _discover = shopData["linePayChannelMap"]["Discover"] != null
              ? shopData["linePayChannelMap"]["Discover"]
              : false;
          bool taxSystem = shopData["taxSystem"] ?? false;
          logger.info('-- server cash state = $_showCash --');
          var machineActivateData = {
            "showCash": _showCash,
            "showWechat": _showWechat,
            "showAlipay": _showAlipay,
            "showPayPay": _showPayPay,
            "showCreditCard": _showCreditCard,
            "au_Pay": _auPay,
            "d_Pay": _dPay,
            "R_Pay": _rPay,
            "m_Pay": _mPay,
            "pos_Edy": _posEdy,
            "pos_iD": _posiD,
            "pos_IC": _posIC,
            "pos_QUICPay": _posQUICPay,
            "pos_WAON": _posWAON,
            "pos_nanaco": _posnanaco,
            "show_visa": _visa,
            "show_master": _master,
            "show_jcb": _jcb,
            "show_unionPay": _unionPay,
            "show_americanExpress": _americanExpress,
            "show_dinersClub": _dinersClub,
            "show_discover": _discover,
            "taxSystem": taxSystem,
          };
          //是否允许退款 1展示退款按钮 0 不展示
          var reimburse = (shopData["reimburse"] == true) ? "1" : "0";
          Storage.setString(
              'smartwe_machineActivateData', json.encode(machineActivateData));
          Storage.setString(
              'smartwe_machineLanguages', json.encode(shopData["languages"]));
          Storage.setString('smartwe_homeImages', json.encode(shopData["homeImages"]));
          Storage.setString('smartwe_headerImages', json.encode(shopData["headerImages"]));
          Storage.setString('smartwe_logoImage', shopData["logoImage"]);
          Storage.setString('smartwe_reimburse', reimburse);
          Storage.setString('smartwe_shopCode', _shopCode);

          GetxStorage.setData('smartwe_machineActivateData', json.encode(machineActivateData));
          GetxStorage.setData('smartwe_machineLanguages', json.encode(shopData["languages"]));
          GetxStorage.setData('smartwe_homeImages', json.encode(shopData["homeImages"]));
          GetxStorage.setData('smartwe_headerImages', json.encode(shopData["headerImages"]));
          GetxStorage.setData('smartwe_logoImage', shopData["logoImage"]);
          GetxStorage.setData('smartwe_reimburse', reimburse);

          var machineSettingBool = {
            'machineLineup': shopData["lineup"],
            'machineActuarial': shopData["actuarial"],
          };

          Storage.setString(
              'machineSettingData', json.encode(machineSettingBool));
          GetxStorage.setData(
              'machineSettingData', json.encode(machineSettingBool));

          _actuarial.value = shopData["actuarial"];

          if (Platform.isAndroid) {
            // FirebaseAnalytics.instance.logEvent(
            //     name: 'machine_activate_launch',
            //     parameters: {'machine_activate': '${_machineCode.value}'});
          }
          if (isFirst) {
             _saveActiveCode(_machineCode.value);
          } else {
            //FirebaseAnalytics.instance.logEvent(name: 'machine_activate_launch', parameters: {'machine_activate': '${_machineCode.value}'});
            //await downloadAndSaveImage(shopData["logoImage"]);
             _getSmartweSystemSettingInfo();
          }

        } else {
          if (Platform.isAndroid) {
            // FirebaseAnalytics.instance.logEvent(
            //     name: 'machine_activate_failure',
            //     parameters: {'machine_activate_error': '${_machineCode.value}'});
          }
          _showErrorDialog(isActive: response['data'] == null);
        }
      }).catchError((e) {
        LogUtil.d("getMachineActivate error: $e");
        logger.warning('getMachineActivate error: $e');
        if (Platform.isAndroid) {
          // FirebaseAnalytics.instance.logEvent(
          //     name: 'machine_activate_error',
          //     parameters: {'machine_activate_error': '${_machineCode.value}'});
        }
        if (retryCount < 3) {
          // 如果失败，重试
          Future.delayed(Duration(seconds: 2), () {
            _getMachineActivate(retryCount: retryCount + 1);
          });
        } else {
          // 如果重试次数超过3次，显示错误对话框
          _showErrorDialog(error: e);
        }
      })
      .timeout(Duration(seconds: 10), onTimeout: () {
        //FirebaseAnalytics.instance.logEvent(name: 'machine_activate_timeout', parameters: {'machine_activate_timeout': '${_machineCode.value}'});
        //print('timeout');
        LogUtil.d("getMachineActivate timeout");
        logger.warning('getMachineActivate timeout');
        if (retryCount < 3) {
          // 如果超时，重试
          Future.delayed(Duration(seconds: 2), () {
            _getMachineActivate(retryCount: retryCount + 1);
          });
        } else {
          // 如果重试次数超过3次，显示错误对话框
          _showErrorDialog();
        }
      });
    } finally {
      logger.info('activation finished');
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
        Storage.setString('activeTimeInfo', now.toString());
        return true;
      } else {
        return false;
      }
    } else {
      //存储当前时间
      Storage.setString('activeTimeInfo', now.toString());
      return true;
    }
  }

  _saveActiveCode(String code) async {
    //保存机器信息
    Storage.setString('machineInfo', code);
    Storage.setBool('homeOpen', true);

    GetxStorage.setData('machineInfo', code);
    GetxStorage.setData('homeOpen', true);

    await _getSmartweSystemSettingInfo();
  }

  _getSmartweSystemSettingInfo() async {
    debugPrint("transit  getSmartweSystemSettingInfo");
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    var checkmachineMode = "1";
    if (SystemSettingInfo["machineMode"] != "" &&
        SystemSettingInfo["machineMode"] != null &&
        SystemSettingInfo["machineMode"] != "1") {
      if (_actuarial.value == true) {
        checkmachineMode =
            (SystemSettingInfo["machineMode"] == "3") ? "3" : "2";
      } else {
        checkmachineMode = "1";
      }
    }
    var systemSettingData = {
      "diningType": (SystemSettingInfo["diningType"] != "" &&
              SystemSettingInfo["diningType"] != null)
          ? SystemSettingInfo["diningType"]
          : "1", //1堂食 2外带
      "menuDirection": (SystemSettingInfo["menuDirection"] != "" &&
              SystemSettingInfo["menuDirection"] != null)
          ? SystemSettingInfo["menuDirection"]
          : "1", //1顶部横向 2左侧竖
      //"printPaperSize":(SystemSettingInfo["printPaperSize"] !="" && SystemSettingInfo["printPaperSize"]!=null) ? SystemSettingInfo["printPaperSize"] :"1",//1 58mm 2 80mm
      "printPaperTxtSize":(SystemSettingInfo["printPaperTxtSize"] !="" && SystemSettingInfo["printPaperTxtSize"]!=null) ? SystemSettingInfo["printPaperTxtSize"] :"1",//1 普通　2大　3特大
      "isAllowReceipt":(SystemSettingInfo["isAllowReceipt"] !="" && SystemSettingInfo["isAllowReceipt"]!=null) ? SystemSettingInfo["isAllowReceipt"] :"1",//1必须打印小票 2不必须
      "isAllowReceiptMenu":(SystemSettingInfo["isAllowReceiptMenu"] !="" && SystemSettingInfo["isAllowReceiptMenu"]!=null) ? SystemSettingInfo["isAllowReceiptMenu"] :"1",//1必须打印小票顶部菜单 2不打印
      "machineMode":checkmachineMode,
      "isReservation":(SystemSettingInfo["isReservation"] !="" && SystemSettingInfo["isReservation"]!=null) ? SystemSettingInfo["isReservation"] :"0",//是否开启预约 0不开启 1开启
      "isAllowAttendance":(SystemSettingInfo["isAllowAttendance"] !="" && SystemSettingInfo["isAllowAttendance"]!=null) ? SystemSettingInfo["isAllowAttendance"] :"0",//0 不开考勤 1开考勤
      "isAllowOneYen":(SystemSettingInfo["isAllowOneYen"] !="" && SystemSettingInfo["isAllowOneYen"]!=null) ? SystemSettingInfo["isAllowOneYen"] :"0",//0禁用1元 1不禁用
      "isAllow5000": SystemSettingInfo["isAllow5000"] ?? "1",
      "isAllow10000": SystemSettingInfo["isAllow10000"] ?? "1",
      "isAllowBackHome":(SystemSettingInfo["isAllowBackHome"] !="" && SystemSettingInfo["isAllowBackHome"]!=null) ? SystemSettingInfo["isAllowBackHome"] :"0",//0回到首页，1回到菜单页
      "isAllowPos":(SystemSettingInfo["isAllowPos"] !="" && SystemSettingInfo["isAllowPos"]!=null) ? SystemSettingInfo["isAllowPos"] :"0",//0 不开pos 1开pos
      "isAllowWlanPrint":(SystemSettingInfo["isAllowWlanPrint"] !="" && SystemSettingInfo["isAllowWlanPrint"]!=null) ? SystemSettingInfo["isAllowWlanPrint"] :"0",//0 不开打印机 1开打印机
      "isAllowWlanPrintContinuous":(SystemSettingInfo["isAllowWlanPrintContinuous"] !="" && SystemSettingInfo["isAllowWlanPrintContinuous"]!=null) ? SystemSettingInfo["isAllowWlanPrintContinuous"] :"1",//0 单票 1连票
      "showPrintType":(SystemSettingInfo["showPrintType"] !="" && SystemSettingInfo["showPrintType"]!=null) ? SystemSettingInfo["showPrintType"] :"0",//0 receipt 1label
      "isAllowWlanPrintTwo":(SystemSettingInfo["isAllowWlanPrintTwo"] !="" && SystemSettingInfo["isAllowWlanPrintTwo"]!=null) ? SystemSettingInfo["isAllowWlanPrintTwo"] :"0",//0 不开打印机 1开打印机
      "isAllowWlanPrintTwoContinuous":(SystemSettingInfo["isAllowWlanPrintTwoContinuous"] !="" && SystemSettingInfo["isAllowWlanPrintTwoContinuous"]!=null) ? SystemSettingInfo["isAllowWlanPrintTwoContinuous"] :"1",//0 单票 1连票
      "isAllowRejishime":(SystemSettingInfo["isAllowRejishime"] !="" && SystemSettingInfo["isAllowRejishime"]!=null) ? SystemSettingInfo["isAllowRejishime"] :"0",
      "panelType": SystemSettingInfo['panelType'] ?? 'Mini',
      "isAllowWlanPanelPrint": SystemSettingInfo["isAllowWlanPanelPrint"] ?? '0'
    };
    Storage.setString('smartwe_systemSetting',
        json.encode(systemSettingData)); //1 默认58mm  2 宽纸80mm
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));
    //}


    var smartweMachineSettingPassword = await HomeServices.getMachineSettingManagePasswordInfo();
    if(smartweMachineSettingPassword != null && smartweMachineSettingPassword!= ""){
      Storage.setString('machineSettingManagePassword', smartweMachineSettingPassword);
      GetxStorage.setData('machineSettingManagePassword', smartweMachineSettingPassword);

    }

    

    //这里判断是否禁用1元

    //_goNext(checkmachineMode);

    //_goNext(checkmachineMode);
     _injectControllers(checkmachineMode, systemSettingData);
  }

  Future _injectControllers(checkmachineMode, systemSettingData) async {
    // if (Get.isRegistered<PosPayController>()) Get.delete<PosPayController>();
    // Get.put(PosPayController());

    //  if (Get.isRegistered<MachineInfoController>()){
    //   Get.delete<MachineInfoController>();
    //  } 

    // Get.put(MachineInfoController(systemSettingData));

    if (!Get.isRegistered<MachineInfoController>()) {
      final controller = MachineInfoController(systemSettingData);
      await Get.putAsync<MachineInfoController>(() async {
        await controller.loadMachineSettingInfo(); // 确保初始化完成
        return controller;
      }, permanent: true);
      debugPrint('put MachineInfoController done');
    } else {
      await Get.find<MachineInfoController>().updateMachineSettingInfo(systemSettingData);
      debugPrint('update MachineInfoController done');
    }
    // await Get.delete<MachineInfoController>();
    // Get.put(MachineInfoController(systemSettingData));
  

    MachineInfoController machineInfo = Get.find<MachineInfoController>();
    Get.lazyPut(() => PrintService(machineInfo));

     final sseService = Get.find<SseService>();
  
    final sseSettingList = machineInfo.sseSettingList;

    for (final sseSetting in sseSettingList) {
      if (sseSetting['isOn'] == true) {
        final url = servicePath[sseSetting['server']];// + sseSetting['identify'];
        if (url != null && url.isNotEmpty) {
          //final address = url + sseSetting['identify'];
          final needInput = sseSetting['needInput'] ?? false;
          final address = url + (needInput ? sseSetting['identify']:machineInfo.machineCode);
          sseService.addSseListen(address);
        }
      }
    }

    if (systemSettingData["isAllowOneYen"] == "0") {
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
     
     goNext(checkmachineMode);
  }

  void startOrder() {
    goNext('1');
  }

  Future goNext(checkmachineMode) async {
    Get.updateLocale(Locale('jp', 'JP'));
    _goCheckOut();
    // if(checkmachineMode == "2"){
    //  _goCheckOut();
    // }else if(checkmachineMode == "3"){
    //   _goSelfService();
    // }else{
    //   _goMain();
    // }
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
