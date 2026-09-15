import 'dart:convert';
import 'package:get/get.dart';

import '../models/machine_activation.dart';
import 'GetxStorage.dart';
import 'Storage.dart';
import 'machine_activation_local_service.dart';
import 'machine_runtime_service.dart';
import 'settings_snapshot_reporter.dart';

class HomeServices {
  static MachineRuntimeService? get _machineRuntime =>
      Get.isRegistered<MachineRuntimeService>()
          ? Get.find<MachineRuntimeService>()
          : null;

  static Future<MachineActivation?> getMachineActivation() async {
    final runtime = _machineRuntime;
    if (runtime?.isHydrated == true) return runtime?.activation;
    return MachineActivationLocalService().load();
  }

  static getOpenFirstState() async {
    var homeOpen = await Storage.getBool('homeOpen');
    if (homeOpen != null) GetxStorage.setBool('homeOpen', homeOpen);

    if (homeOpen != null && homeOpen == true) {
      return true;
    }
    return false;
  }

  static getMachineInfo() async {
    final runtime = _machineRuntime;
    if (runtime?.isHydrated == true) return runtime?.machineCode ?? "";
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
    return (await getMachineActivation())?.shopCode ?? "";
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
  
  static getMachinePrintWidth() async{
    double? labelPrintWidth;
    try {
      double? setting = await Storage.getDouble('machinePrintWidth');
      labelPrintWidth = setting ?? 385.0;
    } catch (e) {
      labelPrintWidth = 385.0;
    }
    return labelPrintWidth;
  }

  static setMachinePrintWidth(double machinePrintWidth) async{
    final runtime = _machineRuntime;
    if (runtime != null) {
      await runtime.updateMachinePrintWidth(machinePrintWidth);
    } else {
      await Storage.setDouble('machinePrintWidth', machinePrintWidth);
    }
    settingsSnapshotReporter.scheduleChanged();
  }

  static setLabelPrintWidth(double labelPrintWidthData) async{
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
    final runtime = _machineRuntime;
    if (runtime?.isHydrated == true) {
      return Map<String, dynamic>.from(runtime!.systemSettings);
    }
    Map? systemSettingInfo;
    try {
      var systemSettingDatatmp =
          await Storage.getString('smartwe_systemSetting');
      Map? systemSettingData = json.decode(systemSettingDatatmp!);
      systemSettingInfo = systemSettingData;
    } catch (e) {
      systemSettingInfo = {};
    }
    return systemSettingInfo;
  }

  static updateSystemSettingInfo(Map systemSettingData) async {
    final settings = Map<String, dynamic>.from(systemSettingData);
    final runtime = _machineRuntime;
    if (runtime != null) {
      await runtime.updateSystemSettings(settings);
    } else {
      await Storage.setString('smartwe_systemSetting', json.encode(settings));
    }
    settingsSnapshotReporter.scheduleChanged();
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

  static Future<List> getPrinterListInfo() async {
    List? list = await Storage.getData("printerListInfo");
    if (list != null) {
      return list;
    } else {
      return [];
    }
  }

  static Future<Map> getMachineModeInfo() async {
    Map? map = await Storage.getData("machineModeInfo");
    if (map != null) {
      return map;
    } else {
      return {};
    }
  }

  static Future<void> setMachineModeInfo(Map machineModeInfo) async {
    final value = Map<String, dynamic>.from(machineModeInfo);
    final runtime = _machineRuntime;
    if (runtime != null) {
      await runtime.updateMachineModeInfo(value);
    } else {
      await Storage.setData("machineModeInfo", json.encode(value));
    }
    settingsSnapshotReporter.scheduleChanged();
  }

  static Future<List<dynamic>> getSSESettingList() async {
    final data = await Storage.getData("SSESetting");
    return data is List ? List<dynamic>.from(data) : <dynamic>[];
  }

  static Future<void> setSSESettingList(List<Map<String, dynamic>> sseSettingList) async {

    final data = json.encode(sseSettingList);
    await Storage.setData("SSESetting", data);
    settingsSnapshotReporter.scheduleChanged();
  }

  static Future<void> setPrinterListInfo(List printerListInfo) async {
    final runtime = _machineRuntime;
    if (runtime != null) {
      await runtime.updatePrinterList(printerListInfo);
    } else {
      await Storage.setData("printerListInfo", json.encode(printerListInfo));
    }
    settingsSnapshotReporter.scheduleChanged();
  }

  static getWlanPrintSettingTwoInfo() async{
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

  static updateWlanPanelPrintSettingInfo(Map wlanPanelPrintSettingData) async {
    final settings = Map<String, dynamic>.from(wlanPanelPrintSettingData);
    final runtime = _machineRuntime;
    if (runtime != null) {
      await runtime.updateScreenCallSettings(settings);
    } else {
      await Storage.setString(
          'smartwe_wlanPanelPrintSetting', json.encode(settings));
    }
    settingsSnapshotReporter.scheduleChanged();
  }

  static updatePosSettingInfo(Map posSettingData) async {
    final settings = Map<String, dynamic>.from(posSettingData);
    final runtime = _machineRuntime;
    if (runtime != null) {
      await runtime.updatePosSettings(settings);
    } else {
      await Storage.setString('smartwe_posSetting', json.encode(settings));
    }
    settingsSnapshotReporter.scheduleChanged();
  }

  static updateUsbPrintSettingInfo(Map usbDevice) async {
    final device = Map<String, dynamic>.from(usbDevice);
    final runtime = _machineRuntime;
    if (runtime != null) {
      await runtime.updateUsbDevice(device);
    } else {
      await Storage.setString('smartwe_usbPrintSetting', json.encode(device));
    }
    settingsSnapshotReporter.scheduleChanged();
  }

  static updateMachineSettingPassword(String password) async {
    final runtime = _machineRuntime;
    if (runtime != null) {
      await runtime.updateSettingPassword(password);
    } else {
      await Storage.setString('machineSettingManagePassword', password);
    }
  }

  //是否展示微信支付宝等
  static getMachineActivateData() async {
    return (await getMachineActivation())?.toLegacyPaymentJson() ?? {};
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

  //多语言
  static getMachineLanguages() async{
    return (await getMachineActivation())?.languages ?? ["JP"];
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
    return (await getMachineActivation())?.homeImages ?? [];
  }

  //顶图
  static getSmartweHeaderImagesData() async{
    return (await getMachineActivation())?.headerImages ?? [];
  }

  //首图
  static getSmartweLogoImagesData() async {
    return (await getMachineActivation())?.logoImage ?? "";
  }

  static getSmartweLogoImage() async{
    var smartweLogoImagesInfo;
    try {
      var logoImageData = await Storage.getString('smartwe_logoImageData');
      //GetxStorage.setData('smartwe_logoImage', logoImageData);
      smartweLogoImagesInfo = logoImageData;
    } catch (e) {
      smartweLogoImagesInfo = "";
    }
    return smartweLogoImagesInfo;
  }

  //首图
  static getSmartweReimburseData() async {
    return (await getMachineActivation())?.canReimburse == true ? "1" : "0";
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
    return (await getMachineActivation())?.toLegacyMachineSettingJson() ?? {};
  }

  static getMachineSettingManagePasswordInfo() async {
    String? passwordinfo;
    try {
      //String machineInfoData = await GetxStorage.getString('machineSettingManagePassword');
      final machineInfoData = await Storage.getString('machineSettingManagePassword');
      if (machineInfoData == null || machineInfoData.isEmpty) {
        return '';
      }
      passwordinfo = machineInfoData;
    } catch (e) {
      passwordinfo = "";
    }
    return passwordinfo;
  }
}
