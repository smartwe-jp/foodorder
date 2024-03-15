
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import 'NumberAdjustWidget.dart';
import 'NumberListView.dart';
import 'SegmentControl.dart';

class AdjustModalView extends StatefulWidget {
  AdjustModalView({Key? key,
    this.switchValue,
    required this.field,
    required this.value,
    this.selectNumber,
    required this.onOutsetNumberChanged,
    required this.onDepositNumberChanged,
    this.segmentData,
    this.depositCatVal,
    this.depositQty,
    required this.onAdjustNumberChanged,
    required this.cashInfo,
    this.depositValue}) : super(key: key);
  final String field;
  final String value;
  final int? depositValue;
  final bool? switchValue;
  final int? selectNumber;
  final List<String>? segmentData;
  final String? depositCatVal;
  final int? depositQty;
  final Map cashInfo;

  final Function(int) onOutsetNumberChanged;
  final Function(String,int,String,int) onDepositNumberChanged;
  final Function(String,int) onAdjustNumberChanged;

  @override
  _AdjustModalViewState createState() => _AdjustModalViewState();
}

class _AdjustModalViewState extends State<AdjustModalView> {

  bool _switchValue = false;
  String _value = "0";
  String _field = "";
  int _selectNumber = 0;
  List<String> _segmentData = [];
  String _depositCatVal = "";
  int _depositQty = 0;
  Map _cashInfo = {};
  int _depositValue = 0;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _switchValue = widget.switchValue ?? false;
    _value = widget.value;
    _cashInfo = widget.cashInfo;
    _depositValue = _getDepositCatVal(widget.field);
    _field = widget.field;
    _selectNumber = widget.selectNumber ?? 0;
    _segmentData = _getSegmentData(_field);
    _depositCatVal = widget.field;
    _depositQty = 0;

  }

  _getSegmentData(filed){
    //找到参数字段包括参数本身之后的所有值
    final defaultSegmentData = ["一円","五円","十円","五十円","百円","五百円","千円","二千円","五千円","一万円"];
    final index = defaultSegmentData.indexOf(filed);
    //找不到的情况下返回空数组
    if (index == -1) {
      return [];
    }
    return defaultSegmentData.sublist(index);
  }

  @override
  void didUpdateWidget(covariant AdjustModalView oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    // if (_switchValue) {
    //     final int mutable =  _depositValue~/_getDepositCatVal(_field);
    //     _selectNumber =  _depositValue*mutable;
    // }
  }



  _getDepositCatVal(value) {
    switch (value) {
      case "一円":
        return 1;
      case "五円":
        return 5;
      case "十円":
        return 10;
      case "五十円":
        return 50;
      case "百円":
        return 100;
      case "五百円":
        return 500;
      case "千円":
        return 1000;
      case "二千円":
        return 2000;
      case "五千円":
        return 5000;
      case "一万円":
        return 10000;
      default:
        return 0;
    }
  }

  _getMaxDepositQty(catKey) {
    for (var entry in _cashInfo.entries) {
      if (entry.key == catKey) {
        return entry.value["deposit"];
      }
    }
    return 0;
  }

  _getSelectNumberValue() {
    // if (_depositQty < 0) {
    //   _selectNumber = _depositQty;
    //   return _depositQty;
    // }
    if (_switchValue) {
      final int mutable =  _depositValue~/_getDepositCatVal(_field);
      _selectNumber =  _depositQty*mutable;
    }
    return _selectNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          children: [
            Container(
              padding: EdgeInsets.all(10),
              width: ScreenAdapter.width(900),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(20), bottom: ScreenAdapter.height(20)),
                    alignment: Alignment.centerLeft,
                    child: Text("最初枚数/残り枚数調整($_field)",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(22),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  ),

                  Divider(
                    thickness: 1,
                    color: Colors.grey[400],
                  ),

                  Container(
                      padding: EdgeInsets.only(
                          top: ScreenAdapter.height(20),
                          left: ScreenAdapter.width(20),
                          bottom: ScreenAdapter.height(20)),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text("$_field最初枚数調整：",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontFamily: GFont.getFontFamily(),
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[700],
                                  )),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(

                                    child: NumberAdjustWidget(initialNumber: int.tryParse(_value) ?? 0, minNumber: 0, onNumberChanged: (int number){
                                      setState(() {
                                        _value = number.toString();
                                      });
                                    }),
                                  ),
                                  SizedBox(height: 10),
                                  Text("*調整後の枚数を入力してください",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(16),
                                        fontFamily: GFont.getFontFamily(),
                                        fontWeight: FontWeight.w200,
                                        color: Colors.grey[700],
                                      )),

                                  Container(
                                    margin: EdgeInsets.only(
                                        top: ScreenAdapter.height(20)),
                                    decoration: BoxDecoration(
                                      color: ColorsUtil.hexToColor("#dca550"),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    height: ScreenAdapter.height(50),
                                    width: double.infinity,

                                    child: TextButton(
                                      child: Text("保存",
                                          style: TextStyle(
                                            fontSize: ScreenAdapter.fontSize(18),
                                            fontWeight: FontWeight.w400,
                                            color: ColorsUtil.hexToColor("#FFFFFF"),
                                          )),
                                      onPressed: () {
                                        widget.onOutsetNumberChanged(int.tryParse(_value) ?? 0);
                                        Get.back();
                                      },
                                    ),
                                  ),

                                ],
                              ),
                            )

                          ]

                      )
                  ),

                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(20),
                        left: ScreenAdapter.width(20),
                        bottom: ScreenAdapter.height(20)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("預り金から：",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(20),
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[700],
                              )),
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: IgnorePointer(
                                      ignoring:_depositQty < 0 ? true : false,
                                      child: CupertinoSwitch(
                                        value: _switchValue,
                                        onChanged: (value) {
                                          // controller.showCashDetail(_detail);

                                          setState(() {
                                            _switchValue = value;
                                          });

                                        },

                                        activeColor: _depositQty < 0 ? ColorsUtil.hexToColor("#f9edde") : ColorsUtil.hexToColor("#dca550"),
                                      ),
                              ),

                            )
                        )
                      ],
                    ),
                  ),


                  _switchValue ? Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(20),
                        left: ScreenAdapter.width(20),
                        bottom: ScreenAdapter.height(20)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("預り金からの金種：",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(20),
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[700],
                              )),
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: SegmentControl(
                                  values: _segmentData,
                                  onValueChanged: (value){
                                    setState(() {
                                      _depositCatVal = value;
                                      _depositValue = _getDepositCatVal(value);
                                      // if (_getMaxDepositQty(value) < 1) {
                                      //   _depositQty = 0;
                                      // } else {
                                      //   _depositQty = 1;
                                      // }
                                    });
                                  },
                                  initialValue: _field,
                                )
                            )
                        )
                      ],
                    ),
                  ):Container(),
                  _switchValue ? Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(20),
                        left: ScreenAdapter.width(20),
                        bottom: ScreenAdapter.height(20)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("預り金からの枚数：",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(20),
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[700],
                              )),
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: NumberAdjustWidget(
                                    initialNumber: _depositQty,
                                    maxNumber: _getMaxDepositQty(_depositCatVal),
                                    onNumberChanged: (int number){
                                  setState(() {
                                    _depositQty = number;
                                  });
                                })
                            )
                        )
                      ],
                    ),
                  ):Container(),
                  IgnorePointer(
                    ignoring: _switchValue,
                    child:Container(
                      color: _switchValue ? Colors.grey[200] : Colors.white,
                      padding: EdgeInsets.only(
                          top: ScreenAdapter.height(20),
                          left: ScreenAdapter.width(20),
                          bottom: ScreenAdapter.height(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text("$_field補充/削减枚数：",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(20),
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[700],
                                )),
                          ),
                          Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: NumberAdjustWidget(initialNumber: _getSelectNumberValue(), onNumberChanged: (int number){
                                        setState(() {
                                          _selectNumber = number;
                                        });
                                      })
                                  ),
                                  SizedBox(height: 10),
                                  Text("*減らす場合は負数を入力してください",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(16),
                                        fontWeight: FontWeight.w200,
                                        color: Colors.grey[700],
                                      )),
                                  SizedBox(height: 10),
                                  NumberListView(numberValues: [50,80,100,150,200,250,300],
                                      onValueChange: (value){
                                        setState(() {
                                          _selectNumber = value;
                                        });
                                      },
                                      measureUnit: "枚"),
                                  SizedBox(height: 10),
                                  Text("*上記のタグをクリックすると補充枚数自動的に入力されます",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(16),
                                        fontWeight: FontWeight.w200,
                                        color: Colors.grey[700],
                                      )),
                                ],
                              )


                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(20),
                        left: ScreenAdapter.width(20),
                        bottom: ScreenAdapter.height(20)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(

                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#dca550"),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            height: ScreenAdapter.height(50),
                            width: double.infinity,

                            child: TextButton(
                              child: Text("保存",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w400,
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )),
                              onPressed: () {
                                if(_switchValue){
                                  widget.onDepositNumberChanged(_field ,_selectNumber,_depositCatVal,_depositQty);
                                } else {
                                  widget.onAdjustNumberChanged(_field ,_selectNumber);
                                }

                                Get.back();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
      ),
    );
  }
}

