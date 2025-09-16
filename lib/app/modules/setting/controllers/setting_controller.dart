import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../config/system_config.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../plugins/appset/lib/appset.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../../SelfCheckoutscanningcode/controllers/self_checkoutscanningcode_controller.dart';
import '../../SelfservicePage/controllers/selfservice_page_controller.dart';
import '../../TransitPage/controllers/transit_page_controller.dart';
import '../../menuPage/controllers/menu_page_controller.dart';
import '../views/RejishimeRequestView.dart';

class SettingController extends GetxController with StateMixin {
  //TODO: Implement SettingController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());
  //MenuPageController menuPagecontroller = Get.put(MenuPageController());
  CreatePrintImageController createPrintImageController =
      Get.put(CreatePrintImageController());
  AppConfig appConfig = Get.find<AppConfig>();
  RxString machineCode = "".obs;
  RxString shopCode = "".obs;
  RxString machine_mode = "1".obs; //1 普通点餐券卖机  2 精算机（结账机）
  RxString is_reimburse = "0".obs; //是否展示退款按钮， 0 不展示 1 展示
  RxBool isAllowRejishime = false.obs;

  RxList cashList = [].obs;
  RxMap cashInfoList = {}.obs;
  RxList lastTotalList = [].obs;
  RxMap depositData = {}.obs;
  RxList mailList = [].obs;

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

  _showEasyLoading() {
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
    _showEasyLoading();
    // String? logfile = "/mnt/sdcard/Android/data/comlib/log/COMLibLog.txt";
    // if (appConfig.isAndroid11)  {
    //   logfile = '/mnt/sdcard/Android/data/com.fanxing.foodorder/files/Comlib/COMLibLog.log';
    // }
    final logfile = await CustomLogHandler.exportLogs();

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
  //20241128PT3_OperationLog.log.zip
  //20241129PT3_OperationLog.log

  Future<String?> compressFiles() async {
    // 获取临时目录路径
    final tempDir = await getTemporaryDirectory();
    final logPathPrefix = '/mnt/sdcard/Android/data/com.fanxing.foodorder/files/Comlib/';
    final outputPath = '${tempDir.path}/${_getDate()}PT3Combined_logs.zip';
    // 创建一个ZipFileEncoder对象
    try {
      final zipEncoder = ZipFileEncoder();
      zipEncoder.create(outputPath);

      // 添加第一个文件（zip文件）
      final zipFile = File(logPathPrefix + '${_getYestodayDate()}PT3_OperationLog.log.zip');
      if (await zipFile.exists()) {
        zipEncoder.addFile(zipFile);
      }

      // 添加第二个文件（普通日志文件）
      final logFile = File(logPathPrefix + '${_getDate()}PT3_OperationLog.log');
      if (await logFile.exists()) {
        zipEncoder.addFile(logFile);
      }

      // 完成压缩
      zipEncoder.close();

      return outputPath;
    } catch (e) {
      showToast('上传失败! ${e.toString()}');
      return null;
    }



    print('Files compressed successfully. Output: $outputPath');
  }

  _getDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMdd').format(now);
    return formattedDate;
  }

  _getYestodayDate() {
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    String formattedDate = DateFormat('yyyyMMdd').format(yesterday);
    return formattedDate;
  }

  //获取版本号
  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version; //+"+"+packageInfo.buildNumber

    getSystemSettingInfo();
  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();
    machine_mode.value = SystemSettingInfo['machineMode'];
    isAllowRejishime.value = (SystemSettingInfo['isAllowRejishime'] ?? "0") == "1"  ? true : false;
    var reimburse = await HomeServices.getSmartweReimburseData();
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
    Get.toNamed('/receipt-query', arguments: {"machineCode": machineCode.value});
  }

  //获取现金机列表
  _getPaycubeChangeState({retryCount = 0}) {
    var formData = {
      "machineCode": machineCode.value,
    };
    request('webBootChangeState', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());

      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        depositData.value = response['data'];
        //cashList.value = response['data']['changeStates'];
        lastTotalList.value = response['data']['last7daysTotal'];

        update();
      } else {}
    }).catchError((error) {
      debugPrint("Error getting change state: $error");
      //
      if (retryCount < 3) {
        Future.delayed(Duration(seconds: 2), () {
          _getPaycubeChangeState(retryCount: retryCount + 1);
        });
      } else {
        //日文显示
        showToast('現金機の状態を取得できませんでした。');
        //change(null, status: RxStatus.error('获取现金机状态失败'));
        Get.back();
      }

    }).timeout(const Duration(seconds: 15), onTimeout: () {
      debugPrint("Timeout getting change state");
      //showToast('获取现金机状态超时');
      if (retryCount < 3) {
        Future.delayed(Duration(seconds: 2), () {
          _getPaycubeChangeState(retryCount: retryCount + 1);
        });
      } else {
        showToast('現金機の状態を取得できませんでした。');
        //change(null, status: RxStatus.error('获取现金机状态超时'));
        Get.back();
      }
    });

    _getChangeState();

    //print(_menuOption);
  }

  _getChangeState() {
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

  recycleCash() {
    var formData = {
      "machineCode": machineCode.value,
      "shopCode": shopCode.value,
    };
    request('webBootChangeReset', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());

      if (response != null && response['code'] == 200) {
        showToast('リサイクル成功');
        _getChangeState();
      } else {
        showToast('リサイクルに失敗しました');
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

  showRejishimeView({bool isNotCash = false}) async {
    Get.dialog(
        RejishiMeRequestView(machineCode: machineCode.value, isNotCash: isNotCash,)
    );
  }

  goToBack() {
    //Get.find<TransitPageController>().getIsShowCashInfo();
    if (machine_mode.value == "1") {
      if (Get.isRegistered<MenuPageController>()) {
        Get.find<MenuPageController>().clearCartList();
        //Get.delete<MenuPageController>();
      }// 手动删除控制器实例
    } else if (machine_mode.value == "2") {
      if (Get.isRegistered<CheckoutPageController>()) {
        //Get.delete<CheckoutPageController>(); // 手动删除控制器实例
      }
    } else if (machine_mode.value == "3") {
      //if (Get.isRegistered<SelfCheckoutscanningcodeController>())
      //Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例

      //if (Get.isRegistered<SelfservicePageController>())
      //Get.delete<SelfservicePageController>();
    }
    if (Get.isRegistered<SettingController>())
    Get.delete<SettingController>(); // 手动删除控制器实例
    FirebaseAnalytics.instance.logEvent(name: "setting_back",parameters: {
      "machineCode":machineCode.value,
    });
    //Future.delayed(Duration(milliseconds: 100), () {
      //Get.toNamed('/transit-page');
      Get.offNamedUntil('/transit-page', (route) => route.isFirst);
    //});
  }
}
