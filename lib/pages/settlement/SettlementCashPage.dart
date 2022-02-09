import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/services/ScreenAdapter.dart';

class SettlementCashPage extends StatefulWidget {
  SettlementCashPage({Key key}) : super(key: key);

  _SettlementCashPageState createState() => _SettlementCashPageState();
}

class _SettlementCashPageState extends State<SettlementCashPage> {

  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomPadding: false, //输入框抵住键盘 内容不随键盘滚动
      body: SimpleDialog(
        contentPadding: EdgeInsets.fromLTRB(ScreenAdapter.width(10), ScreenAdapter.height(5), ScreenAdapter.width(10), ScreenAdapter.height(5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        children: <Widget>[
          Container(
            width: ScreenAdapter.width(540),
            height: ScreenAdapter.height(380),
            padding: EdgeInsets.only(left:ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/22.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top:ScreenAdapter.height(5), right: ScreenAdapter.width(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            child: Image.asset('assets/images/dialog_close.png', width: ScreenAdapter.width(40))
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(left:ScreenAdapter.width(48), top:ScreenAdapter.height(0), right:ScreenAdapter.width(48), bottom:ScreenAdapter.height(4)),

                  child: Center(
                      child: Text("应付金额3000",style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(38.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#000000")
                  ))
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}
