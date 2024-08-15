

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
  void onInit() {
    print('ReimburseOrderController onInit');
  }

    startDeposit() async {
    debugPrint("startDeposit");

    final resultCode = await CashChanger.startDeposit;
    await CashChanger.changerResultNext(
        resultCode: resultCode,
        onSuccess: () {
          debugPrint("startDeposit 1");
          _checkChangerStatus();
        },
        onRetry: () {
          debugPrint("startDeposit 2");
          startDeposit();
        },
        showError: (String error) {
          debugPrint("startDeposit error: $error");
          //errorHandleDialog(GString.getToString(checkLanguage.value, error));
        });
  }

  _checkChangerStatus() async {
    debugPrint("checkChangerStatus 1");
    var resultCode = await CashChanger.checkChangerStatus;
    if (resultCode == null) {
      debugPrint("Unknown error");
      _checkChangerStatus();
      return;
    }
    debugPrint("checkChangerStatus resultCode:  " + resultCode.toString());
    if (resultCode == 0) {
      resultCode = 100;
    }
    HealthResultCode resultCodeEnum = HealthResultCode.values[resultCode - 100];
    switch (resultCodeEnum) {
      case HealthResultCode.OPOS_SUCCESS:
      case HealthResultCode.OPOS_E_ILLEGAL:
        _getInputMoney();
        break;
      case HealthResultCode.OPOS_E_CLOSED:
      case HealthResultCode.OPOS_E_NOTCLAIMED:
      case HealthResultCode.OPOS_E_DISABLED:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
      case HealthResultCode.OPOS_E_BUSY:
        _checkChangerStatus();
        break;
      case HealthResultCode.OPOS_E_NOHARDWARE:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
      default:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
    }
  }

  //获取投入金额
  _getInputMoney() async {
    //await Paycube.setReceiveEvent;
    debugPrint("getPutInMoney");
    CashChanger.onGetPutMoneyStringChange = (int result) {
      debugPrint("onGetPutMoneyStringChange");
      if (result > 0) {
        debugPrint("getPutMoney.value==${result.toString()}");
        //getPutMoney.value = result;
        //update();
        //_getInputMoneyInfo();
      }
    };
  }

  gloryOutputMoney(outMoney) async {
    //debugPrint("startOutPutMoney");
    print("outMoney: $outMoney");
    var outStringMoney = outMoney.toString();
    final resultCode =
        await CashChanger.dispenseChange(int.parse(outStringMoney));
    await CashChanger.changerResultNext(
        resultCode: resultCode,
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

_reportChange(changeString) {
    debugPrint("reportChange isReportCash = ${isReportCash.value}");
    if(isReportCash.value == true){
      return;
    }

    isReportCash.value = true;

    var formData = {
      "responseMessage": changeString,
      "machineCode": machineCode.value,
      "orderId": refundInfo.value["orderId"],
    };
    request('webBootReimburseNotify', method: 'POST', parameters: formData)
        .then((value) {
      var response = json.decode(value.toString());

      EasyLoading.dismiss();
      if(response['code'] == 200 && response['data'] == true){
        printReimburseReceipt(reimbursePrintViewSize, reimbursePrintView);//打印
        Get.dialog(
            DialogUtils.alertOneButton("返金成功。",
                title: "お知らせ",
                confirmtitle: "はい",
                confirm: () {
                  isReportCash.value = false;
                  orderIdController.text = "";
                  orderList.value = [];
                  refundInfo.value = {};
                  queryOrder();
                  Get.back();
                }),
            barrierDismissible: false
        );

      }else{
        Get.dialog(
            DialogUtils.alertOneButton("返金失敗です。",
                title: "お知らせ",
                confirmtitle: "はい",
                confirm: () {
                  orderIdController.text = "";
                  orderList.value = [];
                  refundInfo.value = {};
                  queryOrder();
                  Get.back();
                }),
            barrierDismissible: false
        );
      }
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

    currencyString.value = MoneyParser.migrationGloryToHexString(currency);

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