import 'dart:convert';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:foodorder/app/modules/setting/controllers/exchange_controller_extension.dart';
import 'package:foodorder/app/modules/setting/views/ExchangeView.dart';
import 'package:foodorder/app/modules/setting/views/RecycleAlert.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeRequestView.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../../../config/imageData.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../plugins/appset/lib/appset.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../../SelfCheckoutscanningcode/controllers/self_checkoutscanningcode_controller.dart';
import '../../SelfservicePage/controllers/selfservice_page_controller.dart';
import '../../menuPage/controllers/menu_page_controller.dart';
import '../views/ReplanishView.dart';


class SettingController extends GetxController with StateMixin {
  //TODO: Implement SettingController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());
  //MenuPageController menuPagecontroller = Get.put(MenuPageController());
  CreatePrintImageController createPrintImageController =
      Get.put(CreatePrintImageController());
  RxString machineCode = "".obs;
  RxString shopCode = "".obs;
  RxString machine_mode = "1".obs; //1 普通点餐券卖机  2 精算机（结账机）
  RxString is_reimburse = "0".obs; //是否展示退款按钮， 0 不展示 1 展示
  RxBool isAllowRejishime = false.obs;
  RxString checkLanguage = "JP".obs;

  RxList cashList = [].obs;
  RxMap cashInfoList = {}.obs;
  RxList lastTotalList = [].obs;
  RxMap depositData = {}.obs;
  RxList mailList = [].obs;

  RxBool switchValue = false.obs;
  RxBool ignoreNotify = false.obs;

  RxString local_version = "".obs; //本appversion
  RxMap usbPrinter = {}.obs;
  RxString getPutMoneyCurrency = "".obs;
  RxMap getPutMoneyMap = {}.obs;
  RxInt getPutMoney = 0.obs;
  RxBool isStartPutMoney = false.obs;
  RxList moneyList = [].obs;
  RxMap cashInfo = {}.obs;

  var progressValue = 0.0;

  @override
  void onInit() {
    debugPrint("SettingController onInit");
    machineCode.value = Get.arguments['machineCode'];
    checkLanguage.value = Get.locale?.languageCode.toUpperCase() ?? "JP";
    debugPrint("SettingController machineCode.value = ${machineCode.value}");
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

  showEasyLoading() {
    //var _showTag;
    // _showTag = Text("Uploading……",
    //     style: TextStyle(
    //       fontSize: ScreenAdapter.fontSize(25),
    //       fontFamily: GFont.getFontFamily(),
    //       fontWeight: FontWeight.w600,
    //       color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
    //     ));
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //_showTag,
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(
                  GImage.getImageString("imgpublic", "printticketloading"),
                  fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  //上传现金机log
  uploadErrorLog() async {
    showEasyLoading();
    var logfile = "/mnt/sdcard/Android/data/comlib/log/COMLibLog.txt";

    FormData formData = FormData.fromMap({
      "machineCode": machineCode.value,
      "file": await MultipartFile.fromFile(logfile),
    });

    request('webBootLogUpload', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();
      if (response["code"] == 200) {
        showToast('上传成功~~');
      } else {
        showToast('上传失败!');
      }
    });
  }

  showRejishimeiView() async {
    Get.dialog(RejishiMeRequestView(
      machineCode: machineCode.value,
      resetCash: () {
        recycleCash();
      },
      usbDevice: usbPrinter.value
    ));
  }

  showRecycleAlert() {
    Get.dialog(RecycleAlert(onConfirm: () {
      recycleCash();
      Get.back();
    }, onCancel: () {
      Get.back();
    }));
  }

  showReplenishAlert() {
    Get.dialog(
      barrierDismissible: false,
      ReplanishView()
    );
  }

  showExchangeAlert() async {
    Get.dialog(
      barrierDismissible: false,
      Exchangeview()
    );
    //await Future.delayed(Duration(milliseconds: 800), () {
       
    //});
  }

  //获取版本号
  _getPackageInfo() async {
    debugPrint("SettingController _getPackageInfo");
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // local_version.value = packageInfo.version;//+"+"+packageInfo.buildNumber
    local_version.value = await _getWindowsAppVersion();
    debugPrint(
        "SettingController local_version.value = ${local_version.value}");
    getSystemSettingInfo();
    getCashInfo();
  }

  //获取系统版本信息
  Future<String> _getWindowsAppVersion() async {
    // debugPrint("SettingController _getWindowsAppVersion");
    // var file = File('../../../../../pubspec.yaml');
    // var contents = await file.readAsString();
    // var yaml = loadYaml(contents);
    // var version = yaml['version'];
    // print('Version: $version');
    // return version;
    return "2.4.0";
  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();
    machine_mode.value = SystemSettingInfo['machineMode'];
    isAllowRejishime.value =
        (SystemSettingInfo['isAllowRejishime'] ?? "0") == "1" ? true : false;
    var reimburse = await HomeServices.getSmartweReimburseData();
    is_reimburse.value = reimburse;
    shopCode.value = await HomeServices.getShopCode();
    usbPrinter.value = await HomeServices.getUsbPrintSettingInfo();
    debugPrint("usbPrinter = ${usbPrinter}");
    //查看机器零钱状态
    _getPaycubeChangeState();
  }

  printPreviewReceipt() async {
    showEasyLoading();
    var formData = {
      "machineCode": machineCode.value,
    };
    request('webBootToRetryPrint', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      debugPrint("response:" + response.toString());

      EasyLoading.dismiss();
      if (response['code'] == 200 && null != response['data']) {
        //createPrintImageController.tpPrintReceipt(response['data']);
        createPrintImageController.tpPrintnew(RxInt(1), response['data'], 1);
      } else {
        //showToast('打印失败!');
        Get.dialog(
            DialogUtils.alertOneButton("最近のご注文はキャンセルされており、領収書は発行できません。",
                title: "ご注意", confirmtitle: "はい", confirm: () {
              Get.back();
              update();
            }),
            barrierDismissible: false);
      }
    });
    Get.toNamed('/receipt-query',
        arguments: {"machineCode": machineCode.value});
  }

  //获取现金机列表
  _getPaycubeChangeState() {
    var formData = {
      "machineCode": machineCode.value,
    };
    request('webBootChangeState', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      debugPrint(
          "SettingController _getPaycubeChangeState response = ${response}");
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        depositData.value = response['data'];
        cashList.value = response['data']['changeStates'];
        lastTotalList.value = response['data']['last7daysTotal'];

        update();
      } else {}
    });

