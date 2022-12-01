import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/fontSize.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/config/index.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/pages/setting/SettingPage.dart';
import 'package:foodorder/plugins/flutter_plugin_msprint/lib/flutter_plugin_msprinter.dart';
import 'package:foodorder/routers/custom_router.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/formatMoney.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:get/get.dart';
import 'package:paycube/paycube.dart';
import 'package:foodorder/services/Storage.dart';
import 'package:widget_to_image/widget_to_image.dart';

import 'package:foodorder/services/logUtil.dart';
//import 'SettlementCashPage.dart';
//import 'SettlementQrCodePage.dart';

class SettlementPage extends StatefulWidget {
  Map arguments;
  SettlementPage({Key key, this.arguments}) : super(key: key);

  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  HomePageController controller = Get.put(HomePageController());

  TextEditingController _scanQrCodeController = new TextEditingController();
  FocusNode _scanQrCodeFocusNode = FocusNode();

  bool checkboxSelected = true;

  String _machineCode = "";

  //默认语言包选择
  var _checkLanguage = "JP";

  var _shopInfo = "kanran";

  var _print_paper_size = "1";//1 默认58mm  2 宽纸80mm
  var _is_query_receipt = "1";//1 要领収书  2 不要领収书
  var _is_allow_receipt = "1";//1 必须打印  2 不必须

  var _orderId;
  var _scanQrCode = "";

  var _totalPrice = "0";
  var _getPutMoney = "0"; //投币金额
  var _getPutMoneyCurrency = ""; //投币金额币种
  var _getOutMoney = "0"; //出金金额
  var _showOutMoney = "0"; //展示应出金金额

  Timer timer;
  //Timer outtimer;
  //Timer machinetimer;
  Timer allowtimer;
  Timer stoptimer;
  Timer outmoneytimer;
  Timer getoutmoneytimer;
  Timer endtimer;
  Timer OutMoneytimer;
  Timer putMoneyCurrencytimer;

  Timer ScanCodeConfirmTimer;

  var _allowStatus;
  var _stopStatus;
  var _outStatus;
  var _endStatus;
  var _giveChangeMoney = 0;
  var outStringMoney = "0"; //找零金额
  var _currencyString = ""; // 出金币种
  var _isPrint = true; //是否打印小票，默认打印，如果取消订单则不打印。

  var _showPrintButton = false; //如果投币金额不足，则不显示打印按钮

  var _allowClick = true;

  var _doSetting = false;
  var _isReport = true;
  var _ticketData = null;
  var _scanCode = false;
  var _isReportOutMoney = false; //新处理 默认不汇报出金信息  先汇报入金信息在汇报出金信息
  var _isCancel = false; //新增加  取消默认为false

  //顶部展示支付类型
  var _showWechat = true;
  var _showAlipay = true;
  var _showPayPay = true;
  //后台返回是否可以使用pos刷卡机，如果后台可以使用，并且券卖机设置里面也设置开启并设置好ip，则展示图标及请求pos支付的相关数据
  var _showIsPos = true;

  var _machineMode = "1"; //机器类型 1普通券卖机 2精算机
  var _goodsList = [];

  //支付类型相关
  Socket _socket; //socket对象
  bool _socketState = false; //连接状态
  var _isAllowPos = "0";
  var _pos_ip = "192.168.11.180";
  var _pos_port = "9999";
  var _payment_method_num = "0"; //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc


  @override
  void initState() {
    super.initState();

    this._checkLanguage = widget.arguments['checkLanguage'];
    this._shopInfo = widget.arguments['shopInfo'];
    this._machineCode = widget.arguments['machineCode'];
    this._orderId = widget.arguments['orderId'];
    this._machineMode = widget.arguments['machineMode'];
    if(_machineMode == "1"){
      this._totalPrice = widget.arguments['totalPrice'];
    }
    this._isAllowPos = widget.arguments['isAllowPos'];
    this._pos_ip = widget.arguments['posIp'];
    this._pos_port = widget.arguments['posPort'];
    this._payment_method_num = widget.arguments['paymentMethod'];

    //获取是否展示微信支付宝图标等
    //_getMachineActivateInfo();

    _getSystemSettingInfo();

    if(_machineMode == "2"){
      //精算机获得订单
      _getOrderList();
    }

    //this._showWechat = widget.arguments['showWechat'];
    //this._showAlipay = widget.arguments['showAlipay'];
    //this._showPayPay = widget.arguments['showPayPay'];

    //EasyLoading.dismiss();

    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    //0 1适用之前旧版本，可适用现金机，同时也可以扫码  2只可扫码，不在打开现金机 3只支持刷卡
    if(_payment_method_num == "0" || _payment_method_num == "1"){
      //打开现金机
      Starttoubi();
    }else if(_payment_method_num == "3" || _payment_method_num == "4"){
      //1链接socker 2 请求接口获得支付数据发送给pos机 3监听
      payconnectSocker();
    }





  }

  @override
  void dispose() {
    // TODO: implement dispose
    allowtimer?.cancel();
    timer?.cancel();
    stoptimer?.cancel();
    //outtimer?.cancel();
    outmoneytimer?.cancel();
    getoutmoneytimer?.cancel();
    endtimer?.cancel();
    OutMoneytimer?.cancel();
    putMoneyCurrencytimer?.cancel();
    ScanCodeConfirmTimer?.cancel();
    eventBus.fire(new PayCubeEvent('支付成功...'));
    //eventBus.fire(new clearCartEvent('支付成功...'));

    super.dispose();
  }

