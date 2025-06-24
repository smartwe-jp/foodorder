import 'dart:math';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller.dart';
import 'package:foodorder/app/services/HomeServices.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:widget_to_image/widget_to_image.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:print_image_generate_tool/print_image_generate_tool.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/printer_info.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/NumberCircle.dart';
import '../views/label_constrained_box.dart';
import '../views/receipt_constrained_box.dart';

class PrintService extends GetxService {
  final MachineInfoController _machineInfo;

  PrintService(this._machineInfo);

  get wlan_print_ip => _machineInfo.wlan_print_ip;
  get wlan_print_port => _machineInfo.wlan_print_port;
  get wlan_print_ip_two => _machineInfo.wlan_print_ip_two;
  get wlan_print_port_two => _machineInfo.wlan_print_port_two;
  get is_allow_wlanPrint_continuous =>
      _machineInfo.is_allow_wlanPrint_continuous;
  get is_allow_wlanPrint_Two_continuous =>
      _machineInfo.is_allow_wlanPrint_continuous_two;
  get isLabelPrint => _machineInfo.showPrintType == 1;

  void printData(Map data) async {
    final fromPlate = data["from_plate"] ?? "";
    final orderType = data["order_type"] == 'delivery' ? "☆︎" : "";
    final orderSnCode = data["order_sn_code"] ?? "";
    final orderTime = data["orderTime"] ?? "";
    final orderLinesMap = data["orderLinesMap"] ?? {};
    final remark = data["remark"] ?? "";

    for (var key in orderLinesMap.keys) {
      final printerIp = key == "0" ? wlan_print_ip : wlan_print_ip_two;
      final isContinuous = key == "0"
          ? is_allow_wlanPrint_continuous == "1"
          : is_allow_wlanPrint_Two_continuous == "1";
      if (printerIp == null || printerIp.isEmpty) {
        debugPrint("Printer IP not configured for key: $key");
        continue;
      }

      final rotate = await HomeServices.getPrintDirection() == "1";

      final items = orderLinesMap[key];

      if (isLabelPrint) {
        // If label printing is enabled, print each item separately
        for (var item in items) {
          final qty = item["qty"] ?? 1;
          final name = item["name"] ?? "";
          final options = item["options"] ?? {};

          for (var i = 0; i < qty; i++) {
            // Generate the receipt widget
            final receiptWidget = ReceiptConstrainedBox(
              Transform(
                transform: Matrix4.rotationZ(rotate ? pi : 0.0),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fromPlate,
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                        Text(
                          orderTime,
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          orderSnCode,
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          orderType,
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "x$qty",
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ...options.entries.map((entry) {
                      final optionName = entry.key;
                      final optionValues = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "  $optionName:",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...optionValues.map((option) {
                            final optionDetail = option["name"] ?? "";
                            final optionQty = option["qty"] ?? 1;
                            return Text(
                              "    $optionDetail x$optionQty",
                              style: TextStyle(
                                fontSize: 40,
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            );

            // Add the receipt widget to the print queue
            PictureGeneratorProvider.instance.addPicGeneratorTask(
              PicGenerateTask<PrinterInfo>(
                tempWidget: receiptWidget as ATempWidget,
                printTypeEnum: PrintTypeEnum.label,
                params: PrinterInfo(ip: printerIp),
              ),
            );
          }
        }
        continue;
      }

      if (isContinuous) {
        // If continuous printing is enabled, print all items in one go
        printContinuousData(fromPlate, orderType, orderSnCode, orderTime,
            printerIp, isContinuous, rotate, items, remark);
      } else {
        // If label printing is enabled, print each item separately
        printSingleData(fromPlate, orderType, orderSnCode, orderTime, printerIp,
            isContinuous, rotate, items, remark);
      }

      // continue;
      //
      // for (var item in items) {
      //   final qty = item["qty"] ?? 1;
      //   final name = item["name"] ?? "";
      //   final options = item["options"] ?? {};
      //
      //   //for (var i = 0; i < qty; i++) {
      //     // Generate the receipt widget
      //     final receiptWidget = ReceiptConstrainedBox(
      //       Transform(
      //         transform: Matrix4.rotationZ(rotate),
      //         alignment: Alignment.center,
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(
      //                   fromPlate,
      //                   style: TextStyle(
      //                     fontSize: 40,
      //                   ),
      //                 ),
      //                 Text(
      //                   orderTime,
      //                   style: TextStyle(
      //                     fontSize: 40,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 Text(
      //                   orderSnCode,
      //                   style: TextStyle(
      //                     fontSize: 50,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //
      //                 Text(
      //                   orderType,
      //                   style: TextStyle(
      //                     fontSize: 40,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //
      //             SizedBox(height: 20),
      //
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text(
      //                   name,
      //                   style: TextStyle(
      //                     fontSize: 45,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 Text(
      //                   "x$qty",
      //                   style: TextStyle(
      //                     fontSize: 45,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             ...options.entries.map((entry) {
      //               final optionName = entry.key;
      //               final optionValues = entry.value;
      //               return Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text(
      //                     "  $optionName:",
      //                     style: TextStyle(
      //                       fontSize: 40,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                   ...optionValues.map((option) {
      //                     final optionDetail = option["name"] ?? "";
      //                     final optionQty = option["qty"] ?? 1;
      //                     return Text(
      //                       "    $optionDetail x$optionQty",
      //                       style: TextStyle(
      //                         fontSize: 40,
      //                       ),
      //                     );
      //                   }).toList(),
      //                 ],
      //               );
      //             }).toList(),
      //           ],
      //         ),
      //       ),
      //     );
      //
      //     // Add the receipt widget to the print queue
      //     PictureGeneratorProvider.instance.addPicGeneratorTask(
      //       PicGenerateTask<PrinterInfo>(
      //         tempWidget: receiptWidget as ATempWidget,
      //         printTypeEnum: PrintTypeEnum.receipt,
      //         params: PrinterInfo(ip: printerIp),
      //       ),
      //     );
      //   //}
      // }
    }
  }

  //打印逻辑为 连票打印时 只有一个标题receiptTitle 中间为菜品menuItem，最后右下角为下单时间
  //使用 printData 的同样参数实现这个需求

  printContinuousData(
      String fromPlate,
      String orderType,
      String orderSnCode,
      String orderTime,
      String printerIp,
      bool isContinuous,
      bool isRotate,
      List items,
      String remark) async {
    final rotate = isRotate ? pi : 0.0;

    // Generate the receipt widget
    final receiptWidget = ReceiptConstrainedBox(
      Transform(
        transform: Matrix4.rotationZ(rotate),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            receiptTitle(orderSnCode, orderTime, fromPlate,
                isTakeOut: orderType == 'delivery', continuous: true),
            ...items.map((item) {
              final qty = item["qty"] ?? 1;
              final name = item["name"] ?? "";
              final options = item["options"] ?? {};
              return menuItem(name, qty, options, isUnderLine: true);
            }).toList(),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                orderTime,
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            remarkTitle(remark)
          ],
        ),
      ),
    );

    // Add the receipt widget to the print queue
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: receiptWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(ip: printerIp),
      ),
    );
  }

  //单票打印时 每个菜品分开打印 分别有receiptTitle 和menuItem 最后右下角没有不需要时间

  printSingleData(
      String fromPlate,
      String orderType,
      String orderSnCode,
      String orderTime,
      String printerIp,
      bool isContinuous,
      bool isRotate,
      List items,
      String remark) async {
    final rotate = isRotate ? pi : 0.0;
    for (var item in items) {
      final qty = item["qty"] ?? 1;
      final name = item["name"] ?? "";
      final options = item["options"] ?? {};

      // Generate the receipt widget
      final receiptWidget = ReceiptConstrainedBox(
        Transform(
          transform: Matrix4.rotationZ(rotate),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              receiptTitle(orderSnCode, orderTime, fromPlate,
                  isTakeOut: orderType == 'delivery'),
              menuItem(name, qty, options),
              remarkTitle(remark)
            ],
          ),
        ),
      );

      // Add the receipt widget to the print queue
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: receiptWidget as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: PrinterInfo(ip: printerIp),
        ),
      );
    }
  }

  Widget remarkTitle(String content) {
    return Container(
      child: Text(
        'remark: $content',
        style: TextStyle(
          fontSize: 45,
          color: ColorsUtil.hexToColor("#000000"),
        ),
      ),
    );
  }

  //标题
  Widget receiptTitle(String title, String orderTime, String fromPlate,
      {bool isTakeOut = false, bool continuous = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: continuous
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fromPlate + 'ー',
                    style: TextStyle(
                      fontSize: 50,
                      color: ColorsUtil.hexToColor("#000000"),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isTakeOut ? "☆︎ $title" : title,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: ColorsUtil.hexToColor("#000000"),
                    ),
                  ),
                ],
              ),
              if (!continuous)
                Text(
                  orderTime,
                  style: TextStyle(
                    fontSize: 45,
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                ),
            ],
          ),
          if (!continuous)
            Divider(
              color: ColorsUtil.hexToColor("#000000"),
              thickness: 1,
            )
        ],
      ),
    );
  }

  //单个菜品显示 左标题右分量，如果有Options 换行锁进50 左Option标题 右分量
  Widget menuItem(String title, int qty, Map option,
      {bool isUnderLine = false}) {
    final optionQtyString = qty == 1 ? "" : "x $qty";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 40,
                    color: ColorsUtil.hexToColor("#000000"),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                optionQtyString,
                style: TextStyle(
                  fontSize: 40,
                  color: ColorsUtil.hexToColor("#000000"),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (option.isNotEmpty)
            ...option.entries.map((entry) {
              final optionName = entry.key;
              final optionValues = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "  $optionName",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: [
                          ...optionValues.map((option) {
                            final optionDetail = option["name"] ?? "";
                            final optionQty = option["qty"] ?? 1;
                            final optionQtyString =
                                optionQty == 1 ? "" : "x $optionQty";
                            return Text(
                              "    $optionDetail $optionQtyString",
                              style: TextStyle(
                                fontSize: 36,
                              ),
                            );
                          }).toList(),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20)
                ],
              );
            }).toList(),
          if (isUnderLine)
            Container(
              margin: EdgeInsets.only(top: 5),
              height: 1.5,
              color: ColorsUtil.hexToColor("#000000"),
              width: double.infinity,
            ),
        ],
      ),
    );
  }

  wifiNetworkPrintData(serialNumber, extendPrintVo, takeOut, orderTime) {
    var printData = [];
    extendPrintVo.forEach((k, v) {
      printData = [];
      if (v.length > 0) {
        for (var i = 0; i < v.length; i++) {
          v[i]["checked"] = false;
          //判断是否有需要打印的数据
          if (v[i]["print"] == true) {
            printData.add(v[i]);
          }
        }
        //QueueUtil.get("smartwe_taks_wifi_print")?.addTask(() {
        return wifiNetPrintnew(serialNumber, k, printData, takeOut, orderTime);
        //});
      }
    });
  }

  wifiNetPrintnew(
      serialNumber, printType, printData, takeOut, orderTime) async {
    //如果整理的数据打印机不是10或11就返回
    if (printType != "10" && printType != "12") {
      return;
    }

    //判断是否有打印机ip
    Map printerIpInfo = {
      "printer_ip": "",
      "printer_port": "",
    };
    if (printType == "10") {
      if (wlan_print_ip != null && wlan_print_ip != "") {
        final rotate = await HomeServices.getPrintDirection() == "1" ? pi : 0.0;

        printerIpInfo = {
          "printer_ip": wlan_print_ip,
          "printer_port": wlan_print_port,
        };
        if (is_allow_wlanPrint_continuous == "1") {
          wifiNetworkReceiptPrintContinuousData(serialNumber, printData,
              takeOut, orderTime, wlan_print_ip, rotate);
        } else {
          wifiNetworkReceiptPrintData(serialNumber, printData, takeOut,
              orderTime, wlan_print_ip, rotate);
        }
      } else {
        return;
      }
    } else if (printType == "12") {
      if (wlan_print_ip_two != null && wlan_print_ip_two != "") {
        final rotate =
            await HomeServices.getPrintTwoDirection() == "1" ? pi : 0.0;
        printerIpInfo = {
          "printer_ip": wlan_print_ip_two,
          "printer_port": wlan_print_port_two,
        };
        if (is_allow_wlanPrint_Two_continuous == "1") {
          wifiNetworkReceiptPrintContinuousData(serialNumber, printData,
              takeOut, orderTime, wlan_print_ip_two, rotate);
        } else {
          wifiNetworkReceiptPrintData(serialNumber, printData, takeOut,
              orderTime, wlan_print_ip_two, rotate);
        }
      } else {
        return;
      }
    } else {
      return;
    }
    //print(printData);
    //_wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,printerIpInfo["printer_ip"]);
  }

  //单票
  wifiNetworkReceiptPrintData(
      serialNumber, printData, takeOut, orderTime, printer_ip, rotate) async {
    for (var i = 0; i < printData.length; i++) {
      // wifiNetPrintReceiptnew(serialNumber,printData[i],takeOut,orderTime,printer_ip);

      final printWidget = await wifiNetPrintReceiptnew(
          serialNumber, printData[i], takeOut, orderTime, printer_ip, rotate);

      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: printWidget as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: PrinterInfo(ip: printer_ip),
        ),
      );
    }
  }

  wifiNetPrintReceiptnew(serialNumber, orderprintData, takeOut, orderTime,
      printer_ip, rotate) async {
    var lineHight = 120;
    int menuNum = 0;
    var optionNum = 0;
    int addRowHight = 0;

    List<Widget> printMenus = [];
    printMenus.add(
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom:
                BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: RichText(
                  text: TextSpan(
                      text: (takeOut == true)
                          ? "☆︎"
                          : "", //${printData["takeOut"]}
                      style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      ),
                      children: [
                        TextSpan(
                          text: "${serialNumber.toString()}",
                          style: TextStyle(
                            fontSize: 50,
                            fontFamily: 'JetBrainsMonoRegular',
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#000000"),
                          ),
                        ),
                      ]),
                )),
            Directionality(
                textDirection: TextDirection.ltr,
                child: Text("${orderTime}",
                    style: TextStyle(
                      fontSize: 45,
                      //fontFamily: 'JetBrainsMonoRegular',
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
          ],
        ),
      ),
    );
    printMenus.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.ltr,
        children: [
          Directionality(
              textDirection: TextDirection.ltr,
              child: Expanded(
                  child: Text("${orderprintData["mainTitle"]}",
                      style: TextStyle(
                        fontSize: 45,
                        //fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.hexToColor("#000000"),
                      )))),
          Container(
            width: 50,
            alignment: Alignment.centerRight,
            child: Directionality(
                textDirection: TextDirection.ltr,
                child: (int.parse(orderprintData["qtyBack"]) > 1)
                    ? NumberCircle(
                        number: int.parse(orderprintData["qtyBack"]),
                        circleColor: ColorsUtil.hexToColor("#000000"),
                        circleSize: 50.0,
                        numberStyle: TextStyle(
                          fontSize: 42,
                          fontFamily: 'JetBrainsMonoRegular',
                          fontWeight: FontWeight.w400,
                          color: ColorsUtil.hexToColor("#000000"),
                        ),
                      )
                    : Text("${orderprintData["qty"]}",
                        textAlign: TextAlign.right, //${printData["takeOut"]}
                        style: TextStyle(
                          fontSize: 42,
                          fontFamily: 'JetBrainsMonoRegular',
                          fontWeight: FontWeight.w400,
                          color: ColorsUtil.hexToColor("#000000"),
                        ))),
          ),
        ],
      ),
    );

    var mainTitleLine = orderprintData["mainTitle"].length / 10;
    int mainTitleRowNum = mainTitleLine.ceil();
    optionNum = 0;

    var optionVoListMap = orderprintData["optionVoListMsgMap"] ?? {};
    if (optionVoListMap != null && optionVoListMap.isNotEmpty) {
      optionVoListMap.forEach((key, value) {
        // 计算菜品标题长度
        var groupNameLength = key.length;
        var optionNameLength = value[0].length;
        var optionLine = (groupNameLength + optionNameLength) / 10;
        var countLine = 0;

        //处理option 开始-----------
        if ((key.length + value[0].length) > 10) {
          printMenus.add(Column(
            textDirection: TextDirection.rtl,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Expanded(
                          child: Text("    ${key}",
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'JetBrainsMonoRegular',
                                color: ColorsUtil.hexToColor("#000000"),
                              )))),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                child: Row(
                  mainAxisAlignment: (value[0].length > 10)
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.rtl,
                        child: Expanded(
                          child: Text("${value[0]}",
                              softWrap: true,
                              textAlign: (value[0].length > 10)
                                  ? TextAlign.left
                                  : TextAlign.right,
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'JetBrainsMonoRegular',
                                color: ColorsUtil.hexToColor("#000000"),
                              )),
                        )),
                  ],
                ),
              ),
            ],
          ));
        } else {
          printMenus.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("    ${key}",
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'JetBrainsMonoRegular',
                        color: ColorsUtil.hexToColor("#000000"),
                      ))),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text("${value[0]}",
                      softWrap: true,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'JetBrainsMonoRegular',
                        color: ColorsUtil.hexToColor("#000000"),
                      ))),
            ],
          ));
        }

        //var newOptionSonLine = 0.0;
        if (value.length > 1) {
          List<Widget> optionSons = [];
          for (var j = 1; j < value.length; j++) {
            optionSons.add(Container(
              padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
              child: Row(
                mainAxisAlignment: (value[j].length > 10)
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                      child: Text("${value[j]}",
                          textDirection: TextDirection.ltr,
                          textAlign: (value[j].length > 10)
                              ? TextAlign.left
                              : TextAlign.right,
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'JetBrainsMonoRegular',
                            color: ColorsUtil.hexToColor("#000000"),
                            //fontWeight: FontWeight.w600
                          ))),
                ],
              ),
            ));
          }

          printMenus.add(Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            textDirection: TextDirection.rtl,
            children: optionSons,
          ));
        }
      });
    }

    // 生成打印图层任务，指定任务类型为标签
    return ReceiptConstrainedBox(
      Transform(
          transform: Matrix4.rotationZ(rotate),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: printMenus,
          )),
    );
  }

  //连票
  wifiNetworkReceiptPrintContinuousData(
      serialNumber, printData, takeOut, orderTime, printer_ip, rotate) async {
    final widget = await organizeData(
        serialNumber, printData, takeOut, orderTime, printer_ip, rotate);
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: widget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(ip: printer_ip),
      ),
    );
  }

  organizeData(
      serialNumber, printData, takeOut, orderTime, printer_ip, rotate) async {
    var categoryVos = printData;
    List<Widget> categoryMenus = [];
    var lineHight = 230;
    int menuNum = 0;
    var optionNum = 0;
    int addRowHight = 0;

    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: RichText(
              text: TextSpan(
                  text: (takeOut == true) ? "☆︎" : "", //${printData["takeOut"]}
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'JetBrainsMonoRegular',
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                  children: [
                    TextSpan(
                      text: "${serialNumber.toString()}",
                      style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      ),
                    ),
                  ]),
            )),
      ),
    );

    for (var i = 0; i < categoryVos.length; i++) {
      var lineVos = categoryVos[i];
      var optionVoList = categoryVos[i]["optionVoListMsgMap"] ?? {};

      // 计算菜品标题长度
      var mainTitleLength = lineVos["mainTitle"].length;
      var mainTitleLine = mainTitleLength / 10;
      int mainTitleRowNum = mainTitleLine.ceil();
      optionNum = 0;

      categoryMenus.add(
        Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              margin: EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Expanded(
                        child: Text("${lineVos["mainTitle"]}",
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'JetBrainsMonoRegular',
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      )),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text("${lineVos["qty"]}",
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'JetBrainsMonoRegular',
                            color: ColorsUtil.hexToColor("#000000"),
                            //fontWeight: FontWeight.w600
                          ))),
                ],
              ),
            )),
      );

      if (optionVoList != null && optionVoList.isNotEmpty) {
        optionVoList.forEach((key, value) {
          // 计算菜品标题长度
          var groupNameLength = key.length;
          var optionNameLength = value[0].length;
          var optionLine = (groupNameLength + optionNameLength) / 12;
          var countLine = 0;

          //处理option 开始-----------
          if ((key.length + value[0].length) > 12) {
            var newLineNum = 0.0;
            //if(groupNameLength >6){
            newLineNum = groupNameLength / 12;
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;
            //if(optionNameLength >6){
            newLineNum = optionNameLength / 12;
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;

            categoryMenus.add(Column(
              textDirection: TextDirection.rtl,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(
                            child: Text("    ${key}",
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'JetBrainsMonoRegular',
                                  color: ColorsUtil.hexToColor("#000000"),
                                )))),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                  child: Row(
                    mainAxisAlignment: (value[0].length > 10)
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.rtl,
                          child: Expanded(
                            child: Text("${value[0]}",
                                softWrap: true,
                                textAlign: (value[0].length > 10)
                                    ? TextAlign.left
                                    : TextAlign.right,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'JetBrainsMonoRegular',
                                  color: ColorsUtil.hexToColor("#000000"),
                                )),
                          )),
                    ],
                  ),
                ),
              ],
            ));
          } else {
            countLine += 1;
            categoryMenus.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("    ${key}",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'JetBrainsMonoRegular',
                          color: ColorsUtil.hexToColor("#000000"),
                        ))),
                Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text("${value[0]}",
                        softWrap: true,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'JetBrainsMonoRegular',
                          color: ColorsUtil.hexToColor("#000000"),
                        ))),
              ],
            ));
          }

          var newOptionSonLine = 0.0;
          if (value.length > 1) {
            List<Widget> optionSons = [];
            for (var j = 1; j < value.length; j++) {
              // print(value[j]);
              newOptionSonLine += value[j].length / 10;
              var oneOptionlength = 0.0;
              oneOptionlength = value[j].length / 10;
              countLine += oneOptionlength.ceil();

              optionSons.add(Container(
                padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                child: Row(
                  mainAxisAlignment: (value[j].length > 10)
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                        child: Text("${value[j]}",
                            textDirection: TextDirection.ltr,
                            textAlign: (value[j].length > 10)
                                ? TextAlign.left
                                : TextAlign.right,
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'JetBrainsMonoRegular',
                              color: ColorsUtil.hexToColor("#000000"),
                              //fontWeight: FontWeight.w600
                            ))),
                  ],
                ),
              ));
            }

            categoryMenus.add(Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              textDirection: TextDirection.rtl,
              children: optionSons,
            ));
          }

          //处理option结束-----------
          var optionRowNum = 0.0;
          optionRowNum = optionLine + newOptionSonLine;
          //addRowHight += 52 * optionRowNum;
          addRowHight += 66 * countLine;
          menuNum += optionRowNum.ceil();
          optionNum++;
        });

        //addRowHight += 59 * mainTitleRowNum;
        //menuNum += mainTitleRowNum;
      } else {
        addRowHight += 65 * mainTitleRowNum;
        menuNum += mainTitleRowNum;
      }

      addRowHight += 10;
      categoryMenus.add(
        Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              height: 2.5,
              color: ColorsUtil.hexToColor("#000000"),
              width: 550,
            )),
      );
    }

    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 5),
        alignment: Alignment.centerRight,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              "${orderTime}", //${printData["takeOut"]}
              style: TextStyle(
                fontSize: 45,
                fontFamily: 'JetBrainsMonoRegular',
                fontWeight: FontWeight.w500,
                color: ColorsUtil.hexToColor("#000000"),
              ),
            )),
      ),
    );

    var totalHight = addRowHight + lineHight;
    if (menuNum == 1) {
      totalHight += 15;
    }

    /*return Container(
      width: 550,
      height: totalHight.toDouble(),
      padding: EdgeInsets.only(left: 0.5, right: 0.5),
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: categoryMenus,
      ),
    );*/
    final rotate = await HomeServices.getPrintDirection() == "1" ? pi : 0.0;
    return ReceiptConstrainedBox(Transform(
        transform: Matrix4.rotationZ(rotate),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: categoryMenus,
        )));
  }

  //打印label
  wifiNetworkLabelPrintData(extendPrintVo) async {
    debugPrint("wifiNetworkLabelPrintData: $extendPrintVo");
    for (var i = 0; i < extendPrintVo.length; i++) {
      // 生成打印图层任务，指定任务类型为标签
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: await menuData(extendPrintVo[i]) as ATempWidget,
          printTypeEnum: PrintTypeEnum.label,
          params: PrinterInfo(ip: wlan_print_ip),
        ),
      );
      /*QueueUtil.get("smartwe_taks_wifi_print")?.addTask(() {
        return wifiNetPrintLabelnew(extendPrintVo[i]);
      });*/
    }
  }

  wifiNetPrintLabelnew(orderprintData) async {
    Future.delayed(Duration(milliseconds: 1200), () async {
      ByteData byteData =
          await WidgetToImage.widgetToImage(await menuData(orderprintData));

      Uint8List imageBytes = byteData.buffer.asUint8List();
      var printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
        imgData: imageBytes,
        printType: PrintTypeEnum.label,
      );
      // 网络 打印
      final conn = printerPlus.NetConn(wlan_print_ip);
      conn.writeMultiBytes(printData);
    });
  }

  _getOptions(String originString) {
    List<String> parts = originString.split('\n');

    // 2. 提取每个部分中 "：" 右边的内容
    List<String> extractedValues = parts.map((part) {
      int colonIndex = part.indexOf('：');
      return part.substring(colonIndex + 1);
    }).toList();

    if (extractedValues.isEmpty) {
      return originString;
    }

    if (extractedValues.length == 1) {
      return extractedValues[0];
    }

    return extractedValues.join('、');
  }

  Future<Widget> menuData(orderprintData) async {
    final printWidth = await HomeServices.getLabelPrintWidth() ?? 384.0;
    final rotate =
        await HomeServices.getPrintThreeDirection() == "1" ? pi : 0.0;
    List<String> parts = orderprintData["printTitleText"].split('　');
    String menuNumber = orderprintData["printTitleText"];
    String menuTitle = orderprintData["printTitleText"];
    if (parts.length > 1) {
      menuNumber = parts[0];
      menuTitle = parts[1];
    }

    String optionText = _getOptions(orderprintData["printText"]);

    return LabelConstrainedBox(
      Transform(
          transform: Matrix4.rotationZ(rotate),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(
              //left: 5,
              top: 2,
              //right: 5,
            ),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                //textDirection: TextDirection.ltr,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Directionality(
                          textDirection: TextDirection.rtl,
                          child: Container(
                            child: Text(
                              menuNumber,
                              style: GoogleFonts.zenKakuGothicAntique(
                                  fontSize: ScreenAdapter.fontSize(32),
                                  fontWeight: FontWeight.w500),
                              maxLines: 2,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                  ),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
                        child: AutoSizeText(
                          menuTitle,
                          style: GoogleFonts.zenKakuGothicAntique(
                              fontSize: ScreenAdapter.fontSize(34),
                              fontWeight: FontWeight.w500),
                          maxLines: 2,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(top: 5),
                    child: AutoSizeText(
                      optionText,
                      style: GoogleFonts.zenKakuGothicAntique(
                          fontSize: ScreenAdapter.fontSize(26),
                          fontWeight: FontWeight.w500),
                      maxLines: 4,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                ],
              ),
            ),
          )),
      pagerWidth: printWidth,
    );
  }
}

/*return LabelConstrainedBox(
        Padding(
          padding: const EdgeInsets.only(
            //left: 5,
            top: 5,
            //right: 5,
          ),
          child: Container(

            child: Column(
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [

                Container(
                  decoration: BoxDecoration(
                    //color: Colors.red,
                    border: Border(
                      bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 2.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:MainAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(400),
                              minHeight: ScreenAdapter.height(30),
                              maxHeight: ScreenAdapter.height(70),
                            ),
                            child: AutoSizeText(
                              "${orderprintData["printTitleText"]}",
                              style: GoogleFonts.zenKakuGothicAntique(fontSize: ScreenAdapter.fontSize(32),fontWeight: FontWeight.w500),
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                          )
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment:MainAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: ScreenAdapter.width(20),
                            maxWidth: ScreenAdapter.width(400),
                            minHeight: ScreenAdapter.height(30),
                            maxHeight: ScreenAdapter.height(210),
                          ),
                          child: AutoSizeText(
                            orderprintData["printText"],
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: ScreenAdapter.fontSize(26),fontWeight: FontWeight.w500),
                            maxLines: 4,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                        )
                    ),
                  ],
                ),

              ],
            ),
          ),
        )
    );*/
//}