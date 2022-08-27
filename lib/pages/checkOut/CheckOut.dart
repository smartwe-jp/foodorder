import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:paycube/paycube.dart';
import 'package:get/get.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/services/Storage.dart';

import 'package:foodorder/config/string.dart';
import 'package:foodorder/services/HttpService.dart';

import 'package:foodorder/config/color.dart';
import 'package:foodorder/pages/checkOut/Appointment.dart';

class CheckOutPage extends StatefulWidget {
  CheckOutPage({Key key}) : super(key: key);

  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {

  TextEditingController _scanQrCodeController = new TextEditingController();
  FocusNode _scanQrCodeFocusNode = FocusNode();

  Timer checkTimer;
  Timer stopChecktimer;
  Timer closetimer;

  var _stopStatus;
  var _closeStatus;
  String _machineCode = "";
  String _tableCode = "";
  var _shopInfo = "kanran";
  var _checkLanguage = "JP";
  var _scanQrCode = "";

  //预约页面默认值
  var _tableTypeList = [
    {"optionVal":"A","optionTable":"任意"},
    {"optionVal":"C","optionTable":"カウンタ"},
    {"optionVal":"T","optionTable":"テーブル"},
    {"optionVal":"P","optionTable":"個室"},
  ];
  var _selectTableType = "A";
  var _selectManyPeople = 1;

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();

    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    //先获取店铺信息已获取路径用
    _getShopInfo();


    //监听增加打开现金机的广播
    eventBus.on<PayCubeEvent>().listen((event) {
      CheckPayCube();
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    checkTimer?.cancel();
    stopChecktimer?.cancel();
    closetimer?.cancel();
    eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();
  }

  //获取机器信息
  _getShopInfo() async {
    var shopInfo = await HomeServices.getShopInfo();
    if (shopInfo != "") {
      setState(() {
        _shopInfo = shopInfo;
      });
    }else{
      Storage.setString('shopInfo', "kanran");
    }

    _getMachineInfo();
  }

  //打开现金机
  OpenPayCube() async {
    String checkStatus = await Paycube.CheckPayCubeStatus;

    //如果检测现金机打开错误，则重新打开一下
    if(checkStatus == "openError"){
      String openStatus = await Paycube.openPayCube;
      //print("机器未打开lib未null，重新打开并连接了");
    }else{
      await Paycube.setReceiveEvent;
      //print("机器已打开，并setreceive");
    }

    //await Paycube.endTrade;
  }

  //检测现金机状态
  CheckPayCube() async {
    String machineStatus = await Paycube.getPayCubeMachineStatus;

    checkTimer?.cancel();
    checkTimer = Timer.periodic(Duration(milliseconds: 600), (Timer checktimer) async {
      String machineStatus = await Paycube.getPayCubeMachineStatus;
      // 循环一定要记得设置取消条件，手动取消
      //待機中(入金不可)正常
      if (machineStatus == "30--10--10--10") {
        checktimer.cancel();
      }else{
        stopPaycube();
        checktimer.cancel();
      }
    });

  }

  stopPaycube() async {
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stopChecktimer?.cancel();
    stopChecktimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopcheck) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      //await Paycube.setReceiveEvent;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        closePaycube();
        stopcheck.cancel();

      }else if(_stopStatus == "Error-A0--02"){
        //处理中
        await Paycube.endPayCube;
      }else{
        await Paycube.endPayCube;
      }
    });
  }

  closePaycube() async {
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    await Paycube.setReceiveEvent;
    closetimer?.cancel();
    closetimer = Timer.periodic(Duration(milliseconds: 500), (Timer closecheck) async {
      _closeStatus =  await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_closeStatus == "EndSuccess" || _closeStatus == "Error-A0--02") {
        closecheck.cancel();
      }else{

        await Paycube.endTrade;
      }
    });
  }

