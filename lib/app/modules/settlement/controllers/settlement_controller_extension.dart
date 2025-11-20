import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/common/StringExtension.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_ui_extension.dart';
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
    logger.info('--start Deposit--');
    await CashChanger.startDeposit(
      onSuccess: () {
        debugPrint("startDeposit 1");
        logger.info('--start Deposit success--');
        ret = 'success';
        _checkChangerStatus();
      },
      catchError: (error) {
        debugPrint("startDeposit error: $error");
        ret = error.tr;
        logger.info('--start Deposit error: $ret--');
        //"サービスは利用できません。スタッフに連絡してください。";
        //errorHandleDialog(GString.getToString(checkLanguage.value, error));
      },
    );
    return ret;
  }

  _checkChangerStatus() async {
    debugPrint("checkChangerStatus 1");
    logger.info('--start checkChangerStatus--');
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
    logger.info('-- checkChangerStatus : $resultCodeEnum--');
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
    logger.info('-- getInputMoney --');
    int totalPriceResult = int.tryParse(totalPrice.value) ?? 0;
    logger.info('-- getInputMoney totalPriceResult: $totalPriceResult--');
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
      logger.info('-- getInputMoney onGetPutMoneyStringChange: $result--');
      if (result > 0) {
        hasStartPayflow = true;
        //timer?.cancel();
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
          logger.info('-- getInputMoney showOutMoney: $outMoney --');
        } else {
          showOutMoney.value = "0"; //找零金额
          logger.info('-- getInputMoney showOutMoney: 0 --');
        }
        update();
      }
    };

    CashChanger.onStatusUpdateEventChange = (String result) async {
      logger.info('-- onStatusUpdateEventChange: $result --');
      debugPrint("onStatusUpdateEventChange : $result");
      if (result == 'OK') {
        return;
      }
      if (result == 'NEARFULL') {
        _notifyMachineFull(false);
        return;
      }
      if (result == 'FULL') {
        //GString.getToString(language, 'load_menu_failure_content').trParams({'cash': '$_countdown'}),
        _notifyMachineFull(true);
        String? machineChangeInfo = await getMachineCashInfo();
        if (machineChangeInfo == null) {
          return;
        }

        String cashList = machineChangeInfo.findMaxCash();

        errorHandleDialog('cash_full_tips'.tr
                .trParams({'cash': '$cashList'}), confirm: () {
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

  _notifyMachineFull(bool isFull) {
    debugPrint("发送通知邮件");
    var formData = {
      "machineCode": machineInfo.machineCode,
    };

    final String domain = isFull ? 'webMachineFull' : 'webMachineNearFull';

    request(domain, method: "POST", parameters: formData).then((value) {
      var response = json.decode(value.toString());
      debugPrint("发送通知邮件 response:$response");
      if (response != null && response['code'] == 200) {
      } else {}
    });
  }

  //入金开始-入金结束-交易结束-出金开始-交易结束
  endDeposit({repay = false}) async {
    logger.info('-- end Deposit and isRepay?: $repay --');
    debugPrint("endDeposit repay: $repay");
    //sleep(Duration(milliseconds: 300));
    logger.info('-- end Deposit fixDeposit --');
    final result = await CashChanger.fixDeposit;
    if (result != 0) {
      debugPrint("endDeposit error: $result");
      logger.info('-- end Deposit fixDeposit error: $result--');
      // errorHandleDialog('OPOS_fixDeposit_FAILURE');
      // return;
    }
    //getPutMoney.value = depositAmount.toString();
    //sleep(Duration(milliseconds: 300));

    if (repay) {
      _repayFlow();
      return;
    }
    logger.info('-- end Deposit --');

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
          logger.info('-- end Deposit success --');
          _payCubeCloseTransaction(true);
        },
        onRetry: () {
          debugPrint("endDeposit 2");
          endDeposit();
        },
        showError: (String error) {
          CashChanger.depositRepay;
          debugPrint("endDeposit error: $error");
          logger.info('-- end Deposit error: $error --');
          errorHandleDialog(error.tr, confirm: () {
            _repayFlow();
          });
        });
  }

  cashPayCheck() async {}

  //先找零钱后打印
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
        //TODO 如果已经找钱但是 后续失败了。如何恢复或者下一步。
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
    logger.info('-- gloryNextOper nextOper --');
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
          errorHandleDialog(error.tr);
        } else {
          errorHandleDialogTwo(error.tr, retry);
        }
      },
    );
    return result;
  }

  _startOutputMoney(outMoney) async {
    logger.info('-- startOutPutMoney : $outMoney --');
    var success = false;
    debugPrint("startOutPutMoney");
    CashStep.value = 3;
    outStringMoney.value = outMoney.toString();
    final result =
        await CashChanger.dispenseChange(int.parse(outStringMoney.value));
    logger.info('-- startOutPutMoney result: $result --');
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
          logger.info('-- startOutPutMoney error: $error --');
          errorHandleDialog(error.tr, confirm: () {
            //找钱失败一律退单和退回入金

            //Get.back();
            Get.back();
            _repayFlow();
          });
        });
    return success;
  }

  _repayFlow() async {
    showEasyLoading();
    logger.info('-- start repayFlow --');
    final result = await CashChanger.depositRepay;
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () {
          logger.info('-- start repayFlow depositRepay success --');
          //if (getPutMoney.value == '2000') {
          _getPayCubeOutMoney(reportWithOrder: false);
          // } else {
          //   EasyLoading.dismiss();
          //   Get.back();
          // }
        },
        onRetry: () {
          debugPrint("depositRepay 2");
          _repayFlow();
        },
        showError: (String error) {
          debugPrint("depositRepay error: $error");
          logger.info('-- start repayFlow depositRepay error: $error --');
          // errorHandleDialog(GString.getToString(checkLanguage.value, error),
          //     confirm: () {
          //   Get.back();

          // });

          gloryOutputMoney(int.parse(getPutMoney.value));
        });
  }

  gloryOutputMoney(outMoney) async {
    //debugPrint("startOutPutMoney");
    logger.info('-- start gloryOutputMoney: $outMoney --');
    print("outMoney: $outMoney");
    //var outStringMoney = outMoney.toString();
    bool? result =
        await CashChanger.dispenseChangeOutside(outMoney, onSuccess: () {
      //已经结束入金，处理取引终了
      logger.info('-- start gloryOutputMoney success --');
      _getPayCubeOutMoney(reportWithOrder: false);
    }, catchError: (error) {
      logger.info('-- start gloryOutputMoney error: $error --');
      debugPrint("startOutPutMoney error: $error");
      // _errorHandleDialog(GString.getToString(checkLanguage.value, error),
      // confirm: () {
      //   Get.back();
      // });
    });

    debugPrint("resultCode: $result");
    if (!result) {
      EasyLoading.dismiss();
      errorHandleDialog(
          'repay_cash_error'.tr,
          confirm: () {
        Get.back();
        Get.back();
      });
    }
  }

  reportChange(changeString) {
    debugPrint("reportChange isReportCash = ${isReportCash.value}");
    if (isReportCash.value == true) {
      return;
    }

    isReportCash.value = true;

    var formData = {
      "responseMessage": changeString,
      "machineCode": machineInfo.machineCode,
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
    logger.info('-- getInputMoneyInfo --');
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
    logger.info('-- getInputMoneyInfo: ${getPutMoneyCurrency.value}--');
    _payCubeCloseTransaction(false);
  }

  _getPayCubeOutMoney({reportWithOrder = true}) async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    //OutMoneytimer?.cancel();

    debugPrint("_getPayCubeOutMoney");
    logger.info('-- getPayCubeOutMoney --');
    //获取硬币入金出金币种
    String? currencyCoinStringresult = await CashChanger.changerDIStatus(0x04);
    debugPrint("currencyCoinStringresult==${currencyCoinStringresult}");
    logger.info(
        '-- getPayCubeOutMoney currencyCoinStringresult==${currencyCoinStringresult} --');

    String? currencyCashStringresult = await CashChanger.changerDIStatus(0x82);
    debugPrint("currencyCashStringresult==${currencyCashStringresult}");
    logger.info(
        '-- getPayCubeOutMoney currencyCashStringresult==${currencyCashStringresult} --');

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
    logger.info('-- getPayCubeMoney put==${getPutMoneyCurrency} --');
    currencyString.value =
        MoneyParser.migrationGloryToHexString(currency, isOutMoney: true);
    logger.info('-- getPayCubeMoney out==${currencyString} --');

    getOutMoneyString.value == false;
    if (reportWithOrder) {
      _reportOutMoney();
    } else {
      Map inputInfo = MoneyParser.migrationGloryToMap(putMoneyCurrency);
      List<Map> puts = inputInfo.entries.map((entry) {
        return {'catVal': entry.key, 'val': entry.value};
      }).toList();

      final outInfo = MoneyParser.migrationGloryToMap(currency);
      List<Map> pops = outInfo.entries.map((entry) {
        return {'catVal': entry.key, 'val': entry.value};
      }).toList();

      reportExchange(puts, pops);
    }
  }

  reportExchange(puts, pops) async {
    logger.info('-- getPayCubeMoney reportExchange --');
    var success = false;
    debugPrint('reportExchange');
    var formData = {
      'machineCode': machineInfo.machineCode,
      'puts': puts,
      'pops': pops,
      'shopCode': machineInfo.shopCode,
    };

    debugPrint('formData: $formData');

    await request(
      'webBootGloryExchange',
      method: 'POST',
      parameters: formData,
    ).then((value) {
      final response = json.decode(value.toString());
      logger.info('-- getPayCubeMoney reportExchange success --');
      debugPrint("response: $response");
      EasyLoading.dismiss();
      Get.back();
      if (response["code"] == 200) {
        success = true;
        //showToast('完了しました', context: Get.context);
      } else {
        success = false;
        //showToast('両替失败!', context: Get.context);
      }
    }).catchError((error) {
      logger.info(
          '-- getPayCubeMoney reportExchange error:${error.toString()} --');
      success = false;
      EasyLoading.dismiss();
      Get.back();
      //showToast('両替失败!', context: Get.context);
    });
    return success;
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
    logger.info('payCubeCloseTransaction cancel: $cancel isPrint: ${isPrint.value}');
    if (cancel) {
      if (isPrint.value == true) {
        gotonewBack();
      } else {
        gotonewMenuPage();
      }
    } else {
      //showSuccessAlert(() {
        // if (isPrint.value == true) {
        //   gotonewBack();
        // } else {
        //   gotonewMenuPage();
        // }
        gotonewBack();
      //});
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
            title: "tag_title".tr,
            confirmtitle: "cash_full_confirm".tr,
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
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () {
          confirm();
          Get.back();
        }, cancle: () {
          Get.back();
        }));
  }
}
