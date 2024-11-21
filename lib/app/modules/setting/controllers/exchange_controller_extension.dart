import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/common/StringExtension.dart';
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
    taskTouch = false;
    ignoreNotify.value = false;
    isStartPutMoney.value = true;
    hasExchangeCash = false;

    update();
    await beginDepositOutside();
  }

  getServerCashInfo() async {
    debugPrint('---getServerCashInfo---');
    var formData = {
      'machineCode': machineCode.value, //'PAZK8N7KKE8evkXks4',
    };
    debugPrint('formData: $formData');
    await request(
      'webBootGloryInformation',
      method: 'POST',
      parameters: formData,
    ).then((value) {
      //debugPrint('value: $value');
      final response = json.decode(value.toString());
      debugPrint("getServerCashInfo response: $response");
      // ignore: invalid_use_of_protected_member
      if (response["code"] == 200 && response['data'] != null) {
        cashInfoList.value = response['data'];
        //debugPrint('cashInfoList: ${cashInfoList.value}');
        cashInfo.value = _changeMapKey(response['data'], getCatVal);
        //debugPrint('cashInfo: $cashInfo');
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

  Future<Map?> getMachineCashInfos() async {
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

    CashChanger.onStatusUpdateEventChange = (String result) async {
      debugPrint("onStatusUpdateEventChange : $result");
      if (result == 'OK') {
        return;
      }
      if (result == 'FULL' || result == 'NEARFULL') {
        //GString.getToString(language, 'load_menu_failure_content').trParams({'cash': '$_countdown'}),
        String? machineChangeInfo = await getMachineCashInfo();
        if (machineChangeInfo == null) {
          return;
        }

        String cashList = machineChangeInfo.findMaxCash();

        errorHandleDialog('フルの金種だか、もしくはニアフルの金種があります：$cashList', confirm: () {

          Get.back();
          cancelTimer(shouldBack: false);
        });
        return;
      }
      errorHandleDialog(result);
    };
  }

  Map<String, int> parseCoinCount(String input) {
    return Map.fromEntries(input.split(',').map((item) {
      List<String> parts = item.split(':');
      return MapEntry(parts[0], int.parse(parts[1]));
    }).where((entry) => entry.value > 0));
  }

  Map<String, int> parseCoinCounts(String input, String local, String out) {
    Map<String, int> result = {};

    void processInput(String str) {
      str.split(',').forEach((item) {
        List<String> parts = item.split(':');
        String key = parts[0];
        int value = int.parse(parts[1]);
        result[key] = (result[key] ?? 0) + value;
      });
    }

    void processOutput(String str) {
      str.split(',').forEach((item) {
        List<String> parts = item.split(':');
        String key = parts[0];
        int value = int.parse(parts[1]);
        int count = (result[key] ?? 0);
        if (count >= value) {
          result[key] = count - value;
        }
      });
    }

    processInput(input);
    processInput(local);
    processOutput(out);

    return Map.fromEntries(result.entries.where((entry) => entry.value > 0));
  }

  List<MapEntry<String, int>>? findChange(
      List<String> coins, Map<String, int> coinCounts, int target) {
    if (target == 0) return [];
    if (target < 0 || coins.isEmpty) return null;

    String coin = coins.first;
    int coinValue = int.parse(coin);
    int count = coinCounts[coin] ?? 0;

    for (int i = 0; i <= count; i++) {
      var result =
          findChange(coins.sublist(1), coinCounts, target - coinValue * i);
      if (result != null) {
        final resultMap = i > 0 ? [MapEntry(coin, i), ...result] : result;
        return resultMap;
      }
    }

    return null;
  }

  List<MapEntry<String, int>>? findOptimalChange(
      List<String> coins, Map<String, int> coinCounts, int target) {
    if (target == 0) return [];
    if (target < 0 || coins.isEmpty) return null;
    debugPrint("findOptimalChange");
    List<MapEntry<String, int>>? bestResult;
    int minCoins = 9223372036854775807;
    debugPrint("minCoins:$minCoins");
    String coin = coins.first;
    int coinValue = int.parse(coin);
    int count = coinCounts[coin] ?? 0;
    debugPrint("coin:$coin, coinValue:$coinValue, count:$count");

    for (int i = 0; i <= count; i++) {
      var result = findOptimalChange(
          coins.sublist(1), coinCounts, target - coinValue * i);
      if (result != null) {
        final currentResult = i > 0 ? [MapEntry(coin, i), ...result] : result;
        int totalCoins =
            currentResult.fold(0, (sum, entry) => sum + entry.value);
        if (totalCoins < minCoins) {
          minCoins = totalCoins;
          bestResult = currentResult;
        }
      }
    }

    return bestResult;
  }

  String formatChange(List<MapEntry<String, int>> change, type, int count) {
    Map<String, int> changeMap = Map.fromEntries(change);

    changeMap.update(type, (existingCount) => existingCount + count,
        ifAbsent: () => count);

    return changeMap.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join(',');
  }

  Map<String, int> formatRemainingCoins(
      Map<String, int> coinCounts, List<MapEntry<String, int>> change) {
    Map<String, int> remainingCoins = Map.from(coinCounts);
    for (var entry in change) {
      remainingCoins[entry.key] =
          (remainingCoins[entry.key] ?? 0) - entry.value;
    }
    return Map.fromEntries(
        remainingCoins.entries.where((entry) => entry.value > 0));
  }

  String mapToString(Map<String, String> map) {
    return map.entries.map((entry) => '${entry.key}:${entry.value}').join(',');
  }

  //exchangeFlow
  exchangeFlow(type, count, disconut) async {
    debugPrint('exChangeFlow: $type, $count, $disconut');

    showEasyLoading();

    debugPrint(
        'exChangeFlow getPutMoneyCurrency: ${getPutMoneyCurrency.value}');

    String? localCashInfo = await getMachineCashInfo();
    if (localCashInfo == null) return;
    Map<String, int> coinCounts = parseCoinCounts(
        getPutMoneyCurrency.value, localCashInfo, '$type:$count');

    debugPrint('coinCounts : $coinCounts');
    List<String> availableCoins = coinCounts.keys.toList(); //..sort();
    debugPrint('availableCoins : $availableCoins');

    List<MapEntry<String, int>>? change =
        findChange(availableCoins, coinCounts, disconut);
    debugPrint('change : $change');

    if (change == null) {
      EasyLoading.dismiss();
      errorHandleDialog(
          "現在の組み合わせは両替できません、キャンセルしてやり直してください。"); //localized needed
      return;
    }

    String changeString = formatChange(change, type, count);
    debugPrint('changeString : $changeString');

    String outInfo = getNoneZeroInfo(changeString);
    debugPrint('outInfo: $outInfo');

    Map<String, int> putCoinCounts = parseCoinCount(getPutMoneyCurrency.value);
    //Map remainingCoins = formatRemainingCoins(putCoinCounts, change);

    final puts = putCoinCounts.entries.map((e) {
      return {
        'catVal': catValFromInt(e.key),
        'val': e.value,
      };
    }).toList();

    debugPrint('puts: $puts');

    final pops = [
      {
        'catVal': catValFromInt(type),
        'val': count,
      },
      ...change.map((item) => {
            'catVal': catValFromInt(item.key),
            'val': item.value,
          })
    ];

    debugPrint('pops: $pops');

    //final depositAmount =
    await CashChanger.fixDeposit;
    // if (depositAmount != 0) {
    //   return;
    // }

    var outMoneySuccess = false;
    if (!hasExchangeCash) outMoneySuccess = await gloryOutputMoney(outInfo);

    if (!outMoneySuccess) EasyLoading.dismiss();

    if (outMoneySuccess || hasExchangeCash) {
      hasExchangeCash = true;
      final result =
          await reportExchange(puts, pops); //该步骤失败，后续被取消，数据与后台不一致，如何记录。
      if (result) {
        clearTask();
        Get.back();
      }
    }
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
        showToast('両替失败!', context: Get.context);
      }
    }).catchError((error) {
      success = false;
      EasyLoading.dismiss();
      showToast('両替失败!', context: Get.context);
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

  List<int> getExchange() {
    int exChangeType = int.parse(getCatVal(exchangeFromInfo.keys.first));
    int count = exchangeFromInfo.values.first;

    if (count > 0 && getPutMoney.value >= exChangeType && exChangeType > 0) {
      //预计要换多少个
      var exchange = getPutMoney.value ~/ exChangeType;
      //debugPrint('exchange1000: $exchange');
      //获取剩余的钱
      var remainMoney = getPutMoney.value % exChangeType;
      //debugPrint('remainMoney: $remainMoney');
      if (count < exchange) {
        //不够换
        exchange = count;
        //debugPrint('exchange1000 e: $exchange');
        remainMoney = getPutMoney.value - count * exChangeType;
        //debugPrint('remainMoney e: $remainMoney');
      }

      return [exChangeType, exchange, remainMoney];
    }

    return [];
  }

  List<List<int>> getExchangeList() {
    final exchangeList = <List<int>>[];
    int cash1000 = cashInfo.value['1000'];
    int cash5000 = cashInfo.value['5000'];
    int cash10000 = cashInfo.value['10000'];

    if (cash1000 > 0 && getPutMoney.value >= 1000) {
      //预计要换多少个1000
      var exchange1000 = getPutMoney.value ~/ 1000;
      debugPrint('exchange1000: $exchange1000');
      //获取剩余的钱
      var remainMoney = getPutMoney.value % 1000;
      debugPrint('remainMoney: $remainMoney');
      if (cash1000 < exchange1000) {
        //不够换
        exchange1000 = cash1000;
        debugPrint('exchange1000 e: $exchange1000');
        remainMoney = getPutMoney.value - cash1000 * 1000;
        debugPrint('remainMoney e: $remainMoney');
      }

      exchangeList.add([1000, exchange1000, remainMoney]);
    }

    if (cash5000 > 0 && getPutMoney.value >= 5000) {
      var exchange5000 = getPutMoney.value ~/ 5000;
      var remainMoney = getPutMoney.value % 5000;
      if (cash5000 < exchange5000) {
        exchange5000 = cash5000;
        remainMoney = getPutMoney.value - cash5000 * 5000;
      }

      exchangeList.add([5000, exchange5000, remainMoney]);
    }

    if (cash10000 > 0 && getPutMoney.value >= 10000) {
      var exchange10000 = getPutMoney.value ~/ 10000;
      var remainMoney = getPutMoney.value % 10000;

      if (cash10000 < exchange10000) {
        exchange10000 = cash10000;
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
