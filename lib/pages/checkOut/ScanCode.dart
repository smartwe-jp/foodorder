import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
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

import 'package:foodorder/services/GetxStorage.dart';
import 'package:foodorder/services/showImage.dart';
import '../menu/SelectPayment.dart';
import 'PaymentMethod.dart';

class ScanCodePage extends StatefulWidget {
  Map arguments;
  ScanCodePage({Key key, this.arguments}) : super(key: key);

  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {

  TextEditingController _scanQrCodeController = new TextEditingController();
  FocusNode _scanQrCodeFocusNode = FocusNode();

  String _machineCode = "";
  String _tableCode = "";
  var _menu_direction = "1";//1 默认顶部横向  2 左侧纵向
  var _checkLanguage = "JP";
  var _scanQrCode = "";
  var _isReservation = "0";
  var _actuarial = false;
  var _lineup = false;
  var _takeOut = false; //是否允许外带

  var _isAllowPos = "0"; //1 使用信用卡刷卡  0 不可使用
  var _pos_ip = "";
  var _pos_port = "";

  var _payment_method_num = "0"; //支付类型选择

  //顶部展示支付类型
  var _showWechat = false;
  var _showAlipay = false;
  var _showPayPay = false;
  var _showCreditCard = false;
  var _showCash = false;

  var _showauPay = false;
  var _showdPay = false;
  var _showrPay = false;
  var _showmPay = false;

  var _showPosEdy = false;
  var _showPosiD = false;
  var _showPosIC = false;
  var _showPosQUICPay = false;
  var _showPosWAON = false;
  var _showPosnanaco = false;

  var _showVisa = false;
  var _showMaster = false;
  var _showJcb = false;
  var _showUnionPay = false;
  var _showAmericanExpress = false;
  var _showDinersClub = false;

  var _orderId = "";
  var _totlaPrice = "0";
  var _tableNum = "0";


  var _takeoutButtonList = [];
  var _billButtonList = [];

  var _machineLanguagesList = [];

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();

    _checkLanguage = widget.arguments['checkLanguage'];

    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    _getMachineInfo();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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

    _getSmartweMachineSettingData();
  }

  _getSmartweMachineSettingData() async {
    var smartweMachineSetting = await HomeServices.getSmartweMachineSettingData();
    setState(() {
      _actuarial = smartweMachineSetting["machineActuarial"];
      _lineup = smartweMachineSetting["machineLineup"];
    });

    _getSystemSettingInfo();
  }

  _getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    setState(() {
      _menu_direction = (SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1";
      _isReservation = SystemSettingInfo["isReservation"];
      _isAllowPos = SystemSettingInfo['isAllowPos'];
      _takeOut = (SystemSettingInfo['diningType'] == "2" || SystemSettingInfo['diningType'] == "3") ? true : false;
    });

    _getmenchineLanguages();

  }

  _getmenchineLanguages() async {
    var menchineLanguagesData = await HomeServices.getMachineLanguages();

    setState(() {
      _machineLanguagesList = menchineLanguagesData;
    });

    _getMachineActivateInfo();
  }

  //获取展示支付方式
  _getMachineActivateInfo() async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();

