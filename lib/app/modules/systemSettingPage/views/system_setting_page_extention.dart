import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/system_setting_page_view.dart';

import 'package:get/get.dart';

import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

import '../../../widget/CostomIconButton.dart';

extension SystemSettingPageExtension on SystemSettingPageView {

  editSSETable(Map sseItem) {

    final name = sseItem['name'] ?? "";
    final address = sseItem['address'] ?? "";
    final identify = sseItem['identify'] ?? "";
    final isOn = sseItem['isOn'] ?? false;
    final needInput = sseItem['needInput'] ?? false;
    final needCenterPrint = sseItem['needCenterPrint'] ?? false;
    final centerOn = sseItem['centerOn'] ?? false;
    final printSeat = sseItem['printSeat'] ?? true;
    var statusColor = Colors.red;

    for (var item in controller.sseService.subscriptions.entries) {
      if (item.key.contains(identify) && identify.isNotEmpty) {
        if (item.value == true) {
          statusColor = Colors.green;
        } else {
          statusColor = Colors.orange;
        }
        break;
      }
    }

    return Table(
        border: TableBorder.all(),
        columnWidths: const <int, TableColumnWidth>{
          //0: IntrinsicColumnWidth(),
          0: FlexColumnWidth(258),
          1: FlexColumnWidth(750),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[

          TableRow(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(20)),
                  child: 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(22),
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      //sse status
                      SizedBox(width: ScreenAdapter.width(10)),
                      Icon(Icons.circle, color: statusColor, size: ScreenAdapter.width(24)),
                    ],
                  ),
                ),
                _setSSECell(
                    name,
                    address, identify, isOn,
                    needInput: needInput,
                    needCenterPrint: needCenterPrint,
                    centerOn: centerOn,
                    printSeat: printSeat
                ),
              ]
          ),
        ]
    );
  }

  _setSSECell(String name, String address, String identify, bool isOn, {bool needInput = true, bool needCenterPrint = false, 
  bool centerOn = false, bool printSeat = true}) {
    return Container(
        margin: EdgeInsets.only(
            top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
        padding: EdgeInsets.only(left: ScreenAdapter.width(20),
            top: ScreenAdapter.height(3),
            bottom: ScreenAdapter.height(3), right: ScreenAdapter.width(20)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: ScreenAdapter.height(10),
            children: [
              if (needInput)
              
                InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent,
                  onTap: (){
                    controller.editSSESetting(name, address, identify, isOn);
                  },
                  child: Container(
                    //margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                    //设置 child 居中
                    alignment: Alignment(0, 0),
                    height: ScreenAdapter.height(60),
                    width: ScreenAdapter.width(220),
                    //边框设置
                    decoration: new BoxDecoration(
                      //背景
                      color: ColorsUtil.hexToColor("#409eff"),
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //设置四周边框
                      //border: new Border.all(width: 1, color: Colors.red),
                    ),
                    child: Text(
                            identify.isEmpty ? "ターチして設置":identify,
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(22),
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )
                            ),
                  ),
                ),
            

              //switchButton ios type
              if (identify.isNotEmpty)
              Row(
                children: [
                  Text(
                    isOn ? "オン" : "オフ",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(22),
                      color: isOn ? ColorsUtil.hexToColor("#409eff") : Colors.grey,
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(10)),
                  FlutterSwitch(
                    value: isOn,
                    onToggle: (value) async {
                      controller.updateSSESetting(name, identify: identify, isOn: value, centerOn: value == true ? centerOn : false);
                    },
                  ),
                  SizedBox(width: ScreenAdapter.width(10)),
                  
                ],
              ),

              

              if (isOn && needCenterPrint)
              Row(
                children: [
                  
                  Text(
                    "注文伝票",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(22),
                      color: centerOn ? ColorsUtil.hexToColor("#409eff") : Colors.grey,
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(10)),
                  FlutterSwitch(
                    value: centerOn,
                    onToggle: (value) {
                      controller.updateSSESetting(name, centerOn: value);
                    },
                  ),
                ],
              ),

              if (isOn && name == "SmartWe SSE")
                Row(
                children: [
                  
                  Text(
                    "お会計伝票",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(22),
                      color: printSeat ? ColorsUtil.hexToColor("#409eff") : Colors.grey,
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(10)),
                  FlutterSwitch(
                    value: printSeat,
                    onToggle: (value) {
                      controller.updateSSESetting(name, printSeat: value);
                    },
                  ),
                ],
              ),
            ]
        )
    );
  }






  TableRow printerSettingWidget(Map printerItem) {

    bool isDefaultPrinter = printerItem['isDefault'] ?? true; // 是否默认打印机

    return TableRow(
      children: [
        Container(
          height: ScreenAdapter.height(80),
          alignment: Alignment.center,
          child: Text(
            printerItem['name'],
            style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: ScreenAdapter.fontSize(22),
              fontWeight: FontWeight.w500
            ),
          ),
        ),
        isDefaultPrinter ? _printerSettingWidget(printerItem):
        Dismissible(
          key: Key(printerItem['name']),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            // Show a confirmation dialog or perform any checks
            return await showDialog(
              context: Get.context!,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("削除確認"),
                  content: Text("このプリンター設定を削除しますか？"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("キャンセル"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        controller.removePrinter(printerItem);
                      },
                      child: Text("削除する"),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            // Handle the actual removal logic here
            debugPrint("${printerItem['name']} dismissed");
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: _printerSettingWidget(printerItem),
        )
      ]
    );
  }

  Widget addButton() {
    return Container(
      //margin: EdgeInsets.only(top: ScreenAdapter.height(20)),
      //height: ScreenAdapter.height(80),
      decoration: BoxDecoration(
        color: ColorsUtil.hexToColor("#F5F5F5"),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: ColorsUtil.hexToColor("#979797"),
          width: 0.5,
        ),
      ),
      child: CustomIconButton(
          icon: Icons.add,
          size: 40,
          onPressed: () {
            controller.addCustomPrinter();
          },
          bgColor: Colors.white
      ),
    );
  }

  _printerSettingWidget(Map printerItem) {
    final type = printerItem['type'] ?? 0; // 打印机类型
    final receipt = printerItem['receipt'] ?? 0; // 打印机类型 0 小票 1 标签
    final labelSize = printerItem['labelSize'] ?? '300x225'; // 标签宽度
    final labelWidth = int.parse(labelSize.split('x')[0] ?? "40"); // 标签宽度
    final continuous = printerItem['continuous'] ?? 0; // 连续打印 0 单票 1 连票
    final isOff = printerItem['isOff'] ?? false; // 是否开启打印机
    final printIp = printerItem['printIp'] ?? ""; // 打印机IP
    final printPort = printerItem['printPort'] ?? ""; // 打印机端口
    final printDirection = printerItem['direction'] ?? 0; // 打印方向 0 正 1 逆
    bool printOption = printerItem['option'] ?? false; // 打印选项
    bool isSingleMode = type == 11 ||  receipt == 1;
    bool printCategory = printerItem['printCategory'] ?? false; // 是否打印分类名称
    bool printHead = printerItem['printHead'] ?? true; // 是否打印抬头

        return
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: ScreenAdapter.height(8),
                    bottom: ScreenAdapter.height(8)),
                padding: EdgeInsets.only(left: ScreenAdapter.width(20),
                    top: ScreenAdapter.height(3),
                    bottom: ScreenAdapter.height(3)),
                child: isSingleMode ?
                _singleModePrinter(type, receipt, isOff, continuous == 1, printIp, printPort, labelWidth) :
                _hasContinuosPrinter(type, receipt, isOff, continuous == 1, printIp, printPort),
              ),
              Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    //0: IntrinsicColumnWidth(),
                    0: FlexColumnWidth(200),
                    1: FlexColumnWidth(550),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[

                    TableRow(
                        children: <Widget>[
                          Container(
                            height: ScreenAdapter.height(80),
                            alignment: Alignment.center,
                            child: Text(
                              "プリント方向",
                              style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(22),
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          _setPrintDirection(type, receipt, printDirection),
                          //第二台打印机

                        ]
                    ),
                    if (type == 11)
                      TableRow(
                          children: <Widget>[
                            Container(
                              height: ScreenAdapter.height(80),
                              alignment: Alignment.center,
                              child: Text(
                                "オプション",
                                style: TextStyle(
                                    fontFamily: 'NotoSansJP',
                                    fontSize: ScreenAdapter.fontSize(22),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  FlutterSwitch(
                                    value: printOption,
                                    onToggle: (value) {
                                      controller.updatePrinterInfo(type, receipt, option: value);
                                    },
                                  ),
                                ],
                              ),
                            ),

                          ]
                      ),



                  ]
              ),
              if (receipt == 1)
              Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    //0: IntrinsicColumnWidth(),
                    0: FlexColumnWidth(200),
                    1: FlexColumnWidth(550),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[

                    TableRow(
                        children: <Widget>[
                          Container(
                            height: ScreenAdapter.height(80),
                            alignment: Alignment.center,
                            child: Text(
                              "プリントサイズ",
                              style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(22),
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          _setLabelPrintSize(type, receipt, labelSize), //第二台打印机

                        ]
                    ),

                  ]
              ),

              if (receipt == 1)
                Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    //0: IntrinsicColumnWidth(),
                    0: FlexColumnWidth(200),
                    1: FlexColumnWidth(550),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[

                    TableRow(
                        children: <Widget>[
                          Container(
                            height: ScreenAdapter.height(80),
                            alignment: Alignment.center,
                            child: Text(
                              "ヘッダー印刷",
                              style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(22),
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FlutterSwitch(
                                  value: printHead,
                                  onToggle: (value) {
                                    controller.updatePrinterInfo(type, receipt, printHead: value);
                                  },
                                ),
                              ],
                            ),
                          ),

                        ]
                    )
                  ],
                ),

              //category print
              if (receipt != 1)
              Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    //0: IntrinsicColumnWidth(),
                    0: FlexColumnWidth(200),
                    1: FlexColumnWidth(550),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[

                    TableRow(
                        children: <Widget>[
                          Container(
                            height: ScreenAdapter.height(80),
                            alignment: Alignment.center,
                            child: Text(
                              "カテゴリー",
                              style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(22),
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FlutterSwitch(
                                  value: printCategory,
                                  onToggle: (value) {
                                    controller.updatePrinterInfo(type, receipt, printCategory: value);
                                  },
                                ),
                              ],
                            ),
                          ),

                        ]
                    )
                  ],
              )
              
            ]
        );
  }

  _singleModePrinter(int type, int receipt, bool isOff, bool isContinuous, String printIp, String printPort, int labelWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          highlightColor: Colors.transparent, // 透明色
          splashColor: Colors.transparent, // 透明色
          onTap: () {
            controller.updatePrinterState(type, receipt, true);
          },
          child: Container(
            //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
            //设置 child 居中
            alignment: Alignment(0, 0),
            height: ScreenAdapter.height(60),
            width: ScreenAdapter.width(140),
            //边框设置
            decoration: new BoxDecoration(
              //背景
              color: isOff ? ColorsUtil
                  .hexToColor("#409eff") : Colors.grey[200],
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              //设置四周边框
              //border: new Border.all(width: 1, color: Colors.red),
            ),
            child: Text("オフ",
                style: TextStyle(
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w400,
                  fontSize: ScreenAdapter.fontSize(22.0),
                  color: isOff
                      ? ColorsUtil.hexToColor("#FFFFFF")
                      : ColorsUtil.hexToColor("#000000"),
                )
            ),
          ),
        ),
        InkWell(
          highlightColor: Colors.transparent, // 透明色
          splashColor: Colors.transparent, // 透明色
          onTap: () {
            controller.showPrintSettingDialog(type, receipt, 0, printerIp: printIp, port: printPort);
          },
          child: Container(
            margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
            //设置 child 居中
            alignment: Alignment(0, 0),
            height: ScreenAdapter.height(60),
            width: ScreenAdapter.width(140),
            //边框设置
            decoration: new BoxDecoration(
              //背景
              color: !isOff
                  ? ColorsUtil.hexToColor("#409eff")
                  : Colors.grey[200],
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              //设置四周边框
              //border: new Border.all(width: 1, color: Colors.red),
            ),
            child: RichText(
              text: TextSpan(
                  text: "オン",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: !isOff
                        ? ColorsUtil.hexToColor("#FFFFFF")
                        : ColorsUtil.hexToColor("#000000"),
                  ),
                  children: [
                    TextSpan(
                      text: "",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(18),
                        fontWeight: FontWeight.w400,
                        color: ColorsUtil.hexToColor("#d90000"),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
          //设置 child 居中
          alignment: Alignment(0, 0),
          height: ScreenAdapter.height(60),
          width: ScreenAdapter.width(140),
        ),
        if(printIp != "" && printPort != "")
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: () {
              controller.printTest(printIp,
                  printPort,
                  printType: receipt, labelWidth: labelWidth.toDouble());
            },
            child: Container(
              margin: EdgeInsets.only(
                  left: ScreenAdapter.width(20)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: ColorsUtil.hexToColor("#409eff"),
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(
                    5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "$printIp:",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(20),
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )
                      ),
                      Text(
                          "$printPort",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(20),
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )
                      )
                    ],
                  ),
                  Text("テスト印刷",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenAdapter.fontSize(20.0),
                        color: ColorsUtil.hexToColor("#FFFFFF"),
                      )
                  ),
                ],
              ),
            ),
          ),

      ],
    );
  }

  _hasContinuosPrinter(int type, int receipt, bool isOff, bool isContinuous, String printIp, String printPort) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          highlightColor: Colors.transparent, // 透明色
          splashColor: Colors.transparent, // 透明色
          onTap: (){
            controller.updatePrinterState(type, receipt, true);
          },
          child: Container(
            //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
            //设置 child 居中
            alignment: Alignment(0, 0),
            height: ScreenAdapter.height(60),
            width: ScreenAdapter.width(140),
            //边框设置
            decoration: new BoxDecoration(
              //背景
              color: isOff ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              //设置四周边框
              //border: new Border.all(width: 1, color: Colors.red),
            ),
            child: Text("オフ",
                style: TextStyle(
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w400,
                  fontSize: ScreenAdapter.fontSize(22.0),
                  color: isOff ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                )
            ),
          ),
        ),
        InkWell(
          highlightColor: Colors.transparent, // 透明色
          splashColor: Colors.transparent, // 透明色
          onTap: (){
            controller.showPrintSettingDialog(type, receipt, 0, printerIp: printIp, port: printPort);
          },
          child: Container(
            margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
            //设置 child 居中
            alignment: Alignment(0, 0),
            height: ScreenAdapter.height(60),
            width: ScreenAdapter.width(140),
            //边框设置
            decoration: new BoxDecoration(
              //背景
              color: !isOff&&!isContinuous ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              //设置四周边框
              //border: new Border.all(width: 1, color: Colors.red),
            ),
            child: RichText(
              text: TextSpan(
                  text: "オン",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: !isOff&&!isContinuous ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  ),
                  children: [
                    TextSpan(
                      text: "（単票）",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(18),
                        fontWeight: FontWeight.w400,
                        color: ColorsUtil.hexToColor("#d90000"),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
        InkWell(
          highlightColor: Colors.transparent, // 透明色
          splashColor: Colors.transparent, // 透明色
          onTap: (){
            controller.showPrintSettingDialog(type, receipt, 1, printerIp: printIp, port: printPort);
          },
          child: Container(
            margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
            //设置 child 居中
            alignment: Alignment(0, 0),
            height: ScreenAdapter.height(60),
            width: ScreenAdapter.width(140),
            //边框设置
            decoration: new BoxDecoration(
              //背景
              color: !isOff&&isContinuous ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              //设置四周边框
              //border: new Border.all(width: 1, color: Colors.red),
            ),
            child: RichText(
              text: TextSpan(
                  text: "オン",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: !isOff&&isContinuous ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  ),
                  children: [
                    TextSpan(
                      text: "（連票）",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(18),
                        fontWeight: FontWeight.w400,
                        color: ColorsUtil.hexToColor("#d90000"),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
        if(printIp != "" && printPort != "")
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.printTest(printIp,printPort);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: ColorsUtil.hexToColor("#409eff"),
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "$printIp:",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(20),
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )
                      ),
                      Text(
                          "$printPort",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(20),
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )
                      )
                    ],
                  ),
                  Text("テスト印刷",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenAdapter.fontSize(20.0),
                        color: ColorsUtil.hexToColor("#FFFFFF"),
                      )
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  _setLabelPrintSize(int type, int receipt, String size) {

    final _labelPrintSize = { "60x30":"450x225", "50x30":"375x225", "40x30":"300x225",
                              "60x40":"450x300", "50x40":"375x300", "40x40":"300x300",
                              "60x50":"450x375", "50x50":"375x375", "40x50":"300x375"
    };
    //size 是 value 找到对应的 key
    String? labelSizeKey = _labelPrintSize.keys.firstWhere(
      (key) => _labelPrintSize[key] == size,
      orElse: () => "40x30" // 默认值
    );

    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child:
      Container(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: labelSizeKey,
            onChanged: (String? newValue) {
              final printSize = _labelPrintSize[newValue] ?? "300x225";
              controller.updatePrinterInfo(type, receipt, printSize: printSize);
            },
            items: _labelPrintSize.keys.map<DropdownMenuItem<String>>((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(
                    key,
                    style: TextStyle(
                      color: labelSizeKey == key ? ColorsUtil.hexToColor("#409eff") : Colors.black,
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w600,
                    fontSize: ScreenAdapter.fontSize(20.0),
                  ),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            isExpanded: true,
          ),
        ),
      )
    );
  }

  setMachinePrintSize(double width) {

    final _labelPrintSize = {"58":385, "80":530};

    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: ScreenAdapter.width(15), // 主轴(水平)方向间距
        children: [
        Text(
          "プリント幅:",
          style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: ScreenAdapter.fontSize(22),
              fontWeight: FontWeight.w500
          ),
        ),
        ..._labelPrintSize.keys.map((e) {
          int labelWidth = _labelPrintSize[e] ?? 0;
          return InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.updateMachinePrintWidth(labelWidth.toDouble());
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(140),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (width == labelWidth) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],//
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("$e",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (width == labelWidth) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          );
        }).toList(),]
      ),
    );
  }

  _setPrintDirection(type,receipt, printDirection) {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              //controller.setPrintDirection("0",index);
              controller.updatePrinterInfo(type, receipt, direction: 0);
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(140),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: printDirection == 0 ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("デフォルト",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: printDirection == 0 ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.updatePrinterInfo(type,receipt, direction: 1);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(140),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: printDirection == 1 ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("逆に",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: printDirection == 1 ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

}