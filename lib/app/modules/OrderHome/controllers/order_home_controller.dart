import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

import '../../../controllers/order_sql_controller.dart';
import '../../../services/HomeServices.dart';

class OrderHomeController extends GetxController with StateMixin {
  //TODO: Implement OrderHomeController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());

  RxString machineCode = "".obs;

  RxString menu_direction = "1".obs; //1 默认顶部横向  2 左侧纵向
  RxString dining_type = "0".obs; //就餐类型选择 1店内 2外卖 3全可以

  RxBool machineLanguages_JP = false.obs;
  RxBool machineLanguages_CH = false.obs;
  RxBool machineLanguages_EN = false.obs;
  RxBool machineLanguages_KO = false.obs;

  RxBool isShowTest = false.obs;

  RxList homeList = [].obs;

  @override
  void onInit() {
    EasyLoading.dismiss();
    _getMachineInfo();
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

  //获取机器信息
  _getMachineInfo() async {
    // var machineCodeString = await HomeServices.getMachineInfo();
    // if (machineCodeString != "") {
    //machineCode.value = machineCodeString;
    //}
    machineCode.value = "X3V9YPJABVZGAELIZ9";
    //首页图片
    _getHomeImageList();
  }

  _getHomeImageList() async {
    // var homeimageList = await HomeServices.getSmartweHomeImagesData();

    // homeList.value = homeimageList;

    getSystemSettingInfo();
  }

  void openCashChange() async {
    debugPrint("  openCashChange  ");
    int? resultCode = await CashChanger.openCashChanger;
    debugPrint("open CashChanger resultCode:  " + resultCode.toString());

    Get.dialog(
        DialogUtils.alert(
            "open CashChanger resultCode:  " + resultCode.toString(),
            title: "CashChanger",
            canceltitle: "Sure", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void getPlatformVersion() async {
    debugPrint("  getPlatformVersion  ");
    String? version = await CashChanger.getPlatformVersion;
    debugPrint("windows version:" + version!);
    Get.dialog(
        DialogUtils.alert("windows version:" + version!,
            title: "CashChanger Error", canceltitle: "Sure", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void closeCashChange() async {
    debugPrint("  closeCashChange  ");
    int? resultCode = await CashChanger.closeCashChanger;
    debugPrint("close CashChanger resultCode:  " + resultCode.toString());
    Get.dialog(
        DialogUtils.alert(
            "close CashChanger resultCode:  " + resultCode.toString(),
            title: "CashChanger",
            canceltitle: "Sure", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    menu_direction.value = (SystemSettingInfo["menuDirection"] != "" &&
            SystemSettingInfo["menuDirection"] != null)
        ? SystemSettingInfo["menuDirection"]
        : "1";
    dining_type.value = (SystemSettingInfo["diningType"] != "" &&
            SystemSettingInfo["diningType"] != null)
        ? SystemSettingInfo["diningType"]
        : "1";

    getmenchineLanguages();
  }

  getmenchineLanguages() async {
    var languageJP = false;
    var languageCH = false;
    var languageEN = false;
    var languageKO = false;
    var menchineLanguagesData = await HomeServices.getMachineLanguages();
    for (var item in menchineLanguagesData) {
      if (item == "JP") {
        languageJP = true;
      } else if (item == "CH") {
        languageCH = true;
      } else if (item == "EN") {
        languageEN = true;
      } else if (item == "KO") {
        languageKO = true;
      }
    }

    machineLanguages_JP.value = languageJP;
    machineLanguages_CH.value = languageCH;
    machineLanguages_EN.value = languageEN;
    machineLanguages_KO.value = languageKO;

    update();
    change(null, status: RxStatus.success());
  }

  clearCartList() {
    ordersqlcontroller.removeAllFromCart();
  }
}
