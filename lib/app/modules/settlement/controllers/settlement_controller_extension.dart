import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/common/StringExtension.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_ui_extension.dart';
import 'package:foodorder/app/modules/settlement/views/machine_error_view.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/routes/app_pages.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/cashMoneyParser.dart';
import 'package:foodorder/app/services/payment_event_codes.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

import 'settlement_controller.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';

extension SettlementControllerExtension on SettlementController {
  startDeposit() async {
    debugPrint("startDeposit");
    var ret = 'failure';
    monitorPaymentStageStarted(
      'cash_device_open',
      PaymentEventCode.cashDeviceOpenStarted,
      'Glory cash device open started',
      data: const <String, Object?>{'cash_device': 'glory'},
    );
    logger.info('--start Deposit--');
    await CashChanger.startDeposit(
      onSuccess: () {
        debugPrint("startDeposit 1");
        logger.info('--start Deposit success--');
        monitorPaymentStageSucceeded(
          'cash_device_open',
          PaymentEventCode.cashDeviceOpenSucceeded,
          'Glory cash device open succeeded',
          data: const <String, Object?>{'cash_device': 'glory'},
        );
        ret = 'success';
        _checkChangerStatus();
      },
      catchError: (error) {
        debugPrint("startDeposit error: $error");
        ret = error.tr;
        monitorPaymentStageFailed(
          'cash_device_open',
          PaymentEventCode.cashDeviceOpenFailed,
          'Glory cash device open failed',
          failureType: PaymentFailureType.deviceUnavailable,
          error: error,
          data: const <String, Object?>{'cash_device': 'glory'},
        );
        monitorPaymentFlowFailed(
          failedStage: 'cash_device_open',
          failureType: PaymentFailureType.deviceUnavailable,
          error: error,
        );
        logger.info('--start Deposit error: $ret--');
        //"サービスは利用できません。スタッフに連絡してください。";
        //errorHandleDialog(GString.getToString(checkLanguage.value, error));
      },
    );
    return ret;
  }

  _checkChangerStatus({int attempt = 1}) async {
    debugPrint("checkChangerStatus 1");
    logger.info('--start checkChangerStatus--');
    monitorPaymentInfo(
      PaymentEventCode.cashDeviceStatusCheckStarted,
      'Glory cash device status check started',
      status: 'started',
      data: <String, Object?>{
        'cash_device': 'glory',
        'attempt': attempt,
      },
    );
    var resultCode = await CashChanger.checkChangerStatus;
    if (resultCode == null) {
      debugPrint("Unknown error");
      final willRetry = attempt < 3;
      if (willRetry) {
        monitorPaymentWarning(
          PaymentEventCode.cashDeviceStatusCheckFailed,
          'Glory cash device status check returned no result',
          failureType: PaymentFailureType.invalidResponse,
          data: <String, Object?>{
            'cash_device': 'glory',
            'attempt': attempt,
            'will_retry': true,
          },
        );
        await Future.delayed(const Duration(seconds: 1));
        _checkChangerStatus(attempt: attempt + 1);
      } else {
        monitorPaymentCritical(
          PaymentEventCode.cashDeviceStatusCheckFailed,
          'Glory cash device status check failed after retry',
          failureType: PaymentFailureType.invalidResponse,
          data: <String, Object?>{
            'cash_device': 'glory',
            'attempt': attempt,
            'will_retry': false,
          },
        );
        monitorPaymentFlowFailed(
          failedStage: 'cash_device_status_check',
          failureType: PaymentFailureType.invalidResponse,
        );
      }
      return;
    }
    debugPrint("checkChangerStatus resultCode:  " + resultCode.toString());
    if (resultCode == 0) {
      resultCode = 100;
    }
    final resultIndex = resultCode - 100;
    if (resultIndex < 0 || resultIndex >= HealthResultCode.values.length) {
      monitorPaymentCritical(
        PaymentEventCode.cashDeviceStatusCheckFailed,
        'Glory cash device returned an unknown status code',
        failureType: PaymentFailureType.invalidResponse,
        data: <String, Object?>{
          'cash_device': 'glory',
          'attempt': attempt,
          'result_code': resultCode,
        },
      );
      monitorPaymentFlowFailed(
        failedStage: 'cash_device_status_check',
        failureType: PaymentFailureType.invalidResponse,
      );
      return;
    }
    HealthResultCode resultCodeEnum = HealthResultCode.values[resultIndex];
    logger.info('-- checkChangerStatus : $resultCodeEnum--');
    switch (resultCodeEnum) {
      case HealthResultCode.OPOS_SUCCESS:
      case HealthResultCode.OPOS_E_ILLEGAL:
        monitorPaymentInfo(
          PaymentEventCode.cashDeviceStatusCheckSucceeded,
          'Glory cash device status check succeeded',
          status: 'succeeded',
          data: <String, Object?>{
            'cash_device': 'glory',
            'attempt': attempt,
            'result_code': resultCode,
            'health_status': resultCodeEnum.name,
          },
        );
        _getInputMoney();
        break;
      case HealthResultCode.OPOS_E_CLOSED:
      case HealthResultCode.OPOS_E_NOTCLAIMED:
      case HealthResultCode.OPOS_E_DISABLED:
        debugPrint("checkChangerStatus error: $resultCode");
        _reportGloryStatusCheckFailure(resultCodeEnum, resultCode, attempt);
        break;
      case HealthResultCode.OPOS_E_BUSY:
        monitorPaymentWarning(
          PaymentEventCode.cashDeviceStatusCheckFailed,
          'Glory cash device is busy',
          failureType: PaymentFailureType.deviceUnavailable,
          data: <String, Object?>{
            'cash_device': 'glory',
            'attempt': attempt,
            'result_code': resultCode,
            'health_status': resultCodeEnum.name,
            'will_retry': true,
          },
        );
        await Future.delayed(const Duration(seconds: 5));
        _checkChangerStatus(attempt: attempt + 1);
        break;
      case HealthResultCode.OPOS_E_NOHARDWARE:
        debugPrint("checkChangerStatus error: $resultCode");
        _reportGloryStatusCheckFailure(resultCodeEnum, resultCode, attempt);
        break;
      default:
        debugPrint("checkChangerStatus error: $resultCode");
        _reportGloryStatusCheckFailure(resultCodeEnum, resultCode, attempt);
        break;
    }
  }

