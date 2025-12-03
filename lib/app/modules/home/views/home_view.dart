import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' show PrinterJobController;
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';

import 'package:get/get.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  final printerController = PrinterJobController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(
        builder: (controller) {
        return PrintImageGenerateWidget(
            contentBuilder: (context) {
              return Center(
                    child: Stack(
                      children: [
                        Container(
                          width: ScreenAdapter.width(550),
                          height: ScreenAdapter.height(450),
                          padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("テスト中です、しばらくお待ちください。",
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(25),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                  )),
                              Container(
                                margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                                child: Text("1、インターネットをテストしています",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(25),
                                      fontWeight: FontWeight.w600,
                                      color: (controller.checkSteeps.value == 1)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 1)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                                    )),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                                child: Text("2、釣銭機を開けています。",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(25),
                                      fontWeight: FontWeight.w600,
                                      color: (controller.checkSteeps.value == 2)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 2)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                                    )),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                                child: Text("3、現金機を閉じています。",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(25),
                                      fontWeight: FontWeight.w600,
                                      color: (controller.checkSteeps.value == 3)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 3)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                                    )),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: ScreenAdapter.width(100),top: ScreenAdapter.height(30)),
                                //width: ScreenAdapter.width(400),
                                height: ScreenAdapter.height(250),
                                child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
                              ),
                            ],
                          ),
                        )
                        
                      ],
                    ),
                  );
              //return WindewsTestView();

            },
            onPictureGenerated: _onPictureGenerated,
          );
        
         
      }
    ));
  }

  //打印图层生成成功
  Future<void> _onPictureGenerated(PicGenerateResult imgData) async {
    //final imageBytes = imgdata.data;
      final printTask = imgData.taskItem;

    //指定的打印机
      final printerInfo = printTask.params as PrinterInfo;
      //print('printerInfo: $printerInfo');
      //打印票据类型（标签、小票）
      final printTypeEnum = printTask.printTypeEnum;

      final imageBytes =
          await imgData.convertUint8List(imageByteFormat: ImageByteFormat.rawRgba);
      //也可以使用 ImageByteFormat.png
      final argbWidth = imgData.imageWidth;
      final argbHeight = imgData.imageHeight;
      if (imageBytes == null) {
        return;
      }

      var printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
      imgData: imageBytes,
      printType: printTypeEnum,
      argbWidthPx: argbWidth,
      argbHeightPx: argbHeight,
    );

      if (printerInfo.isUsbPrinter) {
        // usb 打印
        logI('usb 打印');
        final conn = printerPlus.UsbConn(printerInfo.usbDevice!);
        conn.writeMultiBytes(printData, 1024 * 8);
      } else if (printerInfo.isNetPrinter) {
        // 网络 打印
        logI('网络 打印 ${printerInfo.ip!}');
        // final conn = printerPlus.NetConn(printerInfo.ip!);
        // conn.writeMultiBytes(printData);

        try {
          await printerController.enqueue(printerInfo.ip!, printData, timeout: Duration(seconds: 10));
          // final conn = printerPlus.NetConn(printerInfo.ip!);
          // conn.writeMultiBytes(printData);
        } catch (e) {
          // handle/report failure for diagnostics
          logE('打印失败: ${e.toString()}');
        }
      }

      // // 网络 打印
      // final conn = printerPlus.NetConn(printerInfo.ip!);
      // conn.writeMultiBytes(printData);
    }
}
