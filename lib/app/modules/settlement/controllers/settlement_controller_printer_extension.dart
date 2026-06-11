import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:foodorder/app/services/HomeServices.dart';
import 'package:foodorder/app/services/print_failed_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:widget_to_image/widget_to_image.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:print_image_generate_tool/print_image_generate_tool.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/printer_info.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/NumberCircle.dart';
import '../views/label_constrained_box.dart';
import '../views/receipt_constrained_box.dart';

class PrintTask {
  final String printerIp;
  final Widget widget;
  final int printerType;
  final Map printInfo;

  PrintTask({
    required this.printerIp,
    required this.widget,
    required this.printerType,
    required this.printInfo,
  });
}

enum OrderType { shopin, takeout, pickup, delivery }

class PrintService extends GetxService {
  final MachineInfoController _machineInfo;
  final PrintFailedService _service = Get.find<PrintFailedService>();
  final LinkedHashSet<String> _processingUuids = LinkedHashSet<String>(); // 最近处理的 UUID，最多保留 100 条

  PrintService(this._machineInfo);

  void _addProcessingUuid(String uuid) {
    _processingUuids.add(uuid);
    if (_processingUuids.length > 100) {
      _processingUuids.remove(_processingUuids.first);
    }
  }

  get printerList => _machineInfo.printerList;
  get sseList => _machineInfo.sseSettingList;

  //Label打印先存在在一个队列中
  //final Queue<Widget> labelPrintQueue = Queue<Widget>();

  final testData = [
    {
      "uuid": "YK-0HObr4iVk_NaDfVw9WoEH",
      "bizId": 462461846396796928,
      "orderTime": "19:12",
      "remark": "",
      "from_plate": "Shop",
      "order_sn_code": "A17",
      "payment_code": "",
      "order_type": "Shop_In",
      "pay_type": "Paid",
      "orderLinesMap": {
        "12": [
          {
            "categoryName": "ドリンク",
            "name": "ジンジャーエール",
            "price": 600,
            "qty": 1,
            "bizId": 462461855189106697,
            "options": {},
            "extend2qr": null
          }
        ],
        "10": [
          {
            "categoryName": "メインディッシュ",
            "name": "お刺身5種盛り",
            "price": 3000,
            "qty": 1,
            "bizId": 462461855189106688,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "メインディッシュ",
            "name": "ポテサラ",
            "price": 1400,
            "qty": 1,
            "bizId": 462461855189106689,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "メインディッシュ",
            "name": "ローストビーフサラダ",
            "price": 2800,
            "qty": 1,
            "bizId": 462461855189106690,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "メインディッシュ",
            "name": "おでん",
            "price": 1500,
            "qty": 1,
            "bizId": 462461855189106691,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "おすすめ",
            "name": "和牛煮込み",
            "price": 1200,
            "qty": 1,
            "bizId": 462461855189106692,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "メインディッシュ",
            "name": "すき焼き",
            "price": 8000,
            "qty": 2,
            "bizId": 462461855189106693,
            "options": {
              "トッピング": [
                {"name": "うどん", "price": null, "qty": 1}
              ]
            },
            "extend2qr": null
          },
          {
            "categoryName": "小食",
            "name": "追い 卵",
            "price": 600,
            "qty": 3,
            "bizId": 462461855189106695,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "おすすめ",
            "name": "和牛フレーク丼",
            "price": 2500,
            "qty": 1,
            "bizId": 462461855189106696,
            "options": {},
            "extend2qr": null
          }
        ]
      },
      "orderLines": null
    },
    {
      "uuid": "eg36fyjt5igDZVTl7yNzEs7j",
      "bizId": 462461756707897344,
      "orderTime": "19:56",
      "remark": "",
      "from_plate": "Shop",
      "order_sn_code": "A9",
      "payment_code": "",
      "order_type": "Shop_In",
      "pay_type": "Paid",
      "orderLinesMap": {
        "10": [
          {
            "categoryName": "アイス",
            "name": "アイス",
            "price": 1000,
            "qty": 1,
            "bizId": 462462547208372224,
            "options": {
              "味": [
                {"name": "ココナツ", "price": null, "qty": 1}
              ]
            },
            "extend2qr": null
          }
        ]
      },
      "orderLines": null
    },
    {
      "uuid": "XsBjuzH1zlwqCPWDInYd3iDr",
      "bizId": 462461756707897344,
      "orderTime": "19:58",
      "remark": "",
      "from_plate": "Shop",
      "order_sn_code": "A9",
      "payment_code": "",
      "order_type": "Shop_In",
      "pay_type": "Paid",
      "orderLinesMap": {
        "10": [
          {
            "categoryName": "メインディッシュ",
            "name": "和牛煮込み",
            "price": 1200,
            "qty": 1,
            "bizId": 462462566741508096,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "メインディッシュ",
            "name": "ホッケ",
            "price": 2500,
            "qty": 1,
            "bizId": 462462566741508097,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "メインディッシュ",
            "name": "焼鳥-かわ",
            "price": 750,
            "qty": 3,
            "bizId": 462462566741508098,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "メインディッシュ",
            "name": "カツレツ",
            "price": 2400,
            "qty": 1,
            "bizId": 462462566741508099,
            "options": {},
            "extend2qr": null
          }
        ]
      },
      "orderLines": null
    },
    {
      "uuid": "mLhBiJaR0KPV0FaElX-fed42",
      "bizId": 462460811105992704,
      "orderTime": "20:03",
      "remark": "",
      "from_plate": "Shop",
      "order_sn_code": "A15",
      "payment_code": "",
      "order_type": "Shop_In",
      "pay_type": "Paid",
      "orderLinesMap": {
        "12": [
          {
            "categoryName": "ドリンク",
            "name": "ウーロン茶",
            "price": 600,
            "qty": 1,
            "bizId": 462462655712133120,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "ドリンク",
            "name": "ジンジャーエール",
            "price": 600,
            "qty": 1,
            "bizId": 462462655712133121,
            "options": {},
            "extend2qr": null
          },
          {
            "categoryName": "ドリンク",
            "name": "コーラ",
            "price": 600,
            "qty": 1,
            "bizId": 462462655712133122,
            "options": {},
            "extend2qr": null
          }
        ]
      },
      "orderLines": null
    },
    {
      "uuid": "QRNRA_Q5ZQX_vASszPuqGjV-",
      "bizId": 462461756707897344,
      "orderTime": "20:14",
      "remark": "",
      "from_plate": "Shop",
      "order_sn_code": "A9",
      "payment_code": "",
      "order_type": "Shop_In",
      "pay_type": "Paid",
      "orderLinesMap": {
        "10": [
          {
            "categoryName": "メインディッシュ",
            "name": "和牛煮込み",
            "price": 1200,
            "qty": 1,
            "bizId": 462462819377020928,
            "options": {},
            "extend2qr": null
          }
        ]
      },
      "orderLines": null
    }
  ];

