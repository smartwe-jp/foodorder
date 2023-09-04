import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../controllers/order_sql_controller.dart';
import '../../../services/HomeServices.dart';

class SelfservicePageController extends GetxController with StateMixin {
  //TODO: Implement SelfservicePageController
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
    var machineCodeString = await HomeServices.getMachineInfo();
    if (machineCodeString != "") {
      machineCode.value = machineCodeString;

    }
    //首页图片
    _getHomeImageList();
  }

  _getHomeImageList() async {
    var homeimageList = await HomeServices.getSmartweHomeImagesData();

    homeList.value = homeimageList;

    getSystemSettingInfo();

  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    menu_direction.value = (SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1";
    dining_type.value = (SystemSettingInfo["diningType"] !="" && SystemSettingInfo["diningType"]!=null) ? SystemSettingInfo["diningType"] :"1";


    getmenchineLanguages();

  }

  getmenchineLanguages() async {
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

    update();
    change(null, status: RxStatus.success());

  }



}
