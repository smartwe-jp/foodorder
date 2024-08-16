import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/setting/controllers/exchange_controller_extension.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/cashMoneyParser.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

extension SettingControllerExtension on SettingController {
  startPutMoney() async {
    isStartPutMoney.value = true;
    update();
    await _startDeposit();
  }

  _startDeposit() async {
    debugPrint("startDeposit");
    await CashChanger.setEventsListener();
    final resultCode = await CashChanger.startDeposit;
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("startDeposit 1");
          _checkChangerStatus();
        },
        onRetry: () {
          debugPrint("startDeposit 2");
          _startDeposit();
        },
        showError: (String error) {
          debugPrint("startDeposit error: $error");
          //errorHandleDialog(GString.getToString(checkLanguage.value, error));
        });
  }

  _checkChangerStatus() async {
    debugPrint("checkChangerStatus 1");
    var resultCode = await CashChanger.checkChangerStatus;
    if (resultCode == null) {
      debugPrint("Unknown error");
      _checkChangerStatus();
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
        _checkChangerStatus();
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
    //await Paycube.setReceiveEvent;
    debugPrint("getPutInMoney");
    CashChanger.onGetPutMoneyStringChange = (int result) {
      debugPrint("onGetPutMoneyStringChange");
      if (result > 0) {
        debugPrint("getPutMoney.value==${result.toString()}");
        getPutMoney.value = result;
        update();
        //_getInputMoneyInfo();
      }
    };
  }

  _getInputMoneyInfo() async {
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
    getPutMoneyCurrency.value = MoneyParser.migrationGloryToHexString(
        putMoneyCurrency, onResult: (List<int> result, Map details) {
      debugPrint("result==${result}");
      moneyList.value = result;
      moneyMap.value = details;
      update();
    });
  }

  Future<bool> closeDeposit() async {
    debugPrint("closeDeposit");
    //await CashChanger.removeEventsListener();
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
          //errorHandleDialog(GString.getToString(checkLanguage.value, error));
        });
    return success;
  }

  cancelReplanish() async {
    debugPrint("cancelReplanish");

    if (getPutMoney.value == 0) {
      await closeDeposit();
    } else {
      //showEasyLoading();
      await depositRepay();
      //EasyLoading.dismiss();
    }
    clearTask();
    Get.back();
  }

  depositRepay() async {
    final depositAmount = await CashChanger.depositAmount;
    debugPrint("depositAmount: $depositAmount");
    final resultCode = await CashChanger.depositRepay;
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("cancelReplanish 1");
        },
        onRetry: () {
          debugPrint("cancelReplanish 2");
          depositRepay();
        },
        showError: (String error) {
          debugPrint("cancelReplanish error: $error");
          errorHandleDialog(GString.getToString(checkLanguage.value, error));
        });
  }

  //上报
  reportReplanishInfo(changeInfoMap, context) async {
    debugPrint("reportReplanishInfo changeInfoMap: $changeInfoMap");

    showEasyLoading();
    await closeDeposit();

    isStartPutMoney.value = false;

    var formData = {
      'changeInfoMap': {'87': 1},
      'machineCode': 'PAZK8N7KKE8evkXks4',
      'shopCode': shopCode.value,
    };

    request(
      'webBootGlorySupplement',
      method: 'POST',
      parameters: formData,
    ).then((value) {
      final response = json.decode(value.toString());
      debugPrint("response: $response");
      EasyLoading.dismiss();
      if (response["code"] == 200) {
        clearTask();
        Get.back();
        showToast('完了しました', context: context);
      } else {
        showToast('補充失败!', context: context);
      }
    }).catchError((error) {
      EasyLoading.dismiss();
    });
  }

  clearTask() {
    isStartPutMoney.value = false;
    moneyList.value = [];
    moneyMap.value = {};
    getPutMoney.value = 0;
    getCashInfo();
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
