
import 'package:foodorder/services/Storage.dart';
import 'dart:convert';

class HomeServices{

  static getOpenFirstState() async{
      var homeOpen = await Storage.getBool('homeOpen');
      if(homeOpen == true){
        return true;
      }
      return false;
  }

  static getMachineInfo() async{
    String machineinfo;
    try {
      String machineInfoData = await Storage.getString('machineInfo');
      machineinfo = machineInfoData;
    } catch (e) {
      machineinfo = "";
    }
    return machineinfo;
  }
  static getShopInfo() async{
    String shopinfo;
    try {
      String shopInfoData = await Storage.getString('shopInfo');
      shopinfo = shopInfoData;
    } catch (e) {
      shopinfo = "";
    }
    return shopinfo;
  }

  static getDiningTypeInfo() async{
    String diningTypeInfo;
    try {
      String diningTypeData = await Storage.getString('diningType');
      diningTypeInfo = diningTypeData;
    } catch (e) {
      diningTypeInfo = "";
    }
    return diningTypeInfo;
  }

  //菜单方向
  static getMenuDirectionInfo() async{
    String menuDirectionInfo;
    try {
      String menuDirectionData = await Storage.getString('menuDirection');
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
      posSettingInfo = posSettingData;
    } catch (e) {
      posSettingInfo = {};
    }
    return posSettingInfo;
  }

  //是否展示微信支付宝等
  static getMachineActivateData() async{
    Map machineActivateInfo;
    try {
      Map machineActivateData = json.decode(await Storage.getString('smartwe_machineActivateData'));
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
      attendanceCode = attendanceCodeData;
    } catch (e) {
      attendanceCode = "";
    }
    return attendanceCode;
  }

}