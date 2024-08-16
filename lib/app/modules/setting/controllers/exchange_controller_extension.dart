import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:get/get.dart';

extension ExchangeControllerExtension on SettingController {
  //get cashinfo

  getCashInfo() async {
    final result = await CashChanger.getCashBalance;
    print('result: $result');
    if (result == null) {
      return;
    }
    //以逗号为分割获取每个数据，再以冒号分割获取key和value, 再赋值给一个Map
    cashInfo.value = result.split(',').asMap().map((key, value) {
      final cash = value.split(':');
      return MapEntry(cash[0], cash[1]);
    });
    debugPrint('getCashInfo: ${cashInfo.value}');
    update();
  }

  exChangeFlow(type, count, change) async {
    debugPrint('exChangeFlow: $type, $count');
    final outBillInfo = ";$type:$count";
    final depositAmount = await CashChanger.fixDeposit;
    if (depositAmount != 0) {
      return;
    }

    Function endFunction = (result) async {
      debugPrint('endFunction: $result');
        if (result) {
          clearTask();
          Get.back();
        }
      };

    Function pecifyMoney = (result) async {
      debugPrint('pecifyMoney: $result');
      if (result) {
        final result =
          await outSpecifyMoney(outBillInfo, successTask: endFunction);
      endFunction(result);
      }
    };

    if (change > 0) {
      final result = await gloryOutputMoney(change, successTask: pecifyMoney);
      debugPrint('gloryOutputMoney result: $result');
      pecifyMoney(result);
    } else {
      final result =
          await outSpecifyMoney(outBillInfo, successTask: endFunction);
      endFunction(result);
    }
  }

  //日文提示
  tipsTitle() {
    if (getPutMoney.value == 0) {
      return 'お金を入れてください';
    } else if (getPutMoney.value > 0 &&
        (getExchangeList().isEmpty)) {
      //请继续投钱
      return 'お金を入れ続けてください';
    } else {
      //请选择要兑换的金种
      return '両替の種類を選んでください';
    }
  }

  Future<bool> outSpecifyMoney(money, {Function? successTask, bool? fromeError}) async {
    bool success = false;
    final result = await CashChanger.dispenseCash(money);
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () {
          debugPrint("exchangeMoney 1");
          success = true;
          if (fromeError != null && fromeError) {
            successTask?.call(true);
          } 
        },
        onRetry: () {
          debugPrint("exchangeMoney 2");
          outSpecifyMoney(money);
        },
        showError: (String error) {
          debugPrint("exchangeMoney error: $error");
          success = false;
          errorHandleDialog(GString.getToString(checkLanguage.value, error),
              confirm: () {
            Get.back();
            outSpecifyMoney(money, successTask: successTask, fromeError: true);
          });
        });
    return success;
  }

  gloryOutputMoney(outMoney, {Function? successTask, bool? fromeError}) async {
    //debugPrint("startOutPutMoney");
    print("outMoney: $outMoney");
    bool success = false;
    final resultCode = await CashChanger.dispenseChange(outMoney);
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("startOutPutMoney 1");
          success = true;
          if (fromeError != null && fromeError) {
            successTask?.call(true);
          }
        },
        onRetry: () {
          debugPrint("startOutPutMoney 2");
          gloryOutputMoney(outMoney);
        },
        showError: (String error) {
          debugPrint("startOutPutMoney error: $error");
          success = false;
          errorHandleDialog(GString.getToString(checkLanguage.value, error),
              confirm: () {
            Get.back();
            gloryOutputMoney(outMoney, successTask: successTask, fromeError: true);
          });
        });
    return success;
  }

  bool canExchange() {
    var canExchange = false;
    debugPrint('cashInfo: ${cashInfo.value}');
    cashInfo.value.forEach((key, value) {
      if (value != '0' && (key == '1000' || key == '5000' || key == '10000')) {
        canExchange = true;
      }
    });
    return canExchange;
  }

  bool canExchangeMoney() {
    bool canExchange = false;
    getExchangeList().forEach((element) {
      debugPrint('element: $element');
      if (element[2] == 0) {
        canExchange = true;
      }
    });
    return canExchange;
  }

  List<List<int>> getExchangeList() {
    final exchangeList = <List<int>>[];
    final cash1000 = int.parse(cashInfo.value['1000']);
    final cash5000 = int.parse(cashInfo.value['5000']);
    final cash10000 = int.parse(cashInfo.value['10000']);

    if (cash1000 > 0 && getPutMoney.value >= 1000) {
      //获取能换多少个1000
      var exchange1000 = getPutMoney.value ~/ 1000;
      //获取剩余的钱
      var remainMoney = getPutMoney.value % 1000;
      if (cash1000 * 1000 < getPutMoney.value) {
        exchange1000 = (getPutMoney.value - cash10000 * 1000) ~/ 1000;
        remainMoney = getPutMoney.value - cash10000 * 1000;
      }

      exchangeList.add([1000, exchange1000, remainMoney]);
    }

    if (cash5000 > 0 && getPutMoney.value >= 5000) {
      var exchange5000 = getPutMoney.value ~/ 5000;
      var remainMoney = getPutMoney.value % 5000;
      if (cash5000 * 5000 < getPutMoney.value) {
        exchange5000 = (getPutMoney.value - cash10000 * 5000) ~/ 5000;
        remainMoney = getPutMoney.value - cash10000 * 5000;
      }

      exchangeList.add([5000, exchange5000, remainMoney]);
      
    }

    if (cash10000 > 0 && getPutMoney.value >= 10000) {
      var exchange10000 = getPutMoney.value ~/ 10000;
      var remainMoney = getPutMoney.value % 10000;

      if (cash10000 * 10000 < getPutMoney.value) {
        exchange10000 = (getPutMoney.value - cash10000 * 10000) ~/ 10000;
        remainMoney = getPutMoney.value - cash10000 * 10000;
      }

      exchangeList.add([10000, exchange10000, remainMoney]);
    }
    return exchangeList;
  }

  //根据数值获取钱币显示名称
  String getCashName(String value) {
    switch (value) {
      case '1':
        return '一円';
      case '5':
        return '五円';
      case '10':
        return '十円';
      case '50':
        return '五十円';
      case '100':
        return '百円';
      case '500':
        return '五百円';
      case '1000':
        return '千円';
      case '2000':
        return '二千円';
      case '5000':
        return '五千円';
      case '10000':
        return '一万円';
      default:
        return '';
    }
  }
}
