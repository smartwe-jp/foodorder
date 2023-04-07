
import 'package:foodorder/services/Storage.dart';
import 'dart:convert';
import 'package:foodorder/services/GetxStorage.dart';
class HomeServices{

  static getOpenFirstState() async{
      var homeOpen = await Storage.getBool('homeOpen');
      GetxStorage.setBool('machineInfo', homeOpen);
      if(homeOpen == true){
        return true;
      }
      return false;
  }

  static getMachineInfo() async{
    String machineinfo;
    try {
      String machineInfoData = await Storage.getString('machineInfo');
      GetxStorage.setData('machineInfo', machineInfoData);
      machineinfo = machineInfoData;
    } catch (e) {
      machineinfo = "";
    }
    return machineinfo;
  }

  //菜单方向
  static getMenuDirectionInfo() async{
    String menuDirectionInfo;
    try {
      String menuDirectionData = await Storage.getString('menuDirection');
      GetxStorage.setData('menuDirection', menuDirectionData);
      menuDirectionInfo = menuDirectionData;
    } catch (e) {
      menuDirectionInfo = "";
    }
    return menuDirectionInfo;
  }

  //小票纸大小
  static getPrintPaperSizeInfo() async{
    String printPaperSizeInfo;
    try {
      String printPaperSizeData = await Storage.getString('printPaperSize');
      GetxStorage.setData('printPaperSize', printPaperSizeData);
      printPaperSizeInfo = printPaperSizeData;
    } catch (e) {
      printPaperSizeInfo = "";
    }
    return printPaperSizeInfo;
  }

  //是否必须打印领収书
  static getIsAllowReceiptInfo() async{
    String isAllowReceiptInfo;
    try {
      String isAllowReceiptData = await Storage.getString('isAllowReceipt');
      GetxStorage.setData('isAllowReceipt', isAllowReceiptData);
      isAllowReceiptInfo = isAllowReceiptData;
    } catch (e) {
      isAllowReceiptInfo = "";
    }
    return isAllowReceiptInfo;
  }

