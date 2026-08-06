import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/services/sse_subscription_manager.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:foodorder/app/plugins/appset/lib/appset.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


import '../../../controllers/app_config.dart';
import '../../../controllers/machine_info.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/PosCheckService.dart';
import '../../../services/logUtil.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/Storage.dart';
import '../../../widget/DialogUtils.dart';

class TransitPageController extends GetxController {
  //TODO: Implement TransitPageController
  RxString _machineCode = "".obs;
  //var _machineMode = "1";//1 券卖机  2 精算机 3 自助收银
  //RxBool _isCashState = true.obs;
  RxBool _actuarial = false.obs;
  RxString local_version = "".obs; //本appversion
  RxBool _loadActiveInfo = false.obs;
  AppConfig appConfig = Get.find();
  get payCube => appConfig.payCube;

  final RxBool showStartButton = false.obs;
  String? heroImageUrl;
  bool hasStart = false;

  @override
  Future<void> onInit() async {
    await getIsShowCashInfo();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  getIsShowCashInfo() async {
    if (hasStart) {
      logI('-- hasStart true, no need to run again --');
      return;
    }

    debugPrint("getIsShowCashInfo");

    if (Get.arguments != null && Get.arguments.containsKey('loadActive')) {
      _loadActiveInfo.value = Get.arguments['loadActive'];
    }

    await _getMachineInfo();
  }

  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      _machineCode.value = machineCode;

      //_getSystemSettingInfo();
      await _getPackageInfo();
    }
  }

  //获取版本号
  _getPackageInfo() async {
    debugPrint("getPackageInfo");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version;//+"+"+packageInfo.buildNumber

    await _getMachineActivate();
  }

  _getMachineActivate({int retryCount = 0}) async{
    // var shouldActive = await _checkShouldActive();
    // if (!shouldActive) {
    //   await _getSmartweSystemSettingInfo();
    //   return;
    // }
    bool shouldActive = await _checkShouldActive();
    if(_loadActiveInfo.value == false && !shouldActive){
      _actuarial.value = true;
      await _getSmartweSystemSettingInfo();
      return;
    }

    final formData = {
      "machineCode": _machineCode.value,
      "version":local_version.value
    };
    logI("getMachineActivate formData: $formData");
    try {
      final val = await request(
          'webBootActivatev3',
          method: 'POST',
          parameters: formData,
          timeout: Duration(seconds: 10)
      );
      final response = json.decode(val.toString());

      logI("getMachineActivate response: $response");

      if (response != null && response['code'] == 200 && response['data'] != null) {
          logI(response);
          var shopData = response['data'];
          var _shopCode = "";
          if (shopData["shopCode"] != null) {
            _shopCode = shopData["shopCode"];
          }
          var _showCash = shopData["linePayChannelMap"]["Cash"] != null ? shopData["linePayChannelMap"]["Cash"] :false;
          var _showWechat = shopData["linePayChannelMap"]["Wechat"] != null ? shopData["linePayChannelMap"]["Wechat"] :false;
          var _showAlipay = shopData["linePayChannelMap"]["Alipay"] != null ? shopData["linePayChannelMap"]["Alipay"] :false;
          var _showPayPay = shopData["linePayChannelMap"]["PayPay"] != null ? shopData["linePayChannelMap"]["PayPay"] :false;
          var _showCreditCard = shopData["linePayChannelMap"]["POS"] != null ? shopData["linePayChannelMap"]["POS"] :false;
          var _auPay = shopData["linePayChannelMap"]["au_Pay"] != null ? shopData["linePayChannelMap"]["au_Pay"] :false;
          var _dPay = shopData["linePayChannelMap"]["d_Pay"] != null ? shopData["linePayChannelMap"]["d_Pay"] :false;
          var _rPay = shopData["linePayChannelMap"]["R_Pay"] != null ? shopData["linePayChannelMap"]["R_Pay"] :false;
          var _mPay = shopData["linePayChannelMap"]["m_Pay"] != null ? shopData["linePayChannelMap"]["m_Pay"] :false;

          var _posEdy = shopData["linePayChannelMap"]["Edy"] != null ? shopData["linePayChannelMap"]["Edy"] :false;
          var _posiD = shopData["linePayChannelMap"]["iD"] != null ? shopData["linePayChannelMap"]["iD"] :false;
          var _posIC = shopData["linePayChannelMap"]["IC"] != null ? shopData["linePayChannelMap"]["IC"] :false;
          var _posQUICPay = shopData["linePayChannelMap"]["QUICPay"] != null ? shopData["linePayChannelMap"]["QUICPay"] :false;
          var _posWAON = shopData["linePayChannelMap"]["WAON"] != null ? shopData["linePayChannelMap"]["WAON"] :false;
          var _posnanaco = shopData["linePayChannelMap"]["nanaco"] != null ? shopData["linePayChannelMap"]["nanaco"] :false;

          var _visa = shopData["linePayChannelMap"]["VISA"] != null ? shopData["linePayChannelMap"]["VISA"] :false;
          var _master = shopData["linePayChannelMap"]["MASTER"] != null ? shopData["linePayChannelMap"]["MASTER"] :false;
          var _jcb = shopData["linePayChannelMap"]["JCB"] != null ? shopData["linePayChannelMap"]["JCB"] :false;
          var _unionPay = shopData["linePayChannelMap"]["UnionPay"] != null ? shopData["linePayChannelMap"]["UnionPay"] :false;
          var _americanExpress = shopData["linePayChannelMap"]["AMERICAN_EXPRESS"] != null ? shopData["linePayChannelMap"]["AMERICAN_EXPRESS"] :false;
          var _dinersClub = shopData["linePayChannelMap"]["Diners_Club"] != null ? shopData["linePayChannelMap"]["Diners_Club"] :false;
          var _discover = shopData["linePayChannelMap"]["Discover"] != null ? shopData["linePayChannelMap"]["Discover"] :false;
          bool taxSystem = shopData['taxSystem'] ?? false;
          var machineActivateData = {
            "showCash": _showCash,
            "showWechat":_showWechat,
            "showAlipay":_showAlipay,
            "showPayPay":_showPayPay,
            "showCreditCard":_showCreditCard,
            "au_Pay":_auPay,
            "d_Pay":_dPay,
            "R_Pay":_rPay,
            "m_Pay":_mPay,
            "pos_Edy":_posEdy,
            "pos_iD":_posiD,
            "pos_IC":_posIC,
            "pos_QUICPay":_posQUICPay,
            "pos_WAON":_posWAON,
            "pos_nanaco":_posnanaco,
            "show_visa":_visa,
            "show_master":_master,
            "show_jcb":_jcb,
            "show_unionPay":_unionPay,
            "show_americanExpress":_americanExpress,
            "show_dinersClub":_dinersClub,
            "show_discover":_discover,
            "taxSystem": taxSystem,
            "cashMachineWithdraw": shopData["cashMachineWithdraw"] ?? false,
          };
          //是否允许退款 1展示退款按钮 0 不展示
          var reimburse = (shopData["reimburse"]==true) ? "1":"0";
          Storage.setString('smartwe_machineActivateData', json.encode(machineActivateData));
          Storage.setString('smartwe_machineLanguages', json.encode(shopData["languages"]));

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
            'machineLineup':shopData["lineup"],
            'machineActuarial':shopData["actuarial"],
          };

          Storage.setString('machineSettingData', json.encode(machineSettingBool));
          GetxStorage.setData('machineSettingData', json.encode(machineSettingBool));

          _actuarial.value = shopData["actuarial"];

          FirebaseAnalytics.instance.logEvent(name: 'machine_activate_launch', parameters: {'machine_activate': '${_machineCode.value}'});
          await ensureImageLoaded(shopData["logoImage"]);
          await _getSmartweSystemSettingInfo(isLaunch: true);
        } else {
          FirebaseAnalytics.instance.logEvent(name: 'machine_activate_failure', parameters: {'machine_activate_error': '${_machineCode.value}'});
          _showErrorDialog();
        }

    } catch(e) {
        FirebaseAnalytics.instance.logEvent(name: 'machine_activate_error', parameters: {'machine_activate_error': '${_machineCode.value}'});
        logI("machine_activate_error: $e");

        if (retryCount < 2) {
          // 如果失败，重试
          Future.delayed(Duration(seconds: 2), () {
            _getMachineActivate(retryCount: retryCount + 1);
          });
        } else {
          // 如果重试次数超过3次，显示错误对话框
          _showErrorDialog(error: e);
        }
    }
  }

  _showErrorDialog({error}) =>
  Get.dialog(
        DialogUtils.alertOneButton("インターネットが接続していません。ネット環境及び機器の接続状況をご確認の上、券売君アプリを再起動してください。",
        title: "お知らせ",
        confirmtitle: "アプリ再起動",
        confirm: () {
        Future.delayed(Duration(milliseconds: 200), () {
          Get.back();
          //_getMachineActivate();
          Appset.restartApp;
          //exit(0);
        });

        })
  );

  Future<void> downloadAndStoreImage(String imageUrl) async {
    try {
      // 下载图片
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // 将图片转换为字节数组
        Uint8List imageBytes = response.bodyBytes;

        // 将字节数组转换为base64字符串
        String base64Image = base64Encode(imageBytes);
        LogUtil.d("base64Image:$base64Image");
        // 存储base64字符串到SharedPreferences
        //SharedPreferences prefs = await SharedPreferences.getInstance();
        await Storage.setString('smartwe_logoImageData', base64Image);
        await GetxStorage.setData('smartwe_logoImageData', base64Image);

        print('Image downloaded and stored successfully');
      } else {
        print('Failed to download image');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    try {
      // 下载图片
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // 获取应用文档目录
        final directory = await getApplicationDocumentsDirectory();

        // 从Content-Type头部获取实际的MIME类型
        final mimeType = response.headers['content-type'];

        // 根据MIME类型选择正确的文件扩展名
        String extension = '.png'; // 默认为png
        if (mimeType != null) {
          if (mimeType.contains('jpeg') || mimeType.contains('jpg')) {
            extension = '.jpg';
          } else if (mimeType.contains('bmp')) {
            extension = '.bmp';
          } else if (mimeType.contains('gif')) {
            extension = '.gif';
          } else if (mimeType.contains('webp')) {
            extension = '.webp';
          }
        }

        final filePath = '${directory.path}/smartwe_logoImage$extension';

        // 将图片保存到本地文件
        File file = File(filePath);
        debugPrint('filePath:$filePath');
        await file.writeAsBytes(response.bodyBytes);

      // 将文件路径存储到 SharedPreferences
        //SharedPreferences prefs = await SharedPreferences.getInstance();
        //await prefs.setString('smartwe_logoImageData', filePath);
        await Storage.setString('smartwe_logoImageData', filePath);
        await GetxStorage.setData('smartwe_logoImageData', filePath);

        if (Get.context != null)
           await precacheImage(FileImage(File(filePath)), Get.context!);

        print('Image downloaded and path stored successfully');
      } else {
        print('Failed to download image');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  Future<void> ensureImageLoaded(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      final provider = CachedNetworkImageProvider(imageUrl);
      final config = ImageConfiguration.empty;
      final Completer<void> completer = Completer<void>();

      provider.resolve(config).addListener(
        ImageStreamListener(
              (ImageInfo image, bool synchronousCall) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onError: (Object error, StackTrace? stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
        ),
      );

      await completer.future;
    } catch (e) {
      logE('ensureImageLoaded error: $e');
      await CachedNetworkImage.evictFromCache(imageUrl);
    }

  }

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

  _getSmartweSystemSettingInfo({bool isLaunch = false}) async {
    debugPrint("getSmartweSystemSettingInfo");
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    try {
      if (!Get.isRegistered<MachineInfoController>()) {
        final controller = MachineInfoController(systemSettingInfo);
        await Get.putAsync<MachineInfoController>(() async {
          await controller.loadMachineSettingInfo(); // 确保初始化完成
          return controller;
        }, permanent: true);
        debugPrint('put MachineInfoController done');
      } else {
        await Get.find<MachineInfoController>().updateMachineSettingInfo(settingInfo: systemSettingInfo);
        debugPrint('update MachineInfoController done');
      }
      // await Get.delete<MachineInfoController>();
      // Get.put(MachineInfoController(systemSettingData));

      debugPrint('update MachineInfoController done');
      var smartweMachineSettingPassword = await HomeServices.getMachineSettingManagePasswordInfo();
      if(smartweMachineSettingPassword != null && smartweMachineSettingPassword!= ""){
        Storage.setString('machineSettingManagePassword', smartweMachineSettingPassword);
        GetxStorage.setData('machineSettingManagePassword', smartweMachineSettingPassword);
      }

      Get.lazyPut(() => PrintService(Get.find<MachineInfoController>()));
    } catch (e) {
      logI('init MachineInfoController error: $e');
    }


    //这里判断是否禁用1元
    if(systemSettingInfo["isAllowOneYen"] == "0"){
      try {
        await payCube.prohibitOneCash.timeout(
            Duration(seconds: 10));
      } on TimeoutException catch (e) {
        print('Timeout: $e');
      } catch (e) {
        print('error: $e');
      }
    }

    await Get.find<SseSubscriptionManager>().startEnabledSubscriptions();

    // final posCheckService = Get.find<PosCheckService>();
    // posCheckService.setPosConnection(machineInfo.pos_ip, machineInfo.posPort);
    showStartButton.value = true;
    _goNext();

  }


  _senToPrint(Map data) {
    Get.find<PrintService>().printData(data);
  }

  void startOrder() {
    _goNext();
  }

  void _goNext() async {
    //Get.updateLocale(Locale('jp', 'JP'));
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
      //Get.off(() => OrderHomeView());
      Get.toNamed("/order-home", arguments: {
        'initLaunch': _loadActiveInfo.value,
      });
    });
  }

  void _goCheckOut() async {
    //Future.delayed(Duration(milliseconds: 200), () {
      //Get.off(() => CheckoutPageView());
      Get.toNamed("/checkout-page", arguments: {
        'initLaunch': _loadActiveInfo.value,
      });
    //});
  }

  void _goSelfService() async {
    Future.delayed(Duration(milliseconds: 200), () {
      //Get.off(() => SelfservicePageView());
      Get.toNamed("/selfservice-page", arguments: {
        'initLaunch': _loadActiveInfo.value,
      });
    });
  }


}
