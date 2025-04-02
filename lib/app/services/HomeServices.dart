import 'dart:convert';
import 'package:flutter/material.dart';

import 'GetxStorage.dart';
import 'Storage.dart';

class HomeServices {
  static getOpenFirstState() async {
    var homeOpen = await Storage.getBool('homeOpen');
    if (homeOpen != null) GetxStorage.setBool('homeOpen', homeOpen);

    if (homeOpen != null && homeOpen == true) {
      return true;
    }
    return false;
  }

  static getMachineInfo() async {
    String? machineinfo;
    try {
      String? machineInfoData = await Storage.getString('machineInfo');
      GetxStorage.setData('machineInfo', machineInfoData);
      machineinfo = machineInfoData;
    } catch (e) {
      machineinfo = "";
    }
    return machineinfo;
  }

  static getActiveTimeInfo() async {
    String? activeTimeInfo;
    try {
      String? machineInfoData = await Storage.getString('activeTimeInfo');
      GetxStorage.setData('activeTimeInfo', machineInfoData);
      activeTimeInfo = machineInfoData;
    } catch (e) {
      activeTimeInfo = "";
    }
    return activeTimeInfo;
  }

  static getShopCode() async {
    String? shopCode;
    try {
      String? shopCodeData = await Storage.getString('smartwe_shopCode');
      shopCode = shopCodeData;
    } catch (e) {
      shopCode = "";
    }
    return shopCode;
  }

  //菜单方向
  static getMenuDirectionInfo() async {
    String? menuDirectionInfo;
    try {
      String? menuDirectionData = await Storage.getString('menuDirection');
      GetxStorage.setData('menuDirection', menuDirectionData);
      menuDirectionInfo = menuDirectionData;
    } catch (e) {
      menuDirectionInfo = "";
    }
    return menuDirectionInfo;
  }

  //是否必须打印领収书
  static getIsAllowReceiptInfo() async {
    String? isAllowReceiptInfo;
    try {
      String? isAllowReceiptData = await Storage.getString('isAllowReceipt');
      GetxStorage.setData('isAllowReceipt', isAllowReceiptData);
      isAllowReceiptInfo = isAllowReceiptData;
    } catch (e) {
      isAllowReceiptInfo = "";
    }
    return isAllowReceiptInfo;
  }

  //是否必须打印领収书
  static getEditMode() async {
    // var editMode = await Storage.getString('editMode');
    // if(editMode != null){
    //   return editMode == '1';
    // } else {
    //   return false;
    // }

    bool? editMode;
    try {
      String? setting = await Storage.getString('editMode');
      editMode = setting == "1";
    } catch (e) {
      editMode = false;
    }
    return editMode;
  }

  static setEditMode(bool mode) async {
    //await GetxStorage.setData('editMode', mode == true ? '1' : '0');
    await Storage.setString('editMode', mode == true ? '1' : '0');
  }

  static getPrintDirection() async {
    String? printDirection;
    try {
      String? setting = await Storage.getString('printDirection');
      printDirection = setting ?? "0";
    } catch (e) {
      printDirection = "0";
    }
    return printDirection;
  }

  static getPrintTwoDirection() async {
    String? printDirection;
    try {
      String? setting = await Storage.getString('printTwoDirection');
      printDirection = setting ?? "0";
    } catch (e) {
      printDirection = "0";
    }
    return printDirection;
  }

  static getPrintThreeDirection() async {
    String? printDirection;
    try {
      String? setting = await Storage.getString('printThreeDirection');
      printDirection = setting ?? "0";
    } catch (e) {
      printDirection = "0";
    }
    return printDirection;
  }

  static getLabelPrintWidth() async {
    double? labelPrintWidth;
    try {
      double? setting = await Storage.getDouble('labelPrintWidth');
      labelPrintWidth = setting ?? 384.0;
    } catch (e) {
      labelPrintWidth = 384.0;
    }
    return labelPrintWidth;
  }

  static setLabelPrintWidth(double labelPrintWidthData) async {
    Storage.setDouble('labelPrintWidth', labelPrintWidthData);
  }

  static setPrintDirection(String printDirectionData) async {
    Storage.setString('printDirection', printDirectionData);
  }

  static setPrintTwoDirection(String printDirectionData) async {
    Storage.setString('printTwoDirection', printDirectionData);
  }

  static setPrintThreeDirection(String printDirectionData) async {
    Storage.setString('printThreeDirection', printDirectionData);
  }

