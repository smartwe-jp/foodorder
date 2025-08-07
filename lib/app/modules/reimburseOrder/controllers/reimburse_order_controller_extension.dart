import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/reimburseOrder/controllers/reimburse_order_controller.dart';
import 'package:foodorder/app/modules/settlement/views/receipt_constrained_box.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/cashMoneyParser.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:android_usb_printer/android_usb_printer.dart';

extension ReimburseOrderControllerExtension on ReimburseOrderController {
  gloryOutputMoney(outMoney) async {
    //debugPrint("startOutPutMoney");
    print("outMoney: $outMoney");
    //var outStringMoney = outMoney.toString();
    bool? result =
        await CashChanger.dispenseChangeOutside(
          outMoney,
          onSuccess: () {
            //已经结束入金，处理取引终了
            _getPayCubeOutMoney();
          },
          catchError: (error) {
            debugPrint("startOutPutMoney error: $error");
            // _errorHandleDialog(GString.getToString(checkLanguage.value, error),
            // confirm: () {
            //   Get.back();
            // });
          }
        );

    debugPrint("resultCode: $result");
      if (!result) {
        String machineCash = await getMachineCashInfo();
        debugPrint('machineCash: $machineCash');
        if (machineCash.isEmpty) return false;
        String outMoneyString = await findChange(machineCash, outMoney);
        debugPrint('outMoneyString: $outMoneyString');
        if (outMoneyString.isEmpty) {
          _errorHandleDialog('cash_error_over'.tr);
          return false;
        }
        final result = await dispenseCashOutside(getNoneZeroInfo(outMoneyString));
        if (result) {
          _getPayCubeOutMoney();
        }
    }
  }

  getMachineCashInfo() async {
    var cashInfo = "";
    await CashChanger.getCashBalance(onSuccess: (value) {
      cashInfo = value;
    }, catchError: (error) {
      _errorHandleDialog(error.tr);
    });
    debugPrint('machine cashInfo: $cashInfo');
    return cashInfo;
  }

  String findChange(String cashStatus, int changeCount) {
    // 将字符串转换为Map
    Map<int, int> coins = Map.fromEntries(
      cashStatus.split(',').map((item) {
        List<String> parts = item.split(':');
        return MapEntry(int.parse(parts[0]), int.parse(parts[1]));
      }),
    );
    debugPrint('coins: $coins');

    // 按面额从大到小排序
    List<int> denominations = coins.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    debugPrint('denominations: $denominations');

    Map<int, int> change = {};

    for (int denomination in denominations) {
      int count = coins[denomination]!;
      while (count > 0 && changeCount >= denomination) {
        change[denomination] = (change[denomination] ?? 0) + 1;
        changeCount -= denomination;
        count--;
      }
      if (changeCount == 0) break;
    }

    if (changeCount > 0) {
      return "";
    }

    // 将结果转换为字符串
    return change.entries.map((e) => "${e.key}:${e.value}").join(',');
  }

  dispenseCashOutside(outInfo) async {
    var success = false;
    final depositAmount = await CashChanger.fixDeposit;
    debugPrint("fixDeposit: $depositAmount");
    final resultCode = await CashChanger.dispenseCashOutside(outInfo);
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("cancelReplanish 1");
          success = true;
        },
        onRetry: () {
          debugPrint("cancelReplanish 2");
          dispenseCashOutside(outInfo);
        },
        showError: (String error) {
          debugPrint("cancelReplanish error: $error");
          _errorHandleDialog(error.tr);
          success = false;
        });
    return success;
  }

  String getNoneZeroInfo(String input) {
    List<String> currencyPairs = input.split(',');

    List<String> nonZeroPairs = currencyPairs.where((pair) {
      List<String> parts = pair.split(':');
      return parts.length == 2 && parts[1] != '0' && int.parse(parts[0]) <= 500;
    }).toList();
    debugPrint("nonZeroPairs: $nonZeroPairs");

    List<String> nonZeroPairsOver500 = currencyPairs.where((pair) {
      List<String> parts = pair.split(':');
      return parts.length == 2 && parts[1] != '0' && int.parse(parts[0]) > 500;
    }).toList();
    debugPrint("nonZeroPairsOver500: $nonZeroPairsOver500");

    var result = nonZeroPairs.join(',');

    if (nonZeroPairsOver500.isNotEmpty) {
      result += ';' + nonZeroPairsOver500.join(',');
    }

    return result;
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

    var currency = "";

    if (currencyCoinStringresult != null &&
        currencyCoinStringresult.length > 36) {
      currency = currencyCoinStringresult.substring(18, 36); //出金
    }

    if (currencyCashStringresult != null &&
        currencyCashStringresult.length > 24) {
      currency += currencyCashStringresult.substring(12, 24);
    }

    currencyString.value =
        MoneyParser.migrationGloryToHexString(currency, isOutMoney: true);

    getOutMoneyString.value == false;

    reportChange(currencyString.value);
  }

  sendToUsePrinter(widget) {
    final printWidget = ReceiptConstrainedBox(widget);
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
          tempWidget: printWidget as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: PrinterInfo(
            usbDevice: curUsbPrinter,
          )),
    );
  }

  UsbDeviceInfo? get curUsbPrinter {
    if (usbDevice.isEmpty) {
      print("usbDevice is empty");
      //弹出提示框，打印机未设置，请设置打印机或者联系管理员
      Get.dialog(
        AlertDialog(
          title: Text("プリンター未設定"),
          content: Text("プリンターを設定してください。"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );

      return null;
    }
    print("usbDevice.value:${usbDevice}");
    return UsbDeviceInfo.fromMap(Map<String, dynamic>.from(usbDevice));
  }

  _errorHandleDialog(String error, {Function? confirm}) {
    EasyLoading.dismiss();
    debugPrint("errorHandleDialog: $error");
    Get.dialog(DialogUtils.alertOneButton(error,
        title: "tag_title".tr,
        confirmtitle:"tag_button_yes".tr,
        confirm: () {
      //allowClick.value == true;
      if (confirm != null) {
        confirm();
      } else {
        Get.back();
      }
    }));
  }
}
