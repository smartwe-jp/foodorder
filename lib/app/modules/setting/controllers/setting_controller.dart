import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/rejishimei/view.dart';
import 'package:foodorder/app/modules/setting/controllers/exchange_controller_extension.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/modules/setting/views/ExchangeView.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeiPrintView.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:foodorder/app/services/Storage.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../config/imageData.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../plugins/appset/lib/appset.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../views/ReplanishView.dart';

class SettingController extends GetxController with StateMixin {
  //TODO: Implement SettingController
  OrderSqlController ordersqlcontroller = Get.find<OrderSqlController>();
  //MenuPageController menuPagecontroller = Get.put(MenuPageController());
  CreatePrintImageController createPrintImageController =
      Get.find<CreatePrintImageController>();
  AppConfig appConfig = Get.find<AppConfig>();
  MachineInfoController machineInfo = Get.find<MachineInfoController>();
  //RxString machineCode = "".obs;
  //RxString shopCode = "".obs;
  //RxString machine_mode = "1".obs; //1 普通点餐券卖机  2 精算机（结账机）
  //RxString is_reimburse = "0".obs; //是否展示退款按钮， 0 不展示 1 展示
  //RxBool isAllowRejishime = false.obs;
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
  //RxMap usbPrinter = {}.obs;
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
  var exchangeFromInfo = {};
  // Map printInfo = {};
  // double printLength = 2048;
  Timer? showCashTimer;
  final logger = Logger('SettingController');

  bool get isAllowRejishime => machineInfo.isAllowRejishime == '1' ? true : false;
  String get machineCode => machineInfo.machineCode;
  String get shopCode => machineInfo.shopCode;
  bool get is_reimburse => machineInfo.isAllowReimburse;
  Map get usbDevice => machineInfo.usbDevice;