  //多参数设置
  static getSystemSettingInfo() async {
    Map? systemSettingInfo;
    try {
      var systemSettingDatatmp =
          await Storage.getString('smartwe_systemSetting');
      Map? systemSettingData = json.decode(systemSettingDatatmp!);
      GetxStorage.setData(
          'smartwe_systemSetting', json.encode(systemSettingData));
      systemSettingInfo = systemSettingData;
    } catch (e) {
      systemSettingInfo = {};
    }
    return systemSettingInfo;
  }

  static updateSystemSettingInfo(Map systemSettingData) async {
    //GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));
  }

  //pos机多参数设置
  static getPosSettingInfo() async {
    Map? posSettingInfo;
    try {
      var posSettingDatatmp = await Storage.getString('smartwe_posSetting');
      Map? posSettingData = json.decode(posSettingDatatmp!);
      GetxStorage.setData('smartwe_posSetting', json.encode(posSettingData));
      posSettingInfo = posSettingData;
    } catch (e) {
      posSettingInfo = {};
    }
    return posSettingInfo;
  }

  //wlan print机多参数设置
  static getWlanPrintSettingInfo() async {
    Map? printSettingInfo;
    try {
      var printSettingDatatmp =
          await Storage.getString('smartwe_wlanPrintSetting');
      Map? printSettingData = json.decode(printSettingDatatmp!);
      GetxStorage.setData(
          'smartwe_wlanPrintSetting', json.encode(printSettingData));
      printSettingInfo = printSettingData;
    } catch (e) {
      printSettingInfo = {};
    }
    return printSettingInfo;
  }

  //usb print机多参数设置
  static getUsbPrintSettingInfo() async {
    Map? printSettingInfo;
    try {
      var printSettingDatatmp =
          await Storage.getString('smartwe_usbPrintSetting');
      Map? printSettingData = json.decode(printSettingDatatmp!);
      GetxStorage.setData(
          'smartwe_usbPrintSetting', json.encode(printSettingData));
      printSettingInfo = printSettingData;
    } catch (e) {
      printSettingInfo = {};
    }
    return printSettingInfo;
  }

  static getWlanPrintSettingTwoInfo() async {
    Map printSettingInfo;
    try {
      var printSettingDatatmp =
          await Storage.getString('smartwe_wlanPrintSettingTwo');
      Map printSettingData = json.decode(printSettingDatatmp!);
      GetxStorage.setData(
          'smartwe_wlanPrintSettingTwo', json.encode(printSettingData));
      printSettingInfo = printSettingData;
    } catch (e) {
      printSettingInfo = {};
    }
    return printSettingInfo;
  }

  static getWlanPanelPrintSettingInfo() async {
    Map printSettingInfo;
    try {
      var printSettingDatatmp =
          await Storage.getString('smartwe_wlanPanelPrintSetting');
      Map printSettingData = json.decode(printSettingDatatmp!);
      GetxStorage.setData(
          'smartwe_wlanPanelPrintSetting', json.encode(printSettingData));
      printSettingInfo = printSettingData;
    } catch (e) {
      printSettingInfo = {};
    }
    return printSettingInfo;
  }

  //是否展示微信支付宝等
  static getMachineActivateData() async {
    Map machineActivateInfo;
    try {
      var machineActivateDatatmp =
          await Storage.getString('smartwe_machineActivateData');
      Map machineActivateData = json.decode(machineActivateDatatmp!);
      GetxStorage.setData(
          'smartwe_machineActivateData', json.encode(machineActivateData));
      machineActivateInfo = machineActivateData;
    } catch (e) {
      machineActivateInfo = {};
    }
    return machineActivateInfo;
  }

  //打卡机器码
  static getAttendanceCode() async {
    String? attendanceCode;
    try {
      String? attendanceCodeData =
          await Storage.getString('machineAttendanceCode');
      GetxStorage.setData('machineAttendanceCode', attendanceCodeData);
      attendanceCode = attendanceCodeData;
    } catch (e) {
      attendanceCode = "";
    }
    return attendanceCode;
  }

  //多参数设置
  static getIsShowCash() async {
    Map showCashInfo;
    try {
      var showCashDatatmp = await Storage.getString('isCashState');
      Map showCashData = json.decode(showCashDatatmp!);
      GetxStorage.setData('isCashState', json.encode(showCashData));
      showCashInfo = showCashData;
    } catch (e) {
      showCashInfo = {};
    }
    return showCashInfo;
  }

