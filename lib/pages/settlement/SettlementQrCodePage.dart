import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';

class SettlementQrCodePage extends StatefulWidget {
  Map arguments;
  SettlementQrCodePage({Key key, this.arguments}) : super(key: key);

  _SettlementQrCodePageState createState() => _SettlementQrCodePageState();
}

class _SettlementQrCodePageState extends State<SettlementQrCodePage> {

  TextEditingController _scanQrCodeController;
  final FocusNode _scanQrCodeFocusNode = FocusNode();


  var _orderId;
  var _scanQrCode = "";
  String _machineCode = "";
  var _totalPrice = "";
  String _payStatus = "请扫码……";


  @override
  void initState() {
    super.initState();

    this._orderId = widget.arguments['orderId'];
    this._machineCode = widget.arguments['machineCode'];
    this._totalPrice = widget.arguments['totalPrice'].toString();
    //_getMachineInfo();
    _scanQrCodeController = TextEditingController();


    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
  }

  //获取机器信息
  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      setState(() {
        _machineCode = machineCode;
      });
    }
  }

  _doToPay(){
    if (_machineCode != "" && _scanQrCode !="") {

      var formData = {
        "auth_code": this._scanQrCode,
        "machineCode": _machineCode,
        "orderId": this._orderId,
        //"payType": this._paymentType
      };print(formData);
      request('webBootToPay', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());

        if (response['code'] == 200) {
          if(response['data'] == true){
            doPrintOrderMenu();
            setState(() {
              _payStatus = "支付成功，等待打印小票";
            });
          }else{
            _payStatus = "支付失败请重试";
          }
print(response);

          setState(() {
          });
        } else {

        }
      });

    }
  }

  //去打印小票
  doPrintOrderMenu(){
    print("打印小票来了");
    gotonewMyhome();
  }


  gotonewMyhome(){
    Navigator.pop(context);

    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false, //输入框抵住键盘 内容不随键盘滚动
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
                  image: AssetImage("assets/images/logo.png"),
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
                        child: Text("应付金额:${this._totalPrice}",style: TextStyle(
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
                            _doToPay();
                            print("onSubmitted 点击了键盘的确定按钮，输出的信息是：${value}");
                          },

                          /// 扫码密码
                        )),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.only(left:ScreenAdapter.width(48), top:ScreenAdapter.height(0), right:ScreenAdapter.width(48), bottom:ScreenAdapter.height(4)),

                    child: Center(
                        child: Text(_payStatus,style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(38.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.red
                        ))
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
