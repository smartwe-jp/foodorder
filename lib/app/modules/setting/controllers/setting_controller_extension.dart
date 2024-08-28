import 'dart:convert';
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

extension SettingControllerExtension on SettingController {
  startPutMoney() async {
    debugPrint("startPutMoney");
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
        errorHandleDialog(
            GString.getToString(checkLanguage.value, error));
      },
    );

    
  }

  supplyCountsClear() async {
    debugPrint("_supplyCountsClear");

    return await CashChanger.supplyCounts(
      0x01,
      onSuccess: (value) {
      },
      catchError: (error) {
        errorHandleDialog(
            GString.getToString(checkLanguage.value, error));
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

  cancelReplanish() async {
    debugPrint("cancelReplanish");
    //await CashChanger.removeEventsListener();
    ignoreNotify.value = true;

    if (getPutMoney.value == 0) {
      await closeDeposit();
      clearTask();
      Get.back();
    } else {
      final result = await dispenseCashOutside();
      if (result) {
        final result = await supplyCountsClear();
        if (result) {
          clearTask();
          Get.back();
        } 
      } 
    }
  }

  dispenseCashOutside() async {
    var success = false;
    final depositAmount = await CashChanger.fixDeposit;
    debugPrint("fixDeposit: $depositAmount");
    final resultCode = await CashChanger.dispenseCashOutside(
        getNoneZeroInfo(getPutMoneyCurrency.value));
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("cancelReplanish 1");
          success = true;
        },
        onRetry: () {
          debugPrint("cancelReplanish 2");
          dispenseCashOutside();
        },
        showError: (String error) {
          debugPrint("cancelReplanish error: $error");
          errorHandleDialog(GString.getToString(checkLanguage.value, error));
          success = false;
        });
    return success;
  }

  //清空上报

  gloryEmptyReport() async {
    debugPrint("gloryEmptyReposrt");

    var success = false;

    final machineChangeInfo = await getMachineCashInfo();

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
        success = false;
      }
    }).catchError((error) {
      debugPrint("gloryEmptyReport error: $error");
      commonHandleDialog("gloryEmptyReport error");
      //showToast('回收失败!');
      
      success = false;
    });

    return success;
  }

  //上报
  reportReplanishInfo() async {
    debugPrint("reportReplanishInfo changeInfoMap: $uploadMoneyInfo");

    showEasyLoading();
    ignoreNotify.value = true;
    if (!await closeDeposit()) return;

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
      debugPrint("reportReplanishInfo value: $value");
      final response = json.decode(value.toString());
      debugPrint("response: $response");
      EasyLoading.dismiss();
      if (response["code"] == 200) {
        Get.back();
        clearTask();
        showToast('完了しました', context: Get.context);
      } else {
        showToast('補充失败!', context: Get.context);
      }
    }).catchError((error) {
      debugPrint("reportReplanishInfo error: $error");
      EasyLoading.dismiss();
      showToast('補充失败!', context: Get.context);
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
    isStartPutMoney.value = false;
    //moneyList.value = [];
    getPutMoneyCurrency.value = "";
    getPutMoney.value = 0;
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