  //多语言
  static getMachineLanguages() async {
    var machineLanguages;
    try {
      var machineLanguagesDatatmp =
          await Storage.getString('smartwe_machineLanguages');
      var machineLanguagesData = json.decode(machineLanguagesDatatmp!);
      GetxStorage.setData(
          'smartwe_machineLanguages', json.encode(machineLanguagesData));
      machineLanguages = machineLanguagesData;
    } catch (e) {
      machineLanguages = ["JP"];
    }
    return machineLanguages;
  }

  static getSettingLanguage() async {
    var settingLanguge;
    try {
      var language = await Storage.getString('smartwe_settingLanguage');
      if (language == null) {
        language = "JP";
        GetxStorage.setData('smartwe_settingLanguage', language);
      }
      settingLanguge = language;
    } catch (e) {
      settingLanguge = "JP";
    }
    return settingLanguge;
  }

  static updateSettingLanguage(String language) async {
    GetxStorage.setData('smartwe_settingLanguage', language);
  }

  //首图
  static getSmartweHomeImagesData() async {
    var smartweHomeImagesInfo;
    try {
      var homeImageDatatmp = await Storage.getString('smartwe_homeImages');
      var homeImageData = json.decode(homeImageDatatmp!);
      GetxStorage.setData('smartwe_homeImages', json.encode(homeImageData));
      smartweHomeImagesInfo = homeImageData;
    } catch (e) {
      smartweHomeImagesInfo = [];
    }
    return smartweHomeImagesInfo;
  }

  //顶图
  static getSmartweHeaderImagesData() async{
    var smartweHomeImagesInfo;
    try {
      var homeImageDatatmp = await Storage.getString('smartwe_headerImages');
      var homeImageData = json.decode(homeImageDatatmp!);
      GetxStorage.setData('smartwe_headerImages', json.encode(homeImageData));
      smartweHomeImagesInfo = homeImageData;
    } catch (e) {
      smartweHomeImagesInfo = [];
    }
    return smartweHomeImagesInfo;
  }

  //首图
  static getSmartweLogoImagesData() async {
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

  //首图
  static getSmartweReimburseData() async {
    var smartweReimburseInfo;
    try {
      var ReimburseData = await Storage.getString('smartwe_reimburse');
      //GetxStorage.setData('smartwe_logoImage', logoImageData);
      smartweReimburseInfo = ReimburseData;
    } catch (e) {
      smartweReimburseInfo = "0";
    }
    return smartweReimburseInfo;
  }

  //精算 外带按钮
  static getSmartweCheckOutTakeoutData() async {
    var smartweTakeoutInfo;
    try {
      var takeoutDatatmp = await Storage.getString('smartwe_checkOut_takeout');
      var takeoutData = json.decode(takeoutDatatmp!);
      GetxStorage.setData('smartwe_checkOut_takeout', json.encode(takeoutData));
      smartweTakeoutInfo = takeoutData;
    } catch (e) {
      smartweTakeoutInfo = [];
    }
    return smartweTakeoutInfo;
  }

  //精算 按钮
  static getSmartweCheckOutBillData() async {
    var smartweBillInfo;
    try {
      var billDatatmp = await Storage.getString('smartwe_checkOut_bill');
      var billData = json.decode(billDatatmp!);
      GetxStorage.setData('smartwe_checkOut_bill', json.encode(billData));
      smartweBillInfo = billData;
    } catch (e) {
      smartweBillInfo = [];
    }
    return smartweBillInfo;
  }

  //精算 按钮
  static getSmartweCheckOutLineUpData() async {
    var smartweLineUpInfo;
    try {
      var lineUpDatatmp = await Storage.getString('smartwe_checkOut_lineUp');
      var lineUpData = json.decode(lineUpDatatmp!);
      GetxStorage.setData('smartwe_checkOut_lineUp', json.encode(lineUpData));
      smartweLineUpInfo = lineUpData;
    } catch (e) {
      smartweLineUpInfo = {};
    }
    return smartweLineUpInfo;
  }

  //精算配置
  static getSmartweMachineSettingData() async {
    var machineSettingInfo;
    try {
      var machineSettingDatatemp =
          await Storage.getString('machineSettingData');
      var machineSettingData = json.decode(machineSettingDatatemp!);
      machineSettingInfo = machineSettingData;
    } catch (e) {
      machineSettingInfo = {};
    }
    return machineSettingInfo;
  }

  static getMachineSettingManagePasswordInfo() async {
    String? passwordinfo;
    try {
      //String machineInfoData = await GetxStorage.getString('machineSettingManagePassword');
      String? machineInfoData =
          await Storage.getString('machineSettingManagePassword');
      passwordinfo = machineInfoData;
    } catch (e) {
      passwordinfo = "";
    }
    return passwordinfo;
  }
}