  _getOrderList(){
    var formData = {
      "language": this._checkLanguage,
      "machineCode": _machineCode,
      "orderId": this._orderId,
    };
    request('checkOutOrderDetails', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200) {
        setState(() {
          _totalPrice = response["data"]["totalPrice"].toString();
          _goodsList = response["data"]["checkOutOrderDetails"];
        });

      }else{
        showToast(response['msg']);
        sleep(Duration(milliseconds: 2000));
        Navigator.pushNamed(context, '/transitPage');
      }
    });
  }
  //进入结算页面获取小票数据
  _getPrintTicketData(){
    EasyLoading.dismiss();

    var formData = {
      "orderId": this._orderId,
    };
    var queryUrl;
    if(_print_paper_size == "1"){
      queryUrl = "webBootToPrintV2";
    }else{
      queryUrl = "webBootToPrintV3";
    }

    request(queryUrl, method: 'GET', parameters: formData).then((val) async {
      var response = json.decode(val.toString());
      if (response['code'] == 200) {

        setState(() {
          _ticketData = json.encode(response['data']);
        });


      } else {

      }
    });
  }
  _getMachineActivateInfo() async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();

    setState(() {
      this._showWechat = systemSettingInfo['showWechat'];
      this._showAlipay = systemSettingInfo['showAlipay'];
      this._showPayPay = systemSettingInfo['showPayPay'];
      this._showIsPos = systemSettingInfo['showIsPos'];
    });
    _getSystemSettingInfo();
  }
  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();

    setState(() {
      _print_paper_size = systemSettingInfo['printPaperSize'];
      _is_allow_receipt = systemSettingInfo['isAllowReceipt'];
    });
    //获取纸大小后在获取数据
    //_getPrintTicketData();

  }


  //购物车

  _showShoppingCart() {

    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(30),
          top: ScreenAdapter.height(40),
          right: ScreenAdapter.width(30),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
            width: ScreenAdapter.width(930),
            child: GetBuilder<HomePageController>(
              builder: (_) {
                if (controller.cartItems.length == 0) {
                  return Center(
                    child: Text("No item found"),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  children: controller.cartItems
                      .map((d) => generateCartList(context, d))
                      .toList(),
                );
              },
            ),
          )),
          Container(
            height: ScreenAdapter.height(150),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(GString.getToString(this._checkLanguage, "settlement_total_price"),
                  style: TextStyle(
                      fontSize:
                          ScreenAdapter.fontSize(GFontSize.menusettlementHeji),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor))),
              Text('￥ ${getItemTotal(controller.cartItems).toString()} ',
                  style: TextStyle(
                      fontSize:
                          ScreenAdapter.fontSize(GFontSize.menusettlementHeji),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor))),
            ],
          )),

          Container(
              height: ScreenAdapter.height(80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: checkboxSelected,
                      onChanged: (value){
                        checkboxSelected = !checkboxSelected;

                        setState(() {

                        });
                      }
                  ),
                  Text(GString.getToString(this._checkLanguage, "settlement_small_ticket_tag"),
                      style: TextStyle(
                          fontSize:
                          ScreenAdapter.fontSize(GFontSize.menusettlementLingshoushu),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor))),
                ],
              )),
        ],
      ),
    );
  }
  Widget generateCartList(BuildContext context, ShopItemModel d) {
    return Container(
      padding: EdgeInsets.all(ScreenAdapter.height(10)),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white12,
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 1.0),
              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: Container(
              //padding: EdgeInsets.only(left: ScreenAdapter.width(5)),
              //width: ScreenAdapter.width(495),
              child: RichText(
                text: TextSpan(
                    text: d.mainTitle,
                    style: TextStyle(
                        fontSize:
                            ScreenAdapter.fontSize(GFontSize.cartListTitle),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                    children: [
                      d.goodsNum > 1?TextSpan(
                        text: " x ${d.goodsNum}",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.cartListTitleCount),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ):TextSpan(
                        text: "",
                      ),
                      (d.optionVoListMsg != "") ?TextSpan(
                        text: "（${d.optionVoListMsg}）",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.cartListTitleTag),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ):TextSpan(
                        text: "",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.cartListTitleTag),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              ),
            )),
            Container(
              width: ScreenAdapter.width(140),
              alignment: Alignment.centerRight,
              child: Text(
                "￥ ${formatMoney(d.currentPrice.toString())}",
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(GFontSize.mainPriceRight),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getItemTotal(List items) {
    int sum = 0;
    items.forEach((e) {
      sum += e.currentPrice;
    });
    return sum;
  }

//扫码支付
  _doToPay(){
    //不是扫码支付直接return
    if(_payment_method_num != "2") return;

    if(_showWechat == false && _showAlipay == false && _showPayPay == false){
      _showScanCodeNoOpenDialog(1);
      return;
    }

    var _regExpWechat=r"^1[0-5]\d{16}$";
    var _regExpAlipay=r"^(?:2[5-9]|30)\d{14,22}$";
    if(RegExp(_regExpWechat).hasMatch(_scanQrCode)==true && _showWechat == false){
      _showScanCodeNoOpenDialog(2);
      return;
    }else if(RegExp(_regExpAlipay).hasMatch(_scanQrCode)==true && _showAlipay == false){
      _showScanCodeNoOpenDialog(2);
      return;
    }else{
      if(RegExp(_regExpWechat).hasMatch(_scanQrCode)==false && RegExp(_regExpAlipay).hasMatch(_scanQrCode)==false &&_showPayPay == false){
        _showScanCodeNoOpenDialog(2);
        return;
      }
    }


    if (_machineCode != "" && _scanQrCode !="" && _orderId !=null) {
      //_showEasyLoading();
      _showEasyLoadingScan();
      var formData = {
        "auth_code": this._scanQrCode,
        "machineCode": _machineCode,
        "orderId": this._orderId,
      };
      request('webBootToPay', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());

        if (response['code'] == 200 && response['data'] == true) {
          //payCubeEndDeposit();
          setState(() {
            _isReport = false;
            _scanCode = true;
          });
          doPrintOrderMenu("1");


        } else {
          //扫码后超时，再继续请求后台，1秒一次 20次
          _doScanCodeTimeOut();


        }
      });

    }
  }



  //三种扫码支付都未开通，弹出dialog
  _showScanCodeNoOpenDialog(checknum){
    EasyLoading.dismiss();
    setState(() {
      _scanQrCodeController.text = "";
      _scanQrCode = "";
      FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
    });

    var show_dialog_content;

    if(checknum == 1){
      show_dialog_content = GString.getToString(this._checkLanguage, "settlement_scancodenoopen_error");
    }else if(checknum == 2){
      show_dialog_content = GString.getToString(this._checkLanguage, "settlement_scancodenochange_error");
    }
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
                title: Align(
                    alignment: Alignment.center,
                    child:  Text(GString.getToString(this._checkLanguage, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                ),
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(650),

                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text(show_dialog_content,
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
                        Container(
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
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          );
        });
  }

  //扫码后超时，再继续请求后台，5秒一次 60次
  _doScanCodeTimeOut(){
    int queryCount = 0;
    ScanCodeConfirmTimer?.cancel();
    ScanCodeConfirmTimer = Timer.periodic(Duration(milliseconds: 5000), (Timer ConfirmTimer) async {
      queryCount++;
      if(queryCount > 60){
        //退出关闭
        ConfirmTimer?.cancel();
        _showScanCodeTimeOutDialog();
      }

      var formData = {
        "orderId": this._orderId,
      };
      request('webBootLinePayConfirm', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());

        if (response['code'] == 200 && response['data'] == true) {
          //退出关闭
          ConfirmTimer?.cancel();
          setState(() {
            _isReport = false;
            _scanCode = true;
          });
          doPrintOrderMenu("1");
        }
      });



    });
  }

  _doScanCodeTimeOutLastQuery(){
    var formData = {
      "orderId": this._orderId,
    };
    request('webBootLinePayConfirm', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200 && response['data'] == true) {
        setState(() {
          _isReport = false;
          _scanCode = true;
        });
        doPrintOrderMenu("1");
      }else{
        _showScanCodeTimeOutDialog();
      }
    });
  }


  //扫码超时请求20次后依然失败，弹出dialog
  _showScanCodeTimeOutDialog(){
    EasyLoading.dismiss();
    setState(() {
      _scanQrCodeController.text = "";
      _scanQrCode = "";
      FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
    });

    var show_dialog_content = GString.getToString(this._checkLanguage, "settlement_nopayment_error");

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
                title: Align(
                    alignment: Alignment.center,
                    child:  Text(GString.getToString(this._checkLanguage, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                ),
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(650),

                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text(show_dialog_content,
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
                        Container(
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
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          );
        });
  }

  //去打印小票
  doPrintOrderMenu(printType) async {
    var printStatus = await FlutterPluginMsprinter.getPrintStatus();
    if(printStatus == "0" || printStatus == "8"){

      if(_ticketData != null){

        //新接口 券卖机1时候，可选择是否打印领収书，菜单必打  精算机2，不打菜单，可选领収书
        if(_machineMode == "1"){
          _tpPrintnew(_ticketData,printType);
        }else if(_machineMode == "2"){
          //1打印领収书 2不打印，直接返回
          if(printType == "1"){
            _tpPrintReceipt(_ticketData);
          }
        }

        //应对旧接口
        //await FlutterPluginMsprinter.sendPrint(_ticketData,_shopInfo,_print_paper_size,_is_query_receipt,_machineMode);

        if(_machineMode == "1"){
          eventBus.fire(new clearCartEvent('支付成功...'));
        }

        //只有现金机时候才执行 先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
        if(_payment_method_num == "1"){
          nextOper();
          /*if(_scanCode == true){
            //已经结束入金，处理取引终了
            payCubeEndDeposit();
          }else{
            nextOper();
          }*/
        }else{
          gotonewMyhome();
        }


      }else{
        var formData = {
          "orderId": this._orderId,
        };
        var queryUrl;
        /*if(_print_paper_size == "1"){
          queryUrl = "webBootToPrintV2";
        }else{
          queryUrl = "webBootToPrintV3";
        }*/

        queryUrl = "webBootToPrintV4";

        request(queryUrl, method: 'GET', parameters: formData).then((val) async {
          var response = json.decode(val.toString());
          //LogUtil.d(response);
          if (response['code'] == 200) {
            //printType 1 打印菜+领収书 2 只打印菜
            if(_machineMode == "1"){
              _tpPrintnew(response['data'],printType);
            }else if(_machineMode == "2"){
              //1打印领収书 2不打印，直接返回
              if(printType == "1"){
                _tpPrintReceipt(response['data']);
              }
            }



            //await FlutterPluginMsprinter.sendPrint(json.encode(response['data']),_shopInfo,_print_paper_size,_is_query_receipt,_machineMode);

            sleep(Duration(milliseconds: 500));

            if(_machineMode == "1"){
              eventBus.fire(new clearCartEvent('支付成功...'));
            }

            //先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
            /*if(_scanCode == true){
              //已经结束入金，处理取引终了
              payCubeCloseTransaction();
            }else{
              nextOper();
            }*/

            if(_payment_method_num == "1"){
              nextOper();
              /*if(_scanCode == true){
                //已经结束入金，处理取引终了
                payCubeEndDeposit();
              }else{
                nextOper();
              }*/
            }else{
              gotonewMyhome();
            }


          } else {
            //错误后重新调用一次
            doPrintOrderMenu(printType);
            //EasyLoading.dismiss();

          }
        });
      }

    }else{
      EasyLoading.dismiss();

      var show_dialog_content = "";
      if(printStatus == "7"){
        show_dialog_content = GString.getToString(this._checkLanguage, "tag_print_content_paper_shortage");
      }else{
        show_dialog_content = GString.getToString(this._checkLanguage, "tag_print_content_paper_error");
      }
        //小票状态
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Container(
              width: ScreenAdapter.width(950),
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  title: Align(
                      alignment: Alignment.center,
                      child:  Text(GString.getToString(this._checkLanguage, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                  ),
                  children: <Widget>[
                    Container(
                      width: ScreenAdapter.width(650),

                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            child: Text(show_dialog_content,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 70.0),
                                child: TextButton(
                                  child: Text(
                                    GString.getToString(this._checkLanguage, "tag_print_button_no"),
                                    style: TextStyle(
                                        color: Colors.lightBlue,
                                        fontSize: ScreenAdapter.fontSize(32.0)),
                                  ),
                                  onPressed: () {
                                    //sleep(Duration(milliseconds: 3000));
                                    Navigator.pop(context);
                                    gotonewMyhome();

                                  },
                                ),
                              ),
                              //垂直分割线
                              SizedBox(
                                width: 1,
                                height: 40,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(color: Colors.black12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 70.0),
                                child: TextButton(
                                  child: Text(
                                    GString.getToString(this._checkLanguage, "tag_print_button_yes"),
                                    style: TextStyle(
                                        color: Colors.lightBlue,
                                        fontSize: ScreenAdapter.fontSize(32.0)),
                                  ),
                                  onPressed: () async {
                                    //widget.confirmCallback('确定');
                                    Navigator.pop(context);
                                    doPrintOrderMenu(printType);
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]
              ),
            );
          });

    }


  }

  //打印甘蘭
  _tpPrintnew(printData,printType) async {
    var categoryVos = printData["categoryVos"];LogUtil.d(printData);

    List<Widget> categoryMenus = [];
    var lineHight = 75;
    var menuNum = 0;
    var optionNum = 0;
    var addRowHight = 0;

    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["serialNumber"]}",
                style: TextStyle(
                  fontSize: 50,
                  //fontFamily: 'JetBrainsMonoRegular',
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor("#000000"),))),
      ),
    );

    int categoryNum = categoryVos.length;
    int categoryshowNum = 0;
    for(var i=0; i<categoryVos.length; i++){
      int linNum = 0;
      var lineVosList = categoryVos[i]["lineVos"];
      int linVoNum = lineVosList.length;

      for(var m=0; m<lineVosList.length; m++){
        var lineItem = lineVosList[m];
        var optionVoList = lineItem["optionVos"];
        // 计算菜品标题长度
        var menuLength = lineItem["menuName"].length;
        var menuLine = menuLength / 13;
        var menuRowNum = menuLine.ceil();
        optionNum = 0;

        categoryMenus.add(
            _publicGoodsTwoColumnsTxt("${lineItem["menuName"]}",28.0,FontWeight.w100,"${lineItem["menuQty"]}",28.0,FontWeight.w100),
        );
        if(optionVoList != null && optionVoList.length >0){
          for(var n=0; n<optionVoList.length; n++){
            var optionVos = optionVoList[n];
            // 计算菜品标题长度
            var groupNameLength = optionVos["groupName"].length;
            var optionNameLength = optionVos["optionName"].length;
            var optionLine = (groupNameLength + optionNameLength) / 13;
            var optionRowNum = optionLine.ceil();

            categoryMenus.add(
              _publicGoodsTwoColumnsTxt("　${optionVos["groupName"]}",28.0,FontWeight.w100,"${optionVos["optionName"]}",28.0,FontWeight.w100),
            );
            addRowHight += 50*optionRowNum;
            menuNum += optionRowNum;
            optionNum++;
            }
          addRowHight += 48*menuRowNum;
          menuNum += menuRowNum;
        }else{
          addRowHight += 53*menuRowNum;
          menuNum += menuRowNum;
        }

        //分割线
        if(_machineMode == "1"){
          addRowHight += 6;
          categoryMenus.add(
            _publicSplitLine(),
          );
        }

      }



    }
    print("总行数${menuNum}");
    var totalHight = addRowHight+lineHight;
    if(menuNum == 1){
      totalHight +=15;
    }
    /*var totalHight = menuNum*56+lineHight;
    if(menuNum == 1){
      totalHight +=15;
    }
    print(optionNum);
    if(optionNum >0){
      totalHight -= optionNum*20;
    }*/
    /*if(menuNum >= 20 && menuNum <=30 ){
      totalHight -=30;
    }*/

    ByteData byteData = await WidgetToImage.widgetToImage(
        Container(
          width: 380,
          height: totalHight.toDouble(),
          padding: EdgeInsets.only(left:0.5,right: 0.5),
          color: Colors.white,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: categoryMenus,
          ),
        )
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //final result = await ImageGallerySaver.saveImage(imageBytes, quality: 100);
    Future.delayed(Duration(milliseconds: 100),() async {
      String base64Image = base64Encode(imageBytes);
      //LogUtil.d(base64Image);
      if(printType == "1"){
        await FlutterPluginMsprinter.sendPrintImg(base64Image,"1",_shopInfo,"0");
        _tpPrintReceipt(printData);
      }else{
        await FlutterPluginMsprinter.sendPrintImg(base64Image,"0",_shopInfo,"0");
      }

    });


  }

  _tpPrintReceipt(printData) async {

    List<Widget> categoryMenus = [];
    var lineHight = 630;
    var lineZeng = 20;

    //电话
    categoryMenus.add(
      _publicOneColumnTxt("電話 ${printData["telephone"]}",24.0,FontWeight.w200)
    );
    //地址
    categoryMenus.add(
        _publicOneColumnTxt("${printData["shopAddress"]}",24.0,FontWeight.w200)
    );
    //订单日期
    /*categoryMenus.add(
        _publicOneColumnTxt(printData["orderDate"],25.0,FontWeight.w200)
    );*/
    categoryMenus.add(
      Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["orderDate"]}",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w100,
                    fontFamily: 'NotoSansJP',
                    color: ColorsUtil.hexToColor("#000000")
                ))),
      )
    );

