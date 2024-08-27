

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
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:android_usb_printer/android_usb_printer.dart';

extension ReimburseOrderControllerExtension on ReimburseOrderController {

  gloryOutputMoney(outMoney) async {
    //debugPrint("startOutPutMoney");
    print("outMoney: $outMoney");
    var outStringMoney = outMoney.toString();
    final result =
        await CashChanger.dispenseChange(int.parse(outStringMoney));
    
    if (result == null) return;
    debugPrint("resultCode: $result");

    await CashChanger.changerResultNext(
        resultCode: result['code'] ?? 0,
        onSuccess: () {
          //已经结束入金，处理取引终了
          _getPayCubeOutMoney();
        },
        onRetry: () {
          debugPrint("startOutPutMoney 2");
          gloryOutputMoney(outMoney);
        },
        showError: (String error) {
          debugPrint("startOutPutMoney error: $error");
          _errorHandleDialog(GString.getToString(checkLanguage.value, error), 
          confirm: () {
            Get.back();
          });
        });
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

    currencyString.value = MoneyParser.migrationGloryToHexString(currency, isOutMoney: true);

    getOutMoneyString.value == false;

    reportChange(currencyString.value);
  }

  sendToUsePrinter(widget) {

    final printWidget = ReceiptConstrainedBox(widget);
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: printWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(usbDevice: curUsbPrinter,)),
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
        title: GString.getToString(checkLanguage.value, "tag_title"),
        confirmtitle:
            GString.getToString(checkLanguage.value, "tag_button_yes"),
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