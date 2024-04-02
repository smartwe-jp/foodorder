import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../controllers/order_sql_controller.dart';
import '../../../services/HomeServices.dart';

class OrderHomeController extends GetxController with StateMixin {
  //TODO: Implement OrderHomeController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());

  RxString machineCode = "".obs;

  RxString menu_direction = "1".obs;//1 默认顶部横向  2 左侧纵向
  RxString dining_type = "0".obs; //就餐类型选择 1店内 2外卖 3全可以

  RxBool machineLanguages_JP = false.obs;
  RxBool machineLanguages_CH = false.obs;
  RxBool machineLanguages_EN = false.obs;
  RxBool machineLanguages_KO = false.obs;

  RxList homeList = [].obs;

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

  //获取机器信息
  _getMachineInfo() async {
    debugPrint("获取机器信息");
    var machineCodeString = await HomeServices.getMachineInfo();
    if (machineCodeString != "") {
      machineCode.value = machineCodeString;

    }
    //首页图片
    await _getHomeImageList();
  }

  _getHomeImageList() async {
    debugPrint("获取首页图片");
    var homeimageList = await HomeServices.getSmartweHomeImagesData();

    homeList.value = homeimageList;

    await getSystemSettingInfo();

  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

      menu_direction.value = (SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1";
      dining_type.value = (SystemSettingInfo["diningType"] !="" && SystemSettingInfo["diningType"]!=null) ? SystemSettingInfo["diningType"] :"1";


    await getmenchineLanguages();

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

}
