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

  RxBool machineLanguages_JP = false.obs;
  RxBool machineLanguages_CH = false.obs;
  RxBool machineLanguages_EN = false.obs;
  RxBool machineLanguages_KO = false.obs;

  String selectLanguage = 'JP';
  bool startShake = false;
  bool isAnimating = false;


  @override
  Future<void> onInit() async {
    EasyLoading.dismiss();
    await getmenchineLanguages();

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    startRepeatingAnimation();
  }

  @override
  void onClose() {
    super.onClose();
    stopRepeatingAnimation();
  }

  void startRepeatingAnimation() {
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
    isAnimating = false;
    startShake = false;
    update();
  }

  goMenu(String lan, bool mealType) {
    var jumpUrl = (machineInfo.menu_direction == "1") ? '/menu-page' :'/menuzong-page';
    startShake = false;
    Get.toNamed(jumpUrl,arguments: {
      "checkLanguage": lan,
      "mealType":mealType
    });
  }

  getmenchineLanguages() async {
    debugPrint("获取机器语言");
    var languageJP = false;
    var languageCH = false;
    var languageEN = false;
    var languageKO = false;
    var menchineLanguagesData = await HomeServices.getMachineLanguages();
    for (var item in menchineLanguagesData) {
      if(item == "JP"){
        languageJP = true;
      }else if(item == "CH"){
        languageCH = true;
      }else if(item == "EN"){
        languageEN = true;
      }else if(item == "KO"){
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