  // 全局队列 + 是否正在排队
  //定义个类型 包含Widget 和 [Map]

  final Queue<PrintTask> _labelQueue = Queue<PrintTask>();
  bool _labelDraining = false;

  void _processLabelPrintQueueNew(
      String printerIp, Queue<PrintTask> labelPrintQueue) {
    if (labelPrintQueue.isEmpty) return;
    _labelQueue.addAll(labelPrintQueue); // 合并到全局队列
    _ensureLabelDrain(printerIp); // 启动/复用单次循环
  }

  void _ensureLabelDrain(String printerIp) {
    if (_labelDraining) return;
    _labelDraining = true;
    _drainLabelQueue(printerIp);
  }

  Future<void> _drainLabelQueue(String printerIp) async {
    try {
      while (_labelQueue.isNotEmpty) {
        final task = _labelQueue.removeFirst();
        PictureGeneratorProvider.instance.addPicGeneratorTask(
          PicGenerateTask<PrinterInfo>(
            tempWidget: task.widget as ATempWidget,
            printTypeEnum: PrintTypeEnum.label,
            params: PrinterInfo(ip: printerIp, printerType: 11, printInfo: task.printInfo), // 不做 IP 检查
          ),
        );
        await Future.delayed(const Duration(seconds: 1)); // 每张间隔 1 秒
      }
    } finally {
      _labelDraining = false;
      // 若刚结束又入队了，补一次启动
      if (_labelQueue.isNotEmpty) {
        _ensureLabelDrain(printerIp);
      }
    }
  }