//获取机器信息
  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      setState(() {
        _machineCode = machineCode;
      });

    }
    //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
  }

  //扫码，弹出dialog
  _showScanCodeDialog(){
    //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
    //支付状态
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: ScreenAdapter.width(950),
            child: SimpleDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                /*title: Align(
                    alignment: Alignment.center,
                    child:  Text(GString.getToString(this._checkLanguage, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                ),*/
                children: <Widget>[
                  Container(
                    height: 0,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              showCursor: false, // 显示光标
                              //readOnly: true,
                              controller: _scanQrCodeController,
                              focusNode: _scanQrCodeFocusNode,
                              decoration: InputDecoration(
                                hintText: "请扫码",
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: TextStyle(fontSize: ScreenAdapter.fontSize(1.0)),
                              obscureText: false,
                              onChanged: (value) {
                                //print(value);

                              },
                              onSubmitted: (value){
                                setState(() {
                                  this._tableCode = value;
                                });
                                _doNextPay();

                                Navigator.pop(context);
                              },

                              /// 扫码密码
                            )
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: ScreenAdapter.width(650),
                    height: ScreenAdapter.height(580),
                    padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(GString.getToString(this._checkLanguage, "tag_checkOut"),
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
                        //SizedBox(height: ScreenAdapter.height(10),),
                        Container(
                          //width: ScreenAdapter.width(280),
                            height: ScreenAdapter.height(480),
                            child: Image.asset(GImage.getImageString(_shopInfo, "jingsuantag"),fit: BoxFit.fitHeight,height: ScreenAdapter.height(480),)),
                      ],
                    ),
                  )

                  /*Container(
                    width: ScreenAdapter.width(650),

                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text(GString.getToString(this._checkLanguage, "tag_checkOut"),
                              style: TextStyle(fontSize: ScreenAdapter.fontSize(28))),
                          alignment: Alignment(0, 0),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1.0,
                          color: Colors.black12,
                        ),

                      ],
                    ),
                  ),*/
                ]
            ),
          );
        });
  }

  _doNextPay(){
    if(_tableCode !=""){
      _showOrderEasyLoading();

      //自定义声音
      //playQRScannerSound();

      var formData = {
        "language": this._checkLanguage,
        "machineCode": _tableCode
      };
      request('shopOrderTableNum', method: 'GET', parameters: formData).then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();

        if (response['code'] == 200 && response["data"] !=null && response["data"].isNotEmpty) {
          Navigator.pushNamed(context, '/settlement',
              arguments: {
                "checkLanguage": this._checkLanguage,
                "shopInfo":_shopInfo,
                "machineCode": this._tableCode,
                //"showWechat":response["data"]["linePayChannelMap"]["Wechat"],//_showWechat,
                //"showAlipay":response["data"]["linePayChannelMap"]["Alipay"],//_showAlipay,
                //"showPayPay":response["data"]["linePayChannelMap"]["PayPay"],//_showPayPay,
                "orderId" : response["data"]["orderId"],
                "machineMode":"2",
                //"totalPrice" : orderTotlaPrice.toString(),
              });
          //Navigator.pop(context);

        }else{
          setState(() {
            _scanQrCodeController.text = "";
            _tableCode = "";
           // FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
          });

          _showDialogError(response['msg']);
          //showToast(response['msg']);
          //sleep(Duration(milliseconds: 2000));
          //Navigator.pop(context);
        }
      });
    }
  }

  _showOrderEasyLoading(){
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString(_shopInfo, "printticketloading"),fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

  }

  _showDialogError(msg){
    //查询订单弹出提示
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Container(
              width: ScreenAdapter.width(950),
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Align(
                      alignment: Alignment.center,
                      child:  Text(GString.getToString(this._checkLanguage, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                  ),
                  children: <Widget>[
                    Container(
                      width: ScreenAdapter.width(650),
                      padding: EdgeInsets.only(left: ScreenAdapter.width(30),right: ScreenAdapter.width(30)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                //width: ScreenAdapter.width(400),
                                //margin: EdgeInsets.only(top: 60),
                                height: ScreenAdapter.height(75),
                                child: Image.asset(GImage.getImageString(_shopInfo, "error_public"),fit: BoxFit.fitHeight),
                              ),
                              Expanded(
                                  child: Container(
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(25),right: ScreenAdapter.width(25)),
                                      child: Text(msg,style: TextStyle(fontSize: ScreenAdapter.fontSize(28)))
                                  )
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          /*Divider(
                            thickness: 1.0,
                            color: Colors.black12,
                          ),*/
                          Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(85),
                            margin: EdgeInsets.only(top: ScreenAdapter.height(35)),
                            decoration: BoxDecoration(

                              color: ColorsUtil.hexToColor("#A61C1C"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            child: TextButton(
                              child: Text(
                                "${GString.getToString(this._checkLanguage,"settlement_change_method")}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenAdapter.fontSize(32.0)),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          /*Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 70.0),
                              child: TextButton(
                                child: Text(
                                  GString.getToString(this._checkLanguage, "settlement_change_method"),
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  //Navigator.pop(context);
                                },
                              ),
                            ),
                          ),*/
                        ],
                      ),
                    ),
                  ]
              ),
            );
          });
  }

  //预约弹出框
  _showMakeAnAppointmentDialog() async {
    await showDialog(
        context: context,
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        builder: (BuildContext context) {
          return AppointmentPage();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: Container(
            //padding: EdgeInsets.only(bottom: ScreenAdapter.height(30)),
            width: ScreenAdapter.getScreenWidth(),
            height: ScreenAdapter.getScreenHeight(),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(GImage.getImageString(_shopInfo, "home")),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: ScreenAdapter.width(0),
                  top: ScreenAdapter.height(20),
                  child: InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/settingPage', arguments: {"machineCode": this._machineCode,"shopInfo":_shopInfo});
                    },
                    child: Container(
                      height: ScreenAdapter.height(150),
                      width: ScreenAdapter.width(200),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(top:ScreenAdapter.height(20),left: ScreenAdapter.width(20),right: ScreenAdapter.width(20),bottom: ScreenAdapter.height(20)),
                      child: Center(
                        //加上Center让文字居中
                        child: Text(
                          "",
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(48.0),
                              color: ColorsUtil.hexToColor("#F9F9F9"),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top:ScreenAdapter.height(1250),bottom: ScreenAdapter.height(50)),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _checkLanguage = "JP";
                                });
                                _showScanCodeDialog();

                              },
                              child: Container(
                                width: ScreenAdapter.width(217),
                                height: ScreenAdapter.height(90),
                                margin: EdgeInsets.only(left: ScreenAdapter.width(20),right: ScreenAdapter.width(20),),
                                decoration: BoxDecoration(
                                  //color: Color(0x11111111),
                                  image: DecorationImage(
                                    //alignment: Alignment.topCenter,
                                      image: AssetImage(GImage.getImageString(_shopInfo, "home_button")),
                                      fit: BoxFit.fill),
                                ),
                                child: Center(
                                  //加上Center让文字居中
                                  child: Text(
                                    '精算',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(36.0),
                                        color: ColorsUtil.hexToColor("#F9F9F9"),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width:ScreenAdapter.width(35)),
                            InkWell(
                              onTap: () {

                                setState(() {
                                  _checkLanguage = "CH";
                                });
                                _showScanCodeDialog();
                              },
                              child: Container(
                                width: ScreenAdapter.width(217),
                                height: ScreenAdapter.height(90),
                                margin: EdgeInsets.only(left: ScreenAdapter.width(20),right: ScreenAdapter.width(20),),
                                decoration: BoxDecoration(
                                  //color: Color(0x11111111),
                                  image: DecorationImage(
                                    //alignment: Alignment.topCenter,
                                      image: AssetImage(GImage.getImageString(_shopInfo, "home_button")),
                                      fit: BoxFit.fill),
                                ),
                                child: Center(
                                  //加上Center让文字居中
                                  child: Text(
                                    '买单',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(36.0),
                                        color: ColorsUtil.hexToColor("#F9F9F9"),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width:ScreenAdapter.width(35)),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _checkLanguage = "EN";
                                });
                                _showScanCodeDialog();

                              },
                              child: Container(
                                width: ScreenAdapter.width(217),
                                height: ScreenAdapter.height(90),
                                margin: EdgeInsets.only(left: ScreenAdapter.width(20),right: ScreenAdapter.width(20),),
                                decoration: BoxDecoration(
                                  //color: Color(0x11111111),
                                  image: DecorationImage(
                                    //alignment: Alignment.topCenter,
                                      image: AssetImage(GImage.getImageString(_shopInfo, "home_button")),
                                      fit: BoxFit.fill),
                                ),
                                child: Center(
                                  //加上Center让文字居中
                                  child: Text(
                                    'Checkout',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(36.0),
                                        color: ColorsUtil.hexToColor("#F9F9F9"),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height:ScreenAdapter.height(150)),
                      InkWell(
                        onTap: () {
                        //显示预约弹出框
                        _showOrderEasyLoading();
                        _showMakeAnAppointmentDialog();

                        },
                        child: Container(
                          width: ScreenAdapter.width(360),
                          height: ScreenAdapter.height(100),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(

                            color: ColorsUtil.hexToColor("#4876FF"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((16.0)),
                          ),
                          child: Text("予約 / Booking",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(36),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(
                                    Gcolor.settlementBtnColor),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
    );
  }
}
