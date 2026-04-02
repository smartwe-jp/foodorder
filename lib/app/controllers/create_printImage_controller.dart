import 'dart:async';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/printing/auto_print_layout.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/settlement/views/receipt_constrained_box.dart';
import 'package:android_usb_printer/android_usb_printer.dart';
import 'app_config.dart';
import 'machine_info.dart';

class CreatePrintImageController extends GetxController {

  MachineInfoController machineInfo = Get.find();
  AppConfig appConfig = Get.find();
  double get printWidth => 580.0;
  Map get usbDevice => machineInfo.usbDevice;
  String get printLogoImage => machineInfo.printLogoImageUrl;
  bool get printReceiptOptions => machineInfo.printReceiptOptions;
  int get printPaperTxtSize => machineInfo.print_paper_txt_size;

  @override
  void onInit() async {
    super.onInit();
  }

  UsbDeviceInfo? get curUsbPrinter {
    if (usbDevice.isEmpty) {
      print("usbDevice is empty");
      DialogUtils.alertOneButton('プリンター未設定,設定してください', confirm: () {
        Get.back();
      });

      return null;
    }
    print("usbDevice.value:${usbDevice}");
    return UsbDeviceInfo.fromMap(Map<String, dynamic>.from(usbDevice));
  }

  _sendToUsePrinter(widget) {
    print("_sendToUsePrinter 打印lalala：${DateTime.now()}");
    final printWidget = ReceiptConstrainedBox(widget);
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: printWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(usbDevice: curUsbPrinter),
      ),
    );
  }

  tpPrintnew(printData, printType) async {
    printData['brandImage'] = printLogoImage;
    printData['containTax'] = machineInfo.taxSystem;

    Widget kitchenTicketWidget =
        buildKitchenTicketWidget(printData, width: printWidth);

    _sendToUsePrinter(kitchenTicketWidget);
    if (printType == "1") {
      await Future.delayed(Duration(milliseconds: 800));

      Widget receiptWidget = buildReceiptWidget(printData, width: printWidth, printOptions: printReceiptOptions, fontSize: printPaperTxtSize);
      _sendToUsePrinter(receiptWidget);
    }
  }

  tpPrintReceipt(printData) async {
    printData['brandImage'] = printLogoImage;
    printData['containTax'] = machineInfo.taxSystem;

    Widget receiptWidget = buildReceiptWidget(printData, width: printWidth, printOptions: printReceiptOptions, fontSize: printPaperTxtSize);
    _sendToUsePrinter(receiptWidget);
  }
}