  void _reportGloryStatusCheckFailure(
    HealthResultCode status,
    int resultCode,
    int attempt,
  ) {
    monitorPaymentCritical(
      PaymentEventCode.cashDeviceStatusCheckFailed,
      'Glory cash device status check failed',
      failureType: PaymentFailureType.deviceUnavailable,
      data: <String, Object?>{
        'cash_device': 'glory',
        'attempt': attempt,
        'result_code': resultCode,
        'health_status': status.name,
        'will_retry': false,
      },
    );
    monitorPaymentFlowFailed(
      failedStage: 'cash_device_status_check',
      failureType: PaymentFailureType.deviceUnavailable,
    );
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
    // getPutMoney.value = totalPrice.value;
    // showPrintButton.value = true;
    // update();

    CashChanger.onGetPutMoneyStringChange = (int result) {
      debugPrint("onGetPutMoneyStringChange");
      logger.info('-- getInputMoney onGetPutMoneyStringChange: $result--');
      if (result > 0) {
        monitorPaymentInfo(
          PaymentEventCode.cashDepositAmountUpdated,
          'Cash deposit amount updated',
          status: 'received',
          data: <String, Object?>{
            'cash_device': 'glory',
            'inserted_amount': result,
          },
        );
        //_testFull();
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
        monitorPaymentInfo(
          PaymentEventCode.cashDeviceStatusUpdated,
          'Glory cash device status updated',
          status: 'observed',
          data: const <String, Object?>{
            'cash_device': 'glory',
            'health_status': 'OK',
          },
        );
        return;
      }
      // if (result == 'NEARFULL') {
      //   _notifyMachineFull(false);
      //   return;
      // }
      if (result == 'FULL' || result == 'NEARFULL') {
        final isFull = result == 'FULL';
        if (isFull) {
          monitorPaymentCritical(
            PaymentEventCode.cashCapacityFull,
            'Glory cash device capacity is full',
            failureType: PaymentFailureType.cashCapacity,
            data: const <String, Object?>{
              'cash_device': 'glory',
              'health_status': 'FULL',
            },
          );
        } else {
          monitorPaymentWarning(
            PaymentEventCode.cashCapacityWarning,
            'Glory cash device capacity is nearly full',
            failureType: PaymentFailureType.cashCapacity,
            data: const <String, Object?>{
              'cash_device': 'glory',
              'health_status': 'NEARFULL',
            },
          );
        }
        monitorPaymentFlowFailed(
          failedStage: 'cash_capacity',
          failureType: PaymentFailureType.cashCapacity,
        );
        //GString.getToString(language, 'load_menu_failure_content').trParams({'cash': '$_countdown'}),
        // _notifyMachineFull(true);
        // String? machineChangeInfo = await getMachineCashInfo();
        // if (machineChangeInfo == null) {
        //   return;
        // }

        // String cashList = machineChangeInfo.findMaxCash();

        // errorHandleDialog('cash_full_tips'.tr.trParams({'cash': '$cashList'}),
        //     confirm: () {
        //   CashChanger.fixDeposit;
        //   CashChanger.depositRepay;
        //   Get.back();
        //   Get.back();
        // });
        _whileFull();
        return;
      }
      monitorPaymentCritical(
        PaymentEventCode.cashDeviceStatusUpdated,
        'Glory cash device reported an error status',
        failureType: PaymentFailureType.deviceUnavailable,
        error: result,
        data: <String, Object?>{
          'cash_device': 'glory',
          'health_status': result,
        },
      );
      errorHandleDialog(result);
    };
  }

