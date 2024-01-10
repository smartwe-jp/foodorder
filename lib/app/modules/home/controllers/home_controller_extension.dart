import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'home_controller.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';

extension HomeControllerExtension on HomeController {

  //现金机开始 打开现金机，准备开始投币
  openCashChanger() async {
    debugPrint("OpenPayCube 1");
    checkSteeps.value = 2;
    //倒计时，一定时间不开启现金机则继续执行下一步
    //_countDownTimer();
    // String checkStatus = await Paycube.CheckPayCubeStatus;
    // debugPrint("OpenPayCube 2");
    // //如果检测现金机打开错误，则重新打开一下
    // if (checkStatus == "openError") {
    //   String openStatus = await Paycube.openPayCube;
    //   //print("机器未打开lib未null，重新打开并连接了");
    // } else {
    //   await Paycube.setReceiveEvent;
    // }
    int? resultCode = await CashChanger.checkChangerStatus;

    if (resultCode != 0) {
      // if (resultCode == 113 || resultCode == 101) {
      //   sleep(Duration(milliseconds: 200));
      //   await CashChanger.depositAmount;
      //   sleep(Duration(milliseconds: 200));
      //   await CashChanger.depositRepay;
      //   sleep(Duration(milliseconds: 200));
      //   showCashTimer?.cancel();
      //   Starttoubi();

      //   return;
      // }

      debugPrint("OpenPayCube 2");
      //如果检测现金机打开错误，则重新打开一下
      int? openStatus = await CashChanger.openCashChanger;
      if (openStatus == 0 || openStatus == 110 || openStatus == 106 || openStatus == 101) {
        debugPrint("OpenPayCube 3");
        //print("机器未打开lib未null，重新打开并连接了");

        sleep(Duration(milliseconds: 200));
        startDeposit();
      } else {
        debugPrint("Open CashChanger resultCode:  " + resultCode.toString());
        //await CashChanger.checkChangerStatus;
      }
      showCashTimer?.cancel();
    } else {
      debugPrint("OpenPayCube 4");
      await CashChanger.endDeposit(3);
      if (resultCode == 0) {
        debugPrint("OpenPayCube 5");
        sleep(Duration(milliseconds: 200));
        startDeposit();
      } else {
        debugPrint("Open CashChanger resultCode:  " + resultCode.toString());
        //await CashChanger.checkChangerStatus;
      }
      //sleep(Duration(milliseconds: 200));
      //await CashChanger.depositRepay;
      //await CashChanger.checkChangerStatus;
    }
  }

  //现金机开始 打开现金机，准备开始投币
  startDeposit() async {
    //入金开始
    debugPrint("Starttoubi 1");
    int connectCount = 0;

    // String strartPayCube = await Paycube.strartPayCube;
    // //调用插件的监听
    // Paycube.getPayCubeListener();

    int? resultCode = 0; //await CashChanger.startDeposit;

    // await Paycube.setReceiveEvent;
    allowtimer?.cancel();
    allowtimer =
        Timer.periodic(Duration(milliseconds: 150), (Timer allowt) async {
      resultCode = await CashChanger.startDeposit;
      connectCount++;
      if (connectCount > 50) {
        //退出关闭
        //exit(0);
        debugPrint("Starttoubi getIsFirstOpen");
        getIsFirstOpen();
      }
      //print("链接次数${}");
      // 循环一定要记得设置取消条件，手动取消
      if (resultCode == 0) {
        seconds.value = 60;
        //_countDownTimer();
        sleep(Duration(milliseconds: 200));
        _calculateAmount();
        allowt.cancel();
      } else if (resultCode == 106) {
        await CashChanger.endDeposit;
        //await Paycube.endTrade;
        sleep(Duration(milliseconds: 200));
        //await Paycube.strartPayCube;
        await CashChanger.startDeposit;
      } else if (resultCode == 114) {
        sleep(Duration(milliseconds: 300));
      } else {
        await CashChanger.startDeposit;
        //print("_allowStatus:$_allowStatus");
      }
    });
  }

  //计算投币金额
  void _calculateAmount() async {
    debugPrint("CalculateAmount 1");
    //int connectCount = 0;
    //计算投币金额
    int? resultCode = await CashChanger.depositAmount;
    // depositAmounttimer =
    //     Timer.periodic(Duration(microseconds: 150), (Timer allowt) async {
    //   resultCode = await CashChanger.depositAmount;
    //   connectCount++;
    //   if (connectCount > 50) {
    //     //退出关闭
    //     //exit(0);
    //     getIsFirstOpen();
    //   }
    //print("链接次数${}");
    // 循环一定要记得设置取消条件，手动取消
    // if (resultCode == 0) {
    //  seconds.value = 60;
    //  _countDownTimer();
    sleep(Duration(milliseconds: 200));
    stopCashChanger();
    //allowt.cancel();
    // } else if (resultCode == 106) {
    //   await CashChanger.depositAmount;
    //   //await Paycube.endTrade;
    //   sleep(Duration(milliseconds: 200));
    //   //await Paycube.strartPayCube;
    //   await CashChanger.depositAmount;
    // } else if (resultCode == 114) {
    //   sleep(Duration(milliseconds: 300));
    // } else {
    //   await CashChanger.depositAmount;
    //   //print("_allowStatus:$_allowStatus");
    // }
    // });
  }

  stopCashChanger() async {
    debugPrint("stopPaycube 1");
    checkSteeps.value = 3;
    //await Paycube.setReceiveEvent;
    //var endStatus = await Paycube.endPayCube;
    int? resultCode = 0; //await CashChanger.endDeposit;
    stopChecktimer?.cancel();
    stopChecktimer =
        Timer.periodic(Duration(milliseconds: 500), (Timer stopcheck) async {
      resultCode = await CashChanger.depositRepay;
      // 循环一定要记得设置取消条件，手动取消
      if (resultCode == 0) {
        //倒计时，一定时间不开启现金机则继续执行下一步
        debugPrint("stopPaycube 2");
        seconds.value = 60;
        //_countDownTimer();
        sleep(Duration(milliseconds: 200));
        closeCashChanger();
        stopcheck.cancel();
      // } else if (_stopStatus == 106) {
      //   //处理中
      //   sleep(Duration(milliseconds: 200));
      //   //await Paycube.endPayCube;
      //   await CashChanger.depositRepay;
      } else {
        //await Paycube.endPayCube;
        await CashChanger.depositRepay;
      }
    });
  }

  closeCashChanger() async {
    debugPrint("closePaycube 1");
    checkSteeps.value = 4;
    //取引终了结束交易
    //var endTrade = await Paycube.endTrade;
    //await Paycube.setReceiveEvent;
    int? resultCode = 0; //await CashChanger.closeCashChanger;

    // closetimer?.cancel();
    // closetimer =
    //     Timer.periodic(Duration(milliseconds: 500), (Timer closecheck) async {
    //   resultCode = await CashChanger.closeCashChanger;
    // 循环一定要记得设置取消条件，手动取消
    if (resultCode == 0) {
      showCashTimer?.cancel();
      //seconds.value = 60;

      //现金机打开一次后，判断是否第一次打开
      prohibitOneCash();

      //closecheck.cancel();
    } else {
      //await Paycube.endTrade;
      await CashChanger.closeCashChanger;
    }
    // });
  }
}