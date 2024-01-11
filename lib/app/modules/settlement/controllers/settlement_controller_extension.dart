import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodorder/app/services/cashMoneyParser.dart';

import 'settlement_controller.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
extension SettlementControllerExtension on SettlementController {

  startDeposit() async {
    //入金开始
    await CashChanger.startDeposit;
    allowtimer?.cancel();
    allowtimer =
        Timer.periodic(Duration(milliseconds: 250), (Timer allowt) async {
      allowStatus.value = await CashChanger.checkChangerStatus == 0
          ? "AllowSuccess"
          : "Error-F0--16";
      // 循环一定要记得设置取消条件，手动取消

      if (allowStatus.value == "AllowSuccess") {
        //如果打开了现金机，则去掉倒计时监听
        showCashTimer?.cancel();
        seconds.value = 120;
        _getInputMoney();
        //getPayCubeBackDataInfo();

        allowt.cancel();
      } else if (allowStatus.value == "Error-F0--16") {
        await CashChanger.depositRepay;
        sleep(Duration(milliseconds: 200));
        await CashChanger.startDeposit;
      } else if (allowStatus.value == "Error-A0--02") {
        //sleep(Duration(milliseconds: 300));
      } else {
        await CashChanger.startDeposit;
      }
    });
  }

  //获取投入金额
  _getInputMoney() async {
    //await Paycube.setReceiveEvent;
    debugPrint("getPutInMoney");
    CashChanger.setEventsListener();
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

  //入金开始-入金结束-交易结束-出金开始-交易结束  中间可set
  endDeposit() async {
    debugPrint("Endtoubi");
    sleep(Duration(milliseconds: 300));
    var depositAmount = await CashChanger.depositAmount;
    getPutMoney.value = depositAmount.toString();
    sleep(Duration(milliseconds: 300));


    //开启倒计时
    //_countDownTimer("2");

    stoptimer?.cancel();
    stoptimer =
        Timer.periodic(Duration(milliseconds: 950), (Timer stopt) async {
          final result = await CashChanger.endDeposit(2);
      stopStatus.value = result == 0 ? "StopSuccess":"error";
      debugPrint("stopStatus.value :${stopStatus.value}");
      if (stopStatus.value == "StopSuccess") {
        showCashTimer?.cancel();
        seconds.value = 180;
        timer?.cancel();
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
        } /* else {
          showToast(
              GString.getToString(this._checkLanguage, "show_put_money_error"));
        }*/

        stopt.cancel();
      } else {
        debugPrint("endDeposit 1");
        await CashChanger.depositRepay; //temp modify
      }
    });
  }

