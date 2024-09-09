import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'package:get/get.dart';

extension ExchangeControllerExtension on SettingController {
  //get cashinfo

  startPutExchangeMoney() async {
    ignoreNotify.value = false;
    isStartPutMoney.value = true;
    hasExchangeCash = false;
    update();
    await beginDepositOutside();
  }

  getServerCashInfo() async {
    debugPrint('getServerCashInfo');
    var formData = {
      'machineCode': machineCode.value, //'PAZK8N7KKE8evkXks4',
    };
    debugPrint('formData: $formData');
    await request(
      'webBootGloryInformation',
      method: 'POST',
      parameters: formData,
    ).then((value) {
      debugPrint('value: $value');
      final response = json.decode(value.toString());
      debugPrint("response: $response");
      // ignore: invalid_use_of_protected_member
      if (response["code"] == 200 && response['data'] != null) {
        cashInfoList.value = response['data'];
        debugPrint('cashInfoList: ${cashInfoList.value}');
        cashInfo.value = _changeMapKey(response['data'], getCatVal);
        debugPrint('cashInfo: $cashInfo');
        update();
      }
    }).catchError((error) {
      debugPrint('error: $error');
    });
  }

  _changeMapKey(Map<String, dynamic> map, Function(String) keyFunc) {
    Map<String, int> newCashInfoList = {};

    map.forEach((key, value) {
      String newKey = keyFunc(key);
      newCashInfoList[newKey] = value;
    });

    return newCashInfoList;
  }

  Future<Map?> getMachineCashInfo() async {
    var resultMap = null;
    await CashChanger.getCashBalance(
      onSuccess: (value) {
        debugPrint("getMachineCashInfo 1");

        resultMap = value.split(',').asMap().map((key, value) {
          final cash = value.split(':');
          return MapEntry(catValFromInt(cash[0]), cash[1]);
        });
        
      },
      catchError: (error) {
        debugPrint("getMachineCashInfo error: $error");
        errorHandleDialog(GString.getToString(checkLanguage.value, error));
      },
    );
    
    // print('result: $result');
    // if (result == null) {
    //   return {};
    // }

    // //以逗号为分割获取每个数据，再以冒号分割获取key和value, 再赋值给一个Map
    // final resultMap = result.split(',').asMap().map((key, value) {
    //   final cash = value.split(':');
    //   return MapEntry(catValFromInt(cash[0]), cash[1]);
    // });
    // debugPrint('resultMap: ${resultMap}');
    debugPrint('resultMap: ${resultMap}');
    return resultMap;
  }

