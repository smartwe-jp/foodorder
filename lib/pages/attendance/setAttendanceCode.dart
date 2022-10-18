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

import 'package:foodorder/services/EventBus.dart';

import 'package:foodorder/services/HttpService.dart';

class setAttendanceCodePage extends StatefulWidget {
  Map arguments;
  setAttendanceCodePage({Key key, this.arguments}) : super(key: key);

  _setAttendanceCodePageState createState() => _setAttendanceCodePageState();
}

class _setAttendanceCodePageState extends State<setAttendanceCodePage> {
  //final sqlHelper = SqfliteHelper();
  TextEditingController _attendanceCodeController = new TextEditingController();
  FocusNode _attendanceCodeFocusNode = FocusNode();

  var _attendance_code; //激活码
  var _checkedShop = null;
  String _machineCode = "";

  @override
  void initState() {
    super.initState();
    this._machineCode = widget.arguments['machineCode'];

    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
  }

  @override
  void dispose() {
    // TODO: implement dispose

    eventBus.fire(new setAttendanceCodeEvent('支付成功...'));
    super.dispose();
  }

  void _goMain() async {
    Future.delayed(Duration.zero, () {
      Navigator.pop(context);

      Navigator.of(context).pushNamed('/attendance',arguments: {
        "machineCode": this._machineCode,
        "attendanceCode": this._attendance_code
      });


    });
  }

  //把机器码保存到本地
  sendActivationCode() async {
    if (this._attendance_code == null || this._attendance_code.length != 18) {
      showToast('请输入正确激活码');
    }else {
      var formData = {
        "machineCode": _machineCode,
        "attendanceCode":_attendance_code
      };
      request('recognitionRegister', method: 'GET', parameters: formData).then((val) {
        var response = json.decode(val.toString());

        if (response['code'] == 200 && response['data'] == true) {
          //保存机器信息
          Storage.setString('machineAttendanceCode', _attendance_code);

          _goMain();
        } else {
          showToast(response["msg"]);
        }
      });


    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("",textAlign:TextAlign.center,style: TextStyle(color:Colors.white,fontSize: ScreenAdapter.fontSize(34.0))),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,size: 22,),
          onPressed: (){
            Navigator.pop(context); // 关闭当前页面
          },
        ),
      ),
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
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
                controller: _attendanceCodeController,
                focusNode: _attendanceCodeFocusNode,
                decoration: InputDecoration(
                  hintText: "请输入考勤激活码",
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
                    this._attendance_code = value;
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
