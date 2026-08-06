import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'dart:typed_data';

import 'package:foodorder/app/services/logUtil.dart';
import 'package:get/get.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../config/colorsUtil.dart';
import '../modules/settlement/views/receipt_constrained_box.dart';
import '../plugins/flutter_plugin_msprint/lib/flutter_plugin_msprinter.dart';
import '../printing/auto_print_layout.dart';
import '../services/HomeServices.dart';
import '../services/ScreenAdapter.dart';
import '../services/formatMoney.dart';

// lib/app/controllers/create_printImage_controller.dart

extension _MeasureAndRender on CreatePrintImageController {
Future<Size> _layoutAndMeasureOffscreen({
  required BuildContext context,
  required Widget child,
  required double width,
}) async {
  // Measure by inserting into Overlay with zero opacity to ensure layout happens.
  final overlay = Overlay.of(context);
  // if (overlay == null) {
  //   throw StateError('No Overlay found in context');
  // }

  final key = GlobalKey();
  final completer = Completer<Size>();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          type: MaterialType.transparency,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.0,
              child: Align(
                alignment: Alignment.topLeft,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: width),
                    child: Container(
                      key: key,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

  // Wait for a frame so layout completes.
  await Future.delayed(Duration.zero);
  await WidgetsBinding.instance.endOfFrame;

  try {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      throw StateError('Failed to layout widget for measurement');
    }
    final Size size = renderBox.size;
    completer.complete(size);
  } catch (e) {
    completer.completeError(e);
  } finally {
    // Remove the invisible overlay content.
    entry.remove();
  }

  return completer.future;
}

Future<ByteData> _widgetToImageExact({
  required BuildContext context,
  required Widget child,
  required double width,
}) async {
  final Size size = await _layoutAndMeasureOffscreen(
    context: context,
    child: child,
    width: width,
  );

  debugPrint('Measured size: $size');

  final double safeHeight = size.height <= 0 ? 1.0 : size.height + 100;

  return WidgetToImage.widgetToImage(
    child,
    size: Size(width, safeHeight),
  );
}
}

class CreatePrintImageController extends GetxController {
  MachineInfoController machineInfo = Get.find();
  AppConfig appConfig = Get.find();
  double get printWidth => machineInfo.machinePrintWidth;
  int get print_paper_txt_size => machineInfo.print_paper_txt_size;
  String get printLogoImage => machineInfo.printLogoImageUrl;
  bool get printReceiptOptions => machineInfo.printReceiptOptions;
  int get printPaperTxtSize => machineInfo.print_paper_txt_size;

  @override
  void onInit() {
    super.onInit();
  }


  tpPrintNew(printData, printType) async {
    printData['brandImage'] = printLogoImage;
    printData['containTax'] = machineInfo.taxSystem;

    Widget kitchenTicketWidget =
    buildKitchenTicketWidget(printData, width: printWidth, fontSize: printPaperTxtSize);

    ByteData byteData = await _widgetToImageExact(
        context: Get.context!,
        child: kitchenTicketWidget,
        width: printWidth);

    List<int> imageBytes = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    String base64Image = base64Encode(imageBytes);

    if (printType == "1") {
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "0", "");
      await Future.delayed(Duration(milliseconds: 500));
      await FlutterPluginMsprinter.sendPrintCut("1");
      await Future.delayed(Duration(milliseconds: 300));
      await tpPrintReceipt(printData);
    } else {
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", "0", "");
      await Future.delayed(Duration(milliseconds: 800));
      await FlutterPluginMsprinter.sendPrintCut("0");
    }
  }

  tpPrintReceipt(printData) async {
    printData['brandImage'] = printLogoImage;
    printData['containTax'] = machineInfo.taxSystem;
    await ensureImageLoaded(printLogoImage);
    Widget receiptWidget = buildReceiptWidget(printData, width: printWidth, printOptions: printReceiptOptions);

    //ByteData byteData = await WidgetToImage.widgetToImage(receiptWidget,
    //    size: Size(printWidth, 600));
    ByteData byteData = await _widgetToImageExact(
        context: Get.context!,
        child: receiptWidget,
        width: printWidth);

    List<int> imageBytes = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    String base64Image = base64Encode(imageBytes);

    //_showAndPrint(base64Image, printWidget);

    //await Future.delayed(Duration(milliseconds: 800));
    await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "1", "");
    //await Future.delayed(Duration(milliseconds: 300));
    await FlutterPluginMsprinter.sendPrintCut("1");
  }

  Future<void> ensureImageLoaded(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    final provider = CachedNetworkImageProvider(imageUrl);
    final config = ImageConfiguration.empty;
    final Completer<void> completer = Completer<void>();

    provider.resolve(config).addListener(
      ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (Object error, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      ),
    );

    try {
      await completer.future;
    } catch (e) {
      logE('ensureImageLoaded error: $e');
      await CachedNetworkImage.evictFromCache(imageUrl);
    }
  }
}
