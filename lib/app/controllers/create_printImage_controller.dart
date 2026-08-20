import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:android_usb_printer/android_usb_printer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/modules/settlement/views/receipt_constrained_box.dart';
import 'package:foodorder/app/printing/auto_print_layout.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../plugins/flutter_plugin_msprinter/lib/flutter_plugin_msprinter.dart';
import 'app_config.dart';
import 'machine_info.dart';

class CreatePrintImageController extends GetxController {
  MachineInfoController machineInfo = Get.find();
  AppConfig appConfig = Get.find();

  double get printWidth =>
      Platform.isAndroid ? machineInfo.machinePrintWidth : 580.0;
  Map get usbDevice => machineInfo.usbDevice;
  String get printLogoImage => machineInfo.printLogoImageUrl;
  bool get printReceiptOptions => machineInfo.printReceiptOptions;
  int get printPaperTxtSize => machineInfo.print_paper_txt_size;

  UsbDeviceInfo? get curUsbPrinter {
    if (usbDevice.isEmpty) {
      print('usbDevice is empty');
      DialogUtils.alertOneButton('プリンター未設定,設定してください', confirm: () {
        Get.back();
      });
      return null;
    }

    print('usbDevice.value:$usbDevice');
    return UsbDeviceInfo.fromMap(Map<String, dynamic>.from(usbDevice));
  }

  Future<void> tpPrintnew(dynamic printData, dynamic printType) async {
    _preparePrintData(printData);

    final kitchenTicketWidget = buildKitchenTicketWidget(
      printData,
      width: printWidth,
      fontSize: printPaperTxtSize,
    );
    final shouldPrintReceipt = printType.toString() == '1';

    if (Platform.isAndroid) {
      await _printAndroidKitchenTicket(
        kitchenTicketWidget,
        shouldPrintReceipt: shouldPrintReceipt,
      );
      if (shouldPrintReceipt) {
        await Future.delayed(const Duration(milliseconds: 300));
        await tpPrintReceipt(printData);
      }
      return;
    }

    _sendToWindowsUsbPrinter(kitchenTicketWidget);
    if (shouldPrintReceipt) {
      await Future.delayed(const Duration(milliseconds: 800));
      final receiptWidget = buildReceiptWidget(
        printData,
        width: printWidth,
        printOptions: printReceiptOptions,
      );
      _sendToWindowsUsbPrinter(receiptWidget);
    }
  }

  // Keep the Android-branch method name compatible with existing callers.
  Future<void> tpPrintNew(dynamic printData, dynamic printType) =>
      tpPrintnew(printData, printType);

  Future<void> tpPrintReceipt(dynamic printData) async {
    _preparePrintData(printData);

    if (Platform.isAndroid) {
      await _ensureImageLoaded(printLogoImage);
    }

    final receiptWidget = buildReceiptWidget(
      printData,
      width: printWidth,
      printOptions: printReceiptOptions,
    );

    if (Platform.isAndroid) {
      final base64Image = await _widgetToBase64Image(receiptWidget);
      await FlutterPluginMsprinter.sendPrintImgNew(
        base64Image,
        '1',
        '1',
        '',
      );
      await FlutterPluginMsprinter.sendPrintCut('1');
      return;
    }

    _sendToWindowsUsbPrinter(receiptWidget);
  }

  void _preparePrintData(dynamic printData) {
    printData['brandImage'] = printLogoImage;
    printData['containTax'] = machineInfo.taxSystem;
  }

  void _sendToWindowsUsbPrinter(Widget widget) {
    print('_sendToWindowsUsbPrinter: ${DateTime.now()}');
    final printWidget = ReceiptConstrainedBox(widget);
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: printWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(usbDevice: curUsbPrinter),
      ),
    );
  }

  Future<void> _printAndroidKitchenTicket(
    Widget kitchenTicketWidget, {
    required bool shouldPrintReceipt,
  }) async {
    final base64Image = await _widgetToBase64Image(kitchenTicketWidget);
    final cutMode = shouldPrintReceipt ? '1' : '0';

    await FlutterPluginMsprinter.sendPrintImgNew(
      base64Image,
      cutMode,
      '0',
      '',
    );
    await Future.delayed(
      Duration(milliseconds: shouldPrintReceipt ? 500 : 800),
    );
    await FlutterPluginMsprinter.sendPrintCut(cutMode);
  }

  Future<String> _widgetToBase64Image(Widget widget) async {
    final context = Get.context;
    if (context == null) {
      throw StateError('No BuildContext available for receipt rendering');
    }

    final byteData = await _widgetToImageExact(
      context: context,
      child: widget,
      width: printWidth,
    );
    final imageBytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    return base64Encode(imageBytes);
  }

  Future<ByteData> _widgetToImageExact({
    required BuildContext context,
    required Widget child,
    required double width,
  }) async {
    final size = await _layoutAndMeasureOffscreen(
      context: context,
      child: child,
      width: width,
    );
    debugPrint('Measured print widget size: $size');

    final safeHeight = size.height <= 0 ? 1.0 : size.height + 100;
    return WidgetToImage.widgetToImage(
      child,
      size: Size(width, safeHeight),
    );
  }

  Future<Size> _layoutAndMeasureOffscreen({
    required BuildContext context,
    required Widget child,
    required double width,
  }) async {
    final overlay = Overlay.of(context);
    final key = GlobalKey();
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          type: MaterialType.transparency,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: Align(
                alignment: Alignment.topLeft,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: width),
                    child: Container(key: key, child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    try {
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) {
        throw StateError('Failed to layout receipt widget for measurement');
      }
      return renderBox.size;
    } finally {
      entry.remove();
    }
  }

  Future<void> _ensureImageLoaded(String imageUrl) async {
    if (imageUrl.isEmpty) {
      return;
    }

    final completer = Completer<void>();
    final imageStream = CachedNetworkImageProvider(imageUrl).resolve(
      ImageConfiguration.empty,
    );
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (_, __) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        imageStream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        imageStream.removeListener(listener);
      },
    );
    imageStream.addListener(listener);
    await completer.future;
  }
}
