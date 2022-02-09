import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/services/ScreenAdapter.dart';

class SettlementQrCodePage extends StatefulWidget {
  Map arguments;
  SettlementQrCodePage({Key key, this.arguments}) : super(key: key);

  _SettlementQrCodePageState createState() => _SettlementQrCodePageState();
}

class _SettlementQrCodePageState extends State<SettlementQrCodePage> {

  TextEditingController _scanQrCodeController;
  final FocusNode _scanQrCodeFocusNode = FocusNode();

  var _paymentMethod;
  var _scanQrCode = "";

  @override
  void initState() {
    super.initState();

    this._paymentMethod = widget.arguments['paymentMethod'];

    _scanQrCodeController = TextEditingController();


    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomPadding: false, //输入框抵住键盘 内容不随键盘滚动
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: SimpleDialog(
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

                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(child: TextField(
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          controller: _scanQrCodeController,
                          focusNode: _scanQrCodeFocusNode,
                          decoration: InputDecoration(
                            hintText: "请扫码",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                          obscureText: false,
                          onChanged: (value) {
                            print(this._scanQrCode);
                          },
                          onSubmitted: (value){
                            setState(() {
                              this._scanQrCode = value;
                            });
                            print("onSubmitted 点击了键盘的确定按钮，输出的信息是：${value}");
                          },

                          /// 扫码密码
                        )),
                      ],
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
