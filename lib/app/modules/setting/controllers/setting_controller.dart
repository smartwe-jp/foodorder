import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide Response,FormData,MultipartFile;
import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../plugins/appset/lib/appset.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../../TransitPage/controllers/transit_page_controller.dart';
import '../../menuPage/controllers/menu_page_controller.dart';

class SettingController extends GetxController with StateMixin {
  //TODO: Implement SettingController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());
  MenuPageController menuPagecontroller = Get.put(MenuPageController());
  RxString machineCode = "".obs;
  RxString machine_mode = "1".obs;//1 普通点餐券卖机  2 精算机（结账机）

  RxList cashList = [].obs;
  RxList lastTotalList = [].obs;
  RxMap depositData = {}.obs;

  RxString local_version = "".obs; //本appversion
  var progressValue = 0.0;

  @override
  void onInit() {
    machineCode.value = Get.arguments['machineCode'];
    _getPackageInfo();


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

  //显示状态栏导航栏
  showBullyScreen() async {
    await Appset.showBullyScreen;
  }

  _showEasyLoading(){
    var _showTag;
    _showTag = Text("Uploading……",
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  //上传现金机log
  uploadErrorLog() async {
    _showEasyLoading();
    var logfile="/mnt/sdcard/Android/data/comlib/log/COMLibLog.txt";

    FormData formData = FormData.fromMap({
      "machineCode": machineCode.value,
      "file": await MultipartFile.fromFile(logfile),
    });

    request(
        'webBootLogUpload',
        method: 'POST',
        parameters: formData
    ).then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();
      if (response["code"] == 200) {

        showToast('上传成功~~');
      } else {
        showToast('上传失败!');
      }
    });


  }

  //获取版本号
  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version;//+"+"+packageInfo.buildNumber

    getSystemSettingInfo();
  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();
    machine_mode.value = SystemSettingInfo['machineMode'];
    //查看机器零钱状态
    _getPaycubeChangeState();
  }

  //获取现金机列表
  _getPaycubeChangeState() {
    var formData = {
      "machineCode": machineCode.value,
    };
    request('webBootChangeState', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200 && null != response['data']) {
        depositData.value = response['data'];
        cashList.value = response['data']['changeStates'];
        lastTotalList.value = response['data']['last7daysTotal'];

        update();
      } else {}
    });


    change(null, status: RxStatus.success());
    //print(_menuOption);
  }

  goToBack(){
    //Get.find<TransitPageController>().getIsShowCashInfo();
    if(machine_mode.value == "1"){
      menuPagecontroller.clearCartList();
      Get.delete<MenuPageController>(); // 手动删除控制器实例
    }else if(machine_mode.value == "1"){
      Get.delete<CheckoutPageController>(); // 手动删除控制器实例
    }


    Future.delayed(Duration(milliseconds: 100), (){
      Get.toNamed('/transit-page');
    });
  }
}
