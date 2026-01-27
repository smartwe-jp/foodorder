import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodorder/app/common/StringExtension.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/modules/setting/controllers/exchange_controller_extension.dart';
import 'package:foodorder/app/modules/setting/views/RecycleButton.dart';
import 'package:foodorder/app/modules/setting/views/setting_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/common/NumberFormat.dart';

extension CycleCashSettingView on SettingView {


  Color _getCashColor(String type, int count) {
    bool isMax = type.cashReachMax(count);
    if (isMax) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  cycleCashSetting() {
    //final cashListInfo = controller.cashInfoList.value;

    return Container(
        child: Column(children: [
      Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: ScreenAdapter.height(20)),
        //padding: EdgeInsets.only(bottom: ScreenAdapter.width(20)),
        child: Text("お預り金/釣り状態(NO.${controller.machineCode})",
            style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: ScreenAdapter.fontSize(22),
              fontWeight: FontWeight.w600,
              color: ColorsUtil.hexToColor("#000000"),
            )),
      ),
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
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(20),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#000000"),
                    )),
              ),
              ...controller.cashInfoList.entries.map((element) {
                return Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Text("${element.key}",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(20),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      )),
                );
              }).toList()
            ]),
            TableRow(children: [
              Container(
                height: 80,
                alignment: Alignment.center,
                child: Text("枚数",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(20),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#000000"),
                    )),
              ),
              ...controller.cashInfoList.entries.map((element) {
                return Container(
                  padding: EdgeInsets.only(
                      left: ScreenAdapter.width(15),
                      right: ScreenAdapter.width(15),
                      top: ScreenAdapter.height(10),
                      bottom: ScreenAdapter.height(10)),
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: Text("${element.value}",
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: _getCashColor(element.key, element.value),
                            )),
                      ),
                      Container(
                        height: 30,
                        alignment: Alignment.centerRight,
                        child: Text(
                            "/${controller.getCashCountMaxVal(element.key)}",
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                    ],
                  ),
                );
              }).toList()
            ]),
            TableRow(children: [
              Container(
                height: 80,
                alignment: Alignment.center,
                child: Text("金額",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(20),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#000000"),
                    )),
              ),
              ...controller.cashInfo.entries.map((element) {
                return Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Text("${(int.parse(element.key) * element.value).toInt().formatSum()}",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
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
                child: Text("合計",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(20),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#000000"),
                    )),
              ),
              Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Text("${controller.getTotalCashCount().formatSum()}",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(20),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      )),
                )
              
            ]),
          ]
      ),

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
                child: Text("操作",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(20),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#000000"),
                    )),
              ),
              (controller.isAllowRejishime || Platform.isWindows)
                  ? RecycleButton(
                      title: "レジ締め",
                      onPressed: () {
                        controller.showRejishimeiView();
                      },
                    )
                  : RecycleButton(
                      title: "預り金回収",
                      onPressed: () {
                        controller.showRecycleAlert();
                      },
                    ),
              RecycleButton(
                title: "全回収",
                onPressed: () {
                  controller.showRecycleAlert();
                },
              ),
              RecycleButton(
                title: "補充",
                onPressed: () {
                  controller.showReplenishAlert();
                },
              ),
              RecycleButton(
                title: "両替",
                onPressed: () async {
                  controller.showExchangeAlert();
                },
              ),
              // RecycleButton(
              //   title: "出金",
              //   onPressed: () async {
              //     controller.showExportCashAlert();
              //   },
              // )
            ])
          ])
    ]));
  }
}
