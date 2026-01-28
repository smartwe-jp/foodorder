

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/setting/printList/state.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeiPrintView.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:foodorder/app/modules/settlement/views/receipt_constrained_box.dart';
import 'package:foodorder/app/services/PrintInfoService.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:android_usb_printer/android_usb_printer.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../../../plugins/flutter_plugin_msprint/lib/flutter_plugin_msprinter.dart';


class PrintListPageLogic extends GetxController with StateMixin {
  MachineInfoController machineInfo = Get.find();
  final PrintListState state = PrintListState();
  PrintService printService = Get.find();
  CreatePrintImageController createPrintImageController = Get.find();
  PrintInfoService printInfoService = Get.find();
  //Map get usbDevice => machineInfo.usbDevice;

  @override
  void onInit() {
    super.onInit();
    loadCategoriesAndData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> loadPrintList() async {
    change(null, status: RxStatus.loading());
    try {
      final svc = Get.find<PrintInfoService>();
      final jobs = await svc.readAll();
      // 最近 30 条（假设添加顺序即时间顺序）
      final recent = jobs.length > 30 ? jobs.sublist(jobs.length - 30) : jobs;
      state.printList = recent.reversed // 最新的放前面
          .map((e) => PrintOrderItem.fromMap(e))
          .toList();
      change(state, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  void reprint(PrintOrderItem item) {
    createPrintImageController.tpPrintNew(item.raw, machineInfo.receiptPrintType);
  }

  void rePrintSummary(PrintSummaryItem item) {
    showPrintView(item.raw);
  }

  String getRendererForCategory(String category) {
    return state.categoryRenderer[category] ?? 'order';
  }

  /// 加载分类 + 默认分类的数据
  Future<void> loadCategoriesAndData() async {
    change(null, status: RxStatus.loading());
    try {
      await printInfoService.init();
      final cats = printInfoService.listCategories();
      state.categories = cats.isNotEmpty ? cats : ['default'];
      state.selectedCategory = state.categories.first;
      await loadCategoryItems(state.selectedCategory!);
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  /// 切换分类
  Future<void> changeSelectedCategory(String category) async {
    if (state.selectedCategory == category) return;
    state.selectedCategory = category;
    await loadCategoryItems(category);
  }

  void printSummaryWindows(Map data, double printLength) {
    // final printView = PrintView(isPrint: true, printInfo: data);
    //
    // final printWidget = Container(
    //   width: machineInfo.machinePrintWidth,
    //   height: printLength + 150,
    //   child: printView,
    // );
    //
    // final widget = ReceiptConstrainedBox(printWidget);
    // PictureGeneratorProvider.instance.addPicGeneratorTask(
    //   PicGenerateTask<PrinterInfo>(
    //     tempWidget: widget as ATempWidget,
    //     printTypeEnum: PrintTypeEnum.receipt,
    //     params: PrinterInfo(usbDevice: curUsbPrinter),
    //   ),
    // );
  
  }

  // UsbDeviceInfo? get curUsbPrinter {
  //   if (usbDevice.isEmpty) {
  //     //弹出提示框，打印机未设置，请设置打印机或者联系管理员
  //     DialogUtils.alertOneButton('プリンター未設定,設定してください', confirm: () {
  //       Get.back();
  //     });
  //     return null;
  //   }
  //   return UsbDeviceInfo.fromMap(Map<String, dynamic>.from(usbDevice));
  // }

  /// 根据分类加载数据，并识别为订单型（旧结构）或摘要型（新结构）
  Future<void> loadCategoryItems(String category) async {
    change(null, status: RxStatus.loading());
    try {
      final list = await printInfoService.readAll(category: category);
      // 仅维护统一原始数据列表，便于视图层基于分类自由渲染
      final recent = list.length > 30 ? list.sublist(list.length - 30) : list;
      state.currentItemsRaw = recent.reversed.toList();
      debugPrint('Loaded ${state.currentItemsRaw} items for category "$category".');

      // // 维护分类->渲染类型映射（更灵活）。预设两个常用分类：
      // state.categoryRenderer.putIfAbsent('default', () => 'order');
      // state.categoryRenderer.putIfAbsent('rejishime', () => 'summary');

      // // 兼容旧字段：用于右侧标题切换（不影响渲染灵活性）
      // final renderer = state.categoryRenderer[category] ?? 'order';
      // state.showingSummary = renderer == 'summary';
      // // 清理旧强类型缓存，避免误用
      // state.printList = [];
      // state.summaryList = [];
      change(state, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  showPrintView(printData) {
    Get.dialog(
        barrierDismissible: false,
        SimpleDialog(contentPadding: EdgeInsets.all(0), children: [
          Column(
            children: [
              Container(
                  padding:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                  child: Row(
                      //title
                      children: [
                        Expanded(
                          child: Text(
                            "レジ締め情報",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(36),
                              fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        InkWell(
                          highlightColor: Colors.transparent, // 透明色
                          splashColor: Colors.transparent, // 透明色
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.close_outlined,
                            color: ColorsUtil.hexToColor("#000000"),
                            size: 40.0,
                          ),
                        ),
                      ])),
              Container(
                padding: EdgeInsets.only(left: 40, right: 40),
                width: ScreenAdapter.width(770),
                height: ScreenAdapter.height(1080),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: ColorsUtil.hexToColor("#000000"), width: 1),
                ),
                child: RejishimePrintView(
                  printInfo: printData,
                  lengthUpdate: (double length) {
                    print("printLength: $length");
                    state.printLength = length;
                    //_updatePrintInfo(length, printData);
                  },
                ),
              ),
            ],
          ),
          Container(
              height: ScreenAdapter.height(100),
              decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#f1f3f4"),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        child: Center(
                          child: Text(
                            "キャンセル",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28),
                              fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: ScreenAdapter.width(0.5),
                    height: ScreenAdapter.height(100),
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (Platform.isWindows) {
                          printSummaryWindows(printData, state.printLength);
                        } else {
                          printSummaryAndroid(printData, state.printLength);
                        }
                        Get.back();
                      },
                      child: Container(
                        height: ScreenAdapter.height(100),
                        child: Center(
                          child: Text(
                            "印刷",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28),
                              fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ]));
  }
  
  void printSummaryAndroid(printData, double printLength) async{
    ByteData byteData = await WidgetToImage.widgetToImage(
      RejishimePrintView(isPrint: true, printInfo: printData),
      size: Size(machineInfo.machinePrintWidth - 4, printLength + 150),
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    String base64Image = base64Encode(imageBytes);
    await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", "0", " ");
    Future.delayed(Duration(milliseconds: 300), () async {
      await FlutterPluginMsprinter.sendPrintCut("0");
    });
  }
}
