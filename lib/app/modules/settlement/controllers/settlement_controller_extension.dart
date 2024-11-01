import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/common/StringExtension.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/cashMoneyParser.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

import 'settlement_controller.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';

extension SettlementControllerExtension on SettlementController {
  startDeposit() async {
    debugPrint("startDeposit");
    var ret = 'failure';
    await CashChanger.startDeposit(
      onSuccess: () {
        debugPrint("startDeposit 1");
        ret = 'success';
        _checkChangerStatus();
      },
      catchError: (error) {
        debugPrint("startDeposit error: $error");
        ret = GString.getToString(checkLanguage.value, error);
        //"サービスは利用できません。スタッフに連絡してください。";
        //errorHandleDialog(GString.getToString(checkLanguage.value, error));
      },
    );
    return ret;
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
    debugPrint("_getInputMoney");
    //await Paycube.setReceiveEvent;
    int totalPriceResult = int.tryParse(totalPrice.value) ?? 0;
    if (totalPriceResult == 0) {
      debugPrint('totalPriceResult == 0');
      scanQrCodeFocusNode.unfocus();
      getPutMoney.value = "0";
      if (isCancel.value == false) {
        showPrintButton.value = true;
      } else {
        showPrintButton.value = false;
      }
      showOutMoney.value = "0";
      update();
    }

    CashChanger.onGetPutMoneyStringChange = (int result) {
      debugPrint("onGetPutMoneyStringChange");
      if (result > 0) {
        hasStartPayflow = true;
        timer?.cancel();
        getPutMoney.value = result.toString();
        debugPrint("getPutMoney.value==${getPutMoney.value}");
        scanQrCodeFocusNode.unfocus();
        totalPriceResult = int.tryParse(totalPrice.value) ?? 0;
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

    CashChanger.onStatusUpdateEventChange = (String result) async {
      debugPrint("onStatusUpdateEventChange : $result");
      if (result == 'OK') {
        return;
      }
      // if (result == 'NEARFULL') {
      //   //获取机器信息

      //   return;
      // }
      if (result == 'FULL' || result == 'NEARFULL') {
        //GString.getToString(language, 'load_menu_failure_content').trParams({'cash': '$_countdown'}),
        String? machineChangeInfo = await getMachineCashInfo();
        if (machineChangeInfo == null) {
          return;
        }

        String cashList = machineChangeInfo.findMaxCash();

        errorHandleDialog(
            GString.getToString(checkLanguage.value, 'cash_full_tips')
                .trParams({'cash': '$cashList'}), confirm: () {
          //找钱失败一律退单和退回入金
          CashChanger.fixDeposit;
          CashChanger.depositRepay;
          Get.back();
          Get.back();
        });
        return;
      }
      errorHandleDialog(result);
    };
  }

  //入金开始-入金结束-交易结束-出金开始-交易结束
  endDeposit({repay = false}) async {
    debugPrint("endDeposit repay: $repay");
    //sleep(Duration(milliseconds: 300));
    final result = await CashChanger.fixDeposit;
    if (result != 0) {
      debugPrint("endDeposit error: $result");
      // errorHandleDialog('OPOS_fixDeposit_FAILURE');
      // return;
    }
    //getPutMoney.value = depositAmount.toString();
    //sleep(Duration(milliseconds: 300));

    final resultCode = await CashChanger.endDeposit(
        repay ? DepositAction.repay.index : DepositAction.noChange.index);

    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          // if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
          //   giveChangeMoney.value =
          //       int.parse(getPutMoney.value) - int.parse(totalPrice.value);
          //   if (isPrint.value == false) {
          //     _startOutputMoney(giveChangeMoney.value);
          //   }
          // } else if (int.parse(getPutMoney.value) ==
          //     int.parse(totalPrice.value)) {
          //   if (isPrint.value == false) {
          //     //已经结束入金，处理取引终了
          //     _payCubeCloseTransaction();
          //   }
          // }
          _payCubeCloseTransaction(true);
        },
        onRetry: () {
          debugPrint("endDeposit 2");
          endDeposit();
        },
        showError: (String error) {
          CashChanger.depositRepay;
          debugPrint("endDeposit error: $error");
          errorHandleDialog(GString.getToString(checkLanguage.value, error));
        });
  }

  cashPayCheck() async {}

