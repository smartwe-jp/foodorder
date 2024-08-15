import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

class ReplanishView extends GetView<SettingController> {
  final SettingController controller = Get.put(SettingController());
  ReplanishView({Key? key}) : super(key: key);

  showRelanishAlert(context) {
    return SimpleDialog(children: <Widget>[
      Stack(alignment: Alignment.topCenter, children: <Widget>[
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
                          child: Text("金种",
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


                        // ...line1Titles().map((element) {
                        //   return Container(
                        //     height: 80,
                        //     alignment: Alignment.center,
                        //     child: Text("$element",
                        //         style: TextStyle(
                        //           fontFamily: GFont.getFontFamily(),
                        //           fontSize: ScreenAdapter.fontSize(20),
                        //           fontWeight: FontWeight.w600,
                        //           color: ColorsUtil.hexToColor("#000000"),
                        //         )),
                        //   );
                        // }).toList()
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
                          child: Text("金种",
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
                      "${controller.getPutMoney.value.toString()} 円",
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
                        await controller.startPutMoney();
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
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
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
                              await controller.cancelReplanish();
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
                              controller.reportReplanishInfo(controller.moneyMap.value, context);
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
                                    borderRadius: BorderRadius.circular(5.0))),
                          ),
                        ),
                      )),
                    ],
                  ),
              ],
            )),
      ])
    ]);
  }


  titleValues() {
    return ['万円', '５千円', '２千円', '千円', '５百円', '百円', '50円', '10円', '５円', '１円'];
  }

  titleAndValueMap() {
    final values = controller.moneyList.value.isEmpty ? [0,0,0,0,0,0,0,0,0,0] : controller.moneyList.value;
    return titleValues().asMap().map((index, value) {
      return MapEntry(value, values[index] ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          child: showRelanishAlert(context),
        ));
  }
}
