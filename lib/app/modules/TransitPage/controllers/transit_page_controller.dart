import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/plugins/appset/lib/appset.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


import '../../../controllers/machine_info.dart';
import '../../../plugins/paycube/lib/paycube.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/logUtil.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/Storage.dart';
import '../../../widget/DialogUtils.dart';
import '../../CheckoutPage/views/checkout_page_view.dart';
import '../../OrderHome/views/order_home_view.dart';
import '../../SelfservicePage/views/selfservice_page_view.dart';

class TransitPageController extends GetxController {
  //TODO: Implement TransitPageController
  RxString _machineCode = "".obs;
  var _machineMode = "1";//1 券卖机  2 精算机 3 自助收银
  RxBool _isCashState = true.obs;
  RxBool _actuarial = false.obs;
  RxString local_version = "".obs; //本appversion
  RxBool _loadActiveInfo = false.obs;

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
    debugPrint("getIsShowCashInfo");
    Map systemSettingInfo = await HomeServices.getIsShowCash();
    if (Get.arguments != null && Get.arguments.containsKey('loadActive')) {
      _loadActiveInfo.value = Get.arguments['loadActive'];
    }
    _isCashState.value = systemSettingInfo['isCash'];
    debugPrint("isCashState: ${_isCashState.value}");

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