  //打印小票之后在关闭现金机
  gloryPayFlow(printType) async {
    // debugPrint("nextOper");
    // CashStep.value = 2;
    //sleep(Duration(milliseconds: 50));
    var depositAmount = await CashChanger.depositAmount;
    getPutMoney.value = depositAmount.toString();
    debugPrint("depositAmount==${depositAmount}");
    if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
      giveChangeMoney.value =
          int.parse(getPutMoney.value) - int.parse(totalPrice.value);

      //找零
      if (await _startOutputMoney(giveChangeMoney.value)) {
        doPrintOrderMenu(printType);
      }
    } else {
      //已经结束入金，处理取引终了
      doPrintOrderMenu(printType);
    }
  }

  //gloryNextOper 打印小票之后在关闭现金机

  gloryNextOper() async {
    debugPrint("nextOper");
    CashStep.value = 2;
    //sleep(Duration(milliseconds: 50));
    // var depositAmount = await CashChanger.depositAmount;
    // getPutMoney.value = depositAmount.toString();
    // debugPrint("depositAmount==${depositAmount}");
    if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
      _getPayCubeOutMoney();
    } else {
      //已经结束入金，处理取引终了
      _getInputMoneyInfo();
    }
  }

  Future<String?> getMachineCashInfo({Function? retry}) async {
    debugPrint("getMachineCashInfo 0");
    var result = null;
    await CashChanger.getCashBalance(
      onSuccess: (value) {
        debugPrint("getMachineCashInfo 1");

        result = value;
      },
      catchError: (error) {
        debugPrint("getMachineCashInfo error: $error");
        if (retry == null) {
          errorHandleDialog(GString.getToString(checkLanguage.value, error));
        } else {
          errorHandleDialogTwo(
              GString.getToString(checkLanguage.value, error), retry);
        }
      },
    );
    return result;
  }

  _startOutputMoney(outMoney) async {
    var success = false;
    debugPrint("startOutPutMoney");
    CashStep.value = 3;
    outStringMoney.value = outMoney.toString();
    final result =
        await CashChanger.dispenseChange(int.parse(outStringMoney.value));
    if (result == null) return;
    debugPrint("resultCode: $result");

    await CashChanger.changerResultNext(
        resultCode: result['code'] ?? 0,
        onSuccess: () {
          //已经结束入金，处理取引终了
          //_getPayCubeOutMoney();
          success = true;
        },
        onRetry: () {
          debugPrint("startOutPutMoney 2");
          _startOutputMoney(outMoney);
        },
        showError: (String error) {
          success = false;
          debugPrint("startOutPutMoney error: $error");
          errorHandleDialog(GString.getToString(checkLanguage.value, error),
              confirm: () {
            //找钱失败一律退单和退回入金
            CashChanger.depositRepay;
            Get.back();
            Get.back();
          });
        });
    return success;
  }

  reportChange(changeString) {
    debugPrint("reportChange isReportCash = ${isReportCash.value}");
    if (isReportCash.value == true) {
      return;
    }

    isReportCash.value = true;

    var formData = {
      "responseMessage": changeString,
      "machineCode": machineCode.value,
      "orderId": orderId,
    };
    request('webBootReimburseNotify', method: 'POST', parameters: formData)
        .then((value) {
      var response = json.decode(value.toString());

      EasyLoading.dismiss();
      if (response['code'] == 200 && response['data'] == true) {
        Get.dialog(
            DialogUtils.alertOneButton("返金成功。",
                title: "お知らせ", confirmtitle: "はい", confirm: () {
              Get.back();
            }),
            barrierDismissible: false);
      } else {
        Get.dialog(
            DialogUtils.alertOneButton("返金失敗です。",
                title: "お知らせ", confirmtitle: "はい", confirm: () {
              Get.back();
            }),
            barrierDismissible: false);
      }
    });
  }

  //获取入金币种

  _getInputMoneyInfo() async {
    debugPrint("_getInputMoneyInfo");
    String? currencyCoinStringresult = await CashChanger.changerDIStatus(0x04);
    debugPrint("currencyCoinStringresult==${currencyCoinStringresult}");

    String? currencyCashStringresult = await CashChanger.changerDIStatus(0x82);
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
        MoneyParser.migrationGloryToHexString(putMoneyCurrency);
    _payCubeCloseTransaction(false);
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
    currencyString.value =
        MoneyParser.migrationGloryToHexString(currency, isOutMoney: true);

    getOutMoneyString.value == false;

    _reportOutMoney();
  }

  //汇报出金币种,请求后台
  _reportOutMoney() {
    isReportOutMoney.value = true;
    _payCubeCloseTransaction(false);
  }

  _payCubeCloseTransaction(bool cancel) async {
    debugPrint("payCubeCloseTransaction");
    if (int.parse(getPutMoney.value) > 0) {
      //汇报入金币种
      _getPayCubePutMoneyCurrency();
    }
    CashStep.value = 4;

    debugPrint('cash showSuccessAlert');

    if (cancel) {
      if (isPrint.value == true) {
        gotonewBack();
      } else {
        gotonewMenuPage();
      }
    } else {
      showSuccessAlert(() {
        if (isPrint.value == true) {
          gotonewBack();
        } else {
          gotonewMenuPage();
        }
      });
    }

    // if (isPrint.value == true) {
    //   gotonewBack();
    // } else {
    //   gotonewMenuPage();
    // }
  }

  _getPayCubePutMoneyCurrency() async {
    //_putcurrencyString现金机出款币种:61 00 00 62 00 00 63 00 00
    debugPrint("_getPayCubePutMoneyCurrency");
    if (getputMoneyString.value == true) {
      // 循环一定要记得设置取消条件，手动取消
      String putcurrencyString =
          getPutMoneyCurrency.value; //await Paycube.getPayCubePutMoneyCurrency;
      debugPrint("putcurrencyString==${putcurrencyString}");
      if (putcurrencyString.trim().length > 60) {
        var totalAmount =
            MoneyParser.calculateTotalAmount(putcurrencyString.trim());
        if (totalAmount == int.parse(getPutMoney.value)) {
          showCashTimer?.cancel();
          seconds.value = 180;
          getPutMoneyCurrency.value = putcurrencyString;
          getputMoneyString.value = false;
          //汇报入金币种
          debugPrint("--reportPutMoneyCurrency");
          reportPutMoneyCurrency();
        }
      }
    }
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
          allowClick.value == true;
          if (confirm != null) {
            confirm();
          } else {
            Get.back();
          }
        }));
  }

  errorHandleDialogTwo(String message, Function confirm) {
    EasyLoading.dismiss();
    debugPrint("errorHandleDialogTwo: $message");
    Get.dialog(
        barrierDismissible: false,
        DialogUtils.alert(message,
            title: GString.getToString(checkLanguage.value, "tag_title"),
            confirmtitle:
                GString.getToString(checkLanguage.value, "tag_button_yes"),
            confirm: () {
          confirm();
          Get.back();
        }, cancle: () {
          Get.back();
        }));
  }
}
