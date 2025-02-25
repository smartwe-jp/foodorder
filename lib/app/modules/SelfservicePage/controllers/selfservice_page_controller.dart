import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/machine_info_controller.dart';
import 'package:get/get.dart';

import '../../../controllers/order_sql_controller.dart';
import '../../../services/HomeServices.dart';

class SelfservicePageController extends GetxController with StateMixin {
  //TODO: Implement SelfservicePageController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());
  MachineInfoController machineInfo = Get.find();

  bool machineLanguages_JP = false;
  bool machineLanguages_CH = false;
  bool machineLanguages_EN = false;
  bool machineLanguages_KO = false;
  String selectLanguage = 'JP';
  bool startShake = false;
  bool isFirstPage = false;
  bool isAnimating = false;

  @override
  void onInit() {
    EasyLoading.dismiss();
    _getMachineLanguages();

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    startRepeatingAnimation();
  }

  @override
  void onClose() {
    //stopRepeatingAnimation();
    super.onClose();
  }


  void startRepeatingAnimation() {
    debugPrint('startRepeatingAnimation');
    isAnimating = true;
    Timer.periodic(Duration(milliseconds: 1200), (timer) {
      if (!isAnimating) {
        timer.cancel();
        return;
      }
      startShake = !startShake;
      update();
    });
  }

  void stopRepeatingAnimation() {
    debugPrint('stopRepeatingAnimation');
    isAnimating = false;
    startShake = false;
    update();
  }



  _getMachineLanguages() async {

    machineLanguages_JP = machineInfo.supportLanguages.contains('JP');
    machineLanguages_CH = machineInfo.supportLanguages.contains('CH');
    machineLanguages_EN = machineInfo.supportLanguages.contains('EN');
    machineLanguages_KO = machineInfo.supportLanguages.contains('KO');

    update();
    change(null, status: RxStatus.success());
  }

  goMenu(String lan, bool mealType) {
    machineInfo.mealType = mealType;
    var jumpUrl = '/menu-page';
    startShake = false;
    Get.toNamed(jumpUrl,arguments: {
      "checkLanguage": lan,
      "mealType":mealType
    });
  }

  goSelfCheckout() {
    Get.toNamed('/self-checkoutscanningcode',arguments: {
      "checkLanguage": selectLanguage,
      "mealType": machineInfo.mealType
    });
  }

  void updateSettingLanguage(String language) async {
    //await HomeServices.updateSettingLanguage(language);
    selectLanguage = language;
    var locale = Locale('${language.toLowerCase()}', '$language');
    Get.updateLocale(locale);
  }



}