  _getMachineActivate() async{
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
    debugPrint("getMachineActivate");
    var formData = {
      "machineCode": _machineCode.value,
      "version":local_version.value
    };
    print(formData);
    request('webBootActivatev3', method: 'POST', parameters: formData).then((val) async {
      var response = json.decode(val.toString());

      if (response != null && response['code'] == 200 && response['data'] != null) {
        LogUtil.d(response);
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
        var machineActivateData = {
          "showCash":(_isCashState.value == true) ? _showCash :false,
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
        await downloadAndSaveImage(shopData["logoImage"]);
        await _getSmartweSystemSettingInfo();
      } else {
        FirebaseAnalytics.instance.logEvent(name: 'machine_activate_failure', parameters: {'machine_activate_error': '${_machineCode.value}'});
        _showErrorDialog();
      }

    })
    .catchError((e) {
      FirebaseAnalytics.instance.logEvent(name: 'machine_activate_error', parameters: {'machine_activate_error': '${_machineCode.value}'});
      //print("error: $e");
      _showErrorDialog(error: e);
    })
    .timeout(Duration(seconds: 30), onTimeout: () {
      FirebaseAnalytics.instance.logEvent(name: 'machine_activate_timeout', parameters: {'machine_activate_timeout': '${_machineCode.value}'});
      //print('timeout');
      _showErrorDialog();
    });
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

  _getSmartweSystemSettingInfo() async {
    debugPrint("getSmartweSystemSettingInfo");
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    var checkmachineMode = "1";
    if(SystemSettingInfo["machineMode"] !="" && SystemSettingInfo["machineMode"]!=null &&SystemSettingInfo["machineMode"] != "1"){
      if(_actuarial.value==true){
        checkmachineMode = (SystemSettingInfo["machineMode"] == "3") ? "3" : "2";
      }else{
        checkmachineMode = "1";
      }
    }
    var systemSettingData = {
      "diningType": (SystemSettingInfo["diningType"] !="" && SystemSettingInfo["diningType"]!=null) ? SystemSettingInfo["diningType"] :"1", //1堂食 2外带
      "menuDirection":(SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1",//1顶部横向 2左侧竖
      //"printPaperSize":(SystemSettingInfo["printPaperSize"] !="" && SystemSettingInfo["printPaperSize"]!=null) ? SystemSettingInfo["printPaperSize"] :"1",//1 58mm 2 80mm
      "printPaperTxtSize":(SystemSettingInfo["printPaperTxtSize"] !="" && SystemSettingInfo["printPaperTxtSize"]!=null) ? SystemSettingInfo["printPaperTxtSize"] :"1",//1 普通　2大　3特大
      "isAllowReceipt":(SystemSettingInfo["isAllowReceipt"] !="" && SystemSettingInfo["isAllowReceipt"]!=null) ? SystemSettingInfo["isAllowReceipt"] :"1",//1必须打印小票 2不必须
      "isAllowReceiptMenu":(SystemSettingInfo["isAllowReceiptMenu"] !="" && SystemSettingInfo["isAllowReceiptMenu"]!=null) ? SystemSettingInfo["isAllowReceiptMenu"] :"1",//1必须打印小票顶部菜单 2不打印
      "machineMode":checkmachineMode,
      "isReservation":(SystemSettingInfo["isReservation"] !="" && SystemSettingInfo["isReservation"]!=null) ? SystemSettingInfo["isReservation"] :"0",//是否开启预约 0不开启 1开启
      "isAllowAttendance":(SystemSettingInfo["isAllowAttendance"] !="" && SystemSettingInfo["isAllowAttendance"]!=null) ? SystemSettingInfo["isAllowAttendance"] :"0",//0 不开考勤 1开考勤
      "isAllowOneYen":(SystemSettingInfo["isAllowOneYen"] !="" && SystemSettingInfo["isAllowOneYen"]!=null) ? SystemSettingInfo["isAllowOneYen"] :"0",//0禁用1元 1不禁用
      "isAllow5000": SystemSettingInfo["isAllow5000"] ?? "0",
      "isAllow10000": SystemSettingInfo["isAllow10000"] ?? "0",
      "isAllowBackHome":(SystemSettingInfo["isAllowBackHome"] !="" && SystemSettingInfo["isAllowBackHome"]!=null) ? SystemSettingInfo["isAllowBackHome"] :"0",//0回到首页，1回到菜单页
      "isAllowPos":(SystemSettingInfo["isAllowPos"] !="" && SystemSettingInfo["isAllowPos"]!=null) ? SystemSettingInfo["isAllowPos"] :"0",//0 不开pos 1开pos
      "isAllowWlanPrint":(SystemSettingInfo["isAllowWlanPrint"] !="" && SystemSettingInfo["isAllowWlanPrint"]!=null) ? SystemSettingInfo["isAllowWlanPrint"] :"0",//0 不开打印机 1开打印机
      "isAllowWlanPrintContinuous":(SystemSettingInfo["isAllowWlanPrintContinuous"] !="" && SystemSettingInfo["isAllowWlanPrintContinuous"]!=null) ? SystemSettingInfo["isAllowWlanPrintContinuous"] :"1",//0 单票 1连票
      "showPrintType":(SystemSettingInfo["showPrintType"] !="" && SystemSettingInfo["showPrintType"]!=null) ? SystemSettingInfo["showPrintType"] :"0",//0 receipt 1label
      "isAllowWlanPrintTwo":(SystemSettingInfo["isAllowWlanPrintTwo"] !="" && SystemSettingInfo["isAllowWlanPrintTwo"]!=null) ? SystemSettingInfo["isAllowWlanPrintTwo"] :"0",//0 不开打印机 1开打印机
      "isAllowWlanPrintTwoContinuous":(SystemSettingInfo["isAllowWlanPrintTwoContinuous"] !="" && SystemSettingInfo["isAllowWlanPrintTwoContinuous"]!=null) ? SystemSettingInfo["isAllowWlanPrintTwoContinuous"] :"1",//0 单票 1连票
      "isAllowRejishime":(SystemSettingInfo["isAllowRejishime"] !="" && SystemSettingInfo["isAllowRejishime"]!=null) ? SystemSettingInfo["isAllowRejishime"] :"0",
      "panelType": SystemSettingInfo['panelType'] ?? 'Mini',
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));//1 默认58mm  2 宽纸80mm
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));
    //}

    Get.put(MachineInfoController(systemSettingData));
    debugPrint('put MachineInfoController');

    var smartweMachineSettingPassword = await HomeServices.getMachineSettingManagePasswordInfo();
    if(smartweMachineSettingPassword != null && smartweMachineSettingPassword!= ""){
      Storage.setString('machineSettingManagePassword', smartweMachineSettingPassword);
      GetxStorage.setData('machineSettingManagePassword', smartweMachineSettingPassword);
    }

    //这里判断是否禁用1元
    if(systemSettingData["isAllowOneYen"] == "0"){
      try {
        await Paycube.prohibitOneCash.timeout(
            Duration(seconds: 10));
      } on TimeoutException catch (e) {
        print('Timeout: $e');
      } catch (e) {
        print('error: $e');
      }
    }
    _goNext(checkmachineMode);

  }

  void _goNext(checkmachineMode) async {
    Get.updateLocale(Locale('jp', 'JP'));
    if(checkmachineMode == "2"){
      _goCheckOut();
    }else if(checkmachineMode == "3"){
      _goSelfService();
    }else{
      _goMain();
    }
  }


  void _goMain() async {
    debugPrint("transit  goMain");
    Future.delayed(Duration(milliseconds: 200), () {
      //Get.off(() => OrderHomeView());
      Get.toNamed("/order-home");
    });
  }

  void _goCheckOut() async {
    Future.delayed(Duration(milliseconds: 200), () {
      //Get.off(() => CheckoutPageView());
      Get.toNamed("/checkout-page");
    });
  }

  void _goSelfService() async {
    Future.delayed(Duration(milliseconds: 200), () {
      //Get.off(() => SelfservicePageView());
      Get.toNamed("/selfservice-page");
    });
  }


}
