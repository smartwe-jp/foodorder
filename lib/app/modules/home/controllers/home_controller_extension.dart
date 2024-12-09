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
    logger.info('-- checkChangerStatus --');
    countDownTimer();

    int? resultCode = await CashChanger.checkChangerStatus;
    logger.info('-- checkChangerStatus : $resultCode --');
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
    logger.info('-- openCashChanger --');
    bool retCode = await CashChanger.openCashChanger(
      onSuccess: () async {
        debugPrint("OpenPayCube 6");
        logger.info('-- openCashChanger success --');
        await Future.delayed(Duration(milliseconds: 200));
        startDeposit();
      },
      catchError: (retCode, error) async {
        debugPrint("OpenPayCube error: $error");
        logger.info('-- openCashChanger error: $error --');
        if (retCode == 225) {
          //已打开 // clearinput?
          _calculateAmount();
        }
      },
    );
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
    logger.info('-- startDeposit --');
    await CashChanger.startDeposit(onSuccess: () async {
      debugPrint("Starttoubi success");
      logger.info('-- startDeposit success --');
      await Future.delayed(Duration(milliseconds: 200));
      _calculateAmount();
    }, catchError: (error) {
      logger.info('-- startDeposit error: $error --');
      debugPrint("Starttoubi error: $error");
    });
  }

  //计算投币金额
  void _calculateAmount() async {
    debugPrint("CalculateAmount 1");
    logger.info('-- calculateAmount --');
    //int connectCount = 0;
    //计算投币金额
    final result = await CashChanger.depositAmount; //这一步有问题，如果获取金额不为0，需要退金。
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () async {
          debugPrint("CalculateAmount 2");
          logger.info('-- depositAmount success --');
          await Future.delayed(Duration(milliseconds: 200));
          stopCashChanger(DepositAction.repay.index, true);
        },
        onRetry: () {
          debugPrint("CalculateAmount 3");
          sleep(Duration(milliseconds: 200));
          _calculateAmount();
        },
        showError: (String error) {
          logger.info('-- depositAmount error: $error --');
          stopCashChanger(DepositAction.repay.index, true);
          debugPrint("CalculateAmount error: $error");
        });
  }

  stopCashChanger(action, next) async {
    debugPrint("stopPaycube 1");
    checkSteeps.value = 3;
    logger.info('-- stopCashChanger --');
    int? result = await CashChanger.endDeposit(action);
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () async {
          debugPrint("stopPaycube 3");
          logger.info('-- stopCashChanger success --');
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
          logger.info('-- stopCashChanger error: $error --');
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
