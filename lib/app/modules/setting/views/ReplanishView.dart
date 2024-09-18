import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/setting/controllers/exchange_controller_extension.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/modules/setting/views/RejishimeiPrintView.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReplanishView extends StatelessWidget {
  //final SettingController controller = Get.find<SettingController>();

  final SettingController controller;
  ReplanishView({Key? key, required this.controller}) : super(key: key);

  var printLength = 0.0;

  showRelanishAlert() {
    GlobalKey containerKey = GlobalKey();
    return Obx(() => SimpleDialog(children: <Widget>[
          Stack(alignment: Alignment.topCenter, children: <Widget>[
            Container(
              //退款小票信息，计算大小用，不显示。
              child: Offstage(
                offstage: true, //不显示
                child: Container(
                  key: containerKey,
                  alignment: Alignment.centerRight,
                  child: PrintView(
                    printInfo: controller.supplyInfo,
                    printType: PrintType.SUPPLY,
                    lengthUpdate: (double length) {
                      print("printLength: $length");
                      printLength = length;
                    },
                  ),
                ),
              ),
            ),
            Container(
                width: ScreenAdapter.width(680),
                padding: EdgeInsets.only(
                    left: ScreenAdapter.width(30),
                    right: ScreenAdapter.width(30),
                    bottom: ScreenAdapter.height(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "お預り金を補充してください",
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(28),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //当前补充金额明细
                    Text(
                      "今回の補充金額",
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(26),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    //两行表格显示补充状态
                    Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(100),
                        },
                        children: [
                          TableRow(children: [
                            Container(
                              height: 80,
                              alignment: Alignment.center,
                              child: Text("金種",
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#000000"),
                                  )),
                            ),
                            //取titleAndValueMap()的key的前五个
                            ...titleAndValueMap().keys.take(5).map((element) {
                              return Container(
                                height: 80,
                                alignment: Alignment.center,
                                child: Text("$element",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(20),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )),
                              );
                            }).toList()
                          ]),
                        ]),

                    Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(100),
                        },
                        children: [
                          TableRow(children: [
                            Container(
                              height: 80,
                              alignment: Alignment.center,
                              child: Text("枚数",
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#000000"),
                                  )),
                            ),
                            //取titleAndValueMap()的value的前五个
                            ...titleAndValueMap().values.take(5).map((element) {
                              return Container(
                                height: 80,
                                alignment: Alignment.center,
                                child: Text("$element",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(20),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )),
                              );
                            }).toList()
                          ]),
                        ]),

                    Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(100),
                        },
                        children: [
                          TableRow(children: [
                            Container(
                              height: 80,
                              alignment: Alignment.center,
                              child: Text("金種",
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#000000"),
                                  )),
                            ),
                            //取titleAndValueMap()的key的后五个
                            ...titleAndValueMap().keys.skip(5).map((element) {
                              return Container(
                                height: 80,
                                alignment: Alignment.center,
                                child: Text("$element",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(20),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )),
                              );
                            }).toList()
                          ]),
                        ]),

                    Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(100),
                        },
                        children: [
                          TableRow(children: [
                            Container(
                              height: 80,
                              alignment: Alignment.center,
                              child: Text("枚数",
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#000000"),
                                  )),
                            ),
                            //取titleAndValueMap()的value的后五个
                            ...titleAndValueMap().values.skip(5).map((element) {
                              return Container(
                                height: 80,
                                alignment: Alignment.center,
                                child: Text("$element",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(20),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )),
                              );
                            }).toList()
                          ]),
                        ]),

                    SizedBox(
                      height: 20,
                    ),

                    //补充金额总和显示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "合計金額：",
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(26),
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${formatSum(controller.getPutMoney.value)} 円",
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(26),
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    //开始补钱按钮controller.startDeposit();

                    if (!controller.isStartPutMoney.value)
                      Container(
                        width: ScreenAdapter.width(680),
                        height: ScreenAdapter.height(80),
                        child: ElevatedButton(
                          onPressed: () async {
                            //startPutMoney();
                            controller.startPutMoney();
                          },
                          child: Text("開始補充",
                              style: TextStyle(
                                fontFamily: GFont.getFontFamily(),
                                fontSize: ScreenAdapter.fontSize(26),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor("#ffffff"),
                              )),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                ColorsUtil.hexToColor("#A61C1C")),
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                          ),
                        ),
                      ),

                    if (controller.isStartPutMoney.value)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: ScreenAdapter.height(80),
                              child: ElevatedButton(
                                onPressed: () async {
                                  //cancelReplanish();
                                  controller.cancelTimer();
                                },
                                child: Text("キャンセル",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(26),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor("#ffffff"),
                                    )),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      ColorsUtil.hexToColor("#A61C1C")),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0))),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Container(
                            height: ScreenAdapter.height(80),
                            child: ElevatedButton(
                              onPressed: () {
                                if (controller.getPutMoney.value > 0) {
                                  final printWidget = Container(
                                    width: 385,
                                    height: printLength,
                                    child: PrintView(
                                        isPrint: true,
                                        printInfo: controller.supplyInfo,
                                        printType: PrintType.SUPPLY),
                                  );
                                  controller.confirmTimer(printWidget);
                                }
                              },
                              child: Text("確認",
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(26),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#ffffff"),
                                  )),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    controller.getPutMoney.value > 0
                                        ? ColorsUtil.hexToColor("#409eff")
                                        : Colors.grey),
                                shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0))),
                              ),
                            ),
                          )),
                        ],
                      ),
                  ],
                )),
            if (!controller.isStartPutMoney.value)
              Positioned(
                right: ScreenAdapter.width(5),
                child: InkWell(
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
              )
          ])
        ]));
  }

  String formatSum(int sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }

  titleValues() {
    return ['万円', '五千円', '二千円', '千円', '五百円', '百円', '五十円', '十円', '五円', '一円']
        .reversed
        .toList();
  }

  titleAndValueMap() {
    if (controller.getPutMoneyCurrency.isEmpty ||
        !controller.getPutMoneyCurrency.contains(',')) {
      return titleValues().asMap().map((key, value) {
        return MapEntry(value, 0);
      });
    }

    debugPrint('getPutMoneyCurrency: ${controller.getPutMoneyCurrency.value}');

    final typeAndValueMap =
        controller.getPutMoneyCurrency.split(',').asMap().map((key, value) {
      final cash = value.split(':');
      return MapEntry(controller.getCashName(cash[0]), int.parse(cash[1]));
    });

    debugPrint('typeAndValueMap: $typeAndValueMap');

    controller.updateSupplyInfo(typeAndValueMap, 'supply');

    return typeAndValueMap;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: showRelanishAlert(),
    );
  }
}
