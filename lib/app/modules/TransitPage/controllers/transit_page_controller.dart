import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';


import '../../../plugins/paycube/lib/paycube.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/logUtil.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/Storage.dart';
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

  @override
  void onInit() {
    getIsShowCashInfo();
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
    Map systemSettingInfo = await HomeServices.getIsShowCash();

    _isCashState.value = systemSettingInfo['isCash'];

    _getMachineInfo();
  }

  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      _machineCode.value = machineCode;

      //_getSystemSettingInfo();
      _getPackageInfo();
    }
  }

  //获取版本号
  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version;//+"+"+packageInfo.buildNumber

    _getMachineActivate();
  }

  _getMachineActivate(){
    var formData = {
      "machineCode": _machineCode.value,
      "version":local_version.value
    };print(formData);
    request('webBootActivatev3', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());LogUtil.d(response);
      if (response['code'] == 200) {
        var shopData = response['data'];
        //_shopCode = shopData["shopCode"];
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
        };
        //是否允许退款 1展示退款按钮 0 不展示
        var reimburse = (shopData["reimburse"]==true) ? "1":"0";
        Storage.setString('smartwe_machineActivateData', json.encode(machineActivateData));
        Storage.setString('smartwe_machineLanguages', json.encode(shopData["languages"]));

        Storage.setString('smartwe_homeImages', json.encode(shopData["homeImages"]));
        Storage.setString('smartwe_logoImage', shopData["logoImage"]);
        Storage.setString('smartwe_reimburse', reimburse);

        GetxStorage.setData('smartwe_machineActivateData', json.encode(machineActivateData));
        GetxStorage.setData('smartwe_machineLanguages', json.encode(shopData["languages"]));
        GetxStorage.setData('smartwe_homeImages', json.encode(shopData["homeImages"]));
        GetxStorage.setData('smartwe_logoImage', shopData["logoImage"]);
        GetxStorage.setData('smartwe_reimburse', reimburse);

        var machineSettingBool = {
          'machineLineup':shopData["lineup"],
          'machineActuarial':shopData["actuarial"],
        };

        Storage.setString('machineSettingData', json.encode(machineSettingBool));
        GetxStorage.setData('machineSettingData', json.encode(machineSettingBool));

        _actuarial.value = shopData["actuarial"];
      }

      _getSmartweSystemSettingInfo();
    });
  }

  _getSmartweSystemSettingInfo() async {
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
      "isAllowBackHome":(SystemSettingInfo["isAllowBackHome"] !="" && SystemSettingInfo["isAllowBackHome"]!=null) ? SystemSettingInfo["isAllowBackHome"] :"0",//0回到首页，1回到菜单页
      "isAllowPos":(SystemSettingInfo["isAllowPos"] !="" && SystemSettingInfo["isAllowPos"]!=null) ? SystemSettingInfo["isAllowPos"] :"0",//0 不开pos 1开pos
      "isAllowWlanPrint":(SystemSettingInfo["isAllowWlanPrint"] !="" && SystemSettingInfo["isAllowWlanPrint"]!=null) ? SystemSettingInfo["isAllowWlanPrint"] :"0",//0 不开打印机 1开打印机
      "isAllowWlanPrintContinuous":(SystemSettingInfo["isAllowWlanPrintContinuous"] !="" && SystemSettingInfo["isAllowWlanPrintContinuous"]!=null) ? SystemSettingInfo["isAllowWlanPrintContinuous"] :"1",//0 单票 1连票
      "showPrintType":(SystemSettingInfo["showPrintType"] !="" && SystemSettingInfo["showPrintType"]!=null) ? SystemSettingInfo["showPrintType"] :"0",//0 receipt 1label
      "isAllowWlanPrintTwo":(SystemSettingInfo["isAllowWlanPrintTwo"] !="" && SystemSettingInfo["isAllowWlanPrintTwo"]!=null) ? SystemSettingInfo["isAllowWlanPrintTwo"] :"0",//0 不开打印机 1开打印机
      "isAllowWlanPrintTwoContinuous":(SystemSettingInfo["isAllowWlanPrintTwoContinuous"] !="" && SystemSettingInfo["isAllowWlanPrintTwoContinuous"]!=null) ? SystemSettingInfo["isAllowWlanPrintTwoContinuous"] :"1",//0 单票 1连票

    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));//1 默认58mm  2 宽纸80mm
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));
    //}

    var smartweMachineSettingPassword = await HomeServices.getMachineSettingManagePasswordInfo();
    if(smartweMachineSettingPassword != null && smartweMachineSettingPassword!= ""){
      Storage.setString('machineSettingManagePassword', smartweMachineSettingPassword);
      GetxStorage.setData('machineSettingManagePassword', smartweMachineSettingPassword);
    }

    //这里判断是否禁用1元
    if(systemSettingData["isAllowOneYen"] == "0"){
      var prohibitOneCashStatus =  await Paycube.prohibitOneCash;
    }
    if(checkmachineMode == "2"){
      _goCheckOut();
    }else if(checkmachineMode == "3"){
      _goSelfService();
    }else{
      _goMain();
    }
  }

  void _goMain() async {
    Future.delayed(Duration(milliseconds: 200), () {
      Get.off(() => OrderHomeView());
      //Get.toNamed("/order-home");
    });
  }

  void _goCheckOut() async {
    Future.delayed(Duration(milliseconds: 200), () {
      Get.off(() => CheckoutPageView());
      //Get.toNamed("/checkout-page");
    });
  }

  void _goSelfService() async {
    Future.delayed(Duration(milliseconds: 200), () {
      Get.off(() => SelfservicePageView());
      //Get.toNamed("/selfservice-page");
    });
  }


}