  //创建一个方法来处理打印队列
  void _processLabelPrintQueue(String printerIp, Queue<PrintTask> labelPrintQueue) {
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (labelPrintQueue.isEmpty) {
        timer.cancel(); // 停止定时器
        return;
      }

      final task = labelPrintQueue.removeFirst();
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: task.widget as ATempWidget,
          printTypeEnum: PrintTypeEnum.label,
          params: PrinterInfo(ip: printerIp, printerType: 11, printInfo: task.printInfo),
        ),
      );
    });
  }

  _sendToDisplayPanel(data) async {
    logI("_sendToDisplayPanel");

    if (_machineInfo.wlan_panel_print_ip.isEmpty ||
        _machineInfo.wlan_panel_print_port.isEmpty) {
      logI("_sendToDisplayPanel: Panel IP or Port is not set.");
      return;
    }
    final String panelAddress =
        'http://${_machineInfo.wlan_panel_print_ip}:${_machineInfo.wlan_panel_print_port}/api/add/order';
    try {
      final response =
          await request(panelAddress, method: 'POST', parameters: data);
      final responseValue = json.decode(response.toString());
      logI('_sendToDisplayPanel:$responseValue');
    } catch (error) {
      logI('_sendToDisplayPanel error: ${error.toString()}');
    }
  }

  callbackBeforePrint(String event, Map data, {int retryCount = 0}) async {
    // if (event == 'efficientPrint') {
    //     _printEfficientLabel(data);
    // }
    String uuid = data['uuid'] ?? '';
    if (uuid.isEmpty) return;

    if (_processingUuids.contains(uuid)) {
      logI("callbackBeforePrint: UUID $uuid is already being processed or recently processed, skipping.");
      return;
    }
    _addProcessingUuid(uuid);

    try {
      logI("callbackBeforePrint uuid: $uuid send"); //会出现发送没有回复的现象15秒超时了。
      final val = await request('sseCallback',
          method: 'POST',
          parameters: {'uuid': uuid},
          timeout: const Duration(seconds: 15)
      );
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          response['data'] != null) {
        logI("callbackBeforePrint uuid: $uuid send success");
        if (event == 'message' || event == 'rePrint') {
          printData(data);
        }
        if (event == 'print') {
          printTableSeatInfo(data);
        }
        if (event == 'item_cancel') {
          _sendToDisplayPanel(data);
        }
        if (event == 'expiryPrint') {
          _printEfficientLabel(data);
        }
      }
    } catch (e) {
      logI('error Exception:${e.toString()}');
      if (retryCount < 3) {
        // 如果发生错误，重试最多3次
        logI("callbackBeforePrint uuid: $uuid retrying... ($retryCount)");
        await Future.delayed(Duration(seconds: 2));
        callbackBeforePrint(event, data, retryCount: retryCount + 1);
      } else {
        logI("callbackBeforePrint uuid: $uuid failed after retries");
      }
    }
  }

  Future<void> testPrint() async {
    int index = 0;
    for (var data in testData) {
      //间隔2秒打印
      index += 1;
      printData(data);
      await Future.delayed(const Duration(seconds: 15));
      if (index > 1) {
        break;
      }
    }
  }

  _orderTypeFromString(String orderTypeStr) {
    switch (orderTypeStr.toLowerCase()) {
      case 'Shop_In':
        return OrderType.shopin;
      case 'Takeout':
      case 'takeout':
        return OrderType.takeout;
      case 'pickup':
        return OrderType.pickup;
      case 'delivery':
        return OrderType.delivery;
      default:
        return OrderType.shopin; // 默认值
    }
  }

  void printData(Map data,
      {bool fromSSE = true, String orderId = "", shopName = ""}) async {
    logI("---printData---: ${data}");
    String uuid = fromSSE ? data['uuid'].toString() : Uuid().v4();
    //如果数据库已经有该uuid则不打印返回
    if (_service.records.any((r) => r.uuid.contains(uuid))) {
      logI("PrintData: uuid $uuid already received, skipping print.");
      return;
    }
    
    _sendToDisplayPanel(data);
    //获取UUID 如果不存在怎本地生成
    data['uuid'] = uuid;
    final fromPlate = data["from_plate"] ?? "";
    final orderType = data["order_type"] ?? "";
    final orderSnCode = data["order_sn_code"] ?? "";
    final orderTime = data["orderTime"] ?? "";
    final orderLinesMap = data["orderLinesMap"] ?? {};
    String remark = data["remark"] ?? "";
    var payment_code = data["payment_code"] ?? "";
    bool isInShop = data["from_plate"] == "Shop";
    bool isTakeOut = orderType !=
        'Shop_In'; // || orderType == 'takeout' || orderType == 'pickup' || orderType == 'Takeout' || orderType == 'delivery';
    OrderType parsedOrderType = _orderTypeFromString(orderType);

    logI("---printData--- order_sn_code $orderSnCode fromPlate $fromPlate");
    final centerPrinter = printerList.firstWhere(
      (p) => p["type"] == 11,
      orElse: () => null,
    );
    final smartWeSSE = sseList.firstWhere(
      (sse) => sse["name"] == 'SmartWe SSE',
      orElse: () => null,
    );

    bool isCenterPrintOn = centerPrinter != null &&
        !centerPrinter["isOff"] &&
        centerPrinter["printIp"] != null &&
        centerPrinter["printIp"].isNotEmpty;
    bool smartWeCenterOn =
        smartWeSSE != null && smartWeSSE["centerOn"] && isCenterPrintOn;
    List orderLineItems = [];

    for (var key in orderLinesMap.keys) {
      final items = orderLinesMap[key];
      orderLineItems = orderLineItems + items;

      final printer = printerList.firstWhere(
        (p) => p["type"].toString() == key && !p["isOff"],
        orElse: () => null,
      );
      if (printer == null) {
        logI("Printer IP not configured for key: $key");
        continue;
      }
      final printerIp = printer["printIp"];
      if (printerIp == null || printerIp.isEmpty) {
        logI("Printer IP is empty for key: $key");
        continue;
      }

      bool isLabelPrint = printer['receipt'] == 1; // Label printing
      bool isContinuous = printer['continuous'] == 1; // Continuous printing

      final rotate = printer["direction"] == 1; // Rotate if direction is 1
      bool printCategory =
          printer['printCategory'] ?? false; // Print category name
      int printerType = printer['type'] ?? 11;

      if (isLabelPrint) {
        // If label printing is enabled, print each item separately
        // 先打印票号和基本信息
        final Queue<PrintTask> labelPrintQueue = Queue<PrintTask>();
        final printSize = printer['labelSize'] ?? '300x225';
        final printHead = printer['printHead'] ?? true;
        final printOptionCode = printer['printOptionCode'] ?? true;
        final printWidth = int.parse(printSize.split('x')[0]); // 获取标签宽度
        final printHeight = int.parse(printSize.split('x')[1]); // 获取标签高度
        // Add the head receipt widget to the print queue
        debugPrint("Label Print Width: $printWidth, Height: $printHeight");
        final time = await DateTime.now().toString().substring(5, 16);
        final orderIdTime = orderId + "#" + time;
        var totalQty = 0;
        for (var item in items) {
          totalQty += (item["qty"] ?? 0) as int;
        }

        int itemCount = 0;

        for (var item in items) {
          final qty = item["qty"] ?? 1;
          final name = item["name"] ?? "";
          final options = item["options"] ?? {};
          String extend1qr = item["extend1qr"] ?? "";

          for (var i = 0; i < qty; i++) {
            // Generate the receipt widget
            itemCount += 1;
            Widget receiptWidget;

            if (printOptionCode && printHeight >= 450 && printWidth >= 375) {
              receiptWidget = largeLabelItem(
                  name,
                  orderSnCode,
                  options,
                  printWidth.toDouble(),
                  printHeight.toDouble(),
                  _labelMaxLine(printHeight),
                  printOptionCode,
                  extend1qr,
                  rotate,
                  '$totalQty-$itemCount',
                  time,
                  orderId,
                  shopName);
            } else {
              receiptWidget = labelItem(
                  name,
                  orderSnCode,
                  options,
                  printWidth.toDouble(),
                  printHeight.toDouble(),
                  _labelMaxLine(printHeight),
                  rotate,
                  '$totalQty-$itemCount',
                  orderIdTime);
            }

            Map printInfo = Map.from(data);
            printInfo['fromPlate'] = fromPlate;
            printInfo['orderSnCode'] = orderSnCode;
            printInfo['orderTime'] = orderTime;
            printInfo['printType'] = 1;
            printInfo['items'] = [item];
            printInfo['uuid'] = uuid + ':1';

            final printTask = PrintTask(widget: receiptWidget, printerIp: printerIp, printerType: printerType, printInfo: printInfo);

            labelPrintQueue.add(printTask);
          }
        }

        if ((isTakeOut && printHead) || (isTakeOut && remark.isNotEmpty)) {
          final headReceipt = headReceiptWidget(
            fromPlate,
            orderSnCode,
            orderTime,
            parsedOrderType,
            itemCount,
            remark,
            printWidth.toDouble(),
            printHeight.toDouble(),
            time,
            rotate,
          );
          Map printInfo = Map.from(data);
          printInfo['fromPlate'] = fromPlate;
          printInfo['orderSnCode'] = orderSnCode;
          printInfo['orderTime'] = orderTime;
          printInfo['printType'] = 0;
          printInfo['uuid'] = uuid + ':0';

          labelPrintQueue.addFirst(PrintTask(widget: headReceipt, printerIp: printerIp, printerType: printerType, printInfo: printInfo));
        }

        _processLabelPrintQueueNew(printerIp, labelPrintQueue);
        continue;
      }

      if (isContinuous) {
        // If continuous printing is enabled, print all items in one go
        printContinuousData(fromPlate, isTakeOut, orderSnCode, orderTime,
            printerIp, isContinuous, rotate, items, parsedOrderType, remark,
            printCategory: printCategory, printerType: printerType, payload: data);
      } else {
        // If label printing is enabled, print each item separately
        printSingleData(fromPlate, isTakeOut, orderSnCode, orderTime, printerIp,
            isContinuous, rotate, items, printCategory, remark, parsedOrderType,
            printerType: printerType, payload: data);
      }
    }

    if ((isCenterPrintOn && isTakeOut) ||
        (fromSSE && smartWeCenterOn && isInShop)) {
      final printIp = centerPrinter["printIp"];
      final rotate = centerPrinter["direction"] == 1;
      bool option = centerPrinter['option'] ?? false; // 是否打印选项
      //假设 payment_code = https://mobile.smartwe.jp/index?p=jM6JKGOpPij9OHl-xlsgl 获取 jM6JKGOpPij9OHl-xlsgl
      if (payment_code.isNotEmpty) {
        //如果有支付码，打印支付码
        payment_code = payment_code.split("=").last;
      }
      printContinuousData(fromPlate, isTakeOut, orderSnCode, orderTime, printIp,
          true, rotate, orderLineItems, parsedOrderType, remark,
          isCenterPrint: true, printOption: option, printQrCode: payment_code, payload: data);
    }
  }

  _labelMaxLine(int height) {
    //计算标签最大行数
    //假设每行高度为 50
    return (height / (225 * 0.25)).floor();
  }

  //_printEfficientLabel
  _printEfficientLabel(Map data) async {
    logI("_printEfficientLabel data: $data");

    final printer = printerList.firstWhere(
      (p) => p["type"] == 10 && !p["isOff"] && p['receipt'] == 1,
      orElse: () => null,
    );
    if (printer == null) {
      logI("Printer IP not configured for type 10");
      return;
    }

    double rotate =
        printer["direction"] == 1 ? pi : 0.0; // Rotate if direction is 1
    final printSize = printer['labelSize'] ?? '300x225';
    final printWidth = double.parse(printSize.split('x')[0]); // 获取标签宽度
    final printHeight = double.parse(printSize.split('x')[1]); // 获取标签高度

    final name = data["name"] ?? "";
    final saveMethod = data["saveMethod"] ?? "";
    final expiredTimeStr = data["expiredTimeStr"] ?? "";
    final printTimeStr = data["printTimeStr"] ?? "";
    final operatorName = data["operatorName"] ?? "";

    final imageWidget = await _efficientLabel(name, saveMethod, expiredTimeStr,
        printTimeStr, operatorName, printWidth, printHeight, rotate);

    //生成打印图层任务，指定任务类型为标签
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: imageWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.label,
        params: PrinterInfo(ip: printer["printIp"]),
      ),
    );
  }

  _efficientLabel(
      String name,
      String saveMethod,
      String expiredTimeStr,
      String printTimeStr,
      String operatorName,
      double printWidth,
      double printHeight,
      rotate) async {
    final printMenus = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 16, bottom: 3),
          child: Text(
            name,
            maxLines: 2,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 26,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 4),
          child: AutoSizeText(saveMethod,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 4),
          child: AutoSizeText("開封：$printTimeStr",
              maxLines: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              )),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 4),
          child: AutoSizeText("期限切れ：$expiredTimeStr",
              maxLines: 2,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              )),
        ),
      ],
    );

    return LabelConstrainedBox(
      Transform(
        transform: Matrix4.rotationZ(rotate),
        alignment: Alignment.center,
        child: printMenus,
      ),
      pagerWidth: printWidth,
      pagerHeight: printHeight,
    );
  }