    setState(() {
      this._showCash = systemSettingInfo['showCash'];
      this._showWechat = systemSettingInfo['showWechat'];
      this._showAlipay = systemSettingInfo['showAlipay'];
      this._showPayPay = systemSettingInfo['showPayPay'];
      this._showCreditCard = systemSettingInfo['showCreditCard'];

      _showauPay = systemSettingInfo['au_Pay'];
      _showdPay = systemSettingInfo['d_Pay'];
      _showrPay = systemSettingInfo['R_Pay'];
      _showmPay = systemSettingInfo['m_Pay'];

      _showPosEdy = systemSettingInfo['pos_Edy'];
      _showPosiD = systemSettingInfo['pos_iD'];
      _showPosIC = systemSettingInfo['pos_IC'];
      _showPosQUICPay = systemSettingInfo['pos_QUICPay'];
      _showPosWAON = systemSettingInfo['pos_WAON'];
      _showPosnanaco = systemSettingInfo['pos_nanaco'];

      _showVisa = systemSettingInfo['show_visa'];
      _showMaster = systemSettingInfo['show_master'];
      _showJcb = systemSettingInfo['show_jcb'];
      _showUnionPay = systemSettingInfo['show_unionPay'];
      _showAmericanExpress = systemSettingInfo['show_americanExpress'];
      _showDinersClub = systemSettingInfo['show_dinersClub'];
    });
  }


  //扫码，弹出dialog
  _showScanCodeDialog(){

    //支付状态
    showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (BuildContext context) {
          //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
          return Container(
            width: ScreenAdapter.width(950),
            child: SimpleDialog(
              contentPadding: EdgeInsets.only(bottom: 0),
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
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                              keyboardType: TextInputType.text,
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
                              style: TextStyle(fontSize: ScreenAdapter.fontSize(11.0)),
                              onChanged: (value) {
                                //print(value);
                                if(value.length==1){
                                  _showOrderEasyLoading();
                                }

                              },
                              onSubmitted: (value){
                                Navigator.pop(context);
                                setState(() {
                                  this._tableCode = value;
                                });

                                Future.delayed(Duration(milliseconds: 300), () {
                                  _doNextPay();
                                });



                              },

                              /// 扫码密码
                            )
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: ScreenAdapter.width(1050),
                    height: ScreenAdapter.height(1170),
                    padding: EdgeInsets.only(top: ScreenAdapter.height(35)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: ScreenAdapter.height(50)),
                          child: Text(GString.getToString(this._checkLanguage, "tag_checkOut"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(28),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              )),
                        ),
                        //SizedBox(height: ScreenAdapter.height(10),),
                        Container(
                          //width: ScreenAdapter.width(280),
                            height: ScreenAdapter.height(780),
                            child: Image.asset(GImage.getImageString("imgpublic", "jingsuantag"),fit: BoxFit.fitHeight,height: ScreenAdapter.height(480),)),
                        SizedBox(height: ScreenAdapter.height(60),),
                        Container(
                          //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                          height: ScreenAdapter.height(200),
                          color: ColorsUtil.hexToColor("#DCDCDC"),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: (){
                                  try {
                                    Navigator.pop(context);
                                  } catch (_) {}
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: ScreenAdapter.width(270),
                                  height: ScreenAdapter.height(140),
                                  //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                                  decoration: BoxDecoration(

                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                    //设置圆角
                                    borderRadius: new BorderRadius.circular((5.0)),
                                  ),
                                  child: Text(
                                    GString.getToString(this._checkLanguage, "settlement_back"),
                                    style: TextStyle(
                                        color: ColorsUtil.hexToColor("#000000"),
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenAdapter.fontSize(34.0)),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
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
    var _orderkey = _tableCode;
    if(_tableCode !=""){
      //_showOrderEasyLoading();
    if(_tableCode.contains('?p=') == true){
      _orderkey = _tableCode.substring(_tableCode.length-21);
    }
      //自定义声音
      //playQRScannerSound();

      var formData = {
        "orderKey": _orderkey
      };
      request('webBootCalculate', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();
        //print(response);
        if (response['code'] == 200 && response["data"] !=null && response["data"].isNotEmpty) {
          if(response["data"]["totalPrice"] >0){
            setState((){
              _orderId = response["data"]["orderId"].toString();
              _totlaPrice = response["data"]["totalPrice"].toString();
              _tableNum = response["data"]["tableNum"].toString();
            });
            _showSelectMealTypeAndPaymentMethodDialog();
          }else{
            setState(() {
              _scanQrCodeController.text = "";
              _tableCode = "";
            });
            FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
          }

        }else{
          setState(() {
            _scanQrCodeController.text = "";
            _tableCode = "";
           // FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
          });

          _showDialogError(response['msg']);
          FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
        }
      });
    }
  }

  //选择支付方式
  _showSelectMealTypeAndPaymentMethodDialog() async {

    await showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (BuildContext context) {

          return SelectPaymentPage(
            checkLanguage: _checkLanguage,
            menuCount: 0,
            //mealType:_mealType,
            isAllowPos:_isAllowPos,
            payment_method_num:_payment_method_num,
            showCash:this._showCash,
            showWechat:this._showWechat,
            showAlipay:this._showAlipay,
            showPayPay:this._showPayPay,
            showauPay:this._showauPay,
            showdPay:this._showdPay,
            showrPay:this._showrPay,
            showmPay:this._showmPay,
            showCreditCard:this._showCreditCard,
            showPosEdy:this._showPosEdy,
            showPosiD:this._showPosiD,
            showPosIC:this._showPosIC,
            showPosQUICPay:this._showPosQUICPay,
            showPosWAON:this._showPosWAON,
            showPosnanaco:this._showPosnanaco,
              showVisa:this._showVisa,
              showMaster:this._showMaster,
              showJcb:this._showJcb,
              showUnionPay:this._showUnionPay,
              showAmericanExpress:this._showAmericanExpress,
              showDinersClub:this._showDinersClub,
            shopCartTotalPrice:_totlaPrice,
            tableNum: _tableNum,
            onConfrimClick: (String isAllowPos, String payment_method_num) {
              setState(() {
                _isAllowPos = isAllowPos;
                _payment_method_num = payment_method_num;
                _scanQrCodeController.text = "";
                _tableCode = "";
              });

              var paymentMethod = ["3","4","5","6","7","8","9","10"];
              if (paymentMethod.contains(_payment_method_num) == true) {
                _getPosSettingInfo();
              }else{
                _goToSettlement();
              }

              /*if(_payment_method_num == "3" || _payment_method_num == "4"){
                _getPosSettingInfo();
              }else{
                _goToSettlement();
              }*/

            },
            onCancelClick: (String isBack){
              if(isBack == "back"){
                setState(() {
                  _scanQrCodeController.text = "";
                  _tableCode = "";
                });

              }
              FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
            }
          );
        }).then((_){
          FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
        });
  }

  _getPosSettingInfo() async {
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    setState(() {
      _pos_ip = posSettingInfo['posIp'];
      _pos_port = posSettingInfo['posPort'];
    });
    _goToSettlement();
  }
  _goToSettlement(){
    setState(() {
      _scanQrCodeController.text = "";
      _tableCode = "";
    });
    Navigator.pushNamed(context, '/settlement',
        arguments: {
          "checkLanguage": this._checkLanguage,
          "machineCode": this._machineCode,
          "orderId" : _orderId,
          "totalPrice" : _totlaPrice,
          "machineMode":"2",
          "isAllowPos":_isAllowPos,
          "posIp":_pos_ip,
          "posPort":_pos_port,
          "paymentMethod":_payment_method_num,
          "showWechat":this._showWechat,
          "showAlipay":this._showAlipay,
          "showPayPay":this._showPayPay,
          "showCreditCard":_showCreditCard,
          "showauPay":this._showauPay,
          "showdPay":this._showdPay,
          "showrPay":this._showrPay,
          "showmPay":this._showmPay,
          "showPosEdy":this._showPosEdy,
          "showPosiD":this._showPosiD,
          "showPosIC":this._showPosIC,
          "showPosQUICPay":this._showPosQUICPay,
          "showPosWAON":this._showPosWAON,
          "showPosnanaco":this._showPosnanaco,
          "showVisa":this._showVisa,
          "showMaster":this._showMaster,
          "showJcb":this._showJcb,
          "showUnionPay":this._showUnionPay,
          "showAmericanExpress":this._showAmericanExpress,
          "showDinersClub":this._showDinersClub,
        });
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
            InkWell(
              onLongPress: (){
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
              ),
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
                              InkWell(
                                onLongPress: (){
                                  EasyLoading.dismiss();
                                },
                                child: Container(
                                  //width: ScreenAdapter.width(400),
                                  //margin: EdgeInsets.only(top: 60),
                                  height: ScreenAdapter.height(75),
                                  child: Image.asset(GImage.getImageString("imgpublic", "error_public"),fit: BoxFit.fitHeight),
                                ),
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
                          InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: ScreenAdapter.width(180),
                              height: ScreenAdapter.height(85),
                              margin: EdgeInsets.only(top: ScreenAdapter.height(35)),
                              decoration: BoxDecoration(

                                color: ColorsUtil.hexToColor("#A61C1C"),
                                //设置圆角
                                borderRadius: new BorderRadius.circular((16.0)),
                              ),
                              child: Text(
                                "${GString.getToString(this._checkLanguage,"tag_button_yes")}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenAdapter.fontSize(32.0)),
                              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: Container(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  height: 0,
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                            keyboardType: TextInputType.text,
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
                            style: TextStyle(fontSize: ScreenAdapter.fontSize(11.0)),
                            onChanged: (value) {
                              //print(value);
                              if(value.length==1){
                                _showOrderEasyLoading();
                              }

                            },
                            onSubmitted: (value){
                              setState(() {
                                this._tableCode = value;
                              });

                              Future.delayed(Duration(milliseconds: 300), () {
                                _doNextPay();
                              });



                            },

                            /// 扫码密码
                          )
                      ),
                    ],
                  ),
                ),
                Container(
                  width: ScreenAdapter.getScreenWidth(),
                  height: ScreenAdapter.height(95),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        ColorsUtil.hexToColor("#C47829"),
                        ColorsUtil.hexToColor("#854610"),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_top_qr"),
                              width: ScreenAdapter.width(40),
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(20),
                            ),
                            Text(
                              GString.getToString(this._checkLanguage, "checkoutScanTitle"),
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(34.0)),
                            ),
                          ],
                        ),

                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                      //height: ScreenAdapter.height(940),
                      child: Image.asset(
                        GImage.getImageString("imgpublic","jingsuantag"),
                        width: ScreenAdapter.width(1070),
                        fit: BoxFit.fitWidth,
                      ),
                    )
                ),
                Container(
                  //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                  height: ScreenAdapter.height(200),
                  color: ColorsUtil.hexToColor("#DCDCDC"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          try {
                            //showCancelConfirm();
                            Navigator.pop(context);

                          } catch (_) {}
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenAdapter.width(270),
                          height: ScreenAdapter.height(140),
                          //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((5.0)),
                          ),
                          child: Text(
                            GString.getToString(this._checkLanguage, "settlement_back"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#000000"),
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(180)),
                      Container(
                        margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                        width: ScreenAdapter.width(270),
                        height: ScreenAdapter.height(100),
                      )
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