  //多参数设置
  static getSystemSettingInfo() async{
    Map systemSettingInfo;
    try {
      Map systemSettingData = json.decode(await Storage.getString('smartwe_systemSetting'));
      GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));
      systemSettingInfo = systemSettingData;
    } catch (e) {
      systemSettingInfo = {};
    }
    return systemSettingInfo;
  }

  //pos机多参数设置
  static getPosSettingInfo() async{
    Map posSettingInfo;
    try {
      Map posSettingData = json.decode(await Storage.getString('smartwe_posSetting'));
      GetxStorage.setData('smartwe_posSetting', json.encode(posSettingData));
      posSettingInfo = posSettingData;
    } catch (e) {
      posSettingInfo = {};
    }
    return posSettingInfo;
  }

  //wlan print机多参数设置
  static getWlanPrintSettingInfo() async{
    Map printSettingInfo;
    try {
      Map printSettingData = json.decode(await Storage.getString('smartwe_wlanPrintSetting'));
      GetxStorage.setData('smartwe_wlanPrintSetting', json.encode(printSettingData));
      printSettingInfo = printSettingData;
    } catch (e) {
      printSettingInfo = {};
    }
    return printSettingInfo;
  }

  static getWlanPrintSettingTwoInfo() async{
    Map printSettingInfo;
    try {
      Map printSettingData = json.decode(await Storage.getString('smartwe_wlanPrintSettingTwo'));
      GetxStorage.setData('smartwe_wlanPrintSettingTwo', json.encode(printSettingData));
      printSettingInfo = printSettingData;
    } catch (e) {
      printSettingInfo = {};
    }
    return printSettingInfo;
  }

  //是否展示微信支付宝等
  static getMachineActivateData() async{
    Map machineActivateInfo;
    try {
      Map machineActivateData = json.decode(await Storage.getString('smartwe_machineActivateData'));
      GetxStorage.setData('smartwe_machineActivateData', json.encode(machineActivateData));
      machineActivateInfo = machineActivateData;
    } catch (e) {
      machineActivateInfo = {};
    }
    return machineActivateInfo;
  }

  //打卡机器码
  static getAttendanceCode() async{
    String attendanceCode;
    try {
      String attendanceCodeData = await Storage.getString('machineAttendanceCode');
      GetxStorage.setData('machineAttendanceCode', attendanceCodeData);
      attendanceCode = attendanceCodeData;
    } catch (e) {
      attendanceCode = "";
    }
    return attendanceCode;
  }

  //多参数设置
  static getIsShowCash() async{
    Map showCashInfo;
    try {
      Map showCashData = json.decode(await Storage.getString('isCashState'));
      GetxStorage.setData('isCashState', json.encode(showCashData));
      showCashInfo = showCashData;
    } catch (e) {
      showCashInfo = {};
    }
    return showCashInfo;
  }

  //多语言
  static getMachineLanguages() async{
    var machineLanguages;
    try {
      var machineLanguagesData = json.decode(await Storage.getString('smartwe_machineLanguages'));
      GetxStorage.setData('smartwe_machineLanguages', json.encode(machineLanguagesData));
      machineLanguages = machineLanguagesData;
    } catch (e) {
      machineLanguages = ["JP"];
    }
    return machineLanguages;
  }

  //首图
  static getSmartweHomeImagesData() async{
    var smartweHomeImagesInfo;
    try {
      var homeImageData = json.decode(await Storage.getString('smartwe_homeImages'));
      GetxStorage.setData('smartwe_homeImages', json.encode(homeImageData));
      smartweHomeImagesInfo = homeImageData;
    } catch (e) {
      smartweHomeImagesInfo = [];
    }
    return smartweHomeImagesInfo;
  }

  //首图
  static getSmartweLogoImagesData() async{
    var smartweLogoImagesInfo;
    try {
      var logoImageData = await Storage.getString('smartwe_logoImage');
      //GetxStorage.setData('smartwe_logoImage', logoImageData);
      smartweLogoImagesInfo = logoImageData;
    } catch (e) {
      smartweLogoImagesInfo = "";
    }
    return smartweLogoImagesInfo;
  }

  //精算 外带按钮
  static getSmartweCheckOutTakeoutData() async{
    var smartweTakeoutInfo;
    try {
      var takeoutData = json.decode(await Storage.getString('smartwe_checkOut_takeout'));
      GetxStorage.setData('smartwe_checkOut_takeout', json.encode(takeoutData));
      smartweTakeoutInfo = takeoutData;
    } catch (e) {
      smartweTakeoutInfo = [];
    }
    return smartweTakeoutInfo;
  }

  //精算 按钮
  static getSmartweCheckOutBillData() async{
    var smartweBillInfo;
    try {
      var billData = json.decode(await Storage.getString('smartwe_checkOut_bill'));
      GetxStorage.setData('smartwe_checkOut_bill', json.encode(billData));
      smartweBillInfo = billData;
    } catch (e) {
      smartweBillInfo = [];
    }
    return smartweBillInfo;
  }

  //精算 按钮
  static getSmartweCheckOutLineUpData() async{
    var smartweLineUpInfo;
    try {
      var lineUpData = json.decode(await Storage.getString('smartwe_checkOut_lineUp'));
      GetxStorage.setData('smartwe_checkOut_lineUp', json.encode(lineUpData));
      smartweLineUpInfo = lineUpData;
    } catch (e) {
      smartweLineUpInfo = {};
    }
    return smartweLineUpInfo;
  }

  //精算配置
  static getSmartweMachineSettingData() async{
    var machineSettingInfo;
    try {
      var machineSettingData = json.decode(await Storage.getString('machineSettingData'));
      machineSettingInfo = machineSettingData;
    } catch (e) {
      machineSettingInfo = {};
    }
    return machineSettingInfo;
  }

}