//领収书标题
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("領 収 書",
                style: TextStyle(
                  fontSize: 50,
                  fontFamily: 'UbuntuMonoRegular',
                  fontWeight: FontWeight.w300,
                  color: ColorsUtil.hexToColor("#000000"),))),
      ),
    );
//合计
    categoryMenus.add(
      Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            margin: EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("合計",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'ZenKakuGothicAntique',
                          color: ColorsUtil.hexToColor("#000000"),))),
                Expanded(child: Container()),

                Directionality(
                    textDirection: TextDirection.ltr,
                    child: RichText(
                      text: TextSpan(
                          text: "￥",//GString.getToString(this._checkLanguage, "show_price_front"),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000"),
                          ),
                          children: [
                            TextSpan(
                              text: "${printData["payPrice"]} ",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'NotoSansJP',
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                            ),
                          ]),
                    )
                ),
              ],
            ),
          )),
    );
    categoryMenus.add(
      _publicSplitLine(),
    );
    //税拔金额
    categoryMenus.add(
      _publicTwoColumnsTxt("税抜金額",28.0,FontWeight.w200,"${printData["excludingTaxStr"]}",28.0,FontWeight.w200,true),
    );
    //消费税
    categoryMenus.add(
      _publicTwoColumnsTxt("消費税",28.0,FontWeight.w200,"${printData["taxStr"]}",28.0,FontWeight.w200,true),
    );
    //10%
    categoryMenus.add(
      _publicTwoColumnsTxt("対象10%",28.0,FontWeight.w200,(printData["line7"] != "外") ? "${printData["payPrice"]}":"0",28.0,FontWeight.w200,true),
    );
    //内消费税
    categoryMenus.add(
      _publicTwoColumnsTxt("　内消費税",28.0,FontWeight.w200,(printData["line7"] != "外") ? "${printData["taxStr"]}" :"0",28.0,FontWeight.w200,true),
    );
    //8%
    categoryMenus.add(
      _publicTwoColumnsTxt("対象8%",28.0,FontWeight.w200,(printData["line7"] == "外") ? "${printData["payPrice"]}" :"0",28.0,FontWeight.w200,true),
    );
    //内消费税
    categoryMenus.add(
      _publicTwoColumnsTxt("　内消費税",28.0,FontWeight.w200,(printData["line7"] == "外") ? "${printData["taxStr"]}" :"0",28.0,FontWeight.w200,true),
    );

    categoryMenus.add(
      _publicSplitLine(),
    );
    categoryMenus.add(
      _publicTwoColumnsTxt(printData["payMethod"],26.0,FontWeight.w200,"${printData["payPrice"]}",26.0,FontWeight.w200,true),
    );
    if(printData["memberNo"] != null && printData["memberNo"] != ""){
      lineZeng = 110;
      categoryMenus.add(
        _publicTwoColumnsTxt("カード番号",26.0,FontWeight.w200,printData["memberNo"],26.0,FontWeight.w100,false),
      );
      categoryMenus.add(
          _publicTwoColumnsTxt("日期",26.0,FontWeight.w200,printData["payDate"],26.0,FontWeight.w100,false),
      );
      categoryMenus.add(
          _publicSplitLine()
      );
    }
    //お明細は上記のとおりです。
    categoryMenus.add(
      _publicOneColumnTxt("お明細は上記のとおりです。",26.0,FontWeight.w200)
    );


    var totalHight = lineZeng+lineHight;

    ByteData byteData = await WidgetToImage.widgetToImage(
        Container(
          width: 380,
          height: totalHight.toDouble(),
          color: Colors.white,
          //alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryMenus,
          ),
        )
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //final result = await ImageGallerySaver.saveImage(imageBytes, quality: 100);
    Future.delayed(Duration(milliseconds: 100),() async {
      String base64Image = base64Encode(imageBytes);
      //LogUtil.d(base64Image);
      await FlutterPluginMsprinter.sendPrintImg(base64Image,"0",_shopInfo,"1");
    });
  }

  //单列文字
  _publicOneColumnTxt(txtContext,txtFontSize,txtFontWeight){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text("${txtContext}",
              style: TextStyle(
                  fontSize: txtFontSize,
                  fontWeight: txtFontWeight,
                  fontFamily: 'ZenKakuGothicAntique',
                  color: ColorsUtil.hexToColor("#000000")
              ))),
    );
  }
  //两列文字
  _publicTwoColumnsTxt(leftTxtContext,leftTxtFontSize,leftTxtFontWeight,rightTxtContext,rightTxtFontSize,rightTxtFontWeight,isMoney){
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("${leftTxtContext}",
                      style: TextStyle(
                        fontSize: leftTxtFontSize,
                        fontWeight: leftTxtFontWeight,
                        fontFamily: 'ZenKakuGothicAntique',
                        color: ColorsUtil.hexToColor("#000000"),))),
              Expanded(child: Container()),
              (isMoney == true)? Directionality(
                  textDirection: TextDirection.ltr,
                  child: RichText(
                      text: TextSpan(
                      text: "￥",//GString.getToString(this._checkLanguage, "show_price_front"),
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            fontSize: rightTxtFontSize,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000"),
                          ),
                          children: [
                            TextSpan(
                              text: "${rightTxtContext} ",
                              style: TextStyle(
                                fontSize: rightTxtFontSize,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'NotoSansJP',
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                            ),
                          ]),
                )

              ):Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("${rightTxtContext} ",
                      style: TextStyle(
                        fontSize: rightTxtFontSize,
                        fontWeight: rightTxtFontWeight,
                        fontFamily: 'NotoSansJP',
                        color: ColorsUtil.hexToColor("#000000"),
                        //fontWeight: FontWeight.w
                        // 600
                      ))),
            ],
          ),
        ));
  }
  //商品双列
  _publicGoodsTwoColumnsTxt(leftTxtContext,leftTxtFontSize,leftTxtFontWeight,rightTxtContext,rightTxtFontSize,rightTxtFontWeight){
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Text("${leftTxtContext}",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: leftTxtFontSize,
                          fontWeight: leftTxtFontWeight,
                          fontFamily: 'ZenKakuGothicAntique',
                          color: ColorsUtil.hexToColor("#000000"),)),
                  )
              ),
              //Expanded(child: Container()),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("${rightTxtContext}",
                      style: TextStyle(
                        fontSize: rightTxtFontSize,
                        fontWeight: rightTxtFontWeight,
                        fontFamily: 'ZenKakuGothicAntique',
                        color: ColorsUtil.hexToColor("#000000"),
                        //fontWeight: FontWeight.w600
                      ))),
            ],
          ),
        ));
  }
  //分割线
  _publicSplitLine(){
    return Directionality(
        textDirection: TextDirection.ltr,
        child:Container(
          margin: EdgeInsets.only(top: 5,bottom: 5),
          height: 0.5,
          color:ColorsUtil.hexToColor("#000000"),
          width: 375,
        )
    );
  }

  nextOperOld() async {
    setState(() {
      timer?.cancel();
    });

    int putMoney = int.parse(this._getPutMoney); //投币金额
    //如果投币金额大于等于收款金额，则判断找零或结束
    if (putMoney > int.parse(this._totalPrice)) {
      var _outmoney = putMoney - int.parse(this._totalPrice);
      setState(() {
        _giveChangeMoney = _outmoney;
      });

      await Paycube.setReceiveEvent;
      var endStatus = await Paycube.endPayCube;
      stoptimer?.cancel();
      stoptimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopt) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        //startOutPutMoney(_outmoney);
        if(_isPrint == true){
          if(_giveChangeMoney >0){
            startOutPutMoney(_giveChangeMoney);
          }else{

            if(_isReport == true){
              //汇报，关闭现金机
              reportOutMoney();
            }else{
              //已经结束入金，处理取引终了
              payCubeCloseTransaction();
            }

          }
        }else{
          startOutPutMoney(_giveChangeMoney);
        }


        stopt.cancel();

      }else if(_stopStatus == "Error-A0--02"){
        //处理中
        await Paycube.endPayCube;
      }else{
        await Paycube.endPayCube;

      }
      });

    } else if (putMoney == int.parse(this._totalPrice)) {
      //结束入金
      var endStatus = await Paycube.endPayCube;
      await Paycube.setReceiveEvent;
      stoptimer?.cancel();
      stoptimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopt) async {
        _stopStatus =  await Paycube.getPayCubeStopCashStatus;
        // 循环一定要记得设置取消条件，手动取消
        if (_stopStatus == "StopSuccess" || _stopStatus == "Error-A0--02" || _stopStatus == "Error-F0--16") {
          //先打印小票，再去取引终了现金机;
          if(_isPrint == true){
            if(_giveChangeMoney >0){
              startOutPutMoney(_giveChangeMoney);
            }else{

              if(_isReport == true){
                //汇报，关闭现金机
                reportOutMoney();
              }else{
                //已经结束入金，处理取引终了
                payCubeCloseTransaction();
              }

            }
          }else{
            //已经结束入金，处理取引终了
            payCubeCloseTransaction();
          }

          stopt.cancel();

        }/*else if(_stopStatus == "Error-A0--02"){
          //处理中
          //sleep(Duration(milliseconds: 200));
          //await Paycube.endPayCube;
        }*/else{
          await Paycube.endPayCube;

        }
      });
    }
  }
  //打印小票之后在关闭现金机，所以不考虑_isPrint
  nextOper() async {
    sleep(Duration(milliseconds: 300));
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stoptimer?.cancel();
    stoptimer = Timer.periodic(Duration(milliseconds: 950), (Timer stopt) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        setState(() {
          timer?.cancel();
        });
        //如果投币金额大于待支付总金额
        if (int.parse(this._getPutMoney) > int.parse(this._totalPrice)) {
          setState(() {
            _giveChangeMoney = int.parse(this._getPutMoney) - int.parse(this._totalPrice);
          });
          //找零
          startOutPutMoney(_giveChangeMoney);
        }else{
          /*if(_isReport == true){
            //汇报，关闭现金机
            reportOutMoney();
          }else{*/
            //已经结束入金，处理取引终了
            payCubeCloseTransaction();
          //}
        }



        stopt.cancel();

      }/*else if(_stopStatus == "Error-A0--02" || _stopStatus == "Error-F0--16"){
        //处理中
        await Paycube.endPayCube;
      }*/else{
        await Paycube.endPayCube;

      }
    });

  }

  //现金及支付
  //现金机开始 打开现金机，准备开始投币
  Starttoubi() async {
    //入金开始
    String strartPayCube = await Paycube.strartPayCube;
    await Paycube.setReceiveEvent;
    allowtimer?.cancel();
    allowtimer = Timer.periodic(Duration(milliseconds: 150), (Timer allowt) async {
      _allowStatus =  await Paycube.getPayCubeAllowCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_allowStatus == "AllowSuccess") {
        getPutInMoney();

        allowt.cancel();

      }else if (_allowStatus == "Error-F0--16") {
        await Paycube.endTrade;
        //sleep(Duration(milliseconds: 200));
        await Paycube.strartPayCube;
      }else if (_allowStatus == "Error-A0--02") {
        //sleep(Duration(milliseconds: 300));
      }else{

        await Paycube.strartPayCube;

      }
    });


  }

  //获取投入金额
  getPutInMoney() async {
    await Paycube.setReceiveEvent;
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) async {
      var result = await Paycube.getPayCubeMoney;
      if (int.parse(result) > 0) {
        setState(() {
          _getPutMoney = result;

          _scanQrCodeFocusNode.unfocus();
        });
        if(int.parse(result) >= int.parse(this._totalPrice, onError: (source) => -1)){
          setState(() {
            _showPrintButton = true;
            var outMoney = int.parse(result) - int.parse(this._totalPrice); //找零金额
            _showOutMoney = outMoney.toString(); //找零金额
          });
        }else{
          setState(() {
            _showOutMoney = "0"; //找零金额
          });
        }
      }
    });
  }

  //入金开始-入金结束-交易结束-出金开始-交易结束  中间可set
  EndtoubiOld() async {
    setState(() {
      timer?.cancel();
    });

    int putMoney = int.parse(this._getPutMoney); //投币金额
    //如果投币金额大于等于收款金额，则判断找零或结束
    if (putMoney > int.parse(this._totalPrice)) {
      var _outmoney = putMoney - int.parse(this._totalPrice);
      setState(() {
        _giveChangeMoney = _outmoney;
      });

      await Paycube.setReceiveEvent;
      var endStatus = await Paycube.endPayCube;
      stoptimer?.cancel();
      stoptimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopt) async {
        _stopStatus =  await Paycube.getPayCubeStopCashStatus;
        // 循环一定要记得设置取消条件，手动取消
        if (_stopStatus == "StopSuccess") {
          //startOutPutMoney(_outmoney);
          if(_isPrint == false){
            startOutPutMoney(_giveChangeMoney);
          }

          stopt.cancel();

        }else if(_stopStatus == "Error-A0--02"){
          //处理中
          await Paycube.endPayCube;
        }else{
          await Paycube.endPayCube;
        }
      });

    } else if (putMoney == int.parse(this._totalPrice)) {
      //结束入金
      var endStatus = await Paycube.endPayCube;
      await Paycube.setReceiveEvent;
      stoptimer?.cancel();
      stoptimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopt) async {
        _stopStatus =  await Paycube.getPayCubeStopCashStatus;
        // 循环一定要记得设置取消条件，手动取消
        if (_stopStatus == "StopSuccess" || _stopStatus == "Error-A0--02" || _stopStatus == "Error-F0--16") {
          //先打印小票，再去取引终了现金机;
          if(_isPrint == false){
            //已经结束入金，处理取引终了
            payCubeCloseTransaction();
          }
          stopt.cancel();

        }/*else if(_stopStatus == "Error-A0--02"){
          //处理中
          //sleep(Duration(milliseconds: 200));
          //await Paycube.endPayCube;
        }*/else{
          await Paycube.endPayCube;
        }
      });


    } else {
      showToast(GString.getToString(this._checkLanguage, "show_put_money_error"));
    }
  }
  Endtoubi() async {
    sleep(Duration(milliseconds: 300));
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stoptimer?.cancel();
    stoptimer = Timer.periodic(Duration(milliseconds: 950), (Timer stopt) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        setState(() {
          timer?.cancel();
        });
        if (int.parse(this._getPutMoney) > int.parse(this._totalPrice)) {
          setState(() {
            _giveChangeMoney = int.parse(this._getPutMoney) - int.parse(this._totalPrice);
          });

          if(_isPrint == false){
            startOutPutMoney(_giveChangeMoney);
          }

        }else if (int.parse(this._getPutMoney) == int.parse(this._totalPrice)){
          if(_isPrint == false){
            //已经结束入金，处理取引终了
            payCubeCloseTransaction();
          }
        }else {
          showToast(GString.getToString(this._checkLanguage, "show_put_money_error"));
        }

        stopt.cancel();

      }/*else if(_stopStatus == "Error-A0--02"){
        //处理中
        await Paycube.endPayCube;
      }*/else{
        await Paycube.endPayCube;
      }
    });


  }

  startOutPutMoney(outMoney) async {
    setState(() {
      outStringMoney = outMoney.toString();

    });
    await Paycube.setReceiveEvent;

    String outResult = await Paycube.outPayCubeMoney(outStringMoney);

    outmoneytimer?.cancel();
    outmoneytimer = Timer.periodic(Duration(milliseconds: 200), (Timer outmoneyt) async {
      _outStatus =  await Paycube.getPayCubeOutMoneyStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_outStatus == "OutSuccess") {

//如果取消不汇报，则出金后直接关闭 ？？？？？？
          _getPayCubeOutMoney();

        outmoneyt.cancel();

      }else if(_outStatus == "Error-A0--02"){
        //await Paycube.setReceiveEvent;
        //sleep(Duration(milliseconds: 200));
        //await Paycube.getPayCubeOutMoneyStatus;
        //print("_outStatus处理中:$_outStatus");
      }else{

        await Paycube.outPayCubeMoney(outStringMoney);

      }
    });

  }


  gotonewMyhome(){
    Get.find<HomePageController>().removeAllFromCart();

    EasyLoading.dismiss();
    //Navigator.pop(context);
    Navigator.pop(context);
    //Navigator.pushNamed(context, '/transitPage');
    if(_machineMode == "1"){
      Navigator.pushNamed(context, '/home');
    }else{
      //Navigator.pushNamed(context, '/transitPage');
      Navigator.pushNamed(context, '/checkOutPage');
    }
  }

  gotonewMenuPage(){
    EasyLoading.dismiss();
    Navigator.pop(context);
    /*if(_machineMode == "1"){
      Navigator.pushNamed(context, '/menuPage', arguments: {"checkLanguage": this._checkLanguage,"shopInfo":_shopInfo});
    }else{
      Navigator.pushNamed(context, '/checkOutPage');
    }*/
  }

  gotonewSettingPage(){
    EasyLoading.dismiss();
    Navigator.pop(context);
    Navigator.pushNamed(context, '/settingPage', arguments: {"machineCode": this._machineCode,"shopInfo":_shopInfo});
  }


  _getPayCubeOutMoney() async {
  //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
  OutMoneytimer?.cancel();
  await Paycube.setReceiveEvent;
  OutMoneytimer = Timer.periodic(Duration(milliseconds: 400), (Timer outMoneyTime) async {
    // 循环一定要记得设置取消条件，手动取消
    String currencyString = await Paycube.getPayCubeOutMoneyCurrency;
    if(currencyString.trim().length >0){
      setState(() {
        _currencyString = currencyString;

      });

        //汇报出金币种
        reportOutMoney();

      outMoneyTime.cancel();
    }

  });
  }

  //汇报出金币种,请求后台
  reportOutMoney(){
    setState(() {
      _isReportOutMoney = true;
    });
  payCubeCloseTransaction();

    /*var formData = {
      "changeInfo": this._currencyString.trim(),
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "price": int.parse(this._getPutMoney)
    };print(formData);
    request('webBootToReport', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());print(response);
      if (response['code'] == 200) {
          //已经结束入金，处理取引终了
          payCubeCloseTransaction();

      } else {

      }
    });*/


  }


  //扫码支付后，直接结束入金，取引终了
  payCubeEndDeposit() async {
    setState(() {
      timer?.cancel();
    });
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stoptimer?.cancel();
    stoptimer = Timer.periodic(Duration(milliseconds: 950), (Timer stopt) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      //await Paycube.setReceiveEvent;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        //print("扫码成功结束");
        payCubeCloseTransaction();
        stopt.cancel();

      }else{
        //sleep(Duration(milliseconds: 150));
        await Paycube.endPayCube;
      }
    });
  }
  payCubeCloseTransaction() async {
    if(int.parse(_getPutMoney) >0){
      //汇报入金币种
      _getPayCubePutMoneyCurrency();
    }


    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    await Paycube.setReceiveEvent;
    endtimer?.cancel();
    endtimer = Timer.periodic(Duration(milliseconds: 950), (Timer endtradet) async {
      _endStatus =  await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消 || _endStatus == "Error-A0--02"
      if (_endStatus == "EndSuccess") {
        //关闭机器后的跳转
        if(_isPrint == true){
          gotonewMyhome();
        }else{
          if(_doSetting == true){
            gotonewSettingPage();
          }else{
            gotonewMenuPage();
          }
        }


        endtradet.cancel();

      }else{
        //sleep(Duration(milliseconds: 200));
        await Paycube.endTrade;
      }
    });
  }


  //取消购买 要判断是否投入现金，如果投入现金则现金机出金，出已投金额，否则直接取消退回首页 model0 券卖机 `1精算机
  CancelOrder(){

    var formData = {
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "model": (_machineMode == "1")? "0":"1",
    };
    //不用查看返回
    request('webBootCancelV1', method: 'POST', parameters: formData);

    setState(() {
      _isCancel = true;
    });

    if(_payment_method_num == "1" || _payment_method_num == "0"){
      //已投钱
      if(int.parse(_getPutMoney) >0){
        setState(() {
          _isPrint = false;
          _totalPrice = "0";
        });

        //如果现金机投币大于0后取消，则直接关机出金
        Endtoubi();
      }else{
        setState(() {
          _isPrint = false;
          _totalPrice = "0";
          _getPutMoney = "0";
        });
        //如果现金机投币大于0后取消，则直接关机出金
        Endtoubi();
      }
    }else{
      //返回上一级菜单页面
      gotonewMenuPage();
    }

  }

  _getPayCubePutMoneyCurrency() async {
    //_putcurrencyString现金机出款币种:61 00 00 62 00 00 63 00 00
    putMoneyCurrencytimer?.cancel();
    await Paycube.setReceiveEvent;
    putMoneyCurrencytimer = Timer.periodic(Duration(milliseconds: 400), (Timer putMoneyCurrencyTime) async {
      // 循环一定要记得设置取消条件，手动取消
      String putcurrencyString = await Paycube.getPayCubePutMoneyCurrency;
      if(putcurrencyString.trim().length >0){
        setState(() {
          _getPutMoneyCurrency = putcurrencyString;

        });
        //汇报入金币种
        reportPutMoneyCurrency();

        putMoneyCurrencyTime.cancel();
      }

    });
  }

  //汇报入金币种,请求后台
  reportPutMoneyCurrency(){
    //operation  0 确认支付  1 取消返回(券売機)　2 取消返回(精算機)
    var operation = 0;
    if(_isCancel == true){
      operation = (_machineMode == "1") ? 1 :2;
    }

    var formData = {
      "paymentInfo": this._getPutMoneyCurrency.trim(),
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "price": int.parse(this._getPutMoney),
      "operation" :operation,
    };
    request('webBootToReportV1', method: 'POST', parameters: formData).then((value) {
      var response = json.decode(value.toString());
      if (response['code'] == 200) {
        if(_isReportOutMoney == true){
          //已经结束入金，处理取引终了
          reportOutMoneyCurrency();
        }


      }
    }
    );


  }

  reportOutMoneyCurrency(){
    if(_giveChangeMoney>0){
      var formData = {
        "changeInfo": this._currencyString.trim(),
        "machineCode": _machineCode,
        "orderId": this._orderId,
        "price": _giveChangeMoney
      };
      request('webBootToReportV1', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200) {

        } else {

        }
      });
    }

  }

  _showEasyLoadingScan(){
    var _showTag;
    if(int.parse(this._showOutMoney) >0){
    //_showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_outprice_tag"),
        _showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_loading_tag"),
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));

    }else{
      _showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    }
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
          height: ScreenAdapter.height(480),
          padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            InkWell(
              onLongPress: (){
                ScanCodeConfirmTimer?.cancel();
                _doScanCodeTimeOutLastQuery();

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

  _showEasyLoading(){
    var _showTag;
    if(int.parse(this._showOutMoney) >0){
      //_showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_outprice_tag"),
      _showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));

    }else{
      _showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    }
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  _showSuccessEasyLoading(){
    var _showTag;

      _showTag = Text(GString.getToString(this._checkLanguage, "payment_success_title"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));

    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString("imgpublic", "paymentSuccess"),fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  _showBackEasyLoading(){
    var _showTag =Text(GString.getToString(this._checkLanguage, "settlement_noprint_tag"),
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

  }

  //券卖机展示购物车商品
  Widget getmachineModeOneOrderList(BuildContext context){
    return Container(
      width: ScreenAdapter.width(1030),
      height: ScreenAdapter.height(920),
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(15),
          top: ScreenAdapter.height(20),
          right: ScreenAdapter.width(15),
          bottom: ScreenAdapter.height(40)),
      child: GetBuilder<HomePageController>(
        builder: (_) {
          if (controller.cartItems.length == 0) {
            return Center(
              child: Text("No item found"),
            );
          }
          return ListView(
            shrinkWrap: true,
            children: controller.cartItems
                .map((d) => generateCartList(context, d))
                .toList(),
          );
        },
      ),
    );
  }

  //精算机订单列表
  Widget getmachineModeTwoOrderList(BuildContext context){
    return Container(
        width: ScreenAdapter.width(1030),
        height: ScreenAdapter.height(920),
        padding: EdgeInsets.only(
            left: ScreenAdapter.width(15),
            top: ScreenAdapter.height(20),
            right: ScreenAdapter.width(15),
            bottom: ScreenAdapter.height(40)),
        child: this._goodsList.length > 0
            ? ListView.builder(
          shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
          //physics: NeverScrollableScrollPhysics(), //禁用滑动事件
          itemCount: this._goodsList.length,
          //controller: _scrollController,
          itemBuilder: (context, index) {
            var item = _goodsList[index];
            return Container(
              padding: EdgeInsets.only(left:ScreenAdapter.width(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white12,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1.0),
                      //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[

                    Container(
                      padding: EdgeInsets.only(right: ScreenAdapter.width(10)),

                      width: ScreenAdapter.width(100),
                      height: ScreenAdapter.height(100),
                      child: publicShowMenuImage(item["homeImage"],ScreenAdapter.width(120),ScreenAdapter.height(120)),
                    ),
                    Expanded(
                        child: Container(
                          //padding: EdgeInsets.only(left: ScreenAdapter.width(5)),
                          //width: ScreenAdapter.width(495),
                          child: RichText(
                            text: TextSpan(
                                text: "${item["mainTitle"]}",
                                style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(GFontSize.cartListTitle),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                                children: [
                                  item["goodsNum"] > 1?TextSpan(
                                    text: " x ${item["goodsNum"].toString()}",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(
                                          GFontSize.cartListTitleCount),
                                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                    ),
                                  ):TextSpan(
                                    text: "",
                                  ),
                                  (item["optionVoListMsg"] != "") ?TextSpan(
                                    text: "\n(${item["optionVoListMsg"]})",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(GFontSize.cartListTitleTag),
                                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                    ),
                                  ):TextSpan(
                                    text: "",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(
                                          GFontSize.cartListTitleTag),
                                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                    ),
                                  ),
                                ]),
                          ),
                        )),
                    Container(
                      width: ScreenAdapter.width(140),
                      alignment: Alignment.centerRight,
                      child: Text(
                        "￥ ${formatMoney((item["goodsNum"]*item["goodsPrice"])).toString()}",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(GFontSize.mainPriceRight),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : Center(child: Text("No item found"),));
  }

  //公共展示菜品图片
  publicShowMenuImage(imgPath, imgWidth, imgHeight) {
    _checkMemory();

    return Container(
      width: ScreenAdapter.width(imgWidth),
      height: ScreenAdapter.height(imgHeight),

      child: CachedNetworkImage(
        imageUrl: imgPath,
        //fit: BoxFit.cover,
        width: ScreenAdapter.width(imgWidth),
        height: ScreenAdapter.height(imgHeight),
        memCacheWidth: imgWidth.toInt(),
        memCacheHeight: imgHeight.toInt(),
        //cacheManager: EsoImageCacheManager(),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: imageProvider,
                //fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.colorBurn)
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          width: ScreenAdapter.width(200),
          height: ScreenAdapter.height(200),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.network(
            imgPath,
            //fit: BoxFit.cover,
            width: ScreenAdapter.width(imgWidth),
            height: ScreenAdapter.height(imgHeight)
        ),
      ),
    );
  }

  void _checkMemory(){
    var Image_Maxnum = 200;
    var maxSize = 55 << 20;

    ImageCache _imageCache = PaintingBinding.instance.imageCache;
    if(_imageCache.currentSizeBytes >= maxSize || _imageCache.currentSize >= Image_Maxnum){
      _imageCache.clear();
      _imageCache.clearLiveImages();
    }
  }


  //pos机相关
  payconnectSocker() async {
    Socket.connect(
      this._pos_ip,
      int.parse(this._pos_port),
      timeout: Duration(seconds: 5),
    ).then((Socket socket) {print("连接成功了么");
    this._socket = socket;
    //获得pos数据并发送
    _getPaymentPosData();
    // 监听wifi模块发送的数据
    this._socket.listen((List<int> event) {
      //print("监听返回打印");
      //print(event);
      print("\n\r================================\n\r");
      LogUtil.d(event);
      print("\n\r================================\n\r");
      if(event.length > 40)
        event.fillRange(266, 289, 32);
      var zhuanhuan = Uint8List.fromList(event);
      var eventString = Utf8Codec().decode(zhuanhuan);
      //print(Utf8Codec().decode(zhuanhuan));

      String FirstString = eventString.substring(0, 1);
      String SecondString = eventString.substring(1, 3);
      String resultString = eventString.substring(10, 13);
      String resultMPFSString = eventString.substring(13, 16);
      //LogUtil.d(utf8.decode(event));

      //机器端取消返回
      /*if(FirstString == "3" && SecondString == "11" && resultString =="L11"){
        //print("取消");
        CancelOrder();
      }*/
      //支付成功 打印，返回首页 除了成功都取消
      if(FirstString == "3" && SecondString == "11" && resultString =="000" && resultMPFSString =="000"){
        CreditCardPayReport(eventString);
      }else{
        CancelOrder();
      }




    });
    setState(() {
      _socketState = true;
    });



    }).catchError((e) {
      setState(() {
        _socketState = false;
      });
      print("Unable to connect: $e");
    });

    //获得pos数据并发送
    //_getPaymentPosData();
  }

  //刷卡机nfc支付汇报
  CreditCardPayReport(eventString){
    _showEasyLoading();
    var formData = {
      "auth_code":"0000000088888888",
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "payType": "CreditCard",
      "paymentInfo": eventString,
    };
    request('webBootToPay', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu("1");
      } else {
        //扫码后超时，再继续请求后台，1秒一次 20次
        //_doScanCodeTimeOut();
      }
    });
  }


  _getPaymentPosData(){
    //var _queryString =       "2101500001       00509                  000000120221114093225";
    //var _queryString = "2101500001       00509437520456035794944000010020221121142129                                                                       10                                                                                                                                                                                                                                                                                                                                                                                                                               ";
    //this._socket.write(_queryString);
    /*for(var i=0;i<71;i++){
      _queryString += " ";
    }
    _queryString += "10";
    for(var i=0;i<415;i++){
      _queryString += " ";
    }*/

    var formData = {
      "machineCode": _machineCode,
      "orderId": this._orderId,
    };

    request("webBootCreditCard", method: 'POST', parameters: formData).then((val) async {
      var response = json.decode(val.toString());
      if (response['code'] == 200) {
        //var _queryString =       "2101500001       00509                  000000120221114093225";
        this._socket.write(response['data']);

      }
    });
  }


  @override
  Widget build(BuildContext context) {
    var _settlement_payment_method = GString.getToString(this._checkLanguage, "settlement_payment_method");

    return Scaffold(
      backgroundColor: ColorsUtil.hexToColor("#FFFFFF"),
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 0,
              child: Row(
                children: <Widget>[
                  Expanded(child: TextField(
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
                    style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                    obscureText: false,
                    onChanged: (value) {
                      //print(value);

                    },
                    onSubmitted: (value){
                      setState(() {
                        this._scanQrCode = value;
                      });

                      _doToPay();
                    },

                    /// 扫码密码
                  )),
                ],
              ),
            ),
            Container(
              width: ScreenAdapter.getScreenWidth(),
              height: ScreenAdapter.height(95),
              //padding: EdgeInsets.only(right: ScreenAdapter.width(20)),
              //alignment: Alignment.bottomRight,
              //color: ColorsUtil.hexToColor("#000000"),
              /*decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#000000"),
                image: new DecorationImage(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.fitHeight,
                  image: AssetImage(GImage.getImageString(_shopInfo, "logo")),
                ),
              ),*/
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
                  if(_payment_method_num == "1")
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(GImage.getImageString("imgpublic", "settlement_top_cash"),width: ScreenAdapter.width(40),fit: BoxFit.fitWidth,),
                      SizedBox(width: ScreenAdapter.width(20),),
                      Text(GString.getToString(this._checkLanguage, "settlement_top_title_cash"),
                        style: TextStyle(
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenAdapter.fontSize(34.0)),
                      ),
                    ],
                  ),
                  if(_payment_method_num == "2")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(GImage.getImageString("imgpublic", "settlement_top_qr"),width: ScreenAdapter.width(40),fit: BoxFit.fitWidth,),
                        SizedBox(width: ScreenAdapter.width(20),),
                        Text(GString.getToString(this._checkLanguage, "settlement_top_title_qr"),
                          style: TextStyle(
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(34.0)),
                        ),
                      ],
                    ),
                  if(_payment_method_num == "3")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: (){
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(GImage.getImageString("imgpublic", "settlement_top_card"),width: ScreenAdapter.width(40),fit: BoxFit.fitWidth,),
                          SizedBox(width: ScreenAdapter.width(20),),
                          Text(GString.getToString(this._checkLanguage, "settlement_top_title_card"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                  if(_payment_method_num == "4")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: (){
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(GImage.getImageString("imgpublic", "settlement_top_nfc"),width: ScreenAdapter.width(40),fit: BoxFit.fitWidth,),
                          SizedBox(width: ScreenAdapter.width(20),),
                          Text(GString.getToString(this._checkLanguage, "settlement_top_title_nfc"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),



                  /*InkWell(
                    onTap: (){
                      _showBackEasyLoading();
                      //sleep(Duration(milliseconds: 800));
                      CancelOrder();
                    },
                    child: Container(
                      width: ScreenAdapter.width(180),
                      height: ScreenAdapter.height(65),
                      margin: EdgeInsets.only(top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(10)),
                      //spadding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                          image: AssetImage(GImage.getImageString("imgpublic", "settlement_back")),
                        ),
                      ),
                      child: Text(GString.getToString(this._checkLanguage, "settlement_back"),
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(30),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                          )),
                    ),
                  ),*/

                ],
              ),
            ),

            //顶部支持支付类型
            /*Container(
              height: ScreenAdapter.height(240),
              padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(10),right: ScreenAdapter.width(20),  bottom: ScreenAdapter.height(10)),
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_settlement_payment_method,
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(32),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                      )),
                  SizedBox(height: ScreenAdapter.height(25),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(50), right: ScreenAdapter.width(50)),
                          //padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(5), right: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset(GImage.getImageString("imgpublic", "settlement_cash"),
                                  width: ScreenAdapter.width(85),
                                  height: ScreenAdapter.height(85)),
                              SizedBox(height: ScreenAdapter.height(5)),
                              Text(GString.getToString(this._checkLanguage, "settlement_payment_method_cash"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                  )),
                            ],
                          )),
                      if(_showPayPay == true)
                        Container(
                            margin: EdgeInsets.only(left: ScreenAdapter.width(50), right: ScreenAdapter.width(50)),
                            width: ScreenAdapter.width(130),
                            height: ScreenAdapter.height(140),
                            child: Column(
                              children: [
                                Image.asset(GImage.getImageString("imgpublic", "settlement_paypay"),
                                    width: ScreenAdapter.width(85),
                                    height: ScreenAdapter.height(85)),
                                SizedBox(height: ScreenAdapter.height(5)),
                                Text(GString.getToString(this._checkLanguage, "settlement_payment_method_paypay"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(18),
                                      fontWeight: FontWeight.w500,
                                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                    )),
                              ],
                            )),
                      if(_showWechat == true)
                        Container(
                            margin: EdgeInsets.only(left: ScreenAdapter.width(50), right: ScreenAdapter.width(50)),
                            width: ScreenAdapter.width(130),
                            height: ScreenAdapter.height(140),
                            child: Column(
                              children: [
                                Image.asset(
                                    GImage.getImageString("imgpublic", "settlement_wechat"),
                                    width: ScreenAdapter.width(85),
                                    height: ScreenAdapter.height(85)
                                ),
                                SizedBox(height: ScreenAdapter.height(5)),
                                Text(GString.getToString(this._checkLanguage, "settlement_payment_method_wechat"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(18),
                                      fontWeight: FontWeight.w500,
                                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                    )),
                              ],
                            )),
                      if(_showAlipay == true)
                        Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(50), right: ScreenAdapter.width(50)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset(GImage.getImageString("imgpublic", "settlement_alipay"),
                                  width: ScreenAdapter.width(85),
                                  height: ScreenAdapter.height(85)),
                              SizedBox(height: ScreenAdapter.height(5)),
                              Text(GString.getToString(this._checkLanguage, "settlement_payment_method_alipay"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                  )),
                            ],
                          )),
                      if(_showIsPos == true)
                        Container(
                            margin: EdgeInsets.only(left: ScreenAdapter.width(50), right: ScreenAdapter.width(50)),
                            width: ScreenAdapter.width(130),
                            height: ScreenAdapter.height(140),
                            child: Column(
                              children: [
                                Image.asset(GImage.getImageString("imgpublic", "settlement_alipay"),
                                    width: ScreenAdapter.width(85),
                                    height: ScreenAdapter.height(85)),
                                SizedBox(height: ScreenAdapter.height(5)),
                                Text(GString.getToString(this._checkLanguage, "settlement_payment_method_alipay"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(18),
                                      fontWeight: FontWeight.w500,
                                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                    )),
                              ],
                            )),

                    ],
                  ),

                ],
              ),
            ),*/
            if(_payment_method_num == "1")
            Container(
              //height: ScreenAdapter.height(940),
            child: Image.asset(GImage.getImageString("imgpublic", "settlement_top_lead_cash_${_checkLanguage}"),width: ScreenAdapter.width(1080),fit: BoxFit.fitWidth,),
            ),
            if(_payment_method_num == "2")
              Container(
                //height: ScreenAdapter.height(940),
                child: Image.asset(GImage.getImageString("imgpublic", "settlement_top_lead_qr"),width: ScreenAdapter.width(1080),fit: BoxFit.fitWidth,),
              ),
            if(_payment_method_num == "3")
              Container(
                //height: ScreenAdapter.height(940),
                child: Image.asset(GImage.getImageString("imgpublic", "settlement_top_lead_card_${_checkLanguage}"),width: ScreenAdapter.width(1080),fit: BoxFit.fitWidth,),
              ),
            if(_payment_method_num == "4")
              Container(
                //height: ScreenAdapter.height(940),
                child: Image.asset(GImage.getImageString("imgpublic", "settlement_top_lead_nfc_${_checkLanguage}"),width: ScreenAdapter.width(1080),fit: BoxFit.fitWidth,),
              ),
            Container(
              height: ScreenAdapter.height(5),
              color: ColorsUtil.hexToColor("#D8D8D8"),
            ),
            /*Divider(
              height: ScreenAdapter.height(5), // Divider 组件高度
              color: ColorsUtil.hexToColor("#F5F5F5"), // 分割线颜色
            ),*/
            //选择结算方式
            /*Container(
              //height: ScreenAdapter.height(750),
              padding: EdgeInsets.only(
                left: ScreenAdapter.width(20),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(20),
                bottom: ScreenAdapter.height(5),
              ),
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(10),
                        bottom: ScreenAdapter.height(5)),
                    alignment: Alignment.centerLeft,
                    child: Text(GString.getToString(this._checkLanguage, "settlement_payment_method_title"),
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(32),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(Gcolor.settlementTitleColor),
                        )),
                  ),
                  *//*SizedBox(
                    height: ScreenAdapter.height(10),
                  ),*//*
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            bottom: ScreenAdapter.height(20)),
                        width: ScreenAdapter.width(400),
                        //height: ScreenAdapter.height(620),
                        alignment: Alignment.center,
                        child: Container(
                            //width: ScreenAdapter.width(280),
                            height: ScreenAdapter.height(300),
                            child: Image.asset(GImage.getImageString("imgpublic", "xianjin"),fit: BoxFit.fitHeight,)),
                      ),
                      SizedBox(
                        width: ScreenAdapter.width(30),
                      ),
                      if(_showWechat == true || _showAlipay == true || _showPayPay == true)
                      Container(
                        padding: EdgeInsets.only(
                            bottom: ScreenAdapter.height(20)),
                        width: ScreenAdapter.width(400),
                        //height: ScreenAdapter.height(580),
                        alignment: Alignment.center,
                        child: Container(
                          //width: ScreenAdapter.width(280),
                            height: ScreenAdapter.height(300),
                            child: Image.asset(
                                GImage.getImageString("imgpublic", "saoma"),fit: BoxFit.fitHeight,)),
                      ),





                    ],
                  ),

                ],
              ),
            ),
            SizedBox(
              height: ScreenAdapter.height(8),
            ),*/

           /* Container(
              //width: ScreenAdapter.width(240),
              height: ScreenAdapter.height(220),
              // margin: EdgeInsets.only(left: ScreenAdapter.width(60),top: ScreenAdapter.width(50)),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(20),
                  top: ScreenAdapter.height(15),
                  right: ScreenAdapter.width(20),
                  bottom: ScreenAdapter.height(10)
              ),
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              alignment: Alignment.center,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: ScreenAdapter.height(15),
                      left: ScreenAdapter.width(30),
                      bottom: ScreenAdapter.height(16),
                      right: ScreenAdapter.width(30),
                    ),
                    width: ScreenAdapter.width(260),
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(GString.getToString(this._checkLanguage, "settlement_orderPrice"),
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(25),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white12,
                              border: Border(
                                bottom: BorderSide(color: Colors.black, width: 1.5),
                                //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                              )),
                          child: RichText(
                            text: TextSpan(
                                text: formatMoney(this._totalPrice),//GString.getToString(this._checkLanguage, "show_price_front"),
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(52),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#9A5718"),
                                ),
                                children: [
                                  TextSpan(
                                    text: " 円",//" 円",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(28),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor("#000000"),
                                    ),
                                  ),
                                ]),
                          ),
                        ),

                      ],
                    ),
                  ),
                  //垂直分割线
                  SizedBox(
                    width: 1,
                    height: ScreenAdapter.height(180),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black12),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(10),
                        right: ScreenAdapter.width(20),
                        bottom: ScreenAdapter.height(10)
                    ),
                    width: ScreenAdapter.width(375),
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      //所有列宽
                      columnWidths: {
                        //列宽
                        0: FixedColumnWidth(ScreenAdapter.width(145)),
                        1: FixedColumnWidth(ScreenAdapter.width(230)),
                      },
                      children: [
                        TableRow(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(GString.getToString(this._checkLanguage, "settlement_putMoney"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(25),
                                    fontWeight: FontWeight.w600,
                                    color: (int.parse(this._getPutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                  )),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                  color: Colors.white12,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black, width: 1.5),
                                    //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                                  )),
                              child: RichText(
                                text: TextSpan(
                                    text: formatMoney(this._getPutMoney),//" 円",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(52),
                                      fontWeight: FontWeight.w600,
                                      color: (int.parse(this._getPutMoney) >0) ? ColorsUtil.hexToColor("#FF0000"):ColorsUtil.hexToColor("#808080"),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: " 円",//" 円",
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(28),
                                          fontWeight: FontWeight.w600,
                                          color: (int.parse(this._getPutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),

                          ],
                        ),
                        TableRow(
                          children: [

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(GString.getToString(this._checkLanguage, "settlement_outMoney"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(25),
                                    fontWeight: FontWeight.w600,
                                    color: (int.parse(this._showOutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                  )),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                  color: Colors.white12,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black, width: 1.5),
                                    //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                                  )),
                              child: RichText(
                                text: TextSpan(
                                    text: formatMoney(this._showOutMoney),//" 円",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(52),
                                      fontWeight: FontWeight.w600,
                                      color: (int.parse(this._showOutMoney) >0) ? ColorsUtil.hexToColor("#008000"):ColorsUtil.hexToColor("#808080"),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: " 円",//" 円",
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(28),
                                          fontWeight: FontWeight.w600,
                                          color: (int.parse(this._showOutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),


                          ],
                        ),

                      ],
                    ),


                  ),

                  _showPrintButton == true ?
                  _is_allow_receipt == "1" ? InkWell(
                    onTap: (){
                      if(_allowClick == true){
                        setState(() {
                          _allowClick = false;
                        });

                        _showEasyLoading();

                        //Endtoubi();
                        doPrintOrderMenu();
                      }

                    },
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                      width: ScreenAdapter.width(260),
                      height: ScreenAdapter.height(130),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#148DE8"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(GString.getToString(this._checkLanguage, "settlement_confirmButton"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(32),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                              )),
                          *//*Text(GString.getToString(this._checkLanguage, "settlement_confirmButton_yes"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(20),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                              )),*//*
                        ],
                      ),
                    ),
                  ):
                  Column(
                    children: [
                      InkWell(
                        onTap: (){
                          if(_allowClick == true){
                            setState(() {
                              _allowClick = false;
                            });

                            _showEasyLoading();

                            //Endtoubi();
                            doPrintOrderMenu();
                          }

                        },
                        child: Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(260),
                          height: ScreenAdapter.height(100),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#148DE8"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((16.0)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(GString.getToString(this._checkLanguage, "settlement_confirmButton"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(32),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                  )),
                              Text(GString.getToString(this._checkLanguage, "settlement_confirmButton_yes"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenAdapter.height(8)),
                      InkWell(
                        onTap: (){
                          if(_allowClick == true){
                            setState(() {
                              _allowClick = false;
                              _is_query_receipt = "2";
                            });

                            _showEasyLoading();

                            //Endtoubi();
                            doPrintOrderMenu();
                          }

                        },
                        child: Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(260),
                          height: ScreenAdapter.height(100),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#67c23a"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((16.0)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(GString.getToString(this._checkLanguage, "settlement_confirmButton"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(32),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                  )),
                              Text(GString.getToString(this._checkLanguage, "settlement_confirmButton_no"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ) : Container(
                    margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                    width: ScreenAdapter.width(260),
                    height: ScreenAdapter.height(120),
                  ),
                ],
              ),
            ),*/
            Expanded(
              child: Container(
                //width: ScreenAdapter.width(240),
                //height: ScreenAdapter.height(220),
                // margin: EdgeInsets.only(left: ScreenAdapter.width(60),top: ScreenAdapter.width(50)),
                padding: EdgeInsets.only(
                    left: ScreenAdapter.width(200),
                    top: ScreenAdapter.height(35),
                    right: ScreenAdapter.width(200),
                    bottom: ScreenAdapter.height(10)
                ),
                color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
                alignment: Alignment.center,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: ScreenAdapter.height(15),
                        bottom: ScreenAdapter.height(15),
                      ),
                      padding: EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: ColorsUtil.hexToColor("#D8D8D8"), width: 2.5),
                            //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                          )),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(GString.getToString(this._checkLanguage, "settlement_orderPrice"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(32),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              )),
                          SizedBox(height: ScreenAdapter.height(10)),
                          Container(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                  text: formatMoney(this._totalPrice),//GString.getToString(this._checkLanguage, "show_price_front"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(52),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#9A5718"),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " 円",//" 円",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(28),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor("#000000"),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),

                        ],
                      ),
                    ),
                    if(_payment_method_num == "1")
                    Container(
                      margin: EdgeInsets.only(
                        top: ScreenAdapter.height(15),
                        bottom: ScreenAdapter.height(15),
                      ),
                      padding: EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: ColorsUtil.hexToColor("#D8D8D8"), width: 2.5),
                            //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                          )),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(GString.getToString(this._checkLanguage, "settlement_putMoney"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(32),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              )),
                          SizedBox(height: ScreenAdapter.height(10)),
                          Container(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                  text: formatMoney(this._getPutMoney),//" 円",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(52),
                                    fontWeight: FontWeight.w600,
                                    color: (int.parse(this._getPutMoney) >0) ? ColorsUtil.hexToColor("#FF0000"):ColorsUtil.hexToColor("#808080"),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " 円",//" 円",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(28),
                                        fontWeight: FontWeight.w600,
                                        color: (int.parse(this._getPutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),

                        ],
                      ),
                    ),
                    if(_payment_method_num == "1")
                    Container(
                      margin: EdgeInsets.only(
                        top: ScreenAdapter.height(15),
                        bottom: ScreenAdapter.height(15),
                      ),
                      padding: EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: ColorsUtil.hexToColor("#D8D8D8"), width: 2.5),
                            //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                          )),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(GString.getToString(this._checkLanguage, "settlement_outMoney"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(32),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              )),
                          SizedBox(height: ScreenAdapter.height(10)),
                          Container(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                  text: formatMoney(this._showOutMoney),//" 円",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(52),
                                    fontWeight: FontWeight.w600,
                                    color: (int.parse(this._showOutMoney) >0) ? ColorsUtil.hexToColor("#008000"):ColorsUtil.hexToColor("#808080"),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " 円",//" 円",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(28),
                                        fontWeight: FontWeight.w600,
                                        color: (int.parse(this._showOutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),

                        ],
                      ),
                    ),
                    //垂直分割线
                    /*SizedBox(
                      width: 1,
                      height: ScreenAdapter.height(180),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black12),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: ScreenAdapter.width(15),
                          top: ScreenAdapter.height(10),
                          right: ScreenAdapter.width(20),
                          bottom: ScreenAdapter.height(10)
                      ),
                      width: ScreenAdapter.width(375),
                      child: Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        //所有列宽
                        columnWidths: {
                          //列宽
                          0: FixedColumnWidth(ScreenAdapter.width(145)),
                          1: FixedColumnWidth(ScreenAdapter.width(230)),
                        },
                        children: [
                          TableRow(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(GString.getToString(this._checkLanguage, "settlement_putMoney"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(25),
                                      fontWeight: FontWeight.w600,
                                      color: (int.parse(this._getPutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                    )),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                    color: Colors.white12,
                                    border: Border(
                                      bottom: BorderSide(color: Colors.black, width: 1.5),
                                      //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                                    )),
                                child: RichText(
                                  text: TextSpan(
                                      text: formatMoney(this._getPutMoney),//" 円",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(52),
                                        fontWeight: FontWeight.w600,
                                        color: (int.parse(this._getPutMoney) >0) ? ColorsUtil.hexToColor("#FF0000"):ColorsUtil.hexToColor("#808080"),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: " 円",//" 円",
                                          style: TextStyle(
                                            fontSize: ScreenAdapter.fontSize(28),
                                            fontWeight: FontWeight.w600,
                                            color: (int.parse(this._getPutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),

                            ],
                          ),
                          TableRow(
                            children: [

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(GString.getToString(this._checkLanguage, "settlement_outMoney"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(25),
                                      fontWeight: FontWeight.w600,
                                      color: (int.parse(this._showOutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                    )),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                    color: Colors.white12,
                                    border: Border(
                                      bottom: BorderSide(color: Colors.black, width: 1.5),
                                      //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                                    )),
                                child: RichText(
                                  text: TextSpan(
                                      text: formatMoney(this._showOutMoney),//" 円",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(52),
                                        fontWeight: FontWeight.w600,
                                        color: (int.parse(this._showOutMoney) >0) ? ColorsUtil.hexToColor("#008000"):ColorsUtil.hexToColor("#808080"),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: " 円",//" 円",
                                          style: TextStyle(
                                            fontSize: ScreenAdapter.fontSize(28),
                                            fontWeight: FontWeight.w600,
                                            color: (int.parse(this._showOutMoney) >0) ? ColorsUtil.hexToColor(Gcolor.mainTitleColor):ColorsUtil.hexToColor("#808080"),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),


                            ],
                          ),

                        ],
                      ),


                    ),*/
                  ],
                ),
              ),
            ),
            if(_payment_method_num == "0" || _payment_method_num == "1")
              Container(
                //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                height: ScreenAdapter.height(200),
                color: ColorsUtil.hexToColor("#DCDCDC"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: ScreenAdapter.width(440),
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: (){
                          try {
                            //Navigator.pop(context);
                            _showBackEasyLoading();
                            CancelOrder();
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
                    ),
                    SizedBox(width: ScreenAdapter.width(80)),
                    _showPrintButton == true ?
                    _is_allow_receipt == "1" ? Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                      width: ScreenAdapter.width(540),
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: (){
                          if(_allowClick == true){
                            setState(() {
                              _allowClick = false;
                            });

                            _showEasyLoading();

                            //Endtoubi();
                            doPrintOrderMenu("1");
                          }

                        },
                        child: Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(270),
                          height: ScreenAdapter.height(140),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(

                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                ColorsUtil.hexToColor("#C47829"),
                                ColorsUtil.hexToColor("#854610"),
                              ],
                            ),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((5.0)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(GString.getToString(this._checkLanguage, "settlement_confirmButton"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(32),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ):
                    Container(
                      width: ScreenAdapter.width(540),
                      margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: (){
                              if(_allowClick == true){
                                setState(() {
                                  _allowClick = false;
                                });

                                _showEasyLoading();

                                //Endtoubi();
                                doPrintOrderMenu("1");
                              }

                            },
                            child: Container(
                              //margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                              width: ScreenAdapter.width(220),
                              height: ScreenAdapter.height(140),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorsUtil.hexToColor("#148DE8"),
                                //设置圆角
                                borderRadius: new BorderRadius.circular((5.0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(GString.getToString(this._checkLanguage, "settlement_confirmButton"),
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(32),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                      )),
                                  Text(GString.getToString(this._checkLanguage, "settlement_confirmButton_yes"),
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(20),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenAdapter.width(30)),
                          InkWell(
                            onTap: (){
                              if(_allowClick == true){
                                setState(() {
                                  _allowClick = false;
                                  _is_query_receipt = "2";
                                });

                                if(_machineMode == "1"){
                                  _showEasyLoading();
                                }else{
                                  _showSuccessEasyLoading();
                                }

                                //Endtoubi();
                                doPrintOrderMenu("2");
                              }

                            },
                            child: Container(
                              margin: EdgeInsets.only(left: ScreenAdapter.width(10)),
                              width: ScreenAdapter.width(220),
                              height: ScreenAdapter.height(140),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorsUtil.hexToColor("#67c23a"),
                                //设置圆角
                                borderRadius: new BorderRadius.circular((5.0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(GString.getToString(this._checkLanguage, "settlement_confirmButton"),
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(32),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                      )),
                                  Text(GString.getToString(this._checkLanguage, "settlement_confirmButton_no"),
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(20),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) : Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                      width: ScreenAdapter.width(540),
                      height: ScreenAdapter.height(100),
                    ),
                  ],
                ),
              ),
            if(_payment_method_num == "2")
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
                          //Navigator.pop(context);
                          CancelOrder();
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
                          "戻る",
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
            /*SizedBox(
              height: ScreenAdapter.height(8),
            ),
            Expanded(
              child: Container(
                width: ScreenAdapter.width(1080),
                padding: EdgeInsets.only(left: ScreenAdapter.width(10), right: ScreenAdapter.width(10)),
                alignment: Alignment.topCenter,
                color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: (_machineMode == "1") ?getmachineModeOneOrderList(context):getmachineModeTwoOrderList(context),
                  ),
                ),

              ),

            ),*/

          ],
        ),
      ),
    );
  }
}
