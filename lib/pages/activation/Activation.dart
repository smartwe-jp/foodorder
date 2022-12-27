import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/Storage.dart';

import 'package:foodorder/services/HttpService.dart';

class ActivationPage extends StatefulWidget {
  ActivationPage({Key key}) : super(key: key);

  _ActivationPageState createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  //final sqlHelper = SqfliteHelper();
  TextEditingController _activationCodeController = new TextEditingController();
  FocusNode _activationCodeFocusNode = FocusNode();

  var _activation_code; //激活码
  var _checkedShop = null;

  var _showWechat = true;
  var _showAlipay = true;
  var _showPayPay = true;

  var _isCashState = true;

  @override
  void initState() {
    super.initState();


    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  void _goMain() async {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/transitPage');
    });
  }

  //把机器码保存到本地
  sendActivationCode() async {
    if (this._activation_code == null || this._activation_code.length != 18) {
      showToast('请输入正确激活码');
    }else if(this._checkedShop == null){
      showToast('请选择该机器所在商家');
    } else {
      //保存机器信息
      Storage.setString('machineInfo', _activation_code);
      Storage.setString('shopInfo', _checkedShop);
      Storage.setBool('homeOpen', true);

      _goMain();

    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: ScreenAdapter.width(550.0),
              padding:
                  EdgeInsets.only(left: 10.0, right: 10, top: 0, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "请选择所在店铺",
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(32.0),
                        color: ColorsUtil.hexToColor("#0000"),
                        fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        _checkedShop = "kanran";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(top: 3),
                      height: ScreenAdapter.height(95),
                      decoration: (_checkedShop == "kanran")
                          ? BoxDecoration(
                          //color: Colors.transparent, // 背景色
                          border: new Border.all(color: Color(0xFFFF0000), width: 2),// border
                          borderRadius: BorderRadius.circular((5)), // 圆角
                      )
                          : BoxDecoration(
                          color: Colors.transparent

                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            GImage.getImageString("kanran", "logo"),
                            width: ScreenAdapter.width(80),
                            fit: BoxFit.fitWidth,
                          ),
                          Text(
                            "甘蘭",
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(30.0),
                                color: ColorsUtil.hexToColor("#000000"),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        _checkedShop = "rijindoujin";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(top: 3),
                      height: ScreenAdapter.height(95),
                      decoration: (_checkedShop == "rijindoujin")
                          ? BoxDecoration(
                        //color: Colors.transparent, // 背景色
                        border: new Border.all(color: Color(0xFFFF0000), width: 2),// border
                        borderRadius: BorderRadius.circular((5)), // 圆角
                      )
                          : BoxDecoration(
                          color: Colors.transparent

                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            GImage.getImageString("rijindoujin", "logo"),
                            width: ScreenAdapter.width(80),
                            fit: BoxFit.fitWidth,
                          ),
                          Text(
                            "日進斗金フライドチキン",
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(30.0),
                                color: ColorsUtil.hexToColor("#000000"),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        _checkedShop = "ichixianjia";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(top: 3),
                      height: ScreenAdapter.height(95),
                      decoration: (_checkedShop == "ichixianjia")
                          ? BoxDecoration(
                        //color: Colors.transparent, // 背景色
                        border: new Border.all(color: Color(0xFFFF0000), width: 2),// border
                        borderRadius: BorderRadius.circular((5)), // 圆角
                      )
                          : BoxDecoration(
                          color: Colors.transparent

                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            GImage.getImageString("ichixianjia", "logo"),
                            width: ScreenAdapter.width(80),
                            fit: BoxFit.fitWidth,
                          ),
                          Text(
                            "壱賢家",
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(30.0),
                                color: ColorsUtil.hexToColor("#000000"),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        _checkedShop = "sanfeng";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: ScreenAdapter.height(95),
                      decoration: (_checkedShop == "sanfeng")
                          ? BoxDecoration(
                        //color: Colors.transparent, // 背景色
                        border: new Border.all(color: Color(0xFFFF0000), width: 2),// border
                        borderRadius: BorderRadius.circular((5)), // 圆角
                      )
                          : BoxDecoration(
                          color: Colors.transparent

                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            GImage.getImageString("sanfeng", "logo"),
                            width: ScreenAdapter.width(80),
                            fit: BoxFit.fitWidth,
                            color: Colors.black,
                          ),
                          Text(
                            "三豊麺",
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(30.0),
                                color: ColorsUtil.hexToColor("#000000"),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenAdapter.height(80),),
            Container(
              width: ScreenAdapter.width(450.0),
              padding:
                  EdgeInsets.only(left: 10.0, right: 10, top: 0, bottom: 10),
              child: TextField(
                //keyboardType: TextInputType.number,
                autofocus: true,
                showCursor: true,
                // 显示光标
                //readOnly: true,
                controller: _activationCodeController,
                focusNode: _activationCodeFocusNode,
                decoration: InputDecoration(
                  hintText: "请输入激活码",
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                obscureText: false,
                onChanged: (value) {
                  //print(value);
                },
                onSubmitted: (value) {
                  setState(() {
                    this._activation_code = value;
                  });

                  //sendActivationCode();
                  //print("onSubmitted 点击了键盘的确定按钮，输出的信息是：${value}");
                },

                /// 扫码密码
              ),
            ),
            Divider(
              thickness: 1.0,
              color: Colors.black12,
            ),
            TextButton(
              child: Text(
                "确定激活",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: ScreenAdapter.fontSize(32.0)),
              ),
              onPressed: () async {
                sendActivationCode();
              },
            ),
          ],
        ),
      ),
    );
  }
}