  _whileFull() async {
    _notifyMachineFull(true);
    String? machineChangeInfo = await getMachineCashInfo();
    if (machineChangeInfo == null) {
      return;
    }

    String cashList = machineChangeInfo.findMaxCash();
    if (cashList.isEmpty) {
      return;
    }
    String errorMsg = 'cash_full_tips'.tr.trParams({'cash': '$cashList'});
    String error = '金種@cash が上限に達しました。設定に調整してください。'.tr.trParams({'cash': '「$cashList」'});

    errorHandleDialog(errorMsg,
        confirm: () {
        _fullRepayFlow(error);
    });
  }

  _fullRepayFlow(String errorMessage) async {
    Get.back();
    showEasyLoading();
    monitorPaymentStageStarted(
      'cash_refund',
      PaymentEventCode.cashRefundStarted,
      'Glory capacity recovery refund started',
      data: <String, Object?>{
        'cash_device': 'glory',
        'refund_amount': int.tryParse(getPutMoney.value),
        'refund_method': 'capacity_recovery',
      },
    );
    final resultFixDeposit = await CashChanger.fixDeposit;
    logger.info('-- full repayFlow fixDeposit result: $resultFixDeposit --');

    final result = await CashChanger.depositRepay;
    logger.info('-- full repayFlow depositRepay result: $result --');
    if (result == 0) {
      monitorPaymentStageSucceeded(
        'cash_refund',
        PaymentEventCode.cashRefundSucceeded,
        'Glory capacity recovery refund succeeded',
        data: <String, Object?>{
          'cash_device': 'glory',
          'refund_amount': int.tryParse(getPutMoney.value),
          'refund_method': 'capacity_recovery',
          'result_code': result,
        },
      );
    } else {
      monitorPaymentStageFailed(
        'cash_refund',
        PaymentEventCode.cashRefundFailed,
        'Glory capacity recovery refund needs manual handling',
        failureType: PaymentFailureType.deviceRejected,
        critical: true,
        data: <String, Object?>{
          'cash_device': 'glory',
          'refund_amount': int.tryParse(getPutMoney.value),
          'refund_method': 'capacity_recovery',
          'result_code': result,
          'fix_deposit_result': resultFixDeposit,
        },
      );
    }
    EasyLoading.dismiss();
    final pendingCashList = <PendingCashItem>[];
    if (result != 0) {
      //获取入金币种
      String putMoneyCurrency = await _getPutMoneyCurrency();
    
      Map<String, int> inputInfo = MoneyParser.migrationGloryToMap(putMoneyCurrency);
      inputInfo.forEach((key, value) {
        if (value > 0) {
          pendingCashList.add(PendingCashItem(
            denomination: key.getHexCashName(),
            amount: value * key.getHexCashValue(),
            count: value,
          ));
        }
      });
    }

    Get.to(
      MachineErrorView(
        errorMessage:errorMessage, 
        settingsPassword: machineInfo.settingPassword, 
        pendingCash: pendingCashList,
        onGoToSettings: () async {
          await Get.offNamedUntil(Routes.SETTING, (route) => route.settings.name == Routes.CHECKOUT_PAGE);
        },
      )
    );
    
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
  endDeposit({repay = false, int attempt = 1}) async {
    logger.info('-- end Deposit and isRepay?: $repay --');
    debugPrint("endDeposit repay: $repay");
    monitorPaymentStageStarted(
      'cash_deposit_stop',
      PaymentEventCode.cashDepositStopStarted,
      'Glory cash deposit stop started',
      data: <String, Object?>{
        'cash_device': 'glory',
        'repay': repay,
        'attempt': attempt,
      },
    );
    //sleep(Duration(milliseconds: 300));
    logger.info('-- end Deposit fixDeposit --');
    final result = await CashChanger.fixDeposit;
    if (result != 0) {
      debugPrint("endDeposit error: $result");
      logger.info('-- end Deposit fixDeposit error: $result--');
      monitorPaymentWarning(
        PaymentEventCode.cashDeviceStatusUpdated,
        'Glory fix deposit returned a non-zero result',
        failureType: PaymentFailureType.deviceRejected,
        data: <String, Object?>{
          'cash_device': 'glory',
          'repay': repay,
          'attempt': attempt,
          'result_code': result,
        },
      );
      // errorHandleDialog('OPOS_fixDeposit_FAILURE');
      // return;
    }
    //getPutMoney.value = depositAmount.toString();
    //sleep(Duration(milliseconds: 300));

    if (repay) {
      monitorPaymentStageSucceeded(
        'cash_deposit_stop',
        PaymentEventCode.cashDepositStopSucceeded,
        'Glory cash deposit stopped for refund',
        data: <String, Object?>{
          'cash_device': 'glory',
          'repay': true,
          'attempt': attempt,
        },
      );
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
          monitorPaymentStageSucceeded(
            'cash_deposit_stop',
            PaymentEventCode.cashDepositStopSucceeded,
            'Glory cash deposit stop succeeded',
            data: <String, Object?>{
              'cash_device': 'glory',
              'repay': false,
              'attempt': attempt,
              'result_code': resultCode,
            },
          );
          _payCubeCloseTransaction(true);
        },
        onRetry: () {
          debugPrint("endDeposit 2");
          endDeposit(repay: repay, attempt: attempt + 1);
        },
        showError: (String error) {
          CashChanger.depositRepay;
          debugPrint("endDeposit error: $error");
          logger.info('-- end Deposit error: $error --');
          monitorPaymentStageFailed(
            'cash_deposit_stop',
            PaymentEventCode.cashDepositStopFailed,
            'Glory cash deposit stop failed',
            failureType: PaymentFailureType.deviceRejected,
            critical: true,
            error: error,
            data: <String, Object?>{
              'cash_device': 'glory',
              'repay': repay,
              'attempt': attempt,
              'result_code': resultCode,
            },
          );
          monitorPaymentFlowFailed(
            failedStage: 'cash_deposit_stop',
            failureType: PaymentFailureType.deviceRejected,
            error: error,
          );
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
    monitorPaymentInfo(
      PaymentEventCode.cashBalanceReadStarted,
      'Glory cash balance read started',
      status: 'started',
      data: const <String, Object?>{'cash_device': 'glory'},
    );
    var result = null;
    await CashChanger.getCashBalance(
      onSuccess: (value) {
        debugPrint("getMachineCashInfo 1");
        monitorPaymentInfo(
          PaymentEventCode.cashBalanceReadSucceeded,
          'Glory cash balance read succeeded',
          status: 'succeeded',
          data: <String, Object?>{
            'cash_device': 'glory',
            'cash_balance_raw': value,
          },
        );
        result = value;
      },
      catchError: (error) {
        debugPrint("getMachineCashInfo error: $error");
        monitorPaymentWarning(
          PaymentEventCode.cashBalanceReadFailed,
          'Glory cash balance read failed',
          failureType: PaymentFailureType.deviceUnavailable,
          error: error,
          data: const <String, Object?>{'cash_device': 'glory'},
        );
        if (retry == null) {
          errorHandleDialog(error.tr);
        } else {
          errorHandleDialogTwo(error.tr, retry);
        }
      },
    );
    return result;
  }

  _startOutputMoney(outMoney, {int attempt = 1}) async {
    if (isOutMoney) {
      logger.info("-- isOutMoney == true --");
      return false;
    }
    isOutMoney = true;
    monitorPaymentStageStarted(
      'cash_change',
      PaymentEventCode.cashChangeStarted,
      'Glory cash change payout started',
      data: <String, Object?>{
        'cash_device': 'glory',
        'change_amount': int.tryParse(outMoney.toString()),
        'attempt': attempt,
      },
    );
    logger.info('-- startOutPutMoney : $outMoney --');
    var success = false;
    debugPrint("startOutPutMoney");
    CashStep.value = 3;
    outStringMoney.value = outMoney.toString();
    final result =
        await CashChanger.dispenseChange(int.parse(outStringMoney.value));
    logger.info('-- startOutPutMoney result: $result --');
    if (result == null) {
      monitorPaymentStageFailed(
        'cash_change',
        PaymentEventCode.cashChangeFailed,
        'Glory cash change payout returned no result',
        failureType: PaymentFailureType.invalidResponse,
        critical: true,
        data: <String, Object?>{
          'cash_device': 'glory',
          'change_amount': int.tryParse(outMoney.toString()),
          'attempt': attempt,
        },
      );
      monitorPaymentFlowFailed(
        failedStage: 'cash_change',
        failureType: PaymentFailureType.invalidResponse,
      );
      isOutMoney = false;
      return false;
    }
    debugPrint("resultCode: $result");

    await CashChanger.changerResultNext(
        resultCode: result['code'] ?? 0,
        onSuccess: () {
          //已经结束入金，处理取引终了
          //_getPayCubeOutMoney();
          success = true;
          isOutMoney = false;
          monitorPaymentStageSucceeded(
            'cash_change',
            PaymentEventCode.cashChangeSucceeded,
            'Glory cash change payout succeeded',
            data: <String, Object?>{
              'cash_device': 'glory',
              'change_amount': int.tryParse(outMoney.toString()),
              'attempt': attempt,
            },
          );
        },
        onRetry: () {
          debugPrint("startOutPutMoney 2");
          isOutMoney = false;
          _startOutputMoney(outMoney, attempt: attempt + 1);
        },
        showError: (String error) {
          isOutMoney = false;
          success = false;
          monitorPaymentStageFailed(
            'cash_change',
            PaymentEventCode.cashChangeFailed,
            'Glory cash change payout failed',
            failureType: PaymentFailureType.deviceRejected,
            critical: true,
            error: error,
            data: <String, Object?>{
              'cash_device': 'glory',
              'change_amount': int.tryParse(outMoney.toString()),
              'attempt': attempt,
            },
          );
          monitorPaymentFlowFailed(
            failedStage: 'cash_change',
            failureType: PaymentFailureType.deviceRejected,
            error: error,
          );
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

  _repayFlow({int attempt = 1}) async {
    showEasyLoading();
    logger.info('-- start repayFlow --');
    monitorPaymentStageStarted(
      'cash_refund',
      PaymentEventCode.cashRefundStarted,
      'Glory cash refund started',
      data: <String, Object?>{
        'cash_device': 'glory',
        'refund_amount': int.tryParse(getPutMoney.value),
        'refund_method': 'deposit_repay',
        'attempt': attempt,
      },
    );
    final result = await CashChanger.depositRepay;
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () async {
          logger.info('-- start repayFlow depositRepay success --');
          monitorPaymentStageSucceeded(
            'cash_refund',
            PaymentEventCode.cashRefundSucceeded,
            'Glory cash refund succeeded',
            data: <String, Object?>{
              'cash_device': 'glory',
              'refund_amount': int.tryParse(getPutMoney.value),
              'refund_method': 'deposit_repay',
              'attempt': attempt,
              'result_code': result,
            },
          );
          //if (getPutMoney.value == '2000') {
          await _getPayCubeOutMoney(reportWithOrder: false);
          monitorPaymentFlowCancelled(cancelledStage: 'cash_refund');
          // } else {
          //   EasyLoading.dismiss();
          //   Get.back();
          // }
        },
        onRetry: () {
          debugPrint("depositRepay 2");
          _repayFlow(attempt: attempt + 1);
        },
        showError: (String error) {
          debugPrint("depositRepay error: $error");
          logger.info('-- start repayFlow depositRepay error: $error --');
          monitorPaymentWarning(
            PaymentEventCode.cashRefundFailed,
            'Glory deposit repay failed; using outside dispense fallback',
            failureType: PaymentFailureType.deviceRejected,
            error: error,
            data: <String, Object?>{
              'cash_device': 'glory',
              'refund_amount': int.tryParse(getPutMoney.value),
              'refund_method': 'deposit_repay',
              'attempt': attempt,
              'will_retry': true,
            },
          );
          // errorHandleDialog(GString.getToString(checkLanguage.value, error),
          //     confirm: () {
          //   Get.back();

          // });

          gloryOutputMoney(int.parse(getPutMoney.value));
        });
  }

  gloryOutputMoney(outMoney, {int attempt = 1}) async {
    //debugPrint("startOutPutMoney");
    logger.info('-- start gloryOutputMoney: $outMoney --');
    print("outMoney: $outMoney");
    monitorPaymentStageStarted(
      'cash_refund',
      PaymentEventCode.cashRefundStarted,
      'Glory outside cash refund started',
      data: <String, Object?>{
        'cash_device': 'glory',
        'refund_amount': int.tryParse(outMoney.toString()),
        'refund_method': 'dispense_change_outside',
        'attempt': attempt,
      },
    );
    //var outStringMoney = outMoney.toString();
    Object? outsideRefundError;
    bool? result =
        await CashChanger.dispenseChangeOutside(outMoney, onSuccess: () async {
      //已经结束入金，处理取引终了
      logger.info('-- start gloryOutputMoney success --');
      monitorPaymentStageSucceeded(
        'cash_refund',
        PaymentEventCode.cashRefundSucceeded,
        'Glory outside cash refund succeeded',
        data: <String, Object?>{
          'cash_device': 'glory',
          'refund_amount': int.tryParse(outMoney.toString()),
          'refund_method': 'dispense_change_outside',
          'attempt': attempt,
        },
      );
      await _getPayCubeOutMoney(reportWithOrder: false);
      monitorPaymentFlowCancelled(cancelledStage: 'cash_refund');
    }, catchError: (error) {
      logger.info('-- start gloryOutputMoney error: $error --');
      debugPrint("startOutPutMoney error: $error");
      outsideRefundError = error;
      // _errorHandleDialog(GString.getToString(checkLanguage.value, error),
      // confirm: () {
      //   Get.back();
      // });
    });

    debugPrint("resultCode: $result");
    if (!result) {
      monitorPaymentStageFailed(
        'cash_refund',
        PaymentEventCode.cashRefundFailed,
        'Glory outside cash refund failed',
        failureType: PaymentFailureType.deviceRejected,
        critical: true,
        error: outsideRefundError,
        data: <String, Object?>{
          'cash_device': 'glory',
          'refund_amount': int.tryParse(outMoney.toString()),
          'refund_method': 'dispense_change_outside',
          'attempt': attempt,
        },
      );
      monitorPaymentFlowFailed(
        failedStage: 'cash_refund',
        failureType: PaymentFailureType.deviceRejected,
        error: outsideRefundError,
      );
      EasyLoading.dismiss();
      errorHandleDialog('repay_cash_error'.tr, confirm: () {
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
    monitorPaymentStageStarted(
      'cash_reimburse_notify',
      PaymentEventCode.cashReimburseNotifyStarted,
      'Glory cash reimburse notification started',
      data: const <String, Object?>{'cash_device': 'glory'},
    );

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
        monitorPaymentStageSucceeded(
          'cash_reimburse_notify',
          PaymentEventCode.cashReimburseNotifySucceeded,
          'Glory cash reimburse notification succeeded',
          data: <String, Object?>{
            'cash_device': 'glory',
            'result_code': response['code'],
          },
        );
        Get.dialog(
            DialogUtils.alertOneButton("返金成功。",
                title: "お知らせ", confirmtitle: "はい", confirm: () {
              Get.back();
            }),
            barrierDismissible: false);
      } else {
        monitorPaymentStageFailed(
          'cash_reimburse_notify',
          PaymentEventCode.cashReimburseNotifyFailed,
          'Glory cash reimburse notification was rejected',
          failureType: PaymentFailureType.backendRejected,
          critical: true,
          data: <String, Object?>{
            'cash_device': 'glory',
            'result_code': response['code'],
          },
        );
        Get.dialog(
            DialogUtils.alertOneButton("返金失敗です。",
                title: "お知らせ", confirmtitle: "はい", confirm: () {
              Get.back();
            }),
            barrierDismissible: false);
      }
    }).catchError((error) {
      isReportCash.value = false;
      monitorPaymentStageFailed(
        'cash_reimburse_notify',
        PaymentEventCode.cashReimburseNotifyFailed,
        'Glory cash reimburse notification failed',
        failureType: PaymentFailureType.network,
        critical: true,
        error: error,
        data: const <String, Object?>{'cash_device': 'glory'},
      );
    });
  }

  //获取入金币种

  _getPutMoneyCurrency() async {
    String putMoneyCurrency = "";
    logger.info('-- getPutMoneyCurrency --');
    String? currencyCoinStringresult = await CashChanger.changerDIStatus(0x04);
    debugPrint("currencyCoinStringresult==${currencyCoinStringresult}");

    String? currencyCashStringresult = await CashChanger.changerDIStatus(0x82);
    debugPrint("currencyCashStringresult==${currencyCashStringresult}");

    if (currencyCoinStringresult != null &&
        currencyCoinStringresult.length > 36) {
      putMoneyCurrency = currencyCoinStringresult.substring(0, 18); //入金
    }

    if (currencyCashStringresult != null &&
        currencyCashStringresult.length > 24) {
      putMoneyCurrency += currencyCashStringresult.substring(0, 12);
    }

    return putMoneyCurrency;
  }

  _getInputMoneyInfo() async {
    debugPrint("_getInputMoneyInfo");
    logger.info('-- getInputMoneyInfo --');
    monitorPaymentStageStarted(
      'cash_denominations_read',
      PaymentEventCode.cashDenominationsReadStarted,
      'Glory cash denominations read started',
      data: const <String, Object?>{
        'cash_device': 'glory',
        'direction': 'deposit',
      },
    );
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
    if (getPutMoneyCurrency.value.trim().isEmpty &&
        (int.tryParse(getPutMoney.value) ?? 0) > 0) {
      monitorPaymentStageFailed(
        'cash_denominations_read',
        PaymentEventCode.cashDenominationsReadFailed,
        'Glory cash deposit denominations were empty',
        failureType: PaymentFailureType.invalidResponse,
        critical: true,
        data: <String, Object?>{
          'cash_device': 'glory',
          'direction': 'deposit',
          'coin_status_raw': currencyCoinStringresult,
          'banknote_status_raw': currencyCashStringresult,
        },
      );
      monitorPaymentFlowFailed(
        failedStage: 'cash_denominations_read',
        failureType: PaymentFailureType.invalidResponse,
      );
      return;
    }
    monitorPaymentStageSucceeded(
      'cash_denominations_read',
      PaymentEventCode.cashDenominationsReadSucceeded,
      'Glory cash deposit denominations read succeeded',
      data: <String, Object?>{
        'cash_device': 'glory',
        'direction': 'deposit',
        'snapshot_kind': 'device_read',
        'coin_status_raw': currencyCoinStringresult,
        'banknote_status_raw': currencyCashStringresult,
        'payment_info': getPutMoneyCurrency.value,
      },
    );
    monitorPaymentInfo(
      PaymentEventCode.cashDepositDenominationsUpdated,
      'Glory cash deposit denominations updated',
      status: 'received',
      data: <String, Object?>{
        'cash_device': 'glory',
        'direction': 'deposit',
        'snapshot_kind': 'device_read',
        'denomination_data': getPutMoneyCurrency.value,
      },
    );
    _payCubeCloseTransaction(false);
  }

  _getPayCubeOutMoney({reportWithOrder = true}) async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    //OutMoneytimer?.cancel();

    debugPrint("_getPayCubeOutMoney");
    logger.info('-- getPayCubeOutMoney --');
    monitorPaymentStageStarted(
      'cash_denominations_read',
      PaymentEventCode.cashDenominationsReadStarted,
      'Glory cash denominations read started',
      data: const <String, Object?>{
        'cash_device': 'glory',
        'direction': 'deposit_and_payout',
      },
    );
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

    if (getPutMoneyCurrency.value.trim().isEmpty &&
        currencyString.value.trim().isEmpty) {
      monitorPaymentStageFailed(
        'cash_denominations_read',
        PaymentEventCode.cashDenominationsReadFailed,
        'Glory cash denominations were empty',
        failureType: PaymentFailureType.invalidResponse,
        critical: true,
        data: <String, Object?>{
          'cash_device': 'glory',
          'direction': 'deposit_and_payout',
          'coin_status_raw': currencyCoinStringresult,
          'banknote_status_raw': currencyCashStringresult,
        },
      );
      monitorPaymentFlowFailed(
        failedStage: 'cash_denominations_read',
        failureType: PaymentFailureType.invalidResponse,
      );
      return;
    }
    monitorPaymentStageSucceeded(
      'cash_denominations_read',
      PaymentEventCode.cashDenominationsReadSucceeded,
      'Glory cash denominations read succeeded',
      data: <String, Object?>{
        'cash_device': 'glory',
        'direction': 'deposit_and_payout',
        'snapshot_kind': 'device_read',
        'coin_status_raw': currencyCoinStringresult,
        'banknote_status_raw': currencyCashStringresult,
        'payment_info': getPutMoneyCurrency.value,
        'change_info': currencyString.value,
      },
    );
    monitorPaymentInfo(
      PaymentEventCode.cashDepositDenominationsUpdated,
      'Glory cash deposit denominations updated',
      status: 'received',
      data: <String, Object?>{
        'cash_device': 'glory',
        'direction': 'deposit',
        'snapshot_kind': 'device_read',
        'denomination_data': getPutMoneyCurrency.value,
      },
    );
    monitorPaymentInfo(
      PaymentEventCode.cashPayoutDenominationsUpdated,
      'Glory cash payout denominations updated',
      status: 'received',
      data: <String, Object?>{
        'cash_device': 'glory',
        'direction': 'payout',
        'snapshot_kind': 'device_read',
        'denomination_data': currencyString.value,
      },
    );

    getOutMoneyString.value == false;
    if (reportWithOrder) {
      _reportOutMoney();
    } else {
      final operation = machineInfo.machineMode == "1" ? 1 : 2;
      monitorCashDenominationsFinalized(
        operation: operation,
        paymentInfo: getPutMoneyCurrency.value.trim(),
        changeInfo: currencyString.value.trim(),
        insertedAmount: int.tryParse(getPutMoney.value),
        changeAmount: int.tryParse(getPutMoney.value),
      );
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
    monitorPaymentStageStarted(
      'cash_exchange_report',
      PaymentEventCode.cashExchangeReportStarted,
      'Glory cash exchange report started',
      data: const <String, Object?>{'cash_device': 'glory'},
    );
    var formData = {
      'machineCode': machineInfo.machineCode,
      'puts': puts,
      'pops': pops,
      'shopCode': machineInfo.shopCode,
    };

    logger.info('formData: $formData');

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
        monitorPaymentStageSucceeded(
          'cash_exchange_report',
          PaymentEventCode.cashExchangeReportSucceeded,
          'Glory cash exchange report succeeded',
          data: <String, Object?>{
            'cash_device': 'glory',
            'result_code': response['code'],
          },
        );
        //showToast('完了しました', context: Get.context);
      } else {
        success = false;
        monitorPaymentStageFailed(
          'cash_exchange_report',
          PaymentEventCode.cashExchangeReportFailed,
          'Glory cash exchange report was rejected',
          failureType: PaymentFailureType.backendRejected,
          critical: true,
          data: <String, Object?>{
            'cash_device': 'glory',
            'result_code': response['code'],
          },
        );
        //showToast('両替失败!', context: Get.context);
      }
    }).catchError((error) {
      logger.info(
          '-- getPayCubeMoney reportExchange error:${error.toString()} --');
      success = false;
      monitorPaymentStageFailed(
        'cash_exchange_report',
        PaymentEventCode.cashExchangeReportFailed,
        'Glory cash exchange report failed',
        failureType: PaymentFailureType.network,
        critical: true,
        error: error,
        data: const <String, Object?>{'cash_device': 'glory'},
      );
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
    logger.info(
        'payCubeCloseTransaction cancel: $cancel isPrint: ${isPrint.value}');
    if (cancel) {
      monitorPaymentFlowCancelled(cancelledStage: 'cash_transaction_close');
    } else {
      monitorPaymentFlowSucceeded(completionStage: 'cash_transaction_close');
    }
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
            confirmtitle: "cash_full_confirm".tr, confirm: () {
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
            confirmtitle: "tag_button_yes".tr, confirm: () {
          confirm();
          Get.back();
        }, cancle: () {
          Get.back();
        }));
  }
}