  @override
  void onInit() {
    debugPrint("SettingController onInit");
    //machineCode.value = Get.arguments['machineCode'];
    checkLanguage.value = Get.locale?.languageCode.toUpperCase() ?? "JP";
    debugPrint("SettingController machineCode.value = ${machineCode}");
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
    debugPrint("---SettingController onClose---");
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
    if (Platform.isWindows) {
      logfile = await CustomLogHandler.exportLogs();
      //saveLogToD();

      //return;
// =======
//     _showEasyLoading();
//     String? logfile = "/mnt/sdcard/Android/data/comlib/log/COMLibLog.txt";
//     if (appConfig.isAndroid11)  {
//       logfile = '/mnt/sdcard/Android/data/com.fanxing.foodorder/files/Comlib/COMLibLog.log';
// >>>>>>> 2.7.0-dev
    }

    FormData formData = FormData.fromMap({
      "machineCode": machineCode,
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
    final logPathPrefix =
        '/mnt/sdcard/Android/data/com.fanxing.foodorder/files/Comlib/';
    final outputPath = '${tempDir.path}/${_getDate()}PT3Combined_logs.zip';

    // 创建一个ZipFileEncoder对象
    try {
      final zipEncoder = ZipFileEncoder();
      zipEncoder.create(outputPath);

      // 添加第一个文件（zip文件）
      final zipFile =
          File(logPathPrefix + '${_getYestodayDate()}PT3_OperationLog.log.zip');
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

  // Future<void> saveLogToD() async {
  //   String logfilePath = await CustomLogHandler.exportLogs();
  //   File sourceFile = File(logfilePath);

  //   // 获取文件名
  //   String fileName = sourceFile.path.split('/').last;

  //   // 创建目标文件路径
  //   String destinationPath = 'D:\\$fileName';

  //   try {
  //     // 复制文件
  //     await sourceFile.copy(destinationPath);
  //     print('日志文件已成功保存到: $destinationPath');
  //   } catch (e) {
  //     print('保存日志文件时出错: $e');
  //   }
  // }

  printRejishimei(printLength, data) async {
    print('printRejishimei:$printLength, data:$data');
    if (data.isEmpty) {
      EasyLoading.dismiss();
      Get.back();
      clearTask();
      commonHandleDialogs("レジ締め印刷失敗しました、再度印刷しましょうか？", confirm: () {
        printRejishimei(printLength, data);
      }, cancel: () {
        Get.back();
        clearTask();
        //showToast('完了しました');
      });
    } else {
      directPrintRejishimei(printLength, data);
    }
  }

  directPrintRejishimei(printLength, data) async {
    final printView = PrintView(isPrint: true, printInfo: data);

    final printWidget = Container(
      width: 385,
      height: printLength + 150,
      child: printView,
    );

    await sendToUsePrinter(printWidget);

    commonHandleDialog('完了しました', confirm: () {
      debugPrint('commonHandleDialog confirm');
      Get.back();
      Get.back();
      clearTask(syncCash: false);
      //Future.delayed(Duration(milliseconds: 500), () {
      gloryConfirmSync();
      //});
    });

    // await Future.delayed(Duration(seconds: 5), () {
    //   EasyLoading.dismiss();
    //   Get.back();
    //   clearTask();
    //   showToast('完了しました');
    // });
  }

  showRejishimeiView() async {
    hasOutMoney = false;
    // Get.dialog(RejishiMeRequestView(
    //   machineCode: machineCode.value,
    //   settingController: this,
    // ));

    Get.dialog(
        RejishimeView(
          settingController: this,
        ),
        arguments: {'machineCode': machineCode});
  }

  showRecycleAlert() {
    hasOutMoney = false;

    Get.dialog(
        RejishimeView(
          isRejishime: false,
          settingController: this,
        ),
        arguments: {'machineCode': machineCode});

    // Get.to(RejishimeView(
    //   machineCode: machineCode.value,
    //   isRejishime: false,
    // ));
    // Get.dialog(RecycleAlert(onConfirm: () {
    //   recycleCash(isRejishimei: false);
    //   Get.back();
    // }, onCancel: () {
    //   Get.back();
    // }));

    // Get.dialog(RejishiMeRequestView(
    //   machineCode: machineCode.value,
    //   recycleCash: (code, email) async {

    //     recycleCash(code, email);

    //   },
    //   settingController: this,
    // ));
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
    Get.dialog(
        barrierDismissible: false,
        Container(
            padding: EdgeInsets.only(top: 720),
            child: ReplanishView(controller: this)));
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

    //if (Platform.isWindows) {
    //local_version.value = await _getWindowsAppVersion();//该API windows 版本 需要等Flutter Stable 版本升级到3.3.0才能使用
    //  local_version.value = "2.6.0"; //当前每次打包需要手动修改版本号
    //} else {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version;
    //}
    //+"+"+packageInfo.buildNumber

    getSystemSettingInfo();
  }

  //获取系统版本信息
  // Future<String> _getWindowsAppVersion() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   String version = packageInfo.version;
  //   String buildNumber = packageInfo.buildNumber;
  //   local_version.value = packageInfo.version + " ${buildNumber}";
  //   return version;
  // }

  getSystemSettingInfo() async {
    //Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();
    //machine_mode.value = SystemSettingInfo['machineMode'];
    // isAllowRejishime.value =
    //     (SystemSettingInfo['isAllowRejishime'] ?? "0") == "1" ? true : false;
    //is_reimburse.value = await HomeServices.getSmartweReimburseData();
    //shopCode.value = await HomeServices.getShopCode();
    // usbPrinter.value = await HomeServices.getUsbPrintSettingInfo();
    // debugPrint("usbPrinter = ${usbPrinter}");
    //查看机器零钱状态
    await _getPaycubeChangeState();
  }

  printPreviewReceipt() async {
    showEasyLoading();
    var formData = {
      "machineCode": machineCode,
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
        arguments: {"machineCode": machineCode});
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
  _getPaycubeChangeState({retryCount = 0}) async {
    var formData = {
      "machineCode": machineCode,
    };
    request('webBootChangeState', method: 'POST', parameters: formData)
        .then((val) async {
      var response = json.decode(val.toString());
      debugPrint(
          "SettingController _getPaycubeChangeState response = ${response}");
      if (response != null &&
          response['code'] == 200 &&
          null != response['data']) {
        depositData.value = response['data'];
        //cashList.value = response['data']['changeStates'];
        lastTotalList.value = response['data']['last7daysTotal'];
        // final result = await getMachineCashInfo();
        // debugPrint('MachineCashInfo: $result');
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
    change(null, status: RxStatus.success());
    if (Platform.isAndroid) {
      await _getChangeState();
    } else {
      await getCashInfo();
    }

    //print(_menuOption);
  }

  _getChangeState() async {
    var formData = {
      "machineCode": machineCode,
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
      "machineCode": machineCode,
      "shopCode": shopCode,
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
      "machineCode": machineCode,
      "shopCode": shopCode,
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
      "machineCode": machineCode,
      "shopCode": shopCode,
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

  recycleCashOut(count, Function skipAction) async {
    debugPrint("recycleCashOut count = ${count}");
    var outResult = false;
    if (!hasOutMoney) outResult = await dispenseCashCount(count, skipAction);
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

  recycleCash(String verifyCode, String verifyEmail) async {
    if (Platform.isWindows) {
      showEasyLoading();
      if (!await gloryEmptyReport(verifyCode, verifyEmail)) {
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
            commonHandleDialog('回收しました');
            //showToast('回收成功');
          },
          onRetry: () {
            recycleCash(verifyCode, verifyEmail);
          },
          showError: (String error) {
            EasyLoading.dismiss();
            debugPrint("recycleCash error: $error.tr");
            //showToast('回收失败');
            commonHandleDialog("回收失败：$error.tr");
          });
    } else {
      var formData = {
        "machineCode": machineCode,
        "shopCode": shopCode,
      };
      request('webBootChangeReset', method: 'POST', parameters: formData)
          .then((val) async {
        var response = json.decode(val.toString());

        if (response != null && response['code'] == 200) {
          await _getPaycubeChangeState();
          commonHandleDialog('回收成功');
        } else {
          showToast('回收に失敗しました');
          commonHandleDialog("回收に失敗しました：${response['code']}");
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
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr, confirm: () {
          if (confirm != null) {
            confirm();
          } else {
            Get.back();
          }
        }));
  }

  commonHandleDialogs(String messgae,
      {required Function confirm, required Function cancel}) async {
    EasyLoading.dismiss();
    debugPrint("HandleDialog: $messgae");
    Get.dialog(
        barrierDismissible: false,
        DialogUtils.alert(
          messgae,
          title: "tag_title".tr,
          confirmtitle: "tag_button_yes".tr,
          confirm: () async {
            //Get.back();
            showEasyLoading();
            Future.delayed(Duration(seconds: 2), () {
              confirm();
            });
          },
          cancle: () {
            cancel();
          },
        ));
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

  getCashCountMaxVal(type) {
    switch (type) {
      case "一万円":
        return "100";
      case "五千円":
        return "100";
      case "二千円":
        return "200";
      case "千円":
        return "200";
      case "五百円":
        return "105";
      case "百円":
        return "160";
      case "五十円":
        return "120";
      case "十円":
        return "160";
      case "五円":
        return "120";
      case "一円":
        return "160";
      default:
        return "0";
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
    // if (machine_mode.value == "1") {
    //   // if (Get.isRegistered<MenuPageController>()) {
    //   //   Get.find<MenuPageController>().clearCartList();
    //   //   Get.delete<MenuPageController>();
    //   // } // 手动删除控制器实例
    // } else if (machine_mode.value == "2") {
    //   //if (Get.isRegistered<CheckoutPageController>()) {
    //     //Get.delete<CheckoutPageController>(); // 手动删除控制器实例
    //   //}
    // } else if (machine_mode.value == "3") {
    //   //if (Get.isRegistered<SelfCheckoutscanningcodeController>())
    //   //Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例

    //   //if (Get.isRegistered<SelfservicePageController>())
    //   //Get.delete<SelfservicePageController>();
    // }
    // if (Get.isRegistered<SettingController>()) {
    //   //Get.delete<SettingController>(); // 手动删除控制器实例
    // }
    //Future.delayed(Duration(milliseconds: 100), () {
    //Get.offAllNamed('/transit-page');
    //Get.toNamed('/transit-page');
    //Get.offNamedUntil('/transit-page', ModalRoute.withName('/home'));
    //Get.updateLocale(Locale('jp', 'JP'));
    // Get.offNamedUntil('/transit-page',
    //     (route) => route.isFirst); //, arguments: {'toView2': true}
    Get.back();
    //});
  }
}