    _getChangeState();

    //print(_menuOption);
  }

  _getChangeState() async {
    var formData = {
      "machineCode": machineCode.value,
    };
    request('webBootChangeInfo', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());

      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        cashInfoList.value = response['data'];
        debugPrint("cashInfoList.value:" + cashInfoList.value.toString());
        update();
      } else {
        showToast('获取失败');
      }
      change(null, status: RxStatus.success());
    });
  }

  setCashSenOutset(type, number) {
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
    request('webBootChangeSet', method: 'PUT', parameters: formData)
        .then((val) {
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
    request('webBootChangeSet', method: 'PUT', parameters: formData)
        .then((val) {
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
    request('webBootChangeSet', method: 'PUT', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());

      if (response != null && response['code'] == 200) {
        showToast('设置成功');
        _getChangeState();
      } else {
        showToast('设置失败');
      }
    });
  }

  recycleCash() async {
    if (Platform.isWindows) {
      final result = await CashChanger.collectAll();
      await CashChanger.changerResultNext(
          resultCode: result,
          onSuccess: () async {
            debugPrint("recycleCash onSuccess");
            //showToast('回收成功');
          },
          onRetry: () {
            recycleCash();
          },
          showError: (String error) {
            debugPrint("recycleCash error: $error");
            //showToast('回收失败');
            commonHandleDialog("回收失败：$error");
          });
    }

    var formData = {
      "machineCode": machineCode.value,
      "shopCode": shopCode.value,
    };
    request('webBootChangeReset', method: 'POST', parameters: formData)
        .then((val) async {
      var response = json.decode(val.toString());

      if (response != null && response['code'] == 200) {
        await _getChangeState();
        commonHandleDialog('リサイクル成功');
      } else {
        showToast('リサイクルに失敗しました');
        commonHandleDialog("リサイクルに失敗しました：${response['code']}");
      }
    });
  }

  commonHandleDialog(String error) {
    EasyLoading.dismiss();
    debugPrint("errorHandleDialog: $error");
    Get.dialog(DialogUtils.alertOneButton(error,
        title: GString.getToString("JP", "tag_title"),
        confirmtitle: GString.getToString("JP", "tag_button_yes"), confirm: () {
      Get.back();
    }));
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

  goToBack() {
    //Get.find<TransitPageController>().getIsShowCashInfo();
    if (machine_mode.value == "1") {
      if (Get.isRegistered<MenuPageController>()) {
        Get.find<MenuPageController>().clearCartList();
        Get.delete<MenuPageController>();
      } // 手动删除控制器实例
    } else if (machine_mode.value == "2") {
      if (Get.isRegistered<CheckoutPageController>()) {
        Get.delete<CheckoutPageController>(); // 手动删除控制器实例
      }
    } else if (machine_mode.value == "3") {
      if (Get.isRegistered<SelfCheckoutscanningcodeController>())
        Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例

      if (Get.isRegistered<SelfservicePageController>())
        Get.delete<SelfservicePageController>();
    }
    if (Get.isRegistered<SettingController>())
      Get.delete<SettingController>(); // 手动删除控制器实例
    if (Platform.isAndroid) {
      FirebaseAnalytics.instance.logEvent(name: "setting_back", parameters: {
        "machineCode": machineCode.value,
      });
    }
    //Future.delayed(Duration(milliseconds: 100), () {
    Get.toNamed('/transit-page');
    //});
  }
}
