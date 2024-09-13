import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:foodorder/app/modules/setting/controllers/exchange_controller_extension.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/modules/setting/views/ExchangeView.dart';
import 'package:foodorder/app/modules/setting/views/RecycleAlert.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeRequestView.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeiPrintView.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/services/Storage.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart';
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
  RxBool showSignOut = false.obs;

  RxString local_version = "".obs; //本appversion
  RxMap usbPrinter = {}.obs;
  RxString getPutMoneyCurrency = "".obs;
  RxString getOutMoneyCurrency = "".obs;
  RxInt getPutMoney = 0.obs;
  RxBool isStartPutMoney = false.obs;
  RxMap cashInfo = {}.obs;
  RxMap supplyInfo = {}.obs;

  var progressValue = 0.0;
  var hasExchangeCash = false;
  var hasOutMoney = false;
  var taskTouch = false;
  Timer? showCashTimer;

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

  showEasyLoading({content}) {
    var _showTag;
    _showTag = Text("$content",
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontFamily: GFont.getFontFamily(),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));
    EasyLoading.show(
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (content != null) _showTag,
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  void updateSupplyInfo(Map<String, int> newValues, String field) {
    newValues.forEach((key, value) {
      if (supplyInfo.containsKey(key)) {
        supplyInfo[key][field] = value;
        supplyInfo[key]['remain'] =
            supplyInfo[key]['origin'] + supplyInfo[key]['supply'];
      }
    });
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

  printRejishimei(length, data) async {
    final printWidget = Container(
      width: 385,
      height: length + 150,
      child: PrintView(isPrint: true, printInfo: data),
    );
    await sendToUsePrinter(printWidget);
    await Future.delayed(Duration(seconds: 3));
    EasyLoading.dismiss();
    Get.back();
    clearTask();
    showToast('完了しました');
  }

  showRejishimeiView() async {
    // final catValMap = cashInfoList.map((key, value) {
    //   return MapEntry(getCatVal(key), value);
    // });
    String cashInfo = await getMachineCashInfo();

    hasOutMoney = false;
    Get.dialog(RejishiMeRequestView(
        machineCode: machineCode.value,
        resetCash: (length, data) async {
          await printRejishimei(length, data);
        },
        recycleCash: (p0) async {
          debugPrint("recycleCashOut p0 = ${p0}");
          Map result = await recycleCashOut(p0);
          //debugPrint("recycleCashOut result = ${result}");

          return result;
        },
        usbDevice: usbPrinter.value));
  }

  showRecycleAlert() {
    hasOutMoney = false;
    Get.dialog(RecycleAlert(onConfirm: () {
      recycleCash(isRejishimei: false);
      Get.back();
    }, onCancel: () {
      Get.back();
    }));
  }

  showReplenishAlert() {
    hasOutMoney = false;
    isStartPutMoney.value = false;
    supplyInfo.value = cashInfoList.map((key, value) {
      return MapEntry(key, {
        "origin": value,
        "supply": 0,
        "remain": 0,
      });
    });
    Get.dialog(barrierDismissible: false, ReplanishView(controller: this));
  }

  signoutAlert() async {
    debugPrint("SettingController signoutAlert");
    //确定要退出吗？
    Get.dialog(DialogUtils.alert("サインアウトしてもよろしいですか?", confirm: () async {
      await ordersqlcontroller.removeAllFromCart();
      await Storage.clearAll();
      if (Platform.isAndroid) {
        await showBullyScreen();
      }
      sleep(Duration(milliseconds: 1500));
      //Get.back();
      //退出关闭
      exit(0);
    }, cancle: () {
      Get.back();
    }));
  }

  showExchangeAlert() async {
    isStartPutMoney.value = false;
    Get.dialog(barrierDismissible: false, Exchangeview(controller: this));
  }

  //获取版本号
  _getPackageInfo() async {
    debugPrint("SettingController _getPackageInfo");

    if (Platform.isWindows) {
      //local_version.value = await _getWindowsAppVersion();//该API windows 版本 需要等Flutter Stable 版本升级到3.3.0才能使用
      local_version.value = "2.6.0"; //当前每次打包需要手动修改版本号
    } else {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      local_version.value = packageInfo.version;
    }
    //+"+"+packageInfo.buildNumber

    getSystemSettingInfo();
  }

  //获取系统版本信息
  Future<String> _getWindowsAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    local_version.value = packageInfo.version + " ${buildNumber}";
    return version;
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
    await getPaycubeChangeState();
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

  getMachineCashInfo() async {
    var cashInfo = "";
    await CashChanger.getCashBalance(onSuccess: (value) {
      cashInfo = value;
    }, catchError: (error) {
      errorHandleDialog(GString.getToString(checkLanguage.value, error));
    });
    debugPrint('machine cashInfo: $cashInfo');
    return cashInfo;
  }

  String findChange(String cashStatus, int changeCount) {
    // 将字符串转换为Map
    Map<int, int> coins = Map.fromEntries(
      cashStatus.split(',').map((item) {
        List<String> parts = item.split(':');
        return MapEntry(int.parse(parts[0]), int.parse(parts[1]));
      }),
    );

    // 按面额从大到小排序
    List<int> denominations = coins.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    Map<int, int> change = {};

    for (int denomination in denominations) {
      int count = coins[denomination]!;
      while (count > 0 && changeCount >= denomination) {
        change[denomination] = (change[denomination] ?? 0) + 1;
        changeCount -= denomination;
        count--;
      }
      if (changeCount == 0) break;
    }

    if (changeCount > 0) {
      return "";
    }

    // 将结果转换为字符串
    return change.entries.map((e) => "${e.key}:${e.value}").join(',');
  }

  //获取现金机列表
  getPaycubeChangeState() async {
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
      } else {
        debugPrint("SettingController _getPaycubeChangeState 获取失败");
      }
    });

    if (Platform.isAndroid) {
      await _getChangeState();
    } else {
      await getServerCashInfo();
    }
    change(null, status: RxStatus.success());
    //print(_menuOption);
  }

  _getChangeState() async {
    var formData = {
      "machineCode": machineCode.value,
    };
    await request('webBootChangeInfo', method: 'POST', parameters: formData)
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

  recycleCashOut(count) async {
    debugPrint("recycleCashOut count = ${count}");
    var outResult = false;
    if (!hasOutMoney) outResult = await dispenseCashCount(count);
    debugPrint("recycleCashOut result = ${outResult}");
    if (!outResult && !hasOutMoney) {
      return null;
    }
    hasOutMoney = true;
    bool result2 = await getInAndOutMoney();
    debugPrint("recycleCashOut result2 = ${result2}");
    if (result2) {
      return uploadOutMoneyInfo;
    }
    return null;
  }

  recycleCash({isRejishimei = true}) async {
    if (Platform.isWindows) {
      if (isRejishimei) {
        //clearTask();
        //commonHandleDialog('完了しました');
      } else {
        showEasyLoading();
        if (!await gloryEmptyReport()) {
          //commonHandleDialog("回收失败：Glory机器未清空");
          EasyLoading.dismiss();
          return;
        }
        final result = await CashChanger.collectAll(); //该步骤失败如何处理
        await CashChanger.changerResultNext(
            resultCode: result,
            onSuccess: () async {
              debugPrint("recycleCash onSuccess");
              EasyLoading.dismiss();
              await clearTask();
              commonHandleDialog('リサイクルしました');
              //showToast('回收成功');
            },
            onRetry: () {
              recycleCash();
            },
            showError: (String error) {
              EasyLoading.dismiss();
              debugPrint("recycleCash error: $error");
              //showToast('回收失败');
              commonHandleDialog("回收失败：$error");
            });
      }
    } else {
      var formData = {
        "machineCode": machineCode.value,
        "shopCode": shopCode.value,
      };
      request('webBootChangeReset', method: 'POST', parameters: formData)
          .then((val) async {
        var response = json.decode(val.toString());

        if (response != null && response['code'] == 200) {
          await getPaycubeChangeState();
          commonHandleDialog('リサイクル成功');
        } else {
          showToast('リサイクルに失敗しました');
          commonHandleDialog("リサイクルに失敗しました：${response['code']}");
        }
      });
    }
  }

  commonHandleDialog(String error, {Function? confirm}) {
    EasyLoading.dismiss();
    debugPrint("errorHandleDialog: $error");
    Get.dialog(
        barrierDismissible: false,
        DialogUtils.alertOneButton(error,
            title: GString.getToString("JP", "tag_title"),
            confirmtitle: GString.getToString("JP", "tag_button_yes"),
            confirm: () {
          if (confirm != null) {
            confirm();
          } else {
            Get.back();
          }
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

  catValFromInt(type) {
    switch (type) {
      case "10000":
        return "8A";
      case "5000":
        return "89";
      case "2000":
        return "88";
      case "1000":
        return "87";
      case "500":
        return "66";
      case "100":
        return "65";
      case "50":
        return "64";
      case "10":
        return "63";
      case "5":
        return "62";
      case "1":
        return "61";
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

  //根据数值获取钱币显示名称
  String getCashName(String value) {
    switch (value) {
      case '1':
        return '一円';
      case '5':
        return '五円';
      case '10':
        return '十円';
      case '50':
        return '五十円';
      case '100':
        return '百円';
      case '500':
        return '五百円';
      case '1000':
        return '千円';
      case '2000':
        return '二千円';
      case '5000':
        return '五千円';
      case '10000':
        return '一万円';
      default:
        return '';
    }
  }

  //根据显示名称获取数值
  String getCatVal(String value) {
    switch (value) {
      case '一円':
        return '1';
      case '五円':
        return '5';
      case '十円':
        return '10';
      case '五十円':
        return '50';
      case '百円':
        return '100';
      case '五百円':
        return '500';
      case '千円':
        return '1000';
      case '二千円':
        return '2000';
      case '五千円':
        return '5000';
      case '一万円':
        return '10000';
      default:
        return '';
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
