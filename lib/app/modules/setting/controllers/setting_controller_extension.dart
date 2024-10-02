import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/setting/controllers/exchange_controller_extension.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:android_usb_printer/android_usb_printer.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/modules/settlement/views/receipt_constrained_box.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/cashMoneyParser.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

extension SettingControllerExtension on SettingController {
  startPutMoney() async {
    debugPrint("startPutMoney");
    taskTouch = false;
    ignoreNotify.value = false;
    isStartPutMoney.value = true;

    await _startSupply();
  }

  _startSupply() async {
    debugPrint("startSupply");
    final resultCode = await CashChanger.startSupply;
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("startSupply 1");
          checkChangerStatus();
          //_getInputMoney();
        },
        onRetry: () {
          debugPrint("startSupply 2");
          _startSupply();
        },
        showError: (String error) {
          debugPrint("startSupply error: $error");
          errorHandleDialog(GString.getToString(checkLanguage.value, error));
        });
  }

  _supplyCounts() async {
    debugPrint("supplyCounts");
    await CashChanger.supplyCounts(
      0x00,
      onSuccess: (value) {
        //获取=号与;号之间的数据
        final supplyString = value.split('=')[1];
        //再截取;号与;号之间的数据
        final supplyStringList = supplyString.split(';');

        List<String> allPairs = [];
        for (var part in supplyStringList) {
          allPairs.addAll(part.split(','));
        }

        getPutMoneyCurrency.value = allPairs.join(',');
        debugPrint("getPutMoneyCurrency==${getPutMoneyCurrency.value}");
        update();
      },
      catchError: (error) {
        errorHandleDialog(GString.getToString(checkLanguage.value, error));
      },
    );
  }

  supplyCountsClear() async {
    debugPrint("_supplyCountsClear");

    return await CashChanger.supplyCounts(
      0x01,
      onSuccess: (value) {},
      catchError: (error) {
        errorHandleDialog(GString.getToString(checkLanguage.value, error));
      },
    );
  }

  checkChangerStatus() async {
    debugPrint("checkChangerStatus 1");
    var resultCode = await CashChanger.checkChangerStatus;
    if (resultCode == null) {
      debugPrint("Unknown error");
      checkChangerStatus();
      return;
    }
    debugPrint("checkChangerStatus resultCode:  " + resultCode.toString());
    if (resultCode == 0) {
      resultCode = 100;
    }
    HealthResultCode resultCodeEnum = HealthResultCode.values[resultCode - 100];
    switch (resultCodeEnum) {
      case HealthResultCode.OPOS_SUCCESS:
      case HealthResultCode.OPOS_E_ILLEGAL:
        _getInputMoney();
        break;
      case HealthResultCode.OPOS_E_CLOSED:
      case HealthResultCode.OPOS_E_NOTCLAIMED:
      case HealthResultCode.OPOS_E_DISABLED:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
      case HealthResultCode.OPOS_E_BUSY:
        sleep(Duration(seconds: 5));
        checkChangerStatus();
        break;
      case HealthResultCode.OPOS_E_NOHARDWARE:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
      default:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
    }
  }

  //获取投入金额
  _getInputMoney() async {
    final result = await supplyCountsClear();
    if (!result) return;

    await CashChanger.setEventsListener();
    debugPrint("getPutInMoney");
    CashChanger.onGetPutMoneyStringChange = (int result) {
      debugPrint("onGetPutMoneyStringChange");
      if (ignoreNotify.value) {
        return;
      }
      if (result > 0) {
        debugPrint("getPutMoney.value==${result.toString()}");
        getPutMoney.value = result;
        showCashTimer?.cancel();
        if (taskTouch) {
          taskTouch = false;
          EasyLoading.dismiss();
        }
        //update();
        //_getInputMoneyInfo();
        _supplyCounts();
      }
    };
  }

  getInputMoneyInfo() async {
    debugPrint("_getInputMoneyInfo");
    String? currencyCoinStringresult = await CashChanger.changerDIStatus(
        0x04); //'0000010000000000000000000000000010000000000000000000000000000000';
    //await CashChanger.changerDIStatus(0x04);
    debugPrint("currencyCoinStringresult==${currencyCoinStringresult}");

    String? currencyCashStringresult = await CashChanger.changerDIStatus(
        0x82); //'0000000000000000000000000000000000000000000000000000000000000000';
    //await CashChanger.changerDIStatus(0x82);
    debugPrint("currencyCashStringresult==${currencyCashStringresult}");

    var putMoneyCurrency = "";

    if (currencyCoinStringresult != null &&
        currencyCoinStringresult.length > 36) {
      putMoneyCurrency = currencyCoinStringresult.substring(0, 18); //入金
    }

    if (currencyCashStringresult != null &&
        currencyCashStringresult.length > 24) {
      putMoneyCurrency += currencyCashStringresult.substring(0, 12);
    }

    getPutMoneyCurrency.value =
        MoneyParser.migrationGloryToIntString(putMoneyCurrency);

    update();
  }

  getInAndOutMoney() async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00

    debugPrint("_getPayCubeOutMoney");
    //获取硬币入金出金币种
    String? currencyCoinStringresult = await CashChanger.changerDIStatus(0x04);
    debugPrint("currencyCoinStringresult==${currencyCoinStringresult}");

    String? currencyCashStringresult = await CashChanger.changerDIStatus(0x82);
    debugPrint("currencyCashStringresult==${currencyCashStringresult}");

    var putMoneyCurrency = "";
    var currency = "";

    if (currencyCoinStringresult != null &&
        currencyCoinStringresult.length > 36) {
      putMoneyCurrency = currencyCoinStringresult.substring(0, 18); //入金
      currency = currencyCoinStringresult.substring(18, 36); //出金
    }

    if (currencyCashStringresult != null &&
        currencyCashStringresult.length > 24) {
      putMoneyCurrency += currencyCashStringresult.substring(0, 12);
      currency += currencyCashStringresult.substring(12, 24);
    }

    getPutMoneyCurrency.value =
        MoneyParser.migrationGloryToIntString(putMoneyCurrency);
    getOutMoneyCurrency.value = MoneyParser.migrationGloryToIntString(currency);

    return true;
  }

  Future<bool> closeDeposit() async {
    debugPrint("closeDeposit");
    //await Future.delayed(Duration(seconds: 1));
    bool success = false;
    final depositAmount = await CashChanger.fixDeposit;
    debugPrint("fixDeposit: $depositAmount");
    final resultCode =
        await CashChanger.endDeposit(DepositAction.noChange.index);
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("closeDeposit 1");
          success = true;
        },
        onRetry: () {
          debugPrint("closeDeposit 2");
          closeDeposit();
        },
        showError: (String error) {
          debugPrint("closeDeposit error: $error");
          success = false;
          errorHandleDialog(GString.getToString(checkLanguage.value, error));
        });
    return success;
  }

  cancelTimer({shouldBack = true}) async {
    if (taskTouch) return;
    taskTouch = true;
    showEasyLoading(content: 'お待ち下さい');

    var seconds = 5;
    showCashTimer?.cancel();
    showCashTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      seconds--;
      if (seconds == 0) {
        showCashTimer?.cancel();
        cancelReplanish(shouldBack: shouldBack);
      }
    });
  }

  confirmTimer(printView) async {
    if (taskTouch) return;
    taskTouch = true;
    showEasyLoading(content: 'お待ち下さい');

    var seconds = 5;
    showCashTimer?.cancel();
    showCashTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      seconds--;
      if (seconds == 0) {
        showCashTimer?.cancel();
        reportReplanishInfo(printView);
      }
    });
  }

  cancelReplanish({shouldBack = true}) async {
    debugPrint("cancelReplanish");

    ignoreNotify.value = true;
    if (getPutMoney.value == 0) {
      await closeDeposit();
      if (shouldBack) Get.back();
      clearTask();
      taskTouch = false;
    } else {
      final result =
          await dispenseCashOutside(getNoneZeroInfo(getPutMoneyCurrency.value));
      if (result) {
        final result = await supplyCountsClear();
        if (result) {
          if (shouldBack) Get.back();

          clearTask();
        }
      }
      taskTouch = false;
    }
    EasyLoading.dismiss();
  }

  dispenseCashCount(count) async {
    debugPrint("dispenseCashCount");

    bool? result =
        await CashChanger.dispenseChangeOutside(count, onSuccess: () {
      debugPrint("dispenseCashCount 1");
    }, catchError: (error) {
      debugPrint("dispenseCashCount error: $error");
      //errorHandleDialog(GString.getToString(checkLanguage.value, error));
    });
    debugPrint("dispenseCashCount result: $result");
    if (result) {
      return result;
    } else {
      String machineCash = await getMachineCashInfo();
      if (machineCash.isEmpty) return false;
      String outMoneyString = await findChange(machineCash, count);
      if (outMoneyString.isEmpty) {
        errorHandleDialog(GString.getToString(
            checkLanguage.value, 'cash_error_over_dispense'));
        return false;
      }
      final result = await dispenseCashOutside(getNoneZeroInfo(outMoneyString));
      return result;
    }
  }

  dispenseCashOutside(outInfo) async {
    var success = false;
    final depositAmount = await CashChanger.fixDeposit;
    debugPrint("fixDeposit: $depositAmount");
    final resultCode = await CashChanger.dispenseCashOutside(outInfo);
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("dispenseCashOutside 1");
          success = true;
        },
        onRetry: () {
          debugPrint("dispenseCashOutside 2");
          dispenseCashOutside(outInfo);
        },
        showError: (String error) {
          debugPrint("dispenseCashOutside error: $error");
          errorHandleDialog(GString.getToString(checkLanguage.value, error));
          success = false;
        });
    return success;
  }

  //清空上报

  gloryEmptyReport() async {
    debugPrint("gloryEmptyReposrt");

    var success = false;

    Map? machineChangeInfo =
        await getMachineCashInfos(); //这里会获取失败，应该是上次操作未正常结束。
    if (machineChangeInfo == null) {
      return;
    }

    var formData = {
      'changeInfoMap': machineChangeInfo,
      'machineCode': machineCode.value,
      'shopCode': shopCode.value,
    };

    debugPrint("gloryEmptyReposrt formData: $formData");

    await request(
      'webBootGloryEmpty',
      method: 'POST',
      parameters: formData,
    ).then((value) {
      debugPrint("gloryEmptyReport value: $value");
      final response = json.decode(value.toString());
      debugPrint("response: $response");
      if (response["code"] == 200) {
        success = true;
      } else {
        errorHandleDialog("${response["msg"] ?? 'この機能はレジ締め後に実行する必要があります。'}");
        success = false;
      }
    }).catchError((error) {
      debugPrint("gloryEmptyReport error: $error");

      if (error.toString().contains("Http status error")) {
        //全回收功能需要在执行レジ締め后才可以执行。
        errorHandleDialog("この機能はレジ締め後に実行する必要があります。");
      } else {
        errorHandleDialog("gloryEmptyReport error: ${error}");
      }
      //showToast('回收失败!');

      success = false;
    });

    return success;
  }

  UsbDeviceInfo? get curUsbPrinter {
    if (usbPrinter.isEmpty) {
      print("usbDevice is empty");
      //弹出提示框，打印机未设置，请设置打印机或者联系管理员
      DialogUtils.alertOneButton('プリンター未設定,設定してください', confirm: () {
        Get.back();
      });
      return null;
    }
    print("usbDevice.value:${usbPrinter.value}");
    return UsbDeviceInfo.fromMap(Map<String, dynamic>.from(usbPrinter.value));
  }

  sendToUsePrinter(widget) async {
    final printWidget = ReceiptConstrainedBox(widget);
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: printWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(usbDevice: curUsbPrinter),
      ),
    );
  }

  //上报
  reportReplanishInfo(printView) async {
    //该步骤失败，后续程序非正常退出，数据与后台不一致，如何记录。
    //showEasyLoading();
    ignoreNotify.value = true;
    if (!await closeDeposit()) {
      taskTouch = false;
      return;
    }

    var formData = {
      'changeInfoMap': uploadMoneyInfo,
      'machineCode': machineCode.value, //'PAZK8N7KKE8evkXks4'
      'shopCode': shopCode.value,
    };
    debugPrint("formData: $formData");
    request(
      'webBootGlorySupplement',
      method: 'POST',
      parameters: formData,
    ).then((value) async {
      taskTouch = false;
      debugPrint("reportReplanishInfo value: $value");
      final response = json.decode(value.toString());
      debugPrint("response: $response");
      EasyLoading.dismiss();
      if (response["code"] == 200) {
        if (printView != null) {
          sendToUsePrinter(printView);
        }
        Get.back();
        clearTask();
        showToast('完了しました');
        //commonHandleDialog('完了しました');
        //showToast('完了しました', context: Get.context);
      } else {
        commonHandleDialog('補充失败!');
        //showToast('補充失败!', context: Get.context);
      }
    }).catchError((error) {
      taskTouch = false;
      debugPrint("reportReplanishInfo error: $error");
      EasyLoading.dismiss();
      commonHandleDialog('補充失败!');
      //showToast('補充失败!', context: Get.context);
    });
  }

  Map get uploadMoneyInfo {
    if (getPutMoneyCurrency.value.isEmpty) {
      return {};
    }
    final currencyPairs = getPutMoneyCurrency
        .value; //getNoneZeroInfo(getPutMoneyCurrency.value, isReport: true);
    debugPrint("currencyPairs: $currencyPairs");

    //获取不为0的数据返回Map
    List<String> currencyPairsList = currencyPairs.split(',');
    Map<String, String> currencyPairsMap = {};
    for (var pair in currencyPairsList) {
      List<String> parts = pair.split(':');
      if (parts.length == 2 && parts[1] != '0') {
        currencyPairsMap[catValFromInt(parts[0])] = parts[1];
      }
    }
    return currencyPairsMap;
  }

  Map get uploadOutMoneyInfo {
    if (getOutMoneyCurrency.value.isEmpty) {
      return {};
    }
    final currencyPairs = getOutMoneyCurrency
        .value; //getNoneZeroInfo(getPutMoneyCurrency.value, isReport: true);
    debugPrint("currencyPairs: $currencyPairs");

    //获取不为0的数据返回Map
    List<String> currencyPairsList = currencyPairs.split(',');
    Map<String, String> currencyPairsMap = {};
    for (var pair in currencyPairsList) {
      List<String> parts = pair.split(':');
      if (parts.length == 2 && parts[1] != '0') {
        currencyPairsMap[catValFromInt(parts[0])] = parts[1];
      }
    }
    return currencyPairsMap;
  }

  String getNoneZeroInfo(String input) {
    List<String> currencyPairs = input.split(',');

    List<String> nonZeroPairs = currencyPairs.where((pair) {
      List<String> parts = pair.split(':');
      return parts.length == 2 && parts[1] != '0' && int.parse(parts[0]) <= 500;
    }).toList();
    debugPrint("nonZeroPairs: $nonZeroPairs");

    List<String> nonZeroPairsOver500 = currencyPairs.where((pair) {
      List<String> parts = pair.split(':');
      return parts.length == 2 && parts[1] != '0' && int.parse(parts[0]) > 500;
    }).toList();
    debugPrint("nonZeroPairsOver500: $nonZeroPairsOver500");

    var result = nonZeroPairs.join(',');

    if (nonZeroPairsOver500.isNotEmpty) {
      result += ';' + nonZeroPairsOver500.join(',');
    }

    return result;
  }

  clearTask() async {
    //
    //isStartPutMoney.value = false;
    hasOutMoney = false;
    //moneyList.value = [];
    hasExchangeCash = false;
    getPutMoneyCurrency.value = "";
    getPutMoney.value = 0;
    isStartPutMoney.value = false;
    getServerCashInfo();
    //update();
  }

  errorHandleDialog(String error, {Function? confirm}) {
    EasyLoading.dismiss();
    debugPrint("errorHandleDialog: $error");
    Get.dialog(
        barrierDismissible: false,
        DialogUtils.alertOneButton(error,
            title: GString.getToString(checkLanguage.value, "tag_title"),
            confirmtitle:
                GString.getToString(checkLanguage.value, "tag_button_yes"),
            confirm: () {
          if (confirm != null) {
            confirm();
          } else {
            Get.back();
          }
        }));
  }
}
