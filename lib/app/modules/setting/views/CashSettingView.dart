
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/modules/setting/views/AdjustModalView.dart';
import 'package:foodorder/app/modules/setting/views/NumberAdjustWidget.dart';
import 'package:foodorder/app/modules/setting/views/NumberListView.dart';
import 'package:foodorder/app/modules/setting/views/SegmentControl.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../systemSettingPage/views/SetPassword.dart';


class CashSettingView extends StatefulWidget {

  final Map? cashInfoList;
  final Function() recycleCash;
  final Function(String, int) adjustCash;
  final Function(String, int) setOutset;
  final Function(String, int, String, int) adjustCashFromDeposit;
  final Function() resetCash;
  final String? allDepositSum;
  final String? outSetSum;
  final String? remainingSum;
  final String  machineCode;
  CashSettingView({Key? key,
    required this.cashInfoList,
    required this.recycleCash,
    required this.adjustCash,
    required this.setOutset,
    this.allDepositSum,
    this.outSetSum,
    this.remainingSum,
    required this.adjustCashFromDeposit,
    required this.resetCash,
    required this.machineCode}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CashSettingViewState();
  }
}

class CashSettingViewState extends State<CashSettingView> {

  Map _cashInfoList = {};
  String _allDepositSum = "";
  String _outSetSum = "";
  String _remainingSum = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cashInfoList = widget.cashInfoList ?? {};
    _getAllDepositSum();
    _getOusetSum();
    _getRemainingSum();
  }

  @override
  void didUpdateWidget(covariant CashSettingView oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _cashInfoList = widget.cashInfoList ?? {};
    _getAllDepositSum();
    _getOusetSum();
    _getRemainingSum();
  }

  String formatSum(int sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }

  _getAllDepositSum() {
    int sum = 0;
    _cashInfoList.entries.forEach((element) {
      num? depositSum = element.value['depositSum'] as num?;
      sum += depositSum?.toInt() ?? 0;
    });
    _allDepositSum = formatSum(sum);
  }

  _getOusetSum() {
    int sum = 0;
    _cashInfoList.entries.forEach((element) {
      sum += (int.tryParse(element.value['outset']) ?? 0)*(_getMeasureUnit(element.key));

    });

    _outSetSum = formatSum(sum);
  }

  _getRemainingSum() {
    int sum = 0;
    _cashInfoList.entries.forEach((element) {
      sum += (int.tryParse(element.value['remaining']) ?? 0)*(_getMeasureUnit(element.key));
    });

    _remainingSum = formatSum(sum);
  }

  _showAdjustModal(map) {
    if(map['outset'] == "" && map['remaining'] == "" && map['limit'] == "") {
      return false;
    } else {
      return true;
    }
  }


  int _getMeasureUnit(String name) {
    switch (name) {
      case "一万円":
        return 10000;
      case "五千円":
        return 5000;
      case "二千円":
        return 2000;
      case "千円":
        return 1000;
      case "五百円":
        return 500;
      case "百円":
        return 100;
      case "五十円":
        return 50;
      case "十円":
        return 10;
      case "五円":
        return 5;
      case "一円":
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: ScreenAdapter.height(20)),
            //padding: EdgeInsets.only(bottom: ScreenAdapter.width(20)),
            child: Text("お預り金/釣り状態(NO.${widget.machineCode})",
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
                1: FlexColumnWidth(300),
                2: FlexColumnWidth(500),
              },
            children: [
              TableRow(
                children: [
                  Container(
                    height: 60,
                    //color: Colors.green,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 80,
                    child: Text("預り金",
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
                    child: Text("お釣り（枚）",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(20),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  ),

                ]
              ),
            ]
          ),
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade400,
              width: 1.0,
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(100),
              1: FlexColumnWidth(100),
              2: FlexColumnWidth(200),
              3: FlexColumnWidth(100),
              4: FlexColumnWidth(100),
              5: FlexColumnWidth(100),
              6: FlexColumnWidth(200),
            },
            children: [
              TableRow(
                children: [
                  Container(
                    height: 80,

                  ),
                  Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Text("枚",
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
                    child: Text("最初",
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
                    child: Text("最小",
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
                    child: Text("残り",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(20),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  ),
                  Container(
                    height: 80,
                  ),
                ]
              ),

            ],
          ),
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade400,
              width: 1.0,
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(100),
              1: FlexColumnWidth(100),
              2: FlexColumnWidth(200),
              3: FlexColumnWidth(100),
              4: FlexColumnWidth(100),
              5: FlexColumnWidth(100),
              6: FlexColumnWidth(200),
            },
            children:_cashInfoList.entries.map((element) {
              return TableRow(
                  children: [
                    Container(
                      height: 80,
                      alignment: Alignment.center,
                      child: Text("${element.key}",
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
                      child: Text("${element.value['deposit']}",
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
                      child: Text("${formatSum(element.value['depositSum'])}",
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
                      child: Text("${element.value['outset']}",
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
                      child: Text("${element.value['limit']}",
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
                      child: Text("${element.value['remaining']}",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(20),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#000000"),
                          )),
                    ),

                    Container(
                      height: 80,
                      child:
                    _showAdjustModal(element.value) ?
                      InkWell(
                        highlightColor: Colors.transparent, // 透明色
                        splashColor: Colors.transparent, // 透明色
                        onTap: (){
                          // controller.showCashDetail(_detail);
                          _adjustModal(element.key, element.value['outset']);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: ScreenAdapter.height(10),bottom: ScreenAdapter.height(10),left: ScreenAdapter.width(40),right: ScreenAdapter.width(40)),
                          alignment: Alignment.center,
                          height: ScreenAdapter.height(40),
                          //边框设置
                          decoration: new BoxDecoration(
                            //背景
                            color: ColorsUtil.hexToColor("#05ba6d"),
                            //设置四周圆角 角度
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            //设置四周边框
                            //border: new Border.all(width: 1, color: Colors.red),
                          ),
                          child: Text(
                              "補充/削减",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(22),
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )
                          ),
                        ),
                      ):Container(
                        height: 80,
                        color: Colors.grey[400],
                    ),
                    )
                  ]
              );
            }).toList(),
          ),
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade400,
              width: 1.0,
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(100),
              1: FlexColumnWidth(100),
              2: FlexColumnWidth(200),
              3: FlexColumnWidth(100),
              4: FlexColumnWidth(100),
              5: FlexColumnWidth(100),
              6: FlexColumnWidth(200),
            },
            children:[
            TableRow(
                  children: [
                    Container(
                      height: 80,
                    ),

                    Container(
                      height: 80,
                      color: Colors.grey[400],
                    ),

                    Container(
                      height: 80,
                      alignment: Alignment.center,
                      color: Colors.grey[300],
                      child: Text("$_allDepositSum",
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
                      color: Colors.grey[300],
                      child: Text("$_outSetSum",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(20),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#000000"),
                          )),
                    ),

                    Container(
                      height: 80,
                      color: Colors.grey[400],
                    ),

                    Container(
                      height: 80,
                      alignment: Alignment.center,
                      color: Colors.grey[300],
                      child: Text("$_remainingSum",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(20),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#000000"),
                          )),
                    ),

                    Container(
                      height: 80,
                      color: Colors.grey[400],
                    )
                  ]
              ),
        ]

          ),
          Table(
              border: TableBorder.all(
                color: Colors.grey.shade400,
                width: 1.0,
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(100),
                1: FlexColumnWidth(300),
                2: FlexColumnWidth(500),
              },
              children: [
                TableRow(
                    children: [
                      Container(
                        height: 80,
                        //color: Colors.green,
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 80,
                        child: InkWell(
                          highlightColor: Colors.transparent, // 透明色
                          splashColor: Colors.transparent, // 透明色
                          onTap: (){
                            // controller.showCashDetail(_detail);
                            log("預り金回収");
                            _recycleAlert();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(60),

                            //边框设置
                            decoration: new BoxDecoration(
                              //背景
                              color: ColorsUtil.hexToColor("#dca550"),
                              //设置四周圆角 角度
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              //设置四周边框
                              //border: new Border.all(width: 1, color: Colors.red),
                            ),
                            child: Text(
                                "預り金回収",
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(22),
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                      ),

                    ]
                ),
              ]
          ),
        ],
      ),
    );
  }

  _recycleAlert() async {
    Get.dialog(
      SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          children: [
            Container(
              padding: EdgeInsets.all(ScreenAdapter.width(20)),
              width: ScreenAdapter.width(500),
              height: ScreenAdapter.height(200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                    alignment: Alignment.topLeft,
                    child: Text("ご注意",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(22),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  ),

                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                    alignment: Alignment.centerLeft,
                    child: Text("預り金回収してもよろしいですか？",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(22),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      Spacer(),
                      Container(
                        height: 50,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorsUtil.hexToColor("#888888")),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child:
                          TextButton(
                            child: Text("キャンセル",
                            style: TextStyle(
                              fontFamily:'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(18),
                            fontWeight: FontWeight.w400,
                            color: ColorsUtil.hexToColor("#000000"),
                            )),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        height: 50,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#dca550"),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child:
                        TextButton(
                          child: Text("確認",
                                  style: TextStyle(
                                    fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(18),
                                  fontWeight: FontWeight.w400,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )),
                          onPressed: () {
                            widget.resetCash();
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }





  _adjustModal(field,value) async {
    Get.dialog(
        AdjustModalView(
          field: field, value: value, onOutsetNumberChanged: (outset) {
            widget.setOutset(field, outset);
        }, onDepositNumberChanged: (measure, number, deposit, qty) {
            widget.adjustCashFromDeposit(measure, number, deposit, qty);
        }, onAdjustNumberChanged: (type , number ) {
            widget.adjustCash(field, number);
        }, cashInfo: _cashInfoList,)
    );
  }





}