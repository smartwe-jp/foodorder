import 'dart:async';
import 'dart:convert';
import 'dart:io';

//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
//import 'package:foodorder/app/controllers/machine_info_controller.dart';
import 'package:foodorder/app/plugins/appset/lib/appset.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:foodorder/app/config/http_conf.dart';
import 'package:foodorder/app/services/sse_service.dart';
import 'package:foodorder/app/services/sse_subscription_manager.dart';
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

    if (machineCode.isEmpty) {
      _machineCode.value = await HomeServices.getMachineInfo();
    }
    _getPackageInfo();

  }

  //获取版本号
  _getPackageInfo() async {
    debugPrint("transit  getPackageInfo");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version; //+"+"+packageInfo.buildNumber

    _getMachineActivate(isFirst: _loadActiveInfo.value);
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
      
      final formData = {
        "machineCode": _machineCode.value,
        "version": local_version.value
      };
      logI('-- getMachineActivate with loadActive -- machineCode: ${_machineCode.value}, version: ${local_version.value} --');
      final val = await request(
          'webBootActivatev3',
          method: 'POST',
          parameters: formData,
          timeout: Duration(seconds: 10)
      );
      final response = json.decode(val.toString());

      logI("getMachineActivate response: $response");
      
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
            "cashMachineWithdraw": shopData["cashMachineWithdraw"] ?? false,
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
          GetxStorage.setData('smartwe_shopCode', _shopCode);

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
          return;
        } 
        _showErrorDialog(isActive: response['data'] == null);
      
      } catch(e) {
        logW('getMachineActivate error: $e');
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
    logI("getSmartweSystemSettingInfo");
    try {
      Map systemSettingInfo = await HomeServices.getSystemSettingInfo();

    final smartweMachineSettingPassword = await HomeServices.getMachineSettingManagePasswordInfo();

    if(smartweMachineSettingPassword != null && smartweMachineSettingPassword!= ""){
      Storage.setString('machineSettingManagePassword', smartweMachineSettingPassword);
      GetxStorage.setData('machineSettingManagePassword', smartweMachineSettingPassword);

    }
     await _injectControllers(systemSettingInfo);
    } catch (e) {
      logW("getSmartweSystemSettingInfo error: $e");
      
    }
  }

  Future _injectControllers(systemSettingData) async {

    if (!Get.isRegistered<MachineInfoController>()) {
      final controller = MachineInfoController(systemSettingData);
      await Get.putAsync<MachineInfoController>(() async {
        await controller.loadMachineSettingInfo(); // 确保初始化完成
        return controller;
      }, permanent: true);
      debugPrint('put MachineInfoController done');
    } else {
      await Get.find<MachineInfoController>().updateMachineSettingInfo(settingInfo: systemSettingData);
      debugPrint('update MachineInfoController done');
    }

    MachineInfoController machineInfo = Get.find<MachineInfoController>();
    Get.lazyPut(() => PrintService(machineInfo));
  

    await Get.find<SseSubscriptionManager>().startEnabledSubscriptions();

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