  //投币BEGINDEPOSITOUTSIDE
  beginDepositOutside() async {
    final result = await CashChanger.beginDepositOutside;
    debugPrint('beginDepositOutside: $result');
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () {
          debugPrint("beginDepositOutside 1");
          _getOutsideInputMoney();
        },
        onRetry: () {
          debugPrint("beginDepositOutside 2");
          beginDepositOutside();
        },
        showError: (String error) {
          debugPrint("beginDepositOutside error: $error");
          errorHandleDialog(GString.getToString(checkLanguage.value, error));
        });
  }

  _getOutsideInputMoney() async {
    debugPrint("_getOutsideInputMoney");
    await CashChanger.setEventsListener();
    CashChanger.onGetPutMoneyStringChange = (int result) {
      debugPrint("onGetPutMoneyStringChange _getOutsideInputMoney");
      if (ignoreNotify.value) {
        return;
      }
      if (result > 0) {
        debugPrint(
            "_getOutsideInputMoney getPutMoney.value==${result.toString()}");
        getPutMoney.value = result;
        getInputMoneyInfo();
      }
    };
  }

  //如果第一次兑换失败，重新投币开始，这部分数据有误，需要考虑这个问题。
  exChangeFlow(type, count, change) async {
    debugPrint('exChangeFlow: $type, $count, $change');

    showEasyLoading();

    final outBillInfo = "$type:$count";

    debugPrint(
        'exChangeFlow getPutMoneyCurrency: ${getPutMoneyCurrency.value}');

    final changeString =
        findClosestCombination(getPutMoneyCurrency.value, change);
    debugPrint('changeString: $changeString');

    final outStringTemp = changeString[1] + ',' + outBillInfo;
    debugPrint('outStringTemp: $outStringTemp');

    final outInfo = getNoneZeroInfo(outStringTemp);
    debugPrint('outInfo: $outInfo');

    debugPrint('putsString: ${changeString[0]}');

    var puts = [{}];

    if (changeString[0].contains(',')) {
      debugPrint('contains ,');
      puts = changeString[0].split(',').map((e) {
        final cat = e.split(':');
        return {
          'catVal': catValFromInt(cat[0]),
          'val': int.parse(cat[1]),
        };
      }).toList();
    } else {
      debugPrint('not contains ,');
      final cat = changeString[0].split(':');
      debugPrint('cat: $cat');
      puts = [
        {
          'catVal': catValFromInt(cat[0]),
          'val': int.parse(cat[1]),
        }
      ];
    }
    debugPrint('puts: $puts');

    final pops = [
      {
        'catVal': catValFromInt(type),
        'val': count,
      }
    ];

    debugPrint('pops: $pops');

    final depositAmount = await CashChanger.fixDeposit;
    // if (depositAmount != 0) {
    //   return;
    // }
    
    var outMoneySuccess = false;
    if(!hasExchangeCash) 
    outMoneySuccess = await gloryOutputMoney(outInfo); 

    if (!outMoneySuccess)
    EasyLoading.dismiss();
    
    if (outMoneySuccess || hasExchangeCash) {
      hasExchangeCash = true;
      final result = await reportExchange(puts, pops); //该步骤失败，后续被取消，数据与后台不一致，如何记录。
      if (result) {
        clearTask();
        Get.back();
      }
    }

    // Function endFunction = (result) async {
    //   debugPrint('endFunction: $result');
    //   if (result) {
    //     clearTask();
    //     Get.back();
    //   }
    // };

    // Function pecifyMoney = (result) async {
    //   debugPrint('pecifyMoney: $result');
    //   if (result) {
    //     final result =
    //         await outSpecifyMoney(outBillInfo, successTask: endFunction);
    //     endFunction(result);
    //   }
    // };

    // if (change > 0) {
    //   final result = await gloryOutputMoney(change, successTask: pecifyMoney);
    //   debugPrint('gloryOutputMoney result: $result');
    //   pecifyMoney(result);
    // } else {
    //   final result =
    //       await outSpecifyMoney(outBillInfo, successTask: endFunction);
    //   endFunction(result);
    // }
  }

  List<String> findClosestCombination(String depositDetails, int target) {
    debugPrint('findClosestCombination: $depositDetails, $target');

    //去除depositDetails 中为0的数据

    List<String> detailList = depositDetails.split(',');
    String noZeroString = '';
    for (String detail in detailList) {
      if (detail.split(':')[1] != '0') {
        if (noZeroString != '') {
          noZeroString += ',';
        }
        noZeroString += detail;
      }
    }
    debugPrint('noZeroString: $noZeroString');

    Map<String, int> depositMap = {};
    List<String> details = noZeroString.split(',');
    debugPrint('details: $details');

    // 解析每对值，构建 Map
    for (String detail in details) {
      List<String> parts = detail.split(':');

      String denomination = '${parts[0]}:${parts[1]}';
      int count = int.parse(parts[1]) * int.parse(parts[0]);
      depositMap[denomination] = count;
    }

    debugPrint('cashMap: $depositMap');

    var sum = 0;
    String outMoney = '';
    String putMoney = '';
    for (var entry in depositMap.entries) {
      sum += entry.value;

      if (target == 0) {
        outMoney = '';
        putMoney = noZeroString;
        break;
      }

      if (sum < target) {
        if (outMoney != '') {
          outMoney += ',';
        }
        outMoney += entry.key;
      } else if (sum == target) {
        if (outMoney != '') {
          outMoney += ',';
        }
        outMoney += entry.key;
        debugPrint('outMoney: $outMoney');
        //putMoney 字符串 等于 depositDetails字符串除去outMoney
        putMoney = noZeroString.replaceAll(outMoney + ',', '');
        debugPrint('putMoney: $putMoney');
        break;
      } else {
        int diffValue = sum - target; //815 - 315 = 500
        String currentKeyValue = entry.key.split(':')[0]; //100
        int valueCount = int.parse(entry.key.split(':')[1]); //8

        int offset = diffValue ~/ int.parse(currentKeyValue); //500 / 100 = 5
        int diffKey = valueCount - offset; //8 - 5 = 3

        putMoney = noZeroString.replaceAll(
            outMoney + ',' + entry.key + ',', ''); //500:1
        debugPrint('putMoney0: $putMoney');
        // int putMonyValue =
        //     (entry.value - diffValue) ~/ int.parse(currentKeyValue); // (800 - 500) / 100 = 3

        putMoney = '${entry.key.split(':')[0]}:$offset' + ',' + putMoney;
        debugPrint('putMoney: $putMoney');

        outMoney += ',' + '${entry.key.split(':')[0]}:$diffKey'; //100:3
        debugPrint('outMoney: $outMoney');

        break;
      }
    }
    return [putMoney, outMoney];
  }

  //日文提示
  tipsTitle() {
    if (getPutMoney.value == 0) {
      return 'お金を入れてください';
    } else if (getPutMoney.value > 0 && (getExchangeList().isEmpty)) {
      //请继续投钱
      return 'お金を入れ続けてください';
    } else {
      //请选择要兑换的金种
      return '両替の種類を選んでください';
    }
  }

  Future<bool> outSpecifyMoney(money,
      {Function? successTask, bool? fromeError}) async {
    bool result = await CashChanger.dispenseCash(money, onSuccess: () {
      debugPrint("exchangeMoney 1");
      if (fromeError != null && fromeError) {
        successTask?.call(true);
      }
    }, catchError: (error) {
      debugPrint("exchangeMoney error: $error");
      errorHandleDialog(GString.getToString(checkLanguage.value, error),
          confirm: () {
        Get.back();
        outSpecifyMoney(money, successTask: successTask, fromeError: true);
      });
    });
    return result;
  }

  gloryOutputMoney(outMoney, {Function? successTask, bool? fromeError}) async {
    //debugPrint("startOutPutMoney");
    print("outMoney: $outMoney");
    await CashChanger.removeEventsListener();
    bool success = false;
    final resultCode = await CashChanger.dispenseCashOutside(outMoney);
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
            // gloryOutputMoney(outMoney,
            //     successTask: successTask, fromeError: true);
          });
        });
    return success;
  }

  reportExchange(puts, pops) async {
    var success = false;
    debugPrint('reportExchange');
    var formData = {
      'machineCode': machineCode.value, //'PAZK8N7KKE8evkXks4',
      'puts': puts,
      'pops': pops,
      'shopCode': shopCode.value,
    };

    debugPrint('formData: $formData');

    await request(
      'webBootGloryExchange',
      method: 'POST',
      parameters: formData,
    ).then((value) {
      final response = json.decode(value.toString());
      debugPrint("response: $response");
      EasyLoading.dismiss();
      if (response["code"] == 200) {
        success = true;
        //showToast('完了しました', context: Get.context);
      } else {
        success = false;
        showToast('補充失败!', context: Get.context);
      }
    }).catchError((error) {
      success = false;
      EasyLoading.dismiss();
      showToast('補充失败!', context: Get.context);
    });
    return success;
  }

  bool canExchange() {
    var canExchange = false;
    //debugPrint('cashInfo: ${cashInfo.value}');
    cashInfo.forEach((key, value) {
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
    int cash1000 = cashInfo.value['1000'];
    int cash5000 = cashInfo.value['5000'];
    int cash10000 = cashInfo.value['10000'];

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

  exchangeMoney() async {
    debugPrint('exchangeMoney');
  }
}