//{description: いらっしゃいませ。お客様のスマートフォンで、QRコードをスキャンしてご注文をお願いします。お帰りの際は、QRコードを精算機にスキャンして、お支払いくださいますようお願いいたします。ご不明な点がございましたら、スタッフまでお声がけくださいませ。, line1: 卓番：Ａ０２, line2: セルフオーダーQR票, qrCode: a1ght77ycN0OnMBijXzt_}
  printTableSeatInfo(Map data) async {
    debugPrint("printTableSeatInfo data: $data");

    final smartWeSSE = sseList.firstWhere(
      (sse) => sse["name"] == 'SmartWe SSE',
      orElse: () => null,
    );
    debugPrint("SmartWeSSE: $smartWeSSE");

    if (smartWeSSE == null || !(smartWeSSE["printSeat"] ?? true)) {
      debugPrint("SmartWe SSE printSeat is off");
      return;
    }

    //find pinter with type 11
    final printer = printerList.firstWhere(
      (p) => p["type"] == 11 && !p["isOff"],
      orElse: () => null,
    );
    if (printer == null) {
      debugPrint("Printer IP not configured for type 11");
      return;
    }

    double rotate =
        printer["direction"] == 1 ? pi : 0.0; // Rotate if direction is 1

    //final currentTime = DateTime.now().toString().substring(0, 19).replaceAll(" ", "\n");
    final description = data["description"] ?? "";
    final qrCode = data["qrCode"] ?? "";
    final seatNumber = data["line1"] ?? "";
    final line2 = data["line2"] ?? "";

    final imageWidget =
        await _tableSeat(seatNumber, line2, description, qrCode, rotate);

    // 生成打印图层任务，指定任务类型为标签
    //TaskQueueUtils().addTask(task_smartwe_print)?.then((result) {
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: imageWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(ip: printer["printIp"]),
      ),
    );
    //});
  }

  _tableSeat(String line1, String line2, String description, String qrCode,
      rotate) async {
    List<Widget> printMenus = [];
    printMenus.add(
      Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(line1,
                    style: TextStyle(
                      fontSize: 45.sp,
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(line2,
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
          ),
          Container(
              margin: EdgeInsets.only(bottom: 4),
              width: 270.w,
              height: 280.h,
              child: BarcodeWidget(
                height: 280,
                barcode: Barcode.qrCode(),
                data: qrCode,
              )

              // QrImage(
              //   size: 380,
              //   data: orderKey,
              // ),
              ),
          Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(description,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w400,
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
          ),
        ],
      ),
    );

    return ReceiptConstrainedBox(Transform(
        transform: Matrix4.rotationZ(rotate),
        alignment: Alignment.center,
        child: Container(
          //width: 560,
          //height: 720,
          padding: EdgeInsets.only(left: 0.5, right: 0.5),
          color: Colors.white,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: printMenus,
          ),
        )));
  }

  Widget labelItem(
    String name,
    String number,
    Map options,
    double printWidth,
    double printHeight,
    int maxLines,
    bool rotate,
    String index,
    String time,
    {OrderType orderType = OrderType.shopin}
  ) {
    return LabelConstrainedBox(
      Transform(
        transform: Matrix4.rotationZ(rotate ? pi : 0.0),
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.only(right: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
              constraints: const BoxConstraints(
                minHeight: 60,
                // maxHeight: 100, // 先去掉，避免总被顶到上限
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end, 
                children: [
                  Expanded(
                    flex: 2,
                    child: AutoSizeText(
                      name,
                      maxLines: 3,
                      minFontSize: 22,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // 关键：按内容高度
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AutoSizeText(
                          ' # $number',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        AutoSizeText(
                          index,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

              
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              Expanded(
                //flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 5, left: 10),
                        width: double.infinity,
                        child: optionList(options, maxLines),
                      ),
                    ),
                   Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      time,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                    
                  ],
                ),
              ),
              // if (extend1qr.isNotEmpty && printOptionCode)
              // Container(
              //   margin: EdgeInsets.only(left: 10),
              //   child: BarcodeWidget(
              //   height: 140,
              //   width: 140,
              //   barcode: Barcode.qrCode(),
              //   data: extend1qr,
              // ))
            ],
          ),
        ),
      ),
      pagerWidth: printWidth,
      pagerHeight: printHeight,
    );
  }

  Widget largeLabelItem(
    String name,
    String number,
    Map options,
    double printWidth,
    double printHeight,
    int maxLines,
    bool printOptionCode,
    String extend1qr,
    bool rotate,
    String index,
    String time,
    String orderId,
    String shopName,
    {OrderType orderType = OrderType.shopin}
  ) {
    return LabelConstrainedBox(
      Transform(
        transform: Matrix4.rotationZ(rotate ? pi : 0.0),
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.only(right: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    ' # ' + number,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 44,
                      color: const ui.Color.fromARGB(255, 42, 29, 29),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                  ),
                  Text(
                    index,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                  ),
                ],
              ),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // 超出部分显示省略号
              ),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              Expanded(
                //flex: 2,
                child: Container(
                  margin: EdgeInsets.only(top: 5, left: 10),
                  width: double.infinity,
                  child: optionList(options, maxLines),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (extend1qr.isNotEmpty && printOptionCode)
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: BarcodeWidget(
                          height: 140,
                          width: 140,
                          barcode: Barcode.qrCode(),
                          data: extend1qr,
                        )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        shopName,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        time,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        orderId,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      pagerWidth: printWidth,
      pagerHeight: printHeight,
    );
  }

  _getOrderTypeIcon(OrderType orderType) {
    switch (orderType) {
      case OrderType.shopin:
        return Icons.home_outlined;
      case OrderType.takeout:
        return Icons.shopping_bag_outlined;
      case OrderType.pickup:
        return Icons.shopping_bag_outlined;
      case OrderType.delivery:
        return Icons.delivery_dining_sharp;
      default:
        return Icons.restaurant;
    }
  }

  Widget headReceiptWidget(
      String fromPlate,
      String orderSnCode,
      String orderTime,
      OrderType orderType,
      int itemCount,
      String remark,
      double printWidth,
      double printHeight,
      String time,
      bool rotate) {
    return LabelConstrainedBox(
        Transform(
            transform: Matrix4.rotationZ(rotate ? pi : 0.0),
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.only(right: 3),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: 
                              Row(
                                children: [
                                  Icon(
                                    _getOrderTypeIcon(orderType),
                                    size: 56,
                                    color: Colors.black,
                                  ),
                                  AutoSizeText(
                                    fromPlate,
                                    textAlign: TextAlign.left,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 50,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                                  ),
                                ],
                              )
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    ' # ' + orderSnCode,
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis, // 超出部分显示省略号
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    '$itemCount',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis, // 超出部分显示省略号
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                    Expanded(
                      //flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            remark,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(top: 5),
                            child: Text(
                              time,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
            )),
        pagerWidth: printWidth,
        pagerHeight: printHeight);
  }

  Widget optionItem1(String optionName, List optionValues) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$optionName：",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          ...optionValues.map((option) {
            final optionDetail = option["name"] ?? "";
            final optionQty = option["qty"] ?? 1;
            final optionQtyString = optionQty == 1 ? "" : "x $optionQty";
            return Text(
              " $optionDetail $optionQtyString ",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String optionItem(String optionName, List optionValues) {
    //返回Option字符串组合 格式 optionName: optionDetail1, optionDetail2 x qty2;
    return "$optionName: " +
        optionValues.map((option) {
          final optionDetail = option["name"] ?? "";
          final optionQty = option["qty"] ?? 1;
          final optionQtyString = optionQty == 1 ? "" : "x $optionQty";
          return "$optionDetail $optionQtyString";
        }).join(", ");
  }

  Widget optionList(Map options, int maxLines) {
    //合并所有Option为一个字符串格式为 optionName: optionDetail1 x qty1, optionDetail2 x qty2;
    if (options.isEmpty) {
      return Container(); // 如果没有选项，返回空容器
    }

    String optionStrings = options.entries.map((entry) {
      final optionName = entry.key;
      final optionValues = entry.value;
      return optionItem(optionName, optionValues);
    }).join("、");

    //使用 AutoText来自动调整文本大小
    return AutoSizeText(
      optionStrings,
      maxLines: maxLines, // 最多显示两行
      style: TextStyle(
        fontSize: 28,
        color: Colors.black,
      ),
      overflow: TextOverflow.ellipsis, // 超出部分显示省略号
    );
  }

  //打印逻辑为 连票打印时 只有一个标题receiptTitle 中间为菜品menuItem，最后右下角为下单时间
  //使用 printData 的同样参数实现这个需求

  printContinuousData(
    String fromPlate,
    bool isTakeOut,
    String orderSnCode,
    String orderTime,
    String printerIp,
    bool isContinuous,
    bool isRotate,
    List items,
    OrderType orderType,
    String remark, {
    bool isCenterPrint = false,
    bool printOption = true,
    String? printQrCode,
    bool printCategory = false,
    int printerType = 11,
    Map payload = const {},
  }) async {
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
                isTakeOut: isTakeOut, orderType: orderType,
                continuous: true,
                isCenterPrint: isCenterPrint),
            ...items.map((item) {
              final qty = item["qty"] ?? 1;
              final name = item["name"] ?? "";
              final options = item["options"] ?? {};
              final categoryName = item["categoryName"] ?? "";
              return menuItem(name, qty, options,
                  isUnderLine: true,
                  needOption: printOption,
                  isContinuous: true,
                  categoryName: printCategory ? categoryName : null);
            }).toList(),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                orderTime,
                style: TextStyle(
                  fontSize: 45,
                ),
              ),
            ),
            if (isCenterPrint && remark.isNotEmpty) remarkTitle(remark),
            if (printQrCode != null && printQrCode.isNotEmpty)
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      //margin: EdgeInsets.all(20),
                      child: Text(
                        "お会計について、QRコードを精算機にかざしていただき、お支払いくださいますようお願い申し上げます。\nご不明な点がございましたら、恐れ入りますがスタッフまでお声がけくださいませ。",
                        //maxLines: 4,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        //margin: EdgeInsets.all(20),
                        // width: 200.w,
                        // height: 200.h,
                        child: BarcodeWidget(
                      height: 200,
                      width: 200,
                      barcode: Barcode.qrCode(),
                      data: printQrCode,
                    )),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    Map printInfo = Map.from(payload);
    printInfo['fromPlate'] = fromPlate;
    printInfo['orderSnCode'] = orderSnCode;
    printInfo['orderTime'] = orderTime;
    printInfo['printType'] = 3;
    printInfo['items'] = items;
    printInfo['uuid'] = payload['uuid'] + ':3';

    // Add the receipt widget to the print queue
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: receiptWidget as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(ip: printerIp, printerType: printerType, printInfo: printInfo),
      ),
    );
  }

  //单票打印时 每个菜品分开打印 分别有receiptTitle 和menuItem 最后右下角没有不需要时间

  printSingleData(
      String fromPlate,
      bool isTakeOut,
      String orderSnCode,
      String orderTime,
      String printerIp,
      bool isContinuous,
      bool isRotate,
      List items,
      bool printCategory,
      String remark,
      OrderType orderType,
      {
        int printerType = 11, Map payload = const {}}) async {
    final rotate = isRotate ? pi : 0.0;
    int index = 1;
    for (var item in items) {
      final qty = item["qty"] ?? 1;
      final name = item["name"] ?? "";
      final options = item["options"] ?? {};
      final categoryName = item["categoryName"] ?? "";

      // Generate the receipt widget
      final receiptWidget = ReceiptConstrainedBox(
        Transform(
          transform: Matrix4.rotationZ(rotate),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              receiptTitle(orderSnCode, orderTime, fromPlate,
                  isTakeOut: isTakeOut, orderType: orderType,
                  categoryName: printCategory ? categoryName : ""),
              menuItem(name, qty, options,
                  categoryName: printCategory ? categoryName : ""),
              //remarkTitle(remark)
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  orderTime,
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              )
            ],
          ),
        ),
      );

      Map printInfo = Map.from(payload);
      printInfo['printType'] = 2;
      printInfo['fromPlate'] = fromPlate;
      printInfo['orderSnCode'] = orderSnCode;
      printInfo['orderTime'] = orderTime;
      printInfo['items'] = [item];
      printInfo['uuid'] = printInfo['uuid'] + ':2-$index';
      index += 1;

      // Add the receipt widget to the print queue
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: receiptWidget as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: PrinterInfo(ip: printerIp, printerType: printerType, printInfo: printInfo),
        ),
      );
    }
  }

  Widget remarkTitle(String content) {
    return Container(
      child: Text(
        content,
        style: TextStyle(
          fontSize: 32,
          color: ColorsUtil.hexToColor("#000000"),
        ),
      ),
    );
  }

  //标题
  Widget receiptTitle(String title, String orderTime, String fromPlate,
      {bool isTakeOut = false,
      OrderType orderType = OrderType.shopin,
      bool continuous = false,
      bool isCenterPrint = false,
      String categoryName = ""}) {
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
                  if (isTakeOut && !isCenterPrint)
                    Icon(
                      _getOrderTypeIcon(orderType),
                      size: 50,
                      color: Colors.black,
                    ),
                  if (isTakeOut && isCenterPrint)
                    Text(
                      fromPlate + ' # ',
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              if (categoryName.isNotEmpty)
                AutoSizeText(
                  "[$categoryName]",
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
            ],
          ),
          // if (!continuous)
          //   Text(
          //     orderTime,
          //     style: TextStyle(
          //       fontSize: 40,
          //       color: ColorsUtil.hexToColor("#000000"),
          //     ),
          //   ),
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
      {bool isUnderLine = false,
      bool needOption = true,
      bool isContinuous = false,
      String? categoryName}) {
    final optionQtyString = qty == 1 ? "" : "x $qty";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categoryName != null && isContinuous)
            Container(
              child: Text(
                "【$categoryName】",
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 40,
                    color: ColorsUtil.hexToColor("#000000"),
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                optionQtyString,
                style: TextStyle(
                  fontSize: 40,
                  color: ColorsUtil.hexToColor("#000000"),
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (option.isNotEmpty && needOption)
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
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...optionValues.map((option) {
                              final optionDetail = option["name"] ?? "";
                              final optionQty = option["qty"] ?? 1;
                              final optionQtyString =
                                  optionQty == 1 ? "" : "x $optionQty";
                              return Text(
                                maxLines: 3,
                                "    $optionDetail $optionQtyString",
                                style: TextStyle(
                                  fontSize: 36,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
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

    final printer10 = _machineInfo.printerList.firstWhere(
      (p) => p["type"] == 10,
      orElse: () => null,
    );
    final printer12 = _machineInfo.printerList.firstWhere(
      (p) => p["type"] == 12,
      orElse: () => null,
    );

    final wlan_print_ip = printer10?["printIp"] ?? "";
    final wlan_print_port = printer10?["printPort"] ?? "9100";
    final rotate10 = printer10?["direction"] ?? 0;

    final wlan_print_ip_two = printer12?["printIp"] ?? "";
    final wlan_print_port_two = printer12?["printPort"] ?? "9100";
    final rotate12 = printer12?["direction"] ?? 0;
    final is_allow_wlanPrint_continuous = printer10?["continuous"] ?? 0;
    final is_allow_wlanPrint_Two_continuous = printer12?["continuous"] ?? 0;

    //判断是否有打印机ip
    Map printerIpInfo = {
      "printer_ip": "",
      "printer_port": "",
    };
    if (printType == "10") {
      if (wlan_print_ip != null && wlan_print_ip != "") {
        final rotate = rotate10 == 1 ? pi : 0.0;

        printerIpInfo = {
          "printer_ip": wlan_print_ip,
          "printer_port": wlan_print_port,
        };
        if (is_allow_wlanPrint_continuous == 1) {
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
        final rotate = rotate12 == 1 ? pi : 0.0;
        printerIpInfo = {
          "printer_ip": wlan_print_ip_two,
          "printer_port": wlan_print_port_two,
        };
        if (is_allow_wlanPrint_Two_continuous == 1) {
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

    // categoryMenus.add(
    //   Container(
    //     margin: EdgeInsets.only(
    //               bottom: ScreenAdapter.height(50)),
    //     child: BarcodeWidget(
    //             height: ScreenAdapter.height(200),
    //             barcode: Barcode.qrCode(),
    //             data: orderId.value,
    //           )
    //   ),
    // );

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

    // return Container(
    //   width: 550,
    //   height: totalHight.toDouble(),
    //   padding: EdgeInsets.only(left: 0.5, right: 0.5),
    //   color: Colors.white,
    //   alignment: Alignment.topCenter,
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: categoryMenus,
    //   ),
    // );
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
    final printer10 = _machineInfo.printerList.firstWhere(
      (p) => p["type"] == 10,
      orElse: () => null,
    );
    final wlan_print_ip = printer10?["printIp"] ?? "";
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
    final printer10 = _machineInfo.printerList.firstWhere(
      (p) => p["type"] == 10,
      orElse: () => null,
    );
    final wlan_print_ip = printer10?["printIp"] ?? "";
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
