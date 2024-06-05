import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';

import 'home_controller.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';

extension HomeControllerExtension on HomeController {
  //打开之前 检查状态

  checkChangerStatus() async {
    debugPrint("checkChangerStatus 1");

    countDownTimer();

    int? resultCode = await CashChanger.checkChangerStatus;
    debugPrint("checkChangerStatus resultCode:  " + resultCode.toString());
    if (resultCode == null) {
      debugPrint("Unknown error");
      checkChangerStatus();
      return;
    }
    if (resultCode == 0) {
      resultCode = 100;
    }
    HealthResultCode resultCodeEnum = HealthResultCode.values[resultCode - 100];
    debugPrint(
        "checkChangerStatus resultCodeEnum:  " + resultCodeEnum.toString());
    switch (resultCodeEnum) {
      case HealthResultCode.OPOS_SUCCESS:
      case HealthResultCode.OPOS_E_ILLEGAL:
        await stopCashChanger(DepositAction.repay.index, true);
        break;
      case HealthResultCode.OPOS_E_CLOSED:
      case HealthResultCode.OPOS_E_NOTCLAIMED:
      case HealthResultCode.OPOS_E_DISABLED:
        await openCashChanger();
        break;
      case HealthResultCode.OPOS_E_BUSY:
        await Future.delayed(Duration(seconds: 5));
        await checkChangerStatus();
        break;
      case HealthResultCode.OPOS_E_NOHARDWARE:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
      default:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
    }
  }

  //现金机开始 打开现金机，准备开始投币
  openCashChanger() async {
    debugPrint("OpenPayCube 1");
    checkSteeps.value = 2;
    //如果检测现金机打开错误，则重新打开一下
    int? retCode = await CashChanger.openCashChanger;
    debugPrint("OpenPayCube retCode: $retCode");
    //debugPrint("OpenPayCube 3");
    await CashChanger.openChangerNext(
        openResult: retCode,
        onSuccess: () async {
          debugPrint("OpenPayCube 6");
          await Future.delayed(Duration(milliseconds: 200));
          startDeposit();
        },
        onRetry: () {
          debugPrint("OpenPayCube 7");
          sleep(Duration(milliseconds: 200));
          openCashChanger();
        },
        showError: (String error) {
          debugPrint("OpenPayCube error: $error");
          if (retCode==225) {//已打开 
            _calculateAmount();
          }
        });
  }

  //现金机开始 打开现金机，准备开始投币
  startDeposit() async {
    //入金开始
    debugPrint("Starttoubi 1");
    int connectCount = 0;
    connectCount++;
    if (connectCount > 50) {
      //退出关闭
      //exit(0);
      debugPrint("Starttoubi getIsFirstOpen");
      getIsFirstOpen();
    }
    int? result = await CashChanger.startDeposit;
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () async {
          debugPrint("Starttoubi success");
          await Future.delayed(Duration(milliseconds: 200));
          _calculateAmount();
        },
        onRetry: () async {
          debugPrint("Starttoubi retry");
          await Future.delayed(Duration(milliseconds: 200));
          startDeposit();
        },
        showError: (String error) {
          debugPrint("Starttoubi error: $error");
        });
  }

  //计算投币金额
  void _calculateAmount() async {
    debugPrint("CalculateAmount 1");
    //int connectCount = 0;
    //计算投币金额
    final result = await CashChanger.depositAmount;
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () async {
          debugPrint("CalculateAmount 2");
          await Future.delayed(Duration(milliseconds: 200));
          stopCashChanger(DepositAction.repay.index, true);
        },
        onRetry: () {
          debugPrint("CalculateAmount 3");
          sleep(Duration(milliseconds: 200));
          _calculateAmount();
        },
        showError: (String error) {
          debugPrint("CalculateAmount error: $error");
        });
  }

  stopCashChanger(action, next) async {
    debugPrint("stopPaycube 1");
    checkSteeps.value = 3;
    int? result = await CashChanger.endDeposit(action);
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () async {
          debugPrint("stopPaycube 3");
          await Future.delayed(Duration(milliseconds: 200));
          if (next) {
            closeCashChanger();
          }
        },
        onRetry: () async {
          debugPrint("stopPaycube 4");
          await Future.delayed(Duration(milliseconds: 200));
          stopCashChanger(action, true);
        },
        showError: (String error) async {
          debugPrint("stopCashChanger error: $error");
        });
  }

  closeCashChanger() async {
    debugPrint("closePaycube 1");
    checkSteeps.value = 4;
    showCashTimer?.cancel();
    prohibitOneCash();
  }
}
