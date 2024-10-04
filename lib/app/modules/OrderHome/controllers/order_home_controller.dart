// import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
// import 'package:foodorder/app/config/string.dart';
// import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
// import 'package:foodorder/app/services/showToast.dart';
// import 'package:foodorder/app/widget/DialogUtils.dart';
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

  RxBool isLoading = true.obs;

  RxString settingLanguage = "JP".obs;

  RxList homeList = [].obs;
  RxList homeImages = [].obs;
  RxBool mealType = false.obs;
  int mealTypeStatus = 0;
  int resetTime = 3;
  Timer? resetTimer;

  @override
  Future<void> onInit() async {
    EasyLoading.dismiss();
    await _getMachineInfo();
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

  startResetTimer() async {
    debugPrint("startResetTimer");
    resetTimer?.cancel();
    resetTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      resetTime--;
      if (resetTime == 0) {
        resetTimer?.cancel();
        resetTime = 3;
        mealTypeStatus = 0;
        debugPrint("startResetTimer end");
        update();
      }
    });
  }

  //获取机器信息
  _getMachineInfo() async {
    debugPrint("获取机器信息");
    var machineCodeString = await HomeServices.getMachineInfo();
    if (machineCodeString != "") {
      machineCode.value = machineCodeString;
    }
    await _getSettingLanguage();
    //首页图片
    await _getHomeImageList();
  }

  _getHomeImageList() async {
    debugPrint("获取首页图片");
    var homeimageList = await HomeServices.getSmartweHomeImagesData();

    homeImages.value = homeimageList;
    await getSystemSettingInfo();
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
    await getmenchineLanguages();
  }

  updateDingType(int type) async {
    debugPrint("updateDingType $type");
    startResetTimer();
    mealTypeStatus = type;
    //dining_type.value = type;
    if (type == 2) {
      mealType.value = true;
    } else {
      mealType.value = false;
    }
    // Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    // debugPrint("SystemSettingInfo $systemSettingInfo");
    // systemSettingInfo["diningType"] = type;
    // debugPrint("SystemSettingInfo new $systemSettingInfo");
    // await HomeServices.updateSystemSettingInfo(systemSettingInfo);
    await getBookingBootIndexCagegory();
  }

  getmenchineLanguages() async {
    debugPrint("获取机器语言");
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
    debugPrint("获取机器语言结束");
    update();
    change(null, status: RxStatus.success());

    await getBookingBootIndexCagegory();
  }

  _getSettingLanguage() async {
    debugPrint("获取设置语言");
    var language = await HomeServices.getSettingLanguage();
    settingLanguage.value = language;
    debugPrint("获取设置语言done");
  }

  updateSettingLanguage(String language) async {
    await HomeServices.updateSettingLanguage(language);
    settingLanguage.value = language;
    var locale = Locale('${language.toLowerCase()}', '$language');
    Get.updateLocale(locale);
    //reload catagory...
    await getBookingBootIndexCagegory();
  }

  get showCatagory {
    if (homeList.length == 0) {
      debugPrint("homeList.length == 0");
      return [];
    }
    debugPrint("homeList.length > 0");

    var showItemCount = 9;
    if (dining_type.value == "3") {
      showItemCount = 6;
    }
    if (homeList.length >= showItemCount - 1) {
      // 获取前8个
      var newList = List.from(homeList.sublist(0, showItemCount - 1));
      newList.add({
        "categoryCode": homeList.first["categoryCode"],
        "image": null,
        "categoryName":
            GString.getToString(settingLanguage.value, "more_title"),
        "showType": "1"
      });
      return newList;
    } else {
      var newList = List.from(homeList);
      newList.add({
        "categoryCode": homeList.first["categoryCode"],
        "image": null,
        "categoryName":
            GString.getToString(settingLanguage.value, "more_title"),
        "showType": "1"
      });
      return newList;
    }
  }

  //获取页面分类
  getBookingBootIndexCagegory() async {
    debugPrint("获取页面分类");
    isLoading.value = true;
    homeList.value = [];
    var queryTakeout = "2";
    //queryTakeout 0外卖 1都可 2店内
    switch (dining_type.value) {
      case "1":
        queryTakeout = "2";
        break;
      case "2":
        queryTakeout = "0";
        break;
      case "3":
        if (mealType.value == true) {
          queryTakeout = "0";
        } else {
          queryTakeout = "2";
        }
        break;
      default:
        queryTakeout = "2";
    }
    var formData = {
      "machineCode": machineCode.value,
      "language": settingLanguage.value,
      "takeout": queryTakeout,
    };
    request('webBootIndexCategoryv2', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      //isLoading.value = false;
      if (response['code'] == 200) {
        List myList = response['data']['categoryVoList'];
        for (var i = 0; i < myList.length; i++) {
          //if(menuIndex >=5) menuIndex = 0;
          var categoryVoList = myList[i];
          //配置顶部菜单
          homeList.add({
            "categoryCode": categoryVoList['categoryCode'],
            "categoryName": categoryVoList['categoryName'],
            "showType": categoryVoList['showType'],
            "image": categoryVoList['image'],
            "color": categoryVoList['color'],
          });
        }
        update();
        isLoading.value = false;
      } else {
        //showToast(response['msg']);
        Get.dialog(DialogUtils.alertOneButton(response['msg'],
            title: GString.getToString(settingLanguage.value, "tag_title"),
            confirmtitle:
                GString.getToString(settingLanguage.value, "tag_button_yes"),
            confirm: () {
          getBookingBootIndexCagegory();
        }));
        Future.delayed(Duration(milliseconds: 2000), () {
          getBookingBootIndexCagegory();
        });

        //Get.back();
      }
    });
  }

  clearCartList() {
    ordersqlcontroller.removeAllFromCart();
  }
}