  //打印小票之后在关闭现金机，所以不考虑_isPrint
  gloryNextOper() async {
    debugPrint("nextOper");
    CashStep.value = 2;
    //sleep(Duration(milliseconds: 50));
    var depositAmount = await CashChanger.depositAmount;
    getPutMoney.value = depositAmount.toString();
    //开启倒计时
    //_countDownTimer("3");
    stoptimer?.cancel();
    stoptimer =
        Timer.periodic(Duration(milliseconds: 450), (Timer stopt) async {
      stopStatus.value =
          "StopSuccess"; //await Paycube.getPayCubeStopCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (stopStatus.value == "StopSuccess") {
        showCashTimer?.cancel();
        seconds.value = 180;
        timer?.cancel();
        //如果投币金额大于待支付总金额
        if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
          giveChangeMoney.value =
              int.parse(getPutMoney.value) - int.parse(totalPrice.value);

          //找零
          _startOutputMoney(giveChangeMoney.value);
        } else {
          //已经结束入金，处理取引终了
          _payCubeCloseTransaction();
        }

        stopt.cancel();
      } /* else if (stopStatus.value == "Error-A0--02") {

      }*/
      else {
        //await Paycube.endPayCube;
        debugPrint("endDeposit 3");
        await CashChanger.depositRepay;
      }
    });
  }

  _startOutputMoney(outMoney) async {
    debugPrint("startOutPutMoney");
    CashStep.value = 3;
    outStringMoney.value = outMoney.toString();
    //await Paycube.setReceiveEvent;

    //String outResult = await Paycube.outPayCubeMoney(outStringMoney.value);
    var resultCode =
        await CashChanger.dispenseChange(int.parse(outStringMoney.value));
    //_countDownTimer("6");
    outStatus.value = resultCode == 0 ? "OutSuccess" : "Error-A0--02";
    outmoneytimer?.cancel();
    outmoneytimer =
        Timer.periodic(Duration(milliseconds: 350), (Timer outmoneyt) async {
      outStatus.value = "OutSuccess"; //await Paycube.getPayCubeOutMoneyStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (outStatus.value == "OutSuccess") {
        //如果打开了现金机，则去掉倒计时监听
        showCashTimer?.cancel();
        seconds.value = 180;
        //如果取消不汇报，则出金后直接关闭 ？？？？？？
        _getPayCubeOutMoney();

        outmoneyt?.cancel();
      } else if (outStatus.value == "Error-A0--02" ||
          outStatus.value == "Error") {
        //await Paycube.setReceiveEvent;
        //sleep(Duration(milliseconds: 200));
        //await Paycube.getPayCubeOutMoneyStatus;
        //print("_outStatus处理中:$_outStatus");
      } else {
        await await CashChanger.dispenseChange(int.parse(outStringMoney.value));
      }
    });
  }

  _getPayCubeOutMoney() async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    OutMoneytimer?.cancel();
    //await Paycube.setReceiveEvent;
    //_countDownTimer("7");

    //var queryTimes = 0;
    // 循环一定要记得设置取消条件，手动取消
    //String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;

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
    //取引终了结束交易
    //var endTrade = await Paycube.endTrade;
    //开启倒计时
    //_countDownTimer("5");
    //await Paycube.setReceiveEvent;
    endtimer?.cancel();
    endtimer =
        Timer.periodic(Duration(milliseconds: 250), (Timer endtradet) async {
      endStatus.value = "EndSuccess"; //await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消 || _endStatus == "Error-A0--02"
      if (endStatus.value == "EndSuccess") {
        showCashTimer?.cancel();
        seconds.value = 180;
        //关闭机器后的跳转
        if (isPrint.value == true) {
          gotonewBack();
        } else {
          gotonewMenuPage();
        }

        endtradet.cancel();
      } else {
        //sleep(Duration(milliseconds: 200));
        //await Paycube.endTrade;
        debugPrint("endDeposit 2");
        await CashChanger.depositRepay;
      }
    });
  }

  _getPayCubePutMoneyCurrency() async {
    //_putcurrencyString现金机出款币种:61 00 00 62 00 00 63 00 00
    putMoneyCurrencytimer?.cancel();
    //await Paycube.setReceiveEvent;
    //_countDownTimer("8");
    var putQueryNum = 0;
    putMoneyCurrencytimer = Timer.periodic(Duration(milliseconds: 350),
        (Timer putMoneyCurrencyTime) async {
      if (putQueryNum > 100) {
        showCashTimer?.cancel();
        putMoneyCurrencyTime.cancel();
        getputMoneyString.value = false;
        //汇报入金币种
        reportPutMoneyCurrency();
      }
      if (getputMoneyString.value == true) {
        // 循环一定要记得设置取消条件，手动取消
        String putcurrencyString = getPutMoneyCurrency
            .value; //await Paycube.getPayCubePutMoneyCurrency;
        if (putcurrencyString.trim().length > 60) {
          var totalAmount =
              MoneyParser.calculateTotalAmount(putcurrencyString.trim());
          if (totalAmount == int.parse(getPutMoney.value)) {
            showCashTimer?.cancel();
            seconds.value = 180;
            getPutMoneyCurrency.value = putcurrencyString;
            putMoneyCurrencyTime.cancel();
            getputMoneyString.value = false;
            //汇报入金币种
            reportPutMoneyCurrency();
          }
        }
      }
      putQueryNum++;
      putMonyNum.value++;
    });
  }
  
}