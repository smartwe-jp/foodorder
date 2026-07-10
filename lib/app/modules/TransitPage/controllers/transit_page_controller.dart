import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/http_conf.dart';
import 'package:foodorder/app/services/sse_service.dart';
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
  static const String _activateCacheKey = 'smartwe_webBootActivatev3_cache';

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
      LogUtil.d("getMachineActivate response: $response");
      logI("getMachineActivate response: $response");

      if (response != null && response['code'] == 200 && response['data'] != null) {
        logI(response);
        final shopData = Map<String, dynamic>.from(response['data'] as Map);
        await _saveActivateCache(shopData);
        await _applyShopDataAndContinue(shopData, isFromCache: false);
      } else {
        FirebaseAnalytics.instance.logEvent(name: 'machine_activate_failure', parameters: {'machine_activate_error': '${_machineCode.value}'});
        await _tryContinueWithCachedActivate(
          reason: 'activate_response_invalid',
          responseCode: response?['code']?.toString(),
        );
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
          await _tryContinueWithCachedActivate(reason: 'activate_request_failed', error: e);
        }
    }
  }

  /// 激活成功后将完整 data 写入本地，供下次网络异常时降级使用
  Future<void> _saveActivateCache(Map<String, dynamic> shopData) async {
    final cachePayload = {
      'machineCode': _machineCode.value,
      'version': local_version.value,
      'savedAt': DateTime.now().toIso8601String(),
      'data': shopData,
    };
    final encoded = json.encode(cachePayload);
    await Storage.setString(_activateCacheKey, encoded);
    await GetxStorage.setData(_activateCacheKey, encoded);
    logI('webBootActivatev3 cache saved for machine: ${_machineCode.value}');
  }

  /// 读取上次激活成功的缓存，仅当机器码一致时可用
  Future<Map<String, dynamic>?> _loadActivateCache() async {
    try {
      final raw = await Storage.getString(_activateCacheKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final cache = Map<String, dynamic>.from(json.decode(raw) as Map);
      final cachedMachineCode = cache['machineCode']?.toString() ?? '';
      if (cachedMachineCode.isEmpty || cachedMachineCode != _machineCode.value) {
        logI('webBootActivatev3 cache ignored: machineCode mismatch');
        return null;
      }
      final shopData = cache['data'];
      if (shopData is! Map) {
        return null;
      }
      return Map<String, dynamic>.from(shopData);
    } catch (e) {
      logI('webBootActivatev3 cache load error: $e');
      return null;
    }
  }

  bool _readPayChannel(Map<String, dynamic> shopData, String key) {
    final channelMap = shopData['linePayChannelMap'];
    if (channelMap is! Map) {
      return false;
    }
    return channelMap[key] == true;
  }

  /// 将激活 data 写入各业务字段并进入后续流程
  Future<void> _applyShopDataAndContinue(
    Map<String, dynamic> shopData, {
    required bool isFromCache,
  }) async {
    var shopCode = shopData['shopCode']?.toString() ?? '';
    final machineActivateData = {
      'showCash': _readPayChannel(shopData, 'Cash'),
      'showWechat': _readPayChannel(shopData, 'Wechat'),
      'showAlipay': _readPayChannel(shopData, 'Alipay'),
      'showPayPay': _readPayChannel(shopData, 'PayPay'),
      'showCreditCard': _readPayChannel(shopData, 'POS'),
      'au_Pay': _readPayChannel(shopData, 'au_Pay'),
      'd_Pay': _readPayChannel(shopData, 'd_Pay'),
      'R_Pay': _readPayChannel(shopData, 'R_Pay'),
      'm_Pay': _readPayChannel(shopData, 'm_Pay'),
      'pos_Edy': _readPayChannel(shopData, 'Edy'),
      'pos_iD': _readPayChannel(shopData, 'iD'),
      'pos_IC': _readPayChannel(shopData, 'IC'),
      'pos_QUICPay': _readPayChannel(shopData, 'QUICPay'),
      'pos_WAON': _readPayChannel(shopData, 'WAON'),
      'pos_nanaco': _readPayChannel(shopData, 'nanaco'),
      'show_visa': _readPayChannel(shopData, 'VISA'),
      'show_master': _readPayChannel(shopData, 'MASTER'),
      'show_jcb': _readPayChannel(shopData, 'JCB'),
      'show_unionPay': _readPayChannel(shopData, 'UnionPay'),
      'show_americanExpress': _readPayChannel(shopData, 'AMERICAN_EXPRESS'),
      'show_dinersClub': _readPayChannel(shopData, 'Diners_Club'),
      'show_discover': _readPayChannel(shopData, 'Discover'),
      'taxSystem': shopData['taxSystem'] == true,
      'cashMachineWithdraw': shopData['cashMachineWithdraw'] == true,
    };
    // 是否允许退款 1展示退款按钮 0 不展示
    final reimburse = shopData['reimburse'] == true ? '1' : '0';
    final spicyHotPot = shopData['spicyHotPot'] == true ? '1' : '0';
    final logoImage = shopData['logoImage']?.toString() ?? '';

    Storage.setString('smartwe_machineActivateData', json.encode(machineActivateData));
    Storage.setString('smartwe_machineLanguages', json.encode(shopData['languages']));
    Storage.setString('smartwe_homeImages', json.encode(shopData['homeImages']));
    Storage.setString('smartwe_headerImages', json.encode(shopData['headerImages']));
    Storage.setString('smartwe_logoImage', logoImage);
    Storage.setString('smartwe_reimburse', reimburse);
    Storage.setString('smartwe_shopCode', shopCode);
    Storage.setString('smartwe_spicyHotPot', spicyHotPot);

    GetxStorage.setData('smartwe_machineActivateData', json.encode(machineActivateData));
    GetxStorage.setData('smartwe_machineLanguages', json.encode(shopData['languages']));
    GetxStorage.setData('smartwe_homeImages', json.encode(shopData['homeImages']));
    GetxStorage.setData('smartwe_headerImages', json.encode(shopData['headerImages']));
    GetxStorage.setData('smartwe_logoImage', logoImage);
    GetxStorage.setData('smartwe_reimburse', reimburse);
    GetxStorage.setData('smartwe_shopCode', shopCode);
    GetxStorage.setData('smartwe_spicyHotPot', spicyHotPot);

    final machineSettingBool = {
      'machineLineup': shopData['lineup'],
      'machineActuarial': shopData['actuarial'],
    };

    Storage.setString('machineSettingData', json.encode(machineSettingBool));
    GetxStorage.setData('machineSettingData', json.encode(machineSettingBool));

    _actuarial.value = shopData['actuarial'] == true;

    if (isFromCache) {
      FirebaseAnalytics.instance.logEvent(
        name: 'machine_activate_cache_fallback',
        parameters: {
          'machine_activate': _machineCode.value,
        },
      );
      logI('webBootActivatev3 using cached activate data');
    } else {
      FirebaseAnalytics.instance.logEvent(
        name: 'machine_activate_launch',
        parameters: {'machine_activate': _machineCode.value},
      );
    }

    await ensureImageLoaded(logoImage);
    await _getSmartweSystemSettingInfo(isLaunch: !isFromCache);
  }

  /// 请求失败时尝试使用本地缓存继续进入；无缓存则弹窗
  Future<void> _tryContinueWithCachedActivate({
    String? reason,
    String? responseCode,
    Object? error,
  }) async {
    final cachedShopData = await _loadActivateCache();
    if (cachedShopData != null) {
      logI(
        'webBootActivatev3 fallback to cache, reason: $reason, code: $responseCode, error: $error',
      );
      await _applyShopDataAndContinue(cachedShopData, isFromCache: true);
      return;
    }
    _showErrorDialog(error: error);
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
      logI('ensureImageLoaded error: $e');
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

    final sseService = Get.find<SseService>();
    final machineInfo = Get.find<MachineInfoController>();
    final sseSettingList = machineInfo.sseSettingList;

    for (final sseSetting in sseSettingList) {
      if (sseSetting['name'] == 'SmartWe SSE') { //针对切换机器码重新设置存储值
        sseSetting['identify'] = machineInfo.machineCode;
      }
      if (sseSetting['isOn'] == true) {
        final url = servicePath[sseSetting['server']];// + sseSetting['identify'];
        if (url != null && url.isNotEmpty) {
          final address = url + sseSetting['identify'];
          sseService.addSseListen(address);
        }
      }
    }
    HomeServices.setSSESettingList(sseSettingList);

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
