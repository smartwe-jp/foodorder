import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
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
import '../../SelfCheckoutscanningcode/controllers/self_checkoutscanningcode_controller.dart';
import '../../TransitPage/controllers/transit_page_controller.dart';
import '../../menuPage/controllers/menu_page_controller.dart';

class SettingController extends GetxController with StateMixin {
  //TODO: Implement SettingController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());
  MenuPageController menuPagecontroller = Get.put(MenuPageController());
  CreatePrintImageController createPrintImageController = Get.put(CreatePrintImageController());
  RxString machineCode = "".obs;
  RxString shopCode = "".obs;
  RxString machine_mode = "1".obs;//1 普通点餐券卖机  2 精算机（结账机）
  RxString is_reimburse = "0".obs;//是否展示退款按钮， 0 不展示 1 展示

  RxList cashList = [].obs;
  RxMap cashInfoList = {}.obs;
  RxList lastTotalList = [].obs;
  RxMap depositData = {}.obs;

  RxBool switchValue = false.obs;


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

  void toggleSwitch(bool value) {
    switchValue.value = value; // 更新值
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

    var reimburse= await HomeServices.getSmartweReimburseData();
    is_reimburse.value = reimburse;

    shopCode.value = await HomeServices.getShopCode();
    //查看机器零钱状态
    _getPaycubeChangeState();
  }

  printPreviewReceipt() async {
    _showEasyLoading();
    var formData = {
      "machineCode": machineCode.value,
    };
    request('webBootToRetryPrint', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      EasyLoading.dismiss();
      if (response['code'] == 200) {
        //createPrintImageController.tpPrintReceipt(response['data']);
        createPrintImageController.tpPrintnew(RxInt(1), response['data'], 1);
      } else {
        showToast('打印失败!');
      }
    });
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

    _getChangeState();

    //print(_menuOption);
  }

  _getChangeState() {
    var formData = {
      "machineCode": machineCode.value,
    };
    request('webBootChangeInfo', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200 && null != response['data']) {
        cashInfoList.value = response['data'];
        update();
      } else {}
      change(null, status: RxStatus.success());
    });

  }

  setCashSenOutset(type,number) {
    var formData = {
      "currencyInfoVo": {
        "catVal": _getCatVal(type),
        //"adjust": 0,
        "outset": number,
      },
      "fromDeposit": false,
      "machineCode": machineCode.value,
      "shopCode": shopCode.value,
    };
    request('webBootChangeSet', method: 'PUT', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response != null && response['code'] == 200) {
        showToast('设置成功');
        _getChangeState();
      } else {
        showToast('设置失败');
      }
    });
  }

  adjustCash(type, number) {
    var formData = {
      "currencyInfoVo": {
        "catVal": _getCatVal(type),
        "adjust": number,
        "outset": "",
      },
      "fromDeposit": false,
      "fromDepositCatVal": "",
      "fromDepositQty": "",
      "machineCode": machineCode.value,
      "shopCode": shopCode.value,
    };
    request('webBootChangeSet', method: 'PUT', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response != null && response['code'] == 200) {
        showToast('设置成功');
        _getChangeState();
      } else {
        showToast('设置失败');
      }
    });
  }

  adjustCashFromDeposit(type, number, depositCatVal, depositQty) {
    var formData = {
      "currencyInfoVo": {
        "catVal": _getCatVal(type),
        "adjust": number,
      },
      "fromDeposit": true,
      "fromDepositCatVal": _getDepositCatVal(depositCatVal),
      "fromDepositQty": depositQty,
      "machineCode": machineCode.value,
      "shopCode": shopCode.value,
    };
    request('webBootChangeSet', method: 'PUT', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response != null && response['code'] == 200) {
        showToast('设置成功');
        _getChangeState();
      } else {
        showToast('设置失败');
      }
    });
  }

  recycleCash() {
    var formData = {
      "machineCode": machineCode.value,
      "shopCode": shopCode.value,
    };
    request('webBootChangeReset', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response != null && response['code'] == 200) {
        showToast('回收成功');
        _getChangeState();
      } else {
        showToast('回收失败');
      }
    });
  }

  _getCatVal(type) {
    switch (type) {
      case "千円":
        return "97";
      case "五百円":
        return "A6";
      case "百円":
        return "A5";
      case "五十円":
        return "A4";
      case "十円":
        return "A3";
      case "五円":
        return "A2";
      case "一円":
        return "A1";
      default:
        return "";
    }
  }

  _getDepositCatVal(type) {
    switch (type) {
      case "一万円":
        return "8A";
      case "五千円":
        return "89";
      case "二千円":
        return "88";
      case "千円":
        return "87";
      case "五百円":
        return "66";
      case "百円":
        return "65";
      case "五十円":
        return "64";
      case "十円":
        return "63";
      case "五円":
        return "62";
      case "一円":
        return "61";
      default:
        return "";
    }
  }

  goToBack(){
    //Get.find<TransitPageController>().getIsShowCashInfo();
    if(machine_mode.value == "1"){
      menuPagecontroller.clearCartList();
      Get.delete<MenuPageController>(); // 手动删除控制器实例
    }else if(machine_mode.value == "2"){
      Get.delete<CheckoutPageController>(); // 手动删除控制器实例
    }else if(machine_mode.value == "3"){
      Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例
    }


    Future.delayed(Duration(milliseconds: 100), (){
      Get.toNamed('/transit-page');
    });
  }
}
