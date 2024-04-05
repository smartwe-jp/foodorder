import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/services/cashMoneyParser.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

import 'settlement_controller.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';

extension SettlementControllerExtension on SettlementController {
  startDeposit() async {
    debugPrint("startDeposit");

    final resultCode = await CashChanger.startDeposit;
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("startDeposit 1");
          _checkChangerStatus();
        },
        onRetry: () {
          debugPrint("startDeposit 2");
          startDeposit();
        },
        showError: (String error) {
          debugPrint("startDeposit error: $error");
          errorHandleDialog(error);
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
        timer?.cancel();
        getPutMoney.value = result.toString();
        scanQrCodeFocusNode.unfocus();
        int totalPriceResult = int.tryParse(totalPrice.value) ?? 0;
        //if (int.parse(result) >=int.parse(totalPrice.value, onError: (source) => -1)) {
        if (result >= totalPriceResult) {
          if (isCancel.value == false) {
            showPrintButton.value = true;
          } else {
            showPrintButton.value = false;
          }

          var outMoney = result - int.parse(totalPrice.value); //找零金额
          showOutMoney.value = outMoney.toString(); //找零金额
        } else {
          showOutMoney.value = "0"; //找零金额
        }
        update();
      }
    };
  }

  //入金开始-入金结束-交易结束-出金开始-交易结束  
  endDeposit() async {
    debugPrint("endDeposit");
    sleep(Duration(milliseconds: 300));
    var depositAmount = await CashChanger.depositAmount;
    getPutMoney.value = depositAmount.toString();
    sleep(Duration(milliseconds: 300));

    final resultCode =
        await CashChanger.endDeposit(DepositAction.noChange.index);

    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
            giveChangeMoney.value =
                int.parse(getPutMoney.value) - int.parse(totalPrice.value);
            if (isPrint.value == false) {
              _startOutputMoney(giveChangeMoney.value);
            }
          } else if (int.parse(getPutMoney.value) ==
              int.parse(totalPrice.value)) {
            if (isPrint.value == false) {
              //已经结束入金，处理取引终了
              _payCubeCloseTransaction();
            }
          }
        },
        onRetry: () {
          debugPrint("endDeposit 2");
          endDeposit();
        },
        showError: (String error) {
          CashChanger.depositRepay;
          debugPrint("endDeposit error: $error");
          errorHandleDialog(error);
        });
  }

  //打印小票之后在关闭现金机
  gloryNextOper() async {
    debugPrint("nextOper");
    CashStep.value = 2;
    //sleep(Duration(milliseconds: 50));
    var depositAmount = await CashChanger.depositAmount;
    getPutMoney.value = depositAmount.toString();
    if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
      giveChangeMoney.value =
          int.parse(getPutMoney.value) - int.parse(totalPrice.value);

      //找零
      _startOutputMoney(giveChangeMoney.value);
    } else {
      //已经结束入金，处理取引终了
      _payCubeCloseTransaction();
    }
  }

  _startOutputMoney(outMoney) async {
    debugPrint("startOutPutMoney");
    CashStep.value = 3;
    outStringMoney.value = outMoney.toString();
    final resultCode =
        await CashChanger.dispenseChange(int.parse(outStringMoney.value));
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          //已经结束入金，处理取引终了
          _getPayCubeOutMoney();
        },
        onRetry: () {
          debugPrint("startOutPutMoney 2");
          _startOutputMoney(outMoney);
        },
        showError: (String error) {
          debugPrint("startOutPutMoney error: $error");
          errorHandleDialog(error);
        });
  }

  _getPayCubeOutMoney() async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    OutMoneytimer?.cancel();

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
        MoneyParser.migrationGloryToHexString(putMoneyCurrency);
    currencyString.value = MoneyParser.migrationGloryToHexString(currency);

    getOutMoneyString.value == false;

    _reportOutMoney();
  }

  //汇报出金币种,请求后台
  _reportOutMoney() {
    isReportOutMoney.value = true;
    _payCubeCloseTransaction();
  }

  _payCubeCloseTransaction() async {
    debugPrint("payCubeCloseTransaction");
    if (int.parse(getPutMoney.value) > 0) {
      //汇报入金币种
      _getPayCubePutMoneyCurrency();
    }
    CashStep.value = 4;
    if (isPrint.value == true) {
      gotonewBack();
    } else {
      gotonewMenuPage();
    }
  }

  _getPayCubePutMoneyCurrency() async {
    //_putcurrencyString现金机出款币种:61 00 00 62 00 00 63 00 00

    if (getputMoneyString.value == true) {
      // 循环一定要记得设置取消条件，手动取消
      String putcurrencyString =
          getPutMoneyCurrency.value; //await Paycube.getPayCubePutMoneyCurrency;
      if (putcurrencyString.trim().length > 60) {
        var totalAmount =
            MoneyParser.calculateTotalAmount(putcurrencyString.trim());
        if (totalAmount == int.parse(getPutMoney.value)) {
          showCashTimer?.cancel();
          seconds.value = 180;
          getPutMoneyCurrency.value = putcurrencyString;
          getputMoneyString.value = false;
          //汇报入金币种
          reportPutMoneyCurrency();
        }
      }
    }
  }

  errorHandleDialog(String error) {
    EasyLoading.dismiss();
    debugPrint("errorHandleDialog: $error");
    Get.dialog(DialogUtils.alertOneButton(error,
        title: GString.getToString(checkLanguage.value, "tag_title"),
        confirmtitle:
            GString.getToString(checkLanguage.value, "tag_button_yes"),
        confirm: () {
        allowClick.value == true;
        Get.back();
    }));
  }
}
