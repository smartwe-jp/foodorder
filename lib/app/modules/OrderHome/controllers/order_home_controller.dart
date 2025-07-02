import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../controllers/machine_info.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../plugins/appset/lib/appset.dart';
import '../../../services/HomeServices.dart';

class OrderHomeController extends GetxController with StateMixin {
  //TODO: Implement OrderHomeController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());
  MachineInfoController machineInfo = Get.find();
  get printerList => machineInfo.printerList;
  get sseList => machineInfo.sseSettingList;

  bool machineLanguages_JP = false;
  bool machineLanguages_CH = false;
  bool machineLanguages_EN = false;
  bool machineLanguages_KO = false;

  String selectLanguage = 'JP';
  bool startShake = false;
  bool isAnimating = false;
  bool firstLoad = false;


  @override
  void onInit() async {
    debugPrint('OrderHomeController onInit');
    if (Get.arguments != null && Get.arguments.containsKey('initLaunch')) {
      firstLoad = Get.arguments['initLaunch'] ?? false;
    }

    EasyLoading.dismiss();
    getmenchineLanguages();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    startRepeatingAnimation();

    if (firstLoad) {

    }

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

  goMenu(String lan, bool mealType) {
    if (machineInfo.diningType == '2') {
      machineInfo.mealType = true;
    } else {
      machineInfo.mealType = mealType;
    }

    var jumpUrl = '/menu-page';
    startShake = false;
    Get.toNamed(jumpUrl,arguments: {
      "checkLanguage": lan,
    });
  }

  getmenchineLanguages() async {
    debugPrint("获取机器语言");

    machineLanguages_JP = machineInfo.supportLanguages.contains('JP');
    machineLanguages_CH = machineInfo.supportLanguages.contains('CH');
    machineLanguages_EN = machineInfo.supportLanguages.contains('EN');
    machineLanguages_KO = machineInfo.supportLanguages.contains('KO');
    debugPrint("获取机器语言结束");
    update();
    change(null, status: RxStatus.success());

  }

  clearCartList() {
    ordersqlcontroller.removeAllFromCart();
  }

  void updateSettingLanguage(String language) async {
    //await HomeServices.updateSettingLanguage(language);
    selectLanguage = language;
    var locale = Locale('${language.toLowerCase()}', '$language');
    Get.updateLocale(locale);
  }



}
