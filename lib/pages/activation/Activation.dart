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

import 'package:foodorder/services/GetxStorage.dart';

class ActivationPage extends StatefulWidget {
  ActivationPage({Key key}) : super(key: key);

  _ActivationPageState createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  //final sqlHelper = SqfliteHelper();
  TextEditingController _activationCodeController = new TextEditingController();
  FocusNode _activationCodeFocusNode = FocusNode();

  var _activation_code; //激活码


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
    }else {
      //保存机器信息
      Storage.setString('machineInfo', _activation_code);
      Storage.setBool('homeOpen', true);

      GetxStorage.setData('machineInfo', _activation_code);
      GetxStorage.setData('homeOpen', true);

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
                    this._activation_code = value.toUpperCase();
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
