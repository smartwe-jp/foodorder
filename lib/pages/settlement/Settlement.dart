import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:foodorder/pages/settlement/receipt_constrained_box.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' hide Image;
import 'package:paycube/paycube.dart';
import 'package:foodorder/services/Storage.dart';
import 'package:widget_to_image/widget_to_image.dart';

import 'package:foodorder/services/logUtil.dart';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

import 'package:foodorder/services/queue_util.dart';

import '../../config/printer_info.dart';
import '../../widget/NumberCircle.dart';
import 'label_constrained_box.dart';

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

  var _is_query_receipt = "1"; //1 要领収书  2 不要领収书
  var _is_allow_receipt = "1"; //1 必须打印  2 不必须
  var _print_paper_txt_size = "1";//1普通　2大　3特大
  var _is_back_home = "0"; //0 返回home  1 返回菜单

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

  var _ticketData = null;
  var _isReportOutMoney = false; //新处理 默认不汇报出金信息  先汇报入金信息在汇报出金信息
  var _isCancel = false; //新增加  取消默认为false

  //顶部展示支付类型
  var _showWechat = false;
  var _showAlipay = false;
  var _showPayPay = false;
  var _showCreditCard = false;

  var _showauPay = false;
  var _showdPay = false;
  var _showrPay = false;
  var _showmPay = false;

  //用于控制返回是否多关闭页面
  var _showOpenPayment = false;

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

  //后台返回是否可以使用pos刷卡机，如果后台可以使用，并且券卖机设置里面也设置开启并设置好ip，则展示图标及请求pos支付的相关数据
  var _showIsPos = true;

  var _machineMode = "1"; //机器类型 1普通券卖机 2精算机
  var _goodsList = [];

  //支付类型相关
  Socket _socket; //socket对象
  bool _socketState = false; //连接状态
  var _isAllowPos = "0";
  var _wlan_print_ip = "";
  var _wlan_print_port = "";
  var _showPrintType =0; //0 receipt   1Lable
  var _wlan_print_ip_two = "";
  var _wlan_print_port_two = "";
  var _pos_ip = "";
  var _pos_port = "";
  var _payment_method_num = "0"; //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc
  var _posResultReportData = {};

  var _printLogoImage = "";

  //60秒内未接收现金机正确通知，则进行下一步操作
  Timer showCashTimer;
  int seconds = 60;

  @override
  void initState() {
    super.initState();

    this._checkLanguage = widget.arguments['checkLanguage'];
    this._machineCode = widget.arguments['machineCode'];
    this._orderId = widget.arguments['orderId'];
    //this._machineMode = widget.arguments['machineMode'];
    this._totalPrice = widget.arguments['totalPrice'];
    this._isAllowPos = widget.arguments['isAllowPos'];
    this._pos_ip = widget.arguments['posIp'];
    this._pos_port = widget.arguments['posPort'];
    this._payment_method_num = widget.arguments['paymentMethod'];

    this._showWechat = widget.arguments['showWechat'];
    this._showAlipay = widget.arguments['showAlipay'];
    this._showPayPay = widget.arguments['showPayPay'];
    this._showCreditCard = widget.arguments['showCreditCard'];

    this._showauPay = widget.arguments['showauPay'];
    this._showdPay = widget.arguments['showdPay'];
    this._showrPay = widget.arguments['showrPay'];
    this._showmPay = widget.arguments['showmPay'];
    this._showPosEdy = widget.arguments['showPosEdy'];
    this._showPosiD = widget.arguments['showPosiD'];
    this._showPosIC = widget.arguments['showPosIC'];
    this._showPosQUICPay = widget.arguments['showPosQUICPay'];
    this._showPosWAON = widget.arguments['showPosWAON'];
    this._showPosnanaco = widget.arguments['showPosnanaco'];

    this._showVisa = widget.arguments["showVisa"];
    this._showMaster = widget.arguments["showMaster"];
    this._showJcb = widget.arguments["showJcb"];
    this._showUnionPay = widget.arguments["showUnionPay"];
    this._showAmericanExpress = widget.arguments["showAmericanExpress"];
    this._showDinersClub = widget.arguments["showDinersClub"];

    this._showOpenPayment = widget.arguments['showOpenPayment'];

    _getSystemSettingInfo();

    Future.delayed(const Duration(),
            () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    //0 1适用之前旧版本，可适用现金机，同时也可以扫码  2只可扫码，不在打开现金机 3、4只支持刷卡，不在打开现金机
    if (_payment_method_num == "0" || _payment_method_num == "1") {
      //打开现金机
      _countDownTimer("1");
      Starttoubi();
    } else if (_payment_method_num == "2") {
      //检测是否需要连接socket
      checkpayconnectSocker();
    } else if (_payment_method_num == "3" ||
        _payment_method_num == "4" ||
        _payment_method_num == "5" ||
        _payment_method_num == "6" ||
        _payment_method_num == "7" ||
        _payment_method_num == "8" ||
        _payment_method_num == "9" ||
        _payment_method_num == "10"
    ) {
      //1链接socker 2 请求接口获得支付数据发送给pos机 3监听
      if(this._pos_ip != "" && this._pos_port != ""){
        payconnectSocker();
      }
      //payconnectSocker();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (this._socketState) {
      this._socket.close();
    }
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
    showCashTimer?.cancel();
    eventBus.fire(new PayCubeEvent('支付成功...'));
    //eventBus.fire(new clearCartEvent('支付成功...'));

    super.dispose();
  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    print(systemSettingInfo);
    setState(() {
      _is_allow_receipt = systemSettingInfo['isAllowReceipt'];
      _print_paper_txt_size = systemSettingInfo['printPaperTxtSize'];
      _is_back_home = systemSettingInfo['isAllowBackHome'];
      //新版精算模式也可点外带
      _machineMode = systemSettingInfo['machineMode'];
      _showPrintType = int.parse(systemSettingInfo['showPrintType']); //0 receipt   1Lable
    });
    if(systemSettingInfo['isAllowWlanPrint'] == "1"){
      Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
      if(wlanPrintSettingInfo['wlanPrintIp'] !=null && wlanPrintSettingInfo['wlanPrintIp'] !="" && wlanPrintSettingInfo['wlanPrintPort'] !=null && wlanPrintSettingInfo['wlanPrintPort'] !=""){
        _wlan_print_ip = wlanPrintSettingInfo['wlanPrintIp'];
        _wlan_print_port = wlanPrintSettingInfo['wlanPrintPort'];
      }
    }

    if(systemSettingInfo['isAllowWlanPrintTwo'] == "1"){
      Map wlanPrintSettingTwoInfo = await HomeServices.getWlanPrintSettingTwoInfo();
      if(wlanPrintSettingTwoInfo['wlanPrintIp'] !=null && wlanPrintSettingTwoInfo['wlanPrintIp'] !="" && wlanPrintSettingTwoInfo['wlanPrintPort'] !=null && wlanPrintSettingTwoInfo['wlanPrintPort'] !=""){
        _wlan_print_ip_two = wlanPrintSettingTwoInfo['wlanPrintIp'];
        _wlan_print_port_two = wlanPrintSettingTwoInfo['wlanPrintPort'];
      }
    }


    _getPrintLogoImageData();
  }

  _getPrintLogoImageData() async {
    String logoImageInfo = await HomeServices.getSmartweLogoImagesData();
    if(logoImageInfo != "" && logoImageInfo != null){
      setState(() {
        _printLogoImage = logoImageInfo;
      });
    }
  }

//倒计时
  _countDownTimer(stepState) {
    showCashTimer?.cancel();
    showCashTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      //if(mounted) {
      setState(() {
        this.seconds--;
      });
      //}
      if (this.seconds == 0) {
        //如果60秒未接收返回正确通知，则进行下一步操作
        eventBus.fire(new setShowCashEvent('支付成功...'));
        showCashTimer?.cancel(); //清除定时器
        if (stepState == "1") {
          gotonewMenuPage();
        } else {
          gotonewMyhome();
        }
      }
    });
  }

  checkpayconnectSocker() async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();
    var showCreditCard = systemSettingInfo['showCreditCard'];
    if(showCreditCard == true){
      Map posSettingInfo = await HomeServices.getPosSettingInfo();

      if(posSettingInfo.isNotEmpty){
        setState(() {
          _pos_ip = posSettingInfo['posIp'];
          _pos_port = posSettingInfo['posPort'];
        });
        if(_pos_ip != "" && _pos_port != ""){
          payconnectSocker();
        }

      }
    }
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
                  Text(
                      GString.getToString(
                          this._checkLanguage, "settlement_total_price"),
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.menusettlementHeji),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor))),
                  Text('￥ ${getItemTotal(controller.cartItems).toString()} ',
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.menusettlementHeji),
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
                      onChanged: (value) {
                        checkboxSelected = !checkboxSelected;

                        setState(() {});
                      }),
                  Text(
                      GString.getToString(
                          this._checkLanguage, "settlement_small_ticket_tag"),
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.menusettlementLingshoushu),
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
                          d.goodsNum > 1
                              ? TextSpan(
                            text: " x ${d.goodsNum}",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.cartListTitleCount),
                              color: ColorsUtil.hexToColor(
                                  Gcolor.mainTitleColor),
                            ),
                          )
                              : TextSpan(
                            text: "",
                          ),
                          (d.optionVoListMsg != "")
                              ? TextSpan(
                            text: "（${d.optionVoListMsg}）",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.cartListTitleTag),
                              color: ColorsUtil.hexToColor(
                                  Gcolor.mainTitleColor),
                            ),
                          )
                              : TextSpan(
                            text: "",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.cartListTitleTag),
                              color: ColorsUtil.hexToColor(
                                  Gcolor.mainTitleColor),
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
  _doToPay() {
    //不是扫码支付直接return
    if (_payment_method_num != "2") return;

    if (_showWechat == false && _showAlipay == false && _showPayPay == false) {
      _showScanCodeNoOpenDialog(1,"");
      return;
    }

    var _regExpWechat = r"^1[0-5]\d{16}$";
    var _regExpAlipay = r"^(?:2[5-9]|30)\d{14,22}$";
    if (RegExp(_regExpWechat).hasMatch(_scanQrCode) == true &&
        _showWechat == false) {
      _showScanCodeNoOpenDialog(2,"");
      return;
    } else if (RegExp(_regExpAlipay).hasMatch(_scanQrCode) == true &&
        _showAlipay == false) {
      _showScanCodeNoOpenDialog(2,"");
      return;
    } else {
      if (RegExp(_regExpWechat).hasMatch(_scanQrCode) == false &&
          RegExp(_regExpAlipay).hasMatch(_scanQrCode) == false &&
          _showPayPay == false) {
        _showScanCodeNoOpenDialog(2,"");
        return;
      }
    }

    if (_machineCode != "" && _scanQrCode != "" && _orderId != null) {
      //_showEasyLoading();
      _showEasyLoadingScan();
      var formData = {
        "auth_code": this._scanQrCode,
        "machineCode": _machineCode,
        "orderId": this._orderId,
        "payType":"",
      };//print(formData);
      request('webBootToPayv2', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());//print(response);
        //LogUtil.d(response);
        if (response['code'] == 200 && response['data'].isNotEmpty) {
          var resultData = response['data'];
          if(resultData["requestInfo"] != ""){
            if(resultData["exceptionMessage"] == ""){
              _posResultReportData = response['data'];
              //判断不为空则POS机
              this._socket.write(resultData["requestInfo"]);
            }else{
              _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
            }
          }else{
            if(resultData["result"] == true){
              doPrintOrderMenu("1");
            }else{
              _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
            }
          }

        } else {
          //扫码后超时，再继续请求后台，1秒一次 20次
          _doScanCodeTimeOut();
        }

      });

    }
  }

  //三种扫码支付都未开通，弹出dialog
  _showScanCodeNoOpenDialog(checknum, showContent) {
    EasyLoading.dismiss();
    setState(() {
      _scanQrCodeController.text = "";
      _scanQrCode = "";
      FocusScope.of(context).requestFocus(_scanQrCodeFocusNode); // 获取焦点
    });

    var show_dialog_content;

    if (checknum == 1) {
      show_dialog_content = GString.getToString(
          this._checkLanguage, "settlement_scancodenoopen_error");
    } else if (checknum == 2) {
      show_dialog_content = GString.getToString(
          this._checkLanguage, "settlement_scancodenochange_error");
    } else if (checknum == 3) {
      show_dialog_content = showContent;
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
                    child: Text(
                        GString.getToString(this._checkLanguage, "tag_title"),
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(28),
                            fontWeight: FontWeight.w600))),
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
                              style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(28))),
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
                                GString.getToString(this._checkLanguage,
                                    "tag_button_yes"),
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
                ]),
          );
        });
  }

  //扫码后超时，再继续请求后台，5秒一次 60次
  _doScanCodeTimeOut() {
    int queryCount = 0;
    ScanCodeConfirmTimer?.cancel();
    ScanCodeConfirmTimer = Timer.periodic(Duration(milliseconds: 5000),
            (Timer ConfirmTimer) async {
          queryCount++;
          if (queryCount > 60) {
            //退出关闭
            ConfirmTimer?.cancel();
            _showScanCodeTimeOutDialog();
          }

          var formData = {
            "orderId": this._orderId,
          };
          request('webBootLinePayConfirm', method: 'POST', parameters: formData)
              .then((val) {
            var response = json.decode(val.toString());

            if (response['code'] == 200 && response['data'] == true) {
              //退出关闭
              ConfirmTimer?.cancel();
              doPrintOrderMenu("1");
            }
          });
        });
  }

  _doScanCodeTimeOutLastQuery() {
    var formData = {
      "orderId": this._orderId,
    };
    request('webBootLinePayConfirm', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu("1");
      } else {
        _showScanCodeTimeOutDialog();
      }
    });
  }

  //扫码超时请求20次后依然失败，弹出dialog
  _showScanCodeTimeOutDialog() {
    EasyLoading.dismiss();
    setState(() {
      _scanQrCodeController.text = "";
      _scanQrCode = "";
      FocusScope.of(context).requestFocus(_scanQrCodeFocusNode); // 获取焦点
    });

    var show_dialog_content =
    GString.getToString(this._checkLanguage, "settlement_nopayment_error");

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
                    child: Text(
                        GString.getToString(this._checkLanguage, "tag_title"),
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(28),
                            fontWeight: FontWeight.w600))),
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
                              style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(28))),
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
                                GString.getToString(this._checkLanguage,
                                    "tag_button_yes"),
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
                ]),
          );
        });
  }

  //去打印小票
  doPrintOrderMenu(printType) async {
    var printStatus = await FlutterPluginMsprinter.getPrintStatus();
    if (printStatus == "0" || printStatus == "8") {
      var formData = {
        "orderId": this._orderId,
        "payAmount": _getPutMoney,
        "machineCode":_machineCode,
        "printType":(_showPrintType ==1 && _wlan_print_ip !="")?"Label":""
      };
      /*var formData = {
        "orderId": "442800657845387264",
        "payAmount": "1000",
        "machineCode":"X3V9YPJABVZGAELIZ9",
        "printType":(_showPrintType ==1 && _wlan_print_ip !="")?"Label":""
      };print(formData);print(_wlan_print_ip);*/
      var queryUrl;
      //queryUrl = "webBootToPrintV4";
      //queryUrl = "webBootToPrintV5";
      //queryUrl = "webBootToPrintV6"; //23新修改小票
      queryUrl = "webBootToPrintV7"; //230704新修改小票


      request(queryUrl, method: 'POST', parameters: formData).then((val) async {
        var response = json.decode(val.toString());
        //LogUtil.d(response);
        if (response['code'] == 200) {
          //receipt
          if(response['data']["printInfoMapStruct"] != null && response['data']["printInfoMapStruct"].isNotEmpty){
            _wifiNetworkPrintData(response['data']["serialNumber"],response['data']["printInfoMapStruct"],response['data']["takeOut"],response['data']["orderTime"]);
          }

          //label打印
          if(_showPrintType ==1 && _wlan_print_ip !="" && response['data']["printInfoListStruct"].length>0){
            _wifiNetworkLabelPrintData(response['data']["printInfoListStruct"]);
          }
          //printType 1 打印菜+领収书 2 只打印菜
          //orderType 1 打印菜并根据printtype来判断是否打印领収书。orderType 2不打印菜
          if(response['data']["orderType"] == 1){

            _tpPrintnew(response['data'], printType);

          }else{
            if (printType == "1") {
              _tpPrintReceipt(response['data']);
            }
          }



          Future.delayed(Duration(milliseconds: 500),() async {
            if (_machineMode == "1") {
              eventBus.fire(new clearCartEvent('支付成功...'));
            }

            //先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
            if (_payment_method_num == "1") {
              nextOper();
            } else {
              gotonewMyhome();
            }

          });

        } else {
          //错误后重新调用一次
          doPrintOrderMenu(printType);
          //EasyLoading.dismiss();

        }
      });
    } else {
      EasyLoading.dismiss();

      var show_dialog_content = "";
      if (printStatus == "7") {
        show_dialog_content = GString.getToString(
            this._checkLanguage, "tag_print_content_paper_shortage");
      } else {
        show_dialog_content = GString.getToString(
            this._checkLanguage, "tag_print_content_paper_error");
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
                      child: Text(
                          GString.getToString(this._checkLanguage, "tag_title"),
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28),
                              fontWeight: FontWeight.w600))),
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
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(28))),
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
                                    GString.getToString(this._checkLanguage,
                                        "tag_print_button_no"),
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
                                  decoration:
                                  BoxDecoration(color: Colors.black12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 70.0),
                                child: TextButton(
                                  child: Text(
                                    GString.getToString(this._checkLanguage,
                                        "tag_print_button_yes"),
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
                  ]),
            );
          });
    }
  }

  //打印甘蘭
  _tpPrintnew(printData, printType) async {
    var categoryVos = printData["printInfoListStruct"];
    var print_menu_txt_size = 28.0;
    var wrapNum = 10;
    var oneRowHeight = 48;
    if(_print_paper_txt_size == "1"){
      print_menu_txt_size = 28.0;
      wrapNum = 12;
      oneRowHeight = 38;
    }else if(_print_paper_txt_size == "2"){
      print_menu_txt_size = 33.0;
      wrapNum = 10;
      oneRowHeight = 44;
    }else if(_print_paper_txt_size == "3"){
      print_menu_txt_size = 40.0;
      wrapNum = 8;
      oneRowHeight = 55;
    }

    List<Widget> categoryMenus = [];
    var lineHight = 125;
    var menuNum = 0;
    var optionNum = 0;
    var addRowHight = 0;

    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["numberTip"]}",
                style: TextStyle(
                  fontSize: 28,
                  //fontFamily: 'JetBrainsMonoRegular',
                  fontWeight: FontWeight.w200,
                  color: ColorsUtil.hexToColor("#000000"),
                ))),
      ),
    );
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["serialNumber"]}",
                style: TextStyle(
                  fontSize: 32,
                  //fontFamily: 'JetBrainsMonoRegular',
                  fontWeight: FontWeight.w200,
                  color: ColorsUtil.hexToColor("#000000"),
                ))),
      ),
    );

    int categoryNum = categoryVos.length;
    int categoryshowNum = 0;

    for (var m = 0; m < categoryVos.length; m++) {
      var lineItem = categoryVos[m];
      var optionVoList = lineItem["optionVoListMsgMap"];
      // 计算菜品标题长度
      var menuLength = lineItem["mainTitle"].length;
      var menuLine = menuLength / wrapNum;
      var menuRowNum = menuLine.ceil();
      optionNum = 0;

      categoryMenus.add(
        _publicGoodsTwoColumnsTxt("${lineItem["mainTitle"]}", print_menu_txt_size,
            FontWeight.w200, "${lineItem["qty"]}", print_menu_txt_size, FontWeight.w200),
      );
      if (optionVoList != null && optionVoList.isNotEmpty) {
        optionVoList.forEach((key, value) {
          // 计算菜品标题长度
          var groupNameLength = key.length;
          var optionNameLength = value[0].length;
          var optionLine = (groupNameLength + optionNameLength) / wrapNum;
          var countLine = 0;//optionLine.ceil();

          //处理option 开始-----------
          if((key.length+value[0].length) >(wrapNum-2)){
            var newLineNum = 0.0;
            //if(groupNameLength >wrapNum){
            newLineNum = groupNameLength / (wrapNum-2);
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;
            //if(optionNameLength >wrapNum){
            var newLineNumLength = optionNameLength / (wrapNum-2);
            //}
            countLine += newLineNumLength.ceil();
            optionLine += newLineNum;

            categoryMenus.add(Column(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(
                              child:Text("${key}",
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: print_menu_txt_size,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: 'ZenKakuGothicAntique',
                                    color: ColorsUtil.hexToColor("#000000"),
                                  ))
                          )
                      ),

                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(50)),
                  child: Row(
                    mainAxisAlignment: (value[0].length >(wrapNum-2) ) ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(
                            child: Text("${value[0]}",
                                softWrap: true,
                                textAlign: (value[0].length >(wrapNum-2)) ? TextAlign.left : TextAlign.right,
                                style: TextStyle(
                                  fontSize: print_menu_txt_size,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'ZenKakuGothicAntique',
                                  color: ColorsUtil.hexToColor("#000000"),
                                )),
                          )),
                    ],
                  ),
                ),
              ],
            ));
          }else{
            countLine += 1;

            categoryMenus.add(Container(
              height: oneRowHeight.toDouble(),
              padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text("${key}",
                          softWrap: true,
                          style: TextStyle(
                            fontSize: print_menu_txt_size,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'ZenKakuGothicAntique',
                            color: ColorsUtil.hexToColor("#000000"),
                          ))
                  ),
                  Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text("${value[0]}",
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: print_menu_txt_size,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'ZenKakuGothicAntique',
                            color: ColorsUtil.hexToColor("#000000"),
                          ))),
                ],
              ),
            ));
          }

          var newOptionSonLine = 0.0;
          if(value.length>1){
            List<Widget> optionSons = [];
            for (var j = 1; j < value.length; j++) {
              //print(value[j]);
              newOptionSonLine += value[j].length / (wrapNum-2);
              var oneOptionlength = value[j].length / (wrapNum-2);
              countLine += oneOptionlength.ceil();

              optionSons.add(
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(50)),
                    child: Row(
                      mainAxisAlignment: (value[j].length >(wrapNum-2)) ? MainAxisAlignment.start : MainAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(child: Text("${value[j]}",
                            textDirection: TextDirection.ltr,
                            textAlign: (value[j].length >(wrapNum-2)) ? TextAlign.left : TextAlign.right,
                            style: TextStyle(
                              fontSize: print_menu_txt_size,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'ZenKakuGothicAntique',
                              color: ColorsUtil.hexToColor("#000000"),
                              //fontWeight: FontWeight.w600
                            ))),
                      ],
                    ),
                  )
              );
            }

            categoryMenus.add(Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              textDirection: TextDirection.rtl,
              children: optionSons,
            ));
          }


          //处理option结束-----------

          var optionRowNum = optionLine.ceil() + newOptionSonLine.ceil();
          //addRowHight += 52 * optionRowNum;
          addRowHight += oneRowHeight*countLine+(countLine-1)*10;
          menuNum += optionRowNum;
          optionNum++;
        });

        addRowHight += oneRowHeight * menuRowNum+(menuRowNum-1)*10;
        menuNum += menuRowNum;
      } else {
        addRowHight += oneRowHeight * menuRowNum+(menuRowNum-1)*10;
        menuNum += menuRowNum;
      }

      //分割线
      if (_machineMode == "1") {
        addRowHight += 20;
        categoryMenus.add(
          _publicSplitLine(),
        );
      }
    }
    //print("总行数${menuNum}");
    var totalHight = addRowHight + lineHight;
    if (menuNum == 1) {
      totalHight += 15;
    }
    ByteData byteData = await WidgetToImage.widgetToImage(Container(
      width: 385,
      height: totalHight.toDouble(),
      padding: EdgeInsets.only(left: 0.5, right: 0.5),
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: categoryMenus,
      ),
    ));

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //Future.delayed(Duration(milliseconds: 50), () async {
    String base64Image = base64Encode(imageBytes);
    //LogUtil.d(base64Image);
    if (printType == "1") {
      // print("打印小菜来了-开始打印小菜lalala：${DateTime.now()}");
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "0"," ");
      Future.delayed(Duration(milliseconds: 300), () async {
        await FlutterPluginMsprinter.sendPrintCut("1");
        _tpPrintReceipt(printData);
      });
    } else {
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", "0"," ");
      Future.delayed(Duration(milliseconds: 300), () async {
        await FlutterPluginMsprinter.sendPrintCut("0");
      });
    }

    //});
  }

  _wifiNetworkPrintData(serialNumber,extendPrintVo,takeOut,orderTime){
    var printData = [];
    extendPrintVo.forEach((k,v){
      printData = [];
      if(v.length>0){
        for(var i=0; i<v.length; i++){
          v[i]["checked"] = false;
          //判断是否有需要打印的数据
          if(v[i]["print"] == true){
            printData.add(v[i]);
          }
        }
        //QueueUtil.get("smartwe_taks_wifi_print")?.addTask(() {
        return wifiNetPrintnew(serialNumber,k,printData,takeOut,orderTime);
        //});
      }
    });

  }

  wifiNetPrintnew(serialNumber,printType,printData,takeOut,orderTime) async {
    //如果整理的数据打印机不是10或11就返回
    if(printType != "10" && printType != "12"){
      return;
    }

    //判断是否有打印机ip
    Map printerIpInfo = {"printer_ip":"","printer_port":"",};
    if(printType == "10"){
      if(_wlan_print_ip != null && _wlan_print_ip != "" && _wlan_print_port != null && _wlan_print_port != ""){
        printerIpInfo = {"printer_ip":_wlan_print_ip,"printer_port":_wlan_print_port,};
      }else{
        return;
      }
    }else if(printType == "12"){
      if(_wlan_print_ip_two != null && _wlan_print_ip_two != "" && _wlan_print_port_two != null && _wlan_print_port_two != ""){
        printerIpInfo = {"printer_ip":_wlan_print_ip_two,"printer_port":_wlan_print_port_two,};
      }else{
        return;
      }
    }else{
      return;
    }
    //print(printData);
    _wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,printerIpInfo["printer_ip"]);

  }
  _wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,printer_ip){
    for(var i=0;i<printData.length;i++){
     // wifiNetPrintReceiptnew(serialNumber,printData[i],takeOut,orderTime,printer_ip);

      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: wifiNetPrintReceiptnew(serialNumber,printData[i],takeOut,orderTime,printer_ip) as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: PrinterInfo(ip:_wlan_print_ip),
        ),
      );

    }
  }

  Widget wifiNetPrintReceiptnew(serialNumber,orderprintData,takeOut,orderTime,printer_ip) {
    var lineHight = 120;
    var menuNum = 0;
    var optionNum = 0;
    int addRowHight = 0;

    List<Widget> printMenus = [];
    printMenus.add(
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child:
                RichText(
                  text: TextSpan(
                      text: (takeOut == true) ?"☆︎":"",//${printData["takeOut"]}
                      style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      ),
                      children: [
                        TextSpan(
                          text: "${serialNumber.toString()}",
                          style: TextStyle(
                            fontSize: 50,
                            fontFamily: 'JetBrainsMonoRegular',
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#000000"),
                          ),
                        ),
                      ]),
                )
            ),
            Directionality(
                textDirection: TextDirection.ltr,
                child: Text("${orderTime}",
                    style: TextStyle(
                      fontSize: 45,
                      //fontFamily: 'JetBrainsMonoRegular',
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#000000"),
                    ))
            ),
          ],
        ),
      ),
    );
    printMenus.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.ltr,
        children: [
          Directionality(
              textDirection: TextDirection.ltr,
              child: Expanded(
                  child: Text("${orderprintData["mainTitle"]}",
                      style: TextStyle(
                        fontSize: 45,
                        //fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.hexToColor("#000000"),
                      ))
              )
          ),
          Container(
            width: 50,
            alignment: Alignment.centerRight,
            child: Directionality(
                textDirection: TextDirection.ltr,
                child: (int.parse(orderprintData["qtyBack"]) >1) ? NumberCircle(
                  number: int.parse(orderprintData["qtyBack"]),
                  circleColor: ColorsUtil.hexToColor("#000000"),
                  circleSize: 50.0,
                  numberStyle: TextStyle(
                    fontSize: 42,
                    fontFamily: 'JetBrainsMonoRegular',
                    fontWeight: FontWeight.w400,
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                ) :Text("${orderprintData["qty"]}",
                    textAlign: TextAlign.right,//${printData["takeOut"]}
                    style: TextStyle(
                      fontSize: 42,
                      fontFamily: 'JetBrainsMonoRegular',
                      fontWeight: FontWeight.w400,
                      color: ColorsUtil.hexToColor("#000000"),
                    ))
            ),
          ),
        ],
      ),
    );

    var mainTitleLine = orderprintData["mainTitle"].length / 10;
    int mainTitleRowNum = mainTitleLine.ceil();
    optionNum = 0;


    var optionVoListMap = orderprintData["optionVoListMsgMap"] ?? {};
    if (optionVoListMap != null && optionVoListMap.isNotEmpty) {
      optionVoListMap.forEach((key, value) {
        // 计算菜品标题长度
        var groupNameLength = key.length;
        var optionNameLength = value[0].length;
        var optionLine = (groupNameLength + optionNameLength) / 10;
        var countLine = 0;

        //处理option 开始-----------
        if((key.length+value[0].length)>10){
          var newLineNum = 0.0;
          //if(groupNameLength >6){
          newLineNum = groupNameLength / 10;
          //}
          countLine += newLineNum.ceil();
          optionLine += newLineNum;
          //if(optionNameLength >6){
          var optionSonNameLength = optionNameLength / 10;
          //}
          countLine += optionSonNameLength.ceil();
          optionLine += newLineNum;

          printMenus.add(Column(
            textDirection: TextDirection.rtl,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Expanded(
                          child:Text("    ${key}",
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'JetBrainsMonoRegular',
                                color: ColorsUtil.hexToColor("#000000"),
                              ))
                      )
                  ),

                ],
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                child: Row(
                  mainAxisAlignment: (value[0].length >10 ) ? MainAxisAlignment.start : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.rtl,
                        child: Expanded(
                          child: Text("${value[0]}",
                              softWrap: true,
                              textAlign: (value[0].length >10) ? TextAlign.left : TextAlign.right,
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'JetBrainsMonoRegular',
                                color: ColorsUtil.hexToColor("#000000"),
                              )),
                        )),
                  ],
                ),
              ),
            ],
          ));
        }else{
          countLine += 1;
          printMenus.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("    ${key}",
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'JetBrainsMonoRegular',
                        color: ColorsUtil.hexToColor("#000000"),
                      ))
              ),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text("${value[0]}",
                      softWrap: true,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'JetBrainsMonoRegular',
                        color: ColorsUtil.hexToColor("#000000"),
                      ))),
            ],
          ));
        }

        var newOptionSonLine = 0.0;
        if(value.length>1){
          List<Widget> optionSons = [];
          for (var j = 1; j < value.length; j++) {
            // print(value[j]);
            newOptionSonLine += value[j].length / 10;
            var oneOptionlength = value[j].length / 10;
            countLine += oneOptionlength.ceil();

            optionSons.add(
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                  child: Row(
                    mainAxisAlignment: (value[j].length >10) ? MainAxisAlignment.start : MainAxisAlignment.end,
                    textDirection: TextDirection.ltr,
                    children: [
                      Expanded(child: Text("${value[j]}",
                          textDirection: TextDirection.ltr,
                          textAlign: (value[j].length >10) ? TextAlign.left : TextAlign.right,
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'JetBrainsMonoRegular',
                            color: ColorsUtil.hexToColor("#000000"),
                            //fontWeight: FontWeight.w600
                          ))),
                    ],
                  ),
                )
            );
          }

          printMenus.add(Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            textDirection: TextDirection.rtl,
            children: optionSons,
          ));
        }


        //处理option结束-----------

        var optionRowNum = optionLine.ceil() + newOptionSonLine.ceil();
        //addRowHight += 52 * optionRowNum;
        addRowHight += 65*countLine;
        menuNum += optionRowNum;
        optionNum++;
      });

      addRowHight += 45 * mainTitleRowNum;
      menuNum += mainTitleRowNum;
    } else {
      addRowHight += 65 * mainTitleRowNum;
      menuNum += mainTitleRowNum;
    }

    var totalHight = addRowHight+lineHight;
    if(menuNum == 1){
      totalHight +=15;
    }


    // 生成打印图层任务，指定任务类型为标签
    return ReceiptConstrainedBox(Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: printMenus,
    ));

    /*ByteData byteData = await WidgetToImage.widgetToImage(
        Container(
          width: 560,
          height: totalHight.toDouble(),
          padding: EdgeInsets.only(left: 0.5, right: 0.5),
          color: Colors.white,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: printMenus,
          ),
        )
    );

    Uint8List imageBytes = byteData.buffer.asUint8List();
    var printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
        imgData: imageBytes,
        printType: PrintTypeEnum.receipt,
        imgSizeLimit : 560 * totalHight
    );


    QueueUtil.get("smartwe_taks_wifi_print")?.addTask(() {
      return setPrintData(printer_ip,printData);
    });*/

  }

  setPrintData(printerIPVal,printData){
    // 网络 打印
    final conn = printerPlus.NetConn(printerIPVal);
    conn.writeMultiBytes(printData);
  }

  organizeData(serialNumber,printData,takeOut,orderTime) {
    var categoryVos = printData;
    List<Widget> categoryMenus = [];
    var lineHight = 230;
    var menuNum = 0;
    var optionNum = 0;
    int addRowHight = 0;



    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child:
            RichText(
              text: TextSpan(
                  text: (takeOut == true) ?"☆︎":"",//${printData["takeOut"]}
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'JetBrainsMonoRegular',
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                  children: [
                    TextSpan(
                      text: "${serialNumber.toString()}",
                      style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      ),
                    ),
                  ]),
            )
        ),
      ),
    );

    for(var i=0; i<categoryVos.length; i++){
      var lineVos = categoryVos[i];
      var optionVoList = categoryVos[i]["optionVoListMsgMap"] ?? {};

      // 计算菜品标题长度
      var mainTitleLength = lineVos["mainTitle"].length;
      var mainTitleLine = mainTitleLength / 10;
      int mainTitleRowNum = mainTitleLine.ceil();
      optionNum = 0;

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
                      child: Expanded(
                        child: Text("${lineVos["mainTitle"]}",
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'JetBrainsMonoRegular',
                              color: ColorsUtil.hexToColor("#000000"),)),
                      )
                  ),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text("${lineVos["qty"]}",
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'JetBrainsMonoRegular',
                            color: ColorsUtil.hexToColor("#000000"),
                            //fontWeight: FontWeight.w600
                          )
                      )
                  ),
                ],
              ),
            )),
      );

      if (optionVoList != null && optionVoList.isNotEmpty) {
        optionVoList.forEach((key, value) {
          // 计算菜品标题长度
          var groupNameLength = key.length;
          var optionNameLength = value[0].length;
          var optionLine = (groupNameLength + optionNameLength) / 12;
          var countLine = 0;


          //处理option 开始-----------
          if((key.length+value[0].length)>12){
            var newLineNum = 0.0;
            //if(groupNameLength >6){
            newLineNum = groupNameLength / 12;
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;
            //if(optionNameLength >6){
            newLineNum = optionNameLength / 12;
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;

            categoryMenus.add(Column(
              textDirection: TextDirection.rtl,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(
                            child:Text("    ${key}",
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'JetBrainsMonoRegular',
                                  color: ColorsUtil.hexToColor("#000000"),
                                ))
                        )
                    ),

                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                  child: Row(
                    mainAxisAlignment: (value[0].length >10 ) ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.rtl,
                          child: Expanded(
                            child: Text("${value[0]}",
                                softWrap: true,
                                textAlign: (value[0].length >10) ? TextAlign.left : TextAlign.right,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'JetBrainsMonoRegular',
                                  color: ColorsUtil.hexToColor("#000000"),
                                )),
                          )),
                    ],
                  ),
                ),
              ],
            ));
          }else{
            countLine += 1;
            categoryMenus.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("    ${key}",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'JetBrainsMonoRegular',
                          color: ColorsUtil.hexToColor("#000000"),
                        ))
                ),
                Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text("${value[0]}",
                        softWrap: true,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'JetBrainsMonoRegular',
                          color: ColorsUtil.hexToColor("#000000"),
                        ))),
              ],
            ));
          }

          var newOptionSonLine = 0.0;
          if(value.length>1){
            List<Widget> optionSons = [];
            for (var j = 1; j < value.length; j++) {
              // print(value[j]);
              newOptionSonLine += value[j].length / 10;
              var oneOptionlength = value[j].length / 10;
              countLine += oneOptionlength.ceil();

              optionSons.add(
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                    child: Row(
                      mainAxisAlignment: (value[j].length >10) ? MainAxisAlignment.start : MainAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(child: Text("${value[j]}",
                            textDirection: TextDirection.ltr,
                            textAlign: (value[j].length >10) ? TextAlign.left : TextAlign.right,
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'JetBrainsMonoRegular',
                              color: ColorsUtil.hexToColor("#000000"),
                              //fontWeight: FontWeight.w600
                            ))),
                      ],
                    ),
                  )
              );
            }

            categoryMenus.add(Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              textDirection: TextDirection.rtl,
              children: optionSons,
            ));
          }


          //处理option结束-----------

          var optionRowNum = optionLine.ceil() + newOptionSonLine.ceil();
          //addRowHight += 52 * optionRowNum;
          addRowHight += 66*countLine;
          menuNum += optionRowNum;
          optionNum++;
        });

        //addRowHight += 59 * mainTitleRowNum;
        //menuNum += mainTitleRowNum;
      } else {
        addRowHight += 65 * mainTitleRowNum;
        menuNum += mainTitleRowNum;
      }

      addRowHight += 10;
      categoryMenus.add(
        Directionality(
            textDirection: TextDirection.ltr,
            child:Container(
              margin: EdgeInsets.only(top: 5,bottom: 5),
              height: 2.5,
              color:ColorsUtil.hexToColor("#000000"),
              width: 550,
            )
        ),
      );
    }

    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 5),
        alignment: Alignment.centerRight,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child:
            Text(
              "${orderTime}",//${printData["takeOut"]}
              style: TextStyle(
                fontSize: 45,
                fontFamily: 'JetBrainsMonoRegular',
                fontWeight: FontWeight.w500,
                color: ColorsUtil.hexToColor("#000000"),
              ),
            )
        ),
      ),
    );

    var totalHight = addRowHight+lineHight;
    if(menuNum == 1){
      totalHight +=15;
    }

    return Container(
      width: 550,
      height: totalHight.toDouble(),
      padding: EdgeInsets.only(left: 0.5, right: 0.5),
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: categoryMenus,
      ),
    );


  }

  //打印label
  _wifiNetworkLabelPrintData(extendPrintVo){
    var printData = [];
    for(var i=0;i<extendPrintVo.length;i++){
      // 生成打印图层任务，指定任务类型为标签
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: menuData(extendPrintVo[i]) as ATempWidget,
          printTypeEnum: PrintTypeEnum.label,
          params: PrinterInfo(ip:_wlan_print_ip),
        ),
      );
      /*QueueUtil.get("smartwe_taks_wifi_print")?.addTask(() {
        return wifiNetPrintLabelnew(extendPrintVo[i]);
      });*/
    }
  }

  wifiNetPrintLabelnew(orderprintData) async {

    Future.delayed(Duration(milliseconds: 1200),() async {
      ByteData byteData = await WidgetToImage.widgetToImage(
          menuData(orderprintData)
      );

      Uint8List imageBytes = byteData.buffer.asUint8List();
      var printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
        imgData: imageBytes,
        printType: PrintTypeEnum.label,
      );
      // 网络 打印
      final conn = printerPlus.NetConn(_wlan_print_ip);
      conn.writeMultiBytes(printData);

    });

  }

  Widget menuData(orderprintData){
    return LabelConstrainedBox(
        Padding(
          padding: const EdgeInsets.only(
            //left: 5,
            top: 5,
            //right: 5,
            bottom: 5,
          ),
          child: Container(

            child: Column(
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [

                Container(
                  decoration: BoxDecoration(
                    //color: Colors.red,
                    border: Border(
                      bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 2.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:MainAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(400),
                              minHeight: ScreenAdapter.height(30),
                              maxHeight: ScreenAdapter.height(60),
                            ),
                            child: AutoSizeText(
                              "${orderprintData["printTitleText"]}",
                              style: GoogleFonts.zenKakuGothicAntique(fontSize: ScreenAdapter.fontSize(32),fontWeight: FontWeight.w500),
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                          )
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment:MainAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: ScreenAdapter.width(20),
                            maxWidth: ScreenAdapter.width(400),
                            minHeight: ScreenAdapter.height(30),
                            maxHeight: ScreenAdapter.height(150),
                          ),
                          child: AutoSizeText(
                            orderprintData["printText"],
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w500),
                            maxLines: 4,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                        )
                    ),
                  ],
                ),

              ],
            ),
          ),
        )
    );
  }

  _tpPrintReceipt(printData) async {
    List<Widget> categoryMenus = [];
    var menuVos = printData["details"];
    var lineHight = 580;
    var lineZeng = 0;
    var addRowHight = 0;

    //店铺标题
    /*categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["shopName"]}",
              style: GoogleFonts.zenKakuGothicAntique(fontSize: 34,fontWeight: FontWeight.w400,color: Colors.black87),

            )),
      ),
    );*/

    //日期 地址 电话
    //地址
    // 计算菜品标题长度
    var addressLength = printData["address"].length;
    var addressLine = addressLength / 15;
    var addressRowNum = addressLine.ceil();
    addRowHight += addressRowNum*33+(addressRowNum-1)*10;
    categoryMenus.add(_publicOneColumnTxtNew(
        "${printData["address"]}", 26.0, FontWeight.w300));

    categoryMenus.add(SizedBox(height: 5,));
    //登录番号
    if(printData["ntaNo"] != null && printData["ntaNo"] != "")
      categoryMenus.add(_publicOneColumnTxtNew(
          "登録番号 ${printData["ntaNo"]}", 26.0, FontWeight.w300));
    categoryMenus.add(SizedBox(height: 5,));
    categoryMenus.add(Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text("${printData["orderDate"]}",
            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),
          )),
    ));
    //注文番号
    categoryMenus.add(_publicOneColumnTxtNew(
        "注文番号:${printData["order"]}", 26.0, FontWeight.w300));
    /*categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  width: ScreenAdapter.width(160),
                  child: Expanded(
                    child: Text("${printData["orderDate"]}",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000"))),
                  ),
                )),
            Expanded(child: Column(
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("${printData["shopAddress"]}",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000")))),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("登録番号 T12356757656",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000")))),
              ],
            )),
          ],
        ),
      ),
    );*/
    //领収书标题
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              padding: EdgeInsets.only(top: ScreenAdapter.height(5.0),bottom: ScreenAdapter.height(5.0),left:ScreenAdapter.width(20.0),right:ScreenAdapter.width(20.0)),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  left: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  right: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                ),
              ),
              child: Text("領 収 書",
                style: GoogleFonts.zenKakuGothicAntique(fontSize: 50,color: Colors.black,),

              ),
            )),
      ),
    );


    int categoryNum = menuVos.length;
    int linNum = 0;
    for (var i = 0; i < menuVos.length; i++) {

      var lineVosList = menuVos[i];

      // 计算菜品标题长度
      var groupNameLength = lineVosList["menuName"].length;
      var menuLine = groupNameLength / 10;
      var menuRowNum = menuLine.ceil();
      //linNum+=menuRowNum;
      var takeoutTag = (printData["takeOut"] == true) ? "*":"";
      if(groupNameLength>10){
        linNum+=2;
        addRowHight += 76;
        categoryMenus.add(
          Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: 76,
                //margin: EdgeInsets.only(bottom: 3),
                child: Column(
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Expanded(
                              child: Text("${lineVosList["menuName"]}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                              ),
                            )
                        ),
                        (printData["takeOut"] == true) ? Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text("${takeoutTag}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                            )
                        ):Container(width: 0,),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              width: ScreenAdapter.width(30),
                              alignment: Alignment.centerRight,
                              child: Text("${lineVosList["menuQty"]}",
                                style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                              ),
                            )
                        ),
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              width: ScreenAdapter.width(105),
                              alignment: Alignment.centerRight,
                              child: Text("￥${formatMoney(lineVosList["price"])}",
                                style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                              ),
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        );
      }else{
        addRowHight += 33;
        linNum+=1;
        categoryMenus.add(
          Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: 33,
                //margin: EdgeInsets.only(bottom: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(
                          child: Text("${lineVosList["menuName"]}${takeoutTag}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        )
                    ),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          width: ScreenAdapter.width(30),
                          alignment: Alignment.centerRight,
                          child: Text("${lineVosList["menuQty"]}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        )
                    ),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          width: ScreenAdapter.width(105),
                          alignment: Alignment.centerRight,
                          child: Text("￥${formatMoney(lineVosList["price"])}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        )
                    ),
                  ],
                ),
              )),
        );
      }


    }
    //print("总行数${menuNum}");
    //addRowHight += 33 * linNum;
    categoryMenus.add(SizedBox(height: 10,));
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
                    child: Expanded(
                      child: Text("合計",
                        style: GoogleFonts.zenKakuGothicAntique(fontSize: 28,fontWeight: FontWeight.w300,color: Colors.black87),

                      ),
                    )
                ),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Container(
                      width: ScreenAdapter.width(130),
                      alignment: Alignment.centerRight,
                      child: Text("￥${formatMoney(printData["price"])}",
                        style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                      ),
                    )
                ),
              ],
            ),
          )),
    );

    categoryMenus.add(
      _publicSplitLine(),
    );

    //8%
    categoryMenus.add(
      _publicTwoColumnsTxtNew(
          "8%対象",
          24.0,
          FontWeight.w100,
          (printData["takeOut"] == true) ? "${formatMoney(printData["price"])}" : "0",
          24.0,
          FontWeight.w100,
          true),
    );
    //内消费税
    categoryMenus.add(
      _publicTwoColumnsTxtNew(
          "　  (内    消費税额",
          24.0,
          FontWeight.w100,
          (printData["takeOut"] == true) ? "${formatMoney(printData["tax"])})" : "0)",
          24.0,
          FontWeight.w100,
          true),
    );

    //10%
    categoryMenus.add(
      _publicTwoColumnsTxtNew(
          "10%対象",
          24.0,
          FontWeight.w100,
          (printData["takeOut"] == false) ? "${formatMoney(printData["price"])}" : "0",
          24.0,
          FontWeight.w100,
          true),
    );
    //内消费税
    categoryMenus.add(
      _publicTwoColumnsTxtNew(
          "　  (内    消費税额",
          24.0,
          FontWeight.w100,
          (printData["takeOut"] == false) ? "${formatMoney(printData["tax"])})" : "0)",
          24.0,
          FontWeight.w100,
          true),
    );


    categoryMenus.add(
      _publicSplitLine(),
    );
    if(printData["payMethod"] != "現金支払"){
      lineZeng += 33;
      categoryMenus.add(
        _publicTwoColumnsTxtNew(printData["payMethod"], 26.0, FontWeight.w200,
            "${formatMoney(printData["payPrice"])}", 26.0, FontWeight.w200, true),
      );
    }

    if (printData["memberNo"] != null && printData["memberNo"] != "") {
      lineZeng += 76;
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("カード番号", 26.0, FontWeight.w200,
            printData["memberNo"], 26.0, FontWeight.w100, false),
      );
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("日期", 26.0, FontWeight.w200, printData["payDate"],
            26.0, FontWeight.w100, false),
      );
      categoryMenus.add(_publicSplitLine());
    }
    if (printData["serialNo"] != null && printData["serialNo"] != "") {
      lineZeng += 76;
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("カード取引通番", 26.0, FontWeight.w200,
            printData["serialNo"], 26.0, FontWeight.w100, false),
      );
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("取引日時", 26.0, FontWeight.w200, printData["payDate"],
            26.0, FontWeight.w100, false),
      );
      categoryMenus.add(_publicSplitLine());
    }

    //轻减税率对象
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: Expanded(
                  child: Container(
                    width: ScreenAdapter.width(180),
                    child: Text("*軽減税率対象",
                      style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                    ),
                  ),
                )
            ),
            Expanded(child: Column(
              children: [
                if(printData["payMethod"] == "現金支払")
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("お預り",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                          Text("￥${formatMoney(printData["payPrice"])}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        ],
                      )),
                if(printData["payMethod"] == "現金支払" && printData["change"] !=null)
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("お釣",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                          Text("￥${formatMoney(printData["change"])}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        ],
                      )),
              ],
            )),
          ],
        ),
      ),
    );

    //お明細は上記のとおりです。
    categoryMenus.add(_publicOneColumnTxtNew("お明細は上記のとおりです。", 26.0, FontWeight.w300));

    var totalHight = lineZeng + lineHight+addRowHight;

    ByteData byteData = await WidgetToImage.widgetToImage(Container(
      width: 385,
      padding: EdgeInsets.only(left: ScreenAdapter.width(2),right: ScreenAdapter.width(2)),
      height: totalHight.toDouble(),
      color: Colors.white,
      //alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: categoryMenus,
      ),
    ));

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //Future.delayed(Duration(milliseconds: 200), () async {
    String base64Image = base64Encode(imageBytes);
    await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "1",_printLogoImage);
    Future.delayed(Duration(milliseconds: 300), () async {
      await FlutterPluginMsprinter.sendPrintCut("1");
    });
    //});

  }

  //单列文字
  _publicOneColumnTxt(txtContext, txtFontSize, txtFontWeight) {
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
                  color: ColorsUtil.hexToColor("#000000")))),
    );
  }
  _publicOneColumnTxtNew(txtContext, txtFontSize, txtFontWeight) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text("${txtContext}",
            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

          )),
    );
  }

  //两列文字
  _publicTwoColumnsTxt(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight, isMoney) {
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
                        color: ColorsUtil.hexToColor("#000000"),
                      ))),
              Expanded(child: Container()),
              (isMoney == true)
                  ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: RichText(
                    text: TextSpan(
                        text: "￥",
                        //GString.getToString(this._checkLanguage, "show_price_front"),
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
                  ))
                  : Directionality(
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

  _publicTwoColumnsTxtNew(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight, isMoney) {

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
                      style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                    ),
                  )),
              (isMoney == true)
                  ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    width: ScreenAdapter.width(120),
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(
                          text: "￥",
                          style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),
                          children: [
                            TextSpan(
                              text: "${rightTxtContext}",
                              style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                            ),
                          ]),
                    ),
                  ))
                  : Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    width: ScreenAdapter.width(120),
                    alignment: Alignment.centerRight,
                    child: Text("${rightTxtContext}",
                      style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                    ),
                  )),
            ],
          ),
        ));
  }

  _publicTwoColumnsTxtNewLine(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight, isMoney) {

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
                    style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                  )),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Container(
                      width: ScreenAdapter.width(120),
                      alignment: Alignment.centerRight,
                      child: Text("${rightTxtContext}",
                        style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                      ),
                    ),
                  )),
            ],
          ),
        ));
  }
  //商品双列
  _publicGoodsTwoColumnsTxt(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight) {
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
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  )),
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

  _publicGoodsOptionTwoColumnsTxt(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("${leftTxtContext}",
                      softWrap: true,
                      style: TextStyle(
                        fontSize: leftTxtFontSize,
                        fontWeight: leftTxtFontWeight,
                        fontFamily: 'ZenKakuGothicAntique',
                        color: ColorsUtil.hexToColor("#000000"),
                      ))),
              //Expanded(child: Container()),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text("${rightTxtContext}",
                          style: TextStyle(
                            fontSize: rightTxtFontSize,
                            fontWeight: rightTxtFontWeight,
                            fontFamily: 'ZenKakuGothicAntique',
                            color: ColorsUtil.hexToColor("#000000"),
                            //fontWeight: FontWeight.w600
                          )),
                    ),
                  )),
            ],
          ),
        ));
  }
  _publicGoodsNewLineOptionTxt(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Expanded(
                          child:Text("${leftTxtContext}",
                              softWrap: true,
                              style: TextStyle(
                                fontSize: leftTxtFontSize,
                                fontWeight: leftTxtFontWeight,
                                fontFamily: 'ZenKakuGothicAntique',
                                color: ColorsUtil.hexToColor("#000000"),
                              ))
                      )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text("    ${rightTxtContext}",
                              style: TextStyle(
                                fontSize: rightTxtFontSize,
                                fontWeight: rightTxtFontWeight,
                                fontFamily: 'ZenKakuGothicAntique',
                                color: ColorsUtil.hexToColor("#000000"),
                                //fontWeight: FontWeight.w600
                              )),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ));
  }

  _publicGoodsNewLineOptionMoreTxt(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight) {
    //var rightList = json.decode(rightTxtContext);

    //print(rightTxtContext[0]);
    List<Widget> optionSons = [];
    for (var j = 0; j < rightTxtContext.length; j++) {
      //print(rightTxtContext[j]);
      optionSons.add(
          Container(
            alignment: Alignment.centerRight,
            child: Text("    ${rightTxtContext[j]}",
                style: TextStyle(
                  fontSize: rightTxtFontSize,
                  fontWeight: rightTxtFontWeight,
                  fontFamily: 'ZenKakuGothicAntique',
                  color: ColorsUtil.hexToColor("#000000"),
                  //fontWeight: FontWeight.w600
                )),
          )
      );
    }

    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                      child:Text("${leftTxtContext}",
                          softWrap: true,
                          style: TextStyle(
                            fontSize: leftTxtFontSize,
                            fontWeight: leftTxtFontWeight,
                            fontFamily: 'ZenKakuGothicAntique',
                            color: ColorsUtil.hexToColor("#000000"),
                          ))
                  )
              ),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: optionSons,
                  )),
            ],
          ),
        ));
  }

  //分割线
  _publicSplitLine() {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          height: 0.5,
          color: ColorsUtil.hexToColor("#000000"),
          width: 375,
        ));
  }

  //打印小票之后在关闭现金机，所以不考虑_isPrint
  nextOper() async {
    sleep(Duration(milliseconds: 300));
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    //开启倒计时
    _countDownTimer("3");

    stoptimer?.cancel();
    stoptimer =
        Timer.periodic(Duration(milliseconds: 950), (Timer stopt) async {
          _stopStatus = await Paycube.getPayCubeStopCashStatus;
          // 循环一定要记得设置取消条件，手动取消
          if (_stopStatus == "StopSuccess") {
            showCashTimer?.cancel();
            setState(() {
              seconds = 180;
              timer?.cancel();
            });
            //如果投币金额大于待支付总金额
            if (int.parse(this._getPutMoney) > int.parse(this._totalPrice)) {
              setState(() {
                _giveChangeMoney =
                    int.parse(this._getPutMoney) - int.parse(this._totalPrice);
              });
              //找零
              startOutPutMoney(_giveChangeMoney);
            } else {
              //已经结束入金，处理取引终了
              payCubeCloseTransaction();
            }

            stopt.cancel();
          }
          /*else if(_stopStatus == "Error-A0--02" || _stopStatus == "Error-F0--16"){
        //处理中
        await Paycube.endPayCube;
      }*/
          else {
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
    allowtimer =
        Timer.periodic(Duration(milliseconds: 150), (Timer allowt) async {
          _allowStatus = await Paycube.getPayCubeAllowCashStatus;
          // 循环一定要记得设置取消条件，手动取消
          if (_allowStatus == "AllowSuccess") {
            //如果打开了现金机，则去掉倒计时监听
            showCashTimer?.cancel();
            setState(() {
              seconds = 120;
            });

            getPutInMoney();

            allowt.cancel();
          } else if (_allowStatus == "Error-F0--16") {
            await Paycube.endTrade;
            //sleep(Duration(milliseconds: 200));
            await Paycube.strartPayCube;
          } else if (_allowStatus == "Error-A0--02") {
            //sleep(Duration(milliseconds: 300));
          } else {
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
        if (int.parse(result) >=int.parse(this._totalPrice, onError: (source) => -1)) {
          setState(() {
            if(_isCancel == false){
              _showPrintButton = true;
            }else{
              _showPrintButton = false;
            }

            var outMoney = int.parse(result) - int.parse(this._totalPrice); //找零金额
            _showOutMoney = outMoney.toString(); //找零金额
          });
        } else {
          setState(() {
            _showOutMoney = "0"; //找零金额
          });
        }
      }
    });
  }

  //入金开始-入金结束-交易结束-出金开始-交易结束  中间可set
  Endtoubi() async {
    sleep(Duration(milliseconds: 300));
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    //开启倒计时
    _countDownTimer("2");

    stoptimer?.cancel();
    stoptimer =
        Timer.periodic(Duration(milliseconds: 950), (Timer stopt) async {
          _stopStatus = await Paycube.getPayCubeStopCashStatus;
          // 循环一定要记得设置取消条件，手动取消
          if (_stopStatus == "StopSuccess") {
            showCashTimer?.cancel();
            setState(() {
              seconds = 180;
              timer?.cancel();
            });
            if (int.parse(this._getPutMoney) > int.parse(this._totalPrice)) {
              setState(() {
                _giveChangeMoney =
                    int.parse(this._getPutMoney) - int.parse(this._totalPrice);
              });

              if (_isPrint == false) {
                startOutPutMoney(_giveChangeMoney);
              }
            } else if (int.parse(this._getPutMoney) == int.parse(this._totalPrice)) {
              if (_isPrint == false) {
                //已经结束入金，处理取引终了
                payCubeCloseTransaction();
              }
            }/* else {
          showToast(
              GString.getToString(this._checkLanguage, "show_put_money_error"));
        }*/

            stopt.cancel();
          } else {
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
    _countDownTimer("6");

    outmoneytimer?.cancel();
    outmoneytimer =
        Timer.periodic(Duration(milliseconds: 200), (Timer outmoneyt) async {
          _outStatus = await Paycube.getPayCubeOutMoneyStatus;
          // 循环一定要记得设置取消条件，手动取消
          if (_outStatus == "OutSuccess") {
            //如果打开了现金机，则去掉倒计时监听
            showCashTimer?.cancel();
            setState(() {
              seconds = 180;
            });
            //如果取消不汇报，则出金后直接关闭 ？？？？？？
            _getPayCubeOutMoney();

            outmoneyt.cancel();
          } else if (_outStatus == "Error-A0--02") {
            //await Paycube.setReceiveEvent;
            //sleep(Duration(milliseconds: 200));
            //await Paycube.getPayCubeOutMoneyStatus;
            //print("_outStatus处理中:$_outStatus");
          } else {
            await Paycube.outPayCubeMoney(outStringMoney);
          }
        });
  }

  gotonewMyhome() {
    Get.find<HomePageController>().removeAllFromCart();

    EasyLoading.dismiss();
    //Navigator.pop(context);
    Navigator.pop(context);
    //Navigator.pushNamed(context, '/transitPage');
    //Navigator.of(context).pop();
    if(_machineMode == "2") {
      //精算页面
      Navigator.pushNamed(context, '/checkOutPage');
    }else if(_machineMode == "3") {
      Navigator.pushNamed(context, '/selfServiceHomePage');
    } else {
      Navigator.pushNamed(context, '/home');
    }
  }

  gotonewBack() {
    Get.find<HomePageController>().removeAllFromCart();

    print(_is_back_home);
    EasyLoading.dismiss();
    //Navigator.pop(context);
    Navigator.pop(context);
    //Navigator.pushNamed(context, '/transitPage');
    //Navigator.of(context).pop();
    if (_machineMode == "1") {
      if(_is_back_home == "0"){
        Navigator.pushNamed(context, '/home');
      }else{
        eventBus.fire(new clearCartEvent('支付成功...'));

        //有弹窗选择支付才在关闭一个
        if(_showOpenPayment == true){
          Navigator.of(context).pop();
        }

      }

    }else if (_machineMode == "3") {
      if(_is_back_home == "0"){
        Navigator.pushNamed(context, '/selfServiceHomePage');
      }else{
        eventBus.fire(new clearCartEvent('支付成功...'));

        //有弹窗选择支付才在关闭一个
        if(_showOpenPayment == true){
          Navigator.of(context).pop();
        }

      }

    } else {
      //精算页面
      Navigator.pushNamed(context, '/checkOutPage');
    }
  }

  gotonewMenuPage() {
    EasyLoading.dismiss();
    //Navigator.pop(context);
    Navigator.of(context).pop();
    /*if(_machineMode == "1"){
      Navigator.pushNamed(context, '/menuPage', arguments: {"checkLanguage": this._checkLanguage});
    }else{
      Navigator.pushNamed(context, '/checkOutPage');
    }*/
  }


  _getPayCubeOutMoney() async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    OutMoneytimer?.cancel();
    await Paycube.setReceiveEvent;
    _countDownTimer("7");

    OutMoneytimer =
        Timer.periodic(Duration(milliseconds: 400), (Timer outMoneyTime) async {
          // 循环一定要记得设置取消条件，手动取消
          String currencyString = await Paycube.getPayCubeOutMoneyCurrency;
          if (currencyString.trim().length > 0) {
            //如果打开了现金机，则去掉倒计时监听
            showCashTimer?.cancel();
            setState(() {
              seconds = 180;
              _currencyString = currencyString;
            });

            //汇报出金币种
            reportOutMoney();

            outMoneyTime.cancel();
          }
        });
  }

  //汇报出金币种,请求后台
  reportOutMoney() {
    setState(() {
      _isReportOutMoney = true;
    });
    payCubeCloseTransaction();
  }

  //扫码支付后，直接结束入金，取引终了
  payCubeEndDeposit() async {
    setState(() {
      timer?.cancel();
    });
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    //开启倒计时
    _countDownTimer("4");

    stoptimer?.cancel();
    stoptimer =
        Timer.periodic(Duration(milliseconds: 950), (Timer stopt) async {
          _stopStatus = await Paycube.getPayCubeStopCashStatus;
          //await Paycube.setReceiveEvent;
          // 循环一定要记得设置取消条件，手动取消
          if (_stopStatus == "StopSuccess") {
            showCashTimer?.cancel();
            setState(() {
              seconds = 180;
            });
            //print("扫码成功结束");
            payCubeCloseTransaction();
            stopt.cancel();
          } else {
            //sleep(Duration(milliseconds: 150));
            await Paycube.endPayCube;
          }
        });
  }

  payCubeCloseTransaction() async {
    if (int.parse(_getPutMoney) > 0) {
      //汇报入金币种
      _getPayCubePutMoneyCurrency();
    }

    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    //开启倒计时
    _countDownTimer("5");

    await Paycube.setReceiveEvent;
    endtimer?.cancel();
    endtimer =
        Timer.periodic(Duration(milliseconds: 950), (Timer endtradet) async {
          _endStatus = await Paycube.getPayCubeEndTradeStatus;
          // 循环一定要记得设置取消条件，手动取消 || _endStatus == "Error-A0--02"
          if (_endStatus == "EndSuccess") {
            showCashTimer?.cancel();
            setState(() {
              seconds = 180;
            });
            //关闭机器后的跳转
            if (_isPrint == true) {
              gotonewBack();
            } else {
              gotonewMenuPage();
            }

            endtradet.cancel();
          } else {
            //sleep(Duration(milliseconds: 200));
            await Paycube.endTrade;
          }
        });
  }

  //取消购买 要判断是否投入现金，如果投入现金则现金机出金，出已投金额，否则直接取消退回首页 model0 券卖机 `1精算机
  // 如果是刷卡则需要pos机返回成功在发送请求取消订单 取消动作移前并精算不需要取消
  showCancelConfirm(){
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
                          child: Text(GString.getToString(this._checkLanguage, "show_del_cart_item_tag"),
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
                              padding: const EdgeInsets.only(left: 120.0),
                              child: TextButton(
                                child: Text(
                                  GString.getToString(this._checkLanguage, "tag_button_no"),
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
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
                              padding: const EdgeInsets.only(right: 120.0),
                              child: TextButton(
                                child: Text(
                                  GString.getToString(this._checkLanguage, "tag_button_yes"),
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);

                                  _showBackEasyLoading();
                                  var paymentMethod = ["3","4","5","6","7","8","9","10"];
                                  if (paymentMethod.contains(_payment_method_num) == true) {
                                    _getPaymentCancelPosData();
                                  }else{
                                    CancelOrder();
                                  }

                                  /*if (_payment_method_num == "3" ||
                                      _payment_method_num == "4") {

                                    _getPaymentCancelPosData();
                                  } else {
                                    CancelOrder();
                                  }*/

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
  CancelOrder() {
    /*var formData = {
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "model": (_machineMode == "1") ? "0" : "1",
    };
    request('webBootCancelV1', method: 'POST', parameters: formData);*/

    if (_payment_method_num == "1" || _payment_method_num == "0") {
      setState(() {
        _isCancel = true;
      });
      //已投钱
      if (int.parse(_getPutMoney) > 0) {
        setState(() {
          _isPrint = false;
          _totalPrice = "0";
          _showPrintButton = false;
        });

        //如果现金机投币大于0后取消，则直接关机出金
        Endtoubi();
      } else {
        setState(() {
          _isPrint = false;
          _totalPrice = "0";
          _getPutMoney = "0";
          _showPrintButton = false;
        });
        //如果现金机投币大于0后取消，则直接关机出金
        Endtoubi();
      }
    } else {
      //返回上一级菜单页面
      gotonewMenuPage();
    }
  }

  _getPayCubePutMoneyCurrency() async {
    //_putcurrencyString现金机出款币种:61 00 00 62 00 00 63 00 00
    putMoneyCurrencytimer?.cancel();
    await Paycube.setReceiveEvent;
    _countDownTimer("8");
    putMoneyCurrencytimer = Timer.periodic(Duration(milliseconds: 400),
            (Timer putMoneyCurrencyTime) async {
          // 循环一定要记得设置取消条件，手动取消
          String putcurrencyString = await Paycube.getPayCubePutMoneyCurrency;
          if (putcurrencyString.trim().length > 0) {
            showCashTimer?.cancel();
            setState(() {
              seconds = 180;
              _getPutMoneyCurrency = putcurrencyString;
            });
            //汇报入金币种
            reportPutMoneyCurrency();

            putMoneyCurrencyTime.cancel();
          }
        });
  }

  //汇报入金币种,请求后台
  reportPutMoneyCurrency() {
    //operation  0 确认支付  1 取消返回(券売機)　2 取消返回(精算機)
    var operation = 0;
    if (_isCancel == true) {
      operation = (_machineMode == "1") ? 1 : 2;
    }

    var formData = {
      "paymentInfo": this._getPutMoneyCurrency.trim(),
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "price": int.parse(this._getPutMoney),
      "operation": operation,
    };
    request('webBootToReportV1', method: 'POST', parameters: formData)
        .then((value) {
      var response = json.decode(value.toString());
      if (response['code'] == 200) {
        if (_isReportOutMoney == true) {
          //已经结束入金，处理取引终了
          reportOutMoneyCurrency();
        }
      }
    });
  }

  reportOutMoneyCurrency() {
    if (_giveChangeMoney > 0) {
      var formData = {
        "changeInfo": this._currencyString.trim(),
        "machineCode": _machineCode,
        "orderId": this._orderId,
        "price": _giveChangeMoney
      };
      request('webBootToReportV1', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200) {
        } else {}
      });
    }
  }

  _showEasyLoadingScan() {
    var _showTag;
    if (int.parse(this._showOutMoney) > 0) {
      //_showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_outprice_tag"),
      _showTag = Text(
          GString.getToString(
              this._checkLanguage, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    } else {
      _showTag = Text(
          GString.getToString(
              this._checkLanguage, "settlement_print_loading_tag"),
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
              onLongPress: () {
                ScanCodeConfirmTimer?.cancel();
                _doScanCodeTimeOutLastQuery();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  _showEasyLoading() {
    var _showTag;
    if (int.parse(this._showOutMoney) > 0) {
      //_showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_outprice_tag"),
      _showTag = Text(
          GString.getToString(
              this._checkLanguage, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    } else {
      _showTag = Text(
          GString.getToString(
              this._checkLanguage, "settlement_print_loading_tag"),
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
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),

          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  _showSuccessEasyLoading() {
    var _showTag;

    _showTag =
        Text(GString.getToString(this._checkLanguage, "payment_success_title"),
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
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "paymentSuccess"),
                    fit: BoxFit.fitHeight),
              ),
            ),

          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  _showBackEasyLoading() {
    var _showTag =
    Text(GString.getToString(this._checkLanguage, "settlement_noprint_tag"),
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
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  _showPosCancelEasyLoading() {
    EasyLoading.dismiss();
    var _showTag =
    Text(GString.getToString(this._checkLanguage, "settlement_posPay_error"),
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));
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
                    child: Text(
                        GString.getToString(this._checkLanguage, "tag_title"),
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(28),
                            fontWeight: FontWeight.w600))),
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(650),
                    padding: EdgeInsets.only(left: ScreenAdapter.width(20),right: ScreenAdapter.width(20)),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text(GString.getToString(this._checkLanguage, "settlement_posPay_error"),
                              style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(28))),
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
                                GString.getToString(this._checkLanguage,
                                    "tag_button_yes"),
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: ScreenAdapter.fontSize(32.0)),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                _showEasyLoading();
                                Future.delayed(Duration(milliseconds: 1500),() async {
                                  CancelOrder();
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          );
        });

  }

  //pos机相关
  payconnectSocker() async {
    Socket.connect(
      this._pos_ip,
      int.parse(this._pos_port),
      timeout: Duration(seconds: 5),
    ).then((Socket socket) {
      print("连接成功了么");
      this._socket = socket;
      //获得pos数据并发送
      var paymentMethod = ["3","4","5","6","7","8","9","10"];
      if (paymentMethod.contains(_payment_method_num) == true) {
        _getPaymentPosData();
      }
      // 监听wifi模块发送的数据
      this._socket.listen((List<int> event) {
        LogUtil.d(event);
        //if (event.length > 40) event.fillRange(266, 289, 32);
        for(var i=0; i< event.length; i++){
          if(event[i] >127){
            event[i] = 32;
            //print(i);
          }
        }
        var zhuanhuan = Uint8List.fromList(event);
        var eventString = Utf8Codec().decode(zhuanhuan);
        LogUtil.d(eventString);
        //print(Utf8Codec().decode(zhuanhuan));
        //print("event=====${eventString}=====");
        String FirstString = eventString.substring(0, 1);
        String SecondString = eventString.substring(1, 3);
        String transaction_type = eventString.substring(3, 6);
        String resultString = eventString.substring(10, 13);
        String resultMPFSString = eventString.substring(13, 16);
        print("FirstString==${FirstString}");
        print("SecondString==${SecondString}");
        print("transaction_type==${transaction_type}");
        print("resultString==${resultString}");
        print("resultMPFSString==${resultMPFSString}");
        //支付成功 打印，返回首页 除了成功都取消
        if (transaction_type == "900") {
          //print("resultStringresultString==${resultString}");
          //print("resultMPFSStringresultMPFSString==${resultMPFSString}");

          if (FirstString == "3" && SecondString == "11" && resultString == "000") {print("进来取消了");
          //CancelOrder();
          _showEasyLoading();
          }
        } else {
          if (FirstString == "3" && SecondString == "11" && resultString == "000") {// &&  resultMPFSString == "000"
            var thincaCloud = ["5","6","7","8","9","10"];
            if (thincaCloud.contains(_payment_method_num) == true) {
              String reportString = eventString.substring(0, 169);
              CreditCardPayReport(reportString);
            }else{
              CreditCardPayReport(eventString);
            }

          } else {
            if(resultString.trim() != ""){
              /*if(resultString == "L11" || resultString == "L10"){
                CancelOrder();
              }*/
              /*if(resultString != "000" ||resultMPFSString == "L11"){
              CancelOrder();
              }*/
              if(resultString == "L11"){
                Future.delayed(Duration(milliseconds: 2500),() async {
                  CancelOrder();
                });
              }else{// if(resultString == "T10")
                _showPosCancelEasyLoading();
              }
            }
          }
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
      _showScanCodeNoOpenDialog(3,"Unable to connect: $e");
    });

  }

  //刷卡机nfc支付汇报
  CreditCardPayReport(eventString) {
    _showEasyLoading();
    _posResultReportData["result"] = true;
    _posResultReportData["paymentInfo"] = eventString;//LogUtil.d("huibaohhhhhh===${_posResultReportData}");
    request('webBootPosPayReport', method: 'POST', parameters: _posResultReportData).then((val) {
      var response = json.decode(val.toString());//print(response);

      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu("1");
      } else {
        //扫码后超时，再继续请求后台，1秒一次 20次
        //_doScanCodeTimeOut();
      }
    });

  }

  _getPaymentPosData() {
    var payTypeData = {
      //"3":"CreditCard",
      //"4":"CreditCard",
      "5":"Edy",
      "6":"iD",
      "7":"nanaco",
      "8":"WAON",
      "9":"QUICPay",
      "10":"IC",
    };
    var thincaCloud = ["5","6","7","8","9","10"];
    var _payType = "";
    if (thincaCloud.contains(_payment_method_num) == true) {
      _payType = payTypeData[_payment_method_num];
    }

    var formData = {
      "auth_code": "0000000088888888",
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "payType":_payType,
    };//print("_getPaymentPosData===${formData}");
    request('webBootToPayv2', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      print("发送pos请求");LogUtil.d(response);
      if (response['code'] == 200 && response['data'].isNotEmpty) {
        var resultData = response['data'];
        if(resultData["requestInfo"] != null && resultData["requestInfo"] != "" ){
          if(resultData["exceptionMessage"] != null && resultData["exceptionMessage"] == ""){
            _posResultReportData = response['data'];
            //判断不为空则POS机
            this._socket.write(resultData["requestInfo"]);
          }else{
            _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
          }
        }else{
          _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
        }

      } else {
        _showScanCodeNoOpenDialog(3,GString.getToString(this._checkLanguage, "settlement_scancodenochange_error"));
      }

    });

  }

  _getPaymentCancelPosData() {
    var formData = {
      "machineCode": _machineCode,
      "orderId": this._orderId,
    };

    request("webBootCreditCardCancel", method: 'POST', parameters: formData)
        .then((val) async {
      var response = json.decode(val.toString());print("发送取消请求");LogUtil.d(response);
      EasyLoading.dismiss();
      if (response['code'] == 200) {
        //var _queryString =       "2101500001       00509                  000000120221114093225";
        this._socket.write(response['data']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _settlement_payment_method =
    GString.getToString(this._checkLanguage, "settlement_payment_method");

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
                  Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        showCursor: false,
                        // 显示光标
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
                        onSubmitted: (value) {
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
                  if (_payment_method_num == "1")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          GImage.getImageString(
                              "imgpublic", "settlement_top_cash"),
                          width: ScreenAdapter.width(40),
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(20),
                        ),
                        Text(
                          GString.getToString(
                              this._checkLanguage, "settlement_top_title_cash"),
                          style: TextStyle(
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(34.0)),
                        ),
                      ],
                    ),
                  if (_payment_method_num == "2")
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
                          GString.getToString(
                              this._checkLanguage, "settlement_top_title_qr"),
                          style: TextStyle(
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(34.0)),
                        ),
                      ],
                    ),
                  if (_payment_method_num == "3")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: () {
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                          //showCancelConfirm();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_top_card"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(this._checkLanguage,
                                "settlement_top_title_card"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                  if (_payment_method_num == "4")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: () {
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                          //showCancelConfirm();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_top_nfc"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(this._checkLanguage,
                                "settlement_top_title_nfc"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                  if (_payment_method_num == "5")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: () {
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                          //showCancelConfirm();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_edy"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(this._checkLanguage,
                                "settlement_top_title_edy"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                  if (_payment_method_num == "6")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: () {
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                          //showCancelConfirm();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_id"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(this._checkLanguage,
                                "settlement_top_title_iD"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                  if (_payment_method_num == "7")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: () {
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                          //showCancelConfirm();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_nanaco"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(this._checkLanguage,
                                "settlement_top_title_nanaco"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                  if (_payment_method_num == "8")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: () {
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                          //showCancelConfirm();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_waon"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(this._checkLanguage,
                                "settlement_top_title_WAON"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                  if (_payment_method_num == "9")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: () {
                        try {
                          //Navigator.pop(context);
                          CancelOrder();
                          //showCancelConfirm();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_quicpay"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(this._checkLanguage,
                                "settlement_top_title_QUICPay"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                  if (_payment_method_num == "10")
                    InkWell(
                      enableFeedback: false,
                      onLongPress: () {
                        try {
                          //_getPaymentCancelPosData();
                          //Navigator.pop(context);
                          CancelOrder();
                          //showCancelConfirm();
                        } catch (_) {}
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_jiaotongxi"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(this._checkLanguage,
                                "settlement_top_title_IC"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_payment_method_num == "1")
              Container(
                width: ScreenAdapter.width(1080),
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString("imgpublic",
                      "settlement_top_lead_cash_${_checkLanguage}"),
                  width: ScreenAdapter.width(780),
                  height: ScreenAdapter.width(870),
                  fit: BoxFit.fitHeight,
                ),
              ),
            if (_payment_method_num == "2")
              Container(
                //height: ScreenAdapter.height(940),
                child: Stack(
                  children: [
                    Image.asset(
                      GImage.getImageString(
                          "imgpublic", "settlement_top_lead_qr"),
                      width: ScreenAdapter.width(1080),
                      fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                        right: ScreenAdapter.width(120),
                        top: ScreenAdapter.height(250),
                        child: Container(
                          width: ScreenAdapter.width(250),
                          child: Wrap(
                              spacing: ScreenAdapter.width(5), // set spacing here
                              runSpacing: ScreenAdapter.height(5),
                              alignment: WrapAlignment.center,
                              children: [
                                if (_showPayPay == true)
                                  Container(
                                    height: ScreenAdapter.height(130),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        top: ScreenAdapter.height(10),
                                        right: ScreenAdapter.width(10),
                                        bottom: ScreenAdapter.height(10)),
                                    child: Image.asset(
                                      GImage.getImageString(
                                          "imgpublic", "settlement_paypay"),
                                      width: ScreenAdapter.width(100),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if (_showAlipay == true)
                                  Container(
                                    height: ScreenAdapter.height(130),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        top: ScreenAdapter.height(10),
                                        right: ScreenAdapter.width(10),
                                        bottom: ScreenAdapter.height(10)),
                                    child: Image.asset(
                                      GImage.getImageString(
                                          "imgpublic", "settlement_alipay"),
                                      width: ScreenAdapter.width(100),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if (_showWechat == true)
                                  Container(
                                    height: ScreenAdapter.height(130),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        top: ScreenAdapter.height(10),
                                        right: ScreenAdapter.width(10),
                                        bottom: ScreenAdapter.height(10)),
                                    child: Image.asset(
                                      GImage.getImageString(
                                          "imgpublic", "settlement_wechat"),
                                      width: ScreenAdapter.width(100),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if (_showCreditCard == true && _isAllowPos =="1" && _showauPay == true)
                                  Container(
                                    height: ScreenAdapter.height(130),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        top: ScreenAdapter.height(10),
                                        right: ScreenAdapter.width(10),
                                        bottom: ScreenAdapter.height(10)),
                                    child: Image.asset(
                                      GImage.getImageString(
                                          "imgpublic", "settlement_aupay"),
                                      width: ScreenAdapter.width(100),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if (_showCreditCard == true && _isAllowPos =="1" && _showdPay == true)
                                  Container(
                                    height: ScreenAdapter.height(130),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        top: ScreenAdapter.height(10),
                                        right: ScreenAdapter.width(10),
                                        bottom: ScreenAdapter.height(10)),
                                    child: Image.asset(
                                      GImage.getImageString(
                                          "imgpublic", "settlement_dpay"),
                                      width: ScreenAdapter.width(100),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if (_showCreditCard == true && _isAllowPos =="1" && _showrPay == true)
                                  Container(
                                    height: ScreenAdapter.height(130),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        top: ScreenAdapter.height(10),
                                        right: ScreenAdapter.width(10),
                                        bottom: ScreenAdapter.height(10)),
                                    child: Image.asset(
                                      GImage.getImageString(
                                          "imgpublic", "settlement_rpay"),
                                      width: ScreenAdapter.width(100),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if (_showCreditCard == true && _isAllowPos =="1" && _showmPay == true)
                                  Container(
                                    height: ScreenAdapter.height(130),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        top: ScreenAdapter.height(10),
                                        right: ScreenAdapter.width(10),
                                        bottom: ScreenAdapter.height(10)),
                                    child: Image.asset(
                                      GImage.getImageString(
                                          "imgpublic", "settlement_mpay"),
                                      width: ScreenAdapter.width(100),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),

                              ]),
                        ))
                  ],
                ),
              ),
            if (_payment_method_num == "3")
              Container(
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Stack(
                  children: [
                    Image.asset(
                      GImage.getImageString("imgpublic",
                          "settlement_top_lead_card_${_checkLanguage}"),
                      width: ScreenAdapter.width(1060),
                      fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                      //right: ScreenAdapter.width(120),
                      bottom: ScreenAdapter.height(25),
                      child: Container(
                        width: ScreenAdapter.width(1080),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              spacing: ScreenAdapter.width(50), // set spacing here
                              runSpacing: ScreenAdapter.height(40),
                              alignment: WrapAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(_showVisa == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_visa"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if(_showJcb == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_jcb"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if(_showMaster == true)
                                  Container(
                                    // width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_master"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if(_showUnionPay == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_unionp"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if(_showAmericanExpress == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_american"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),

                                if(_showDinersClub == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_diners"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            if (_payment_method_num == "4")
              Container(
                //height: ScreenAdapter.height(940),
                child: Stack(
                  children: [
                    Image.asset(
                      GImage.getImageString(
                          "imgpublic", "settlement_top_lead_nfc_${_checkLanguage}"),
                      width: ScreenAdapter.width(1060),
                      fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                      //right: ScreenAdapter.width(120),
                      bottom: ScreenAdapter.height(25),
                      child: Container(
                        width: ScreenAdapter.width(1080),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              spacing: ScreenAdapter.width(50), // set spacing here
                              runSpacing: ScreenAdapter.height(40),
                              alignment: WrapAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(_showVisa == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_visa"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if(_showJcb == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_jcb"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if(_showMaster == true)
                                  Container(
                                    // width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_master"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if(_showUnionPay == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_unionp"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                if(_showAmericanExpress == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_american"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),

                                if(_showDinersClub == true)
                                  Container(
                                    //width: ScreenAdapter.width(120),
                                    //height: ScreenAdapter.height(90),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                    child: Image.asset(GImage.getImageString("imgpublic", "card_diners"),
                                      width: ScreenAdapter.width(105),
                                      //height: ScreenAdapter.height(100),
                                      //color: Colors.lightGreen,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            if (_payment_method_num == "5")
              Container(
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString(
                      "imgpublic", "settlement_top_lead_posEdy_${_checkLanguage}"),
                  width: ScreenAdapter.width(1060),
                  fit: BoxFit.fitWidth,
                ),
              ),
            if (_payment_method_num == "6")
              Container(
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString(
                      "imgpublic", "settlement_top_lead_posID_${_checkLanguage}"),
                  width: ScreenAdapter.width(1060),
                  fit: BoxFit.fitWidth,
                ),
              ),
            if (_payment_method_num == "7")
              Container(
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString(
                      "imgpublic", "settlement_top_lead_posNanaco_${_checkLanguage}"),
                  width: ScreenAdapter.width(1060),
                  fit: BoxFit.fitWidth,
                ),
              ),
            if (_payment_method_num == "8")
              Container(
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString(
                      "imgpublic", "settlement_top_lead_posWAON_${_checkLanguage}"),
                  width: ScreenAdapter.width(1060),
                  fit: BoxFit.fitWidth,
                ),
              ),
            if (_payment_method_num == "9")
              Container(
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString(
                      "imgpublic", "settlement_top_lead_posQUICPay_${_checkLanguage}"),
                  width: ScreenAdapter.width(1060),
                  fit: BoxFit.fitWidth,
                ),
              ),
            if (_payment_method_num == "10")
              Container(
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString(
                      "imgpublic", "settlement_top_lead_posIC_${_checkLanguage}"),
                  width: ScreenAdapter.width(1060),
                  fit: BoxFit.fitWidth,
                ),
              ),
            /*if (_payment_method_num == "5" || _payment_method_num == "6"|| _payment_method_num == "7"|| _payment_method_num == "8"|| _payment_method_num == "9"|| _payment_method_num == "10")
              Container(
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString(
                      "imgpublic", "settlement_top_lead_nfc_${_checkLanguage}"),
                  width: ScreenAdapter.width(1080),
                  fit: BoxFit.fitWidth,
                ),
              ),*/
            Container(
              height: ScreenAdapter.height(5),
              color: ColorsUtil.hexToColor("#D8D8D8"),
            ),
            Expanded(
              child: Container(
                //width: ScreenAdapter.width(240),
                //height: ScreenAdapter.height(220),
                // margin: EdgeInsets.only(left: ScreenAdapter.width(60),top: ScreenAdapter.width(50)),
                padding: EdgeInsets.only(
                    left: ScreenAdapter.width(200),
                    top: ScreenAdapter.height(35),
                    right: ScreenAdapter.width(200),
                    bottom: ScreenAdapter.height(10)),
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
                      padding:
                      EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: ColorsUtil.hexToColor("#D8D8D8"),
                                width: 2.5),
                            //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                          )),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              GString.getToString(
                                  this._checkLanguage, "settlement_orderPrice"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(32),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(
                                    Gcolor.mainTitleColor),
                              )),
                          SizedBox(height: ScreenAdapter.height(10)),
                          Container(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                  text: formatMoney(this._totalPrice),
                                  //GString.getToString(this._checkLanguage, "show_price_front"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(52),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#9A5718"),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " 円", //" 円",
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
                    if (_payment_method_num == "1")
                      Container(
                        margin: EdgeInsets.only(
                          top: ScreenAdapter.height(15),
                          bottom: ScreenAdapter.height(15),
                        ),
                        padding:
                        EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: ColorsUtil.hexToColor("#D8D8D8"),
                                  width: 2.5),
                              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                            )),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                GString.getToString(
                                    this._checkLanguage, "settlement_putMoney"),
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(32),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.mainTitleColor),
                                )),
                            SizedBox(height: ScreenAdapter.height(10)),
                            Container(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                    text: formatMoney(this._getPutMoney),
                                    //" 円",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(52),
                                      fontWeight: FontWeight.w600,
                                      color: (int.parse(this._getPutMoney) > 0)
                                          ? ColorsUtil.hexToColor("#FF0000")
                                          : ColorsUtil.hexToColor("#808080"),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: " 円", //" 円",
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(28),
                                          fontWeight: FontWeight.w600,
                                          color:
                                          (int.parse(this._getPutMoney) > 0)
                                              ? ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor)
                                              : ColorsUtil.hexToColor(
                                              "#808080"),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_payment_method_num == "1")
                      Container(
                        margin: EdgeInsets.only(
                          top: ScreenAdapter.height(15),
                          bottom: ScreenAdapter.height(15),
                        ),
                        padding:
                        EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: ColorsUtil.hexToColor("#D8D8D8"),
                                  width: 2.5),
                              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                            )),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                GString.getToString(
                                    this._checkLanguage, "settlement_outMoney"),
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(32),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.mainTitleColor),
                                )),
                            SizedBox(height: ScreenAdapter.height(10)),
                            Container(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                    text: formatMoney(this._showOutMoney),
                                    //" 円",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(52),
                                      fontWeight: FontWeight.w600,
                                      color: (int.parse(this._showOutMoney) > 0)
                                          ? ColorsUtil.hexToColor("#008000")
                                          : ColorsUtil.hexToColor("#808080"),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: " 円", //" 円",
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(28),
                                          fontWeight: FontWeight.w600,
                                          color:
                                          (int.parse(this._showOutMoney) >
                                              0)
                                              ? ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor)
                                              : ColorsUtil.hexToColor(
                                              "#808080"),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_payment_method_num == "1")
              Container(
                width: ScreenAdapter.width(1080),
                alignment: Alignment.center,
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString("imgpublic",
                      "settlement_bottom_lead_cash_${_checkLanguage}"),
                  height: ScreenAdapter.height(280),
                  fit: BoxFit.fitHeight,
                ),
              ),
            if (_payment_method_num == "0" || _payment_method_num == "1")
              Container(
                //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                height: ScreenAdapter.height(200),
                color: ColorsUtil.hexToColor("#DCDCDC"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: ScreenAdapter.width(440),
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.only(left: ScreenAdapter.width(40),bottom: ScreenAdapter.height(30)),
                      child: InkWell(
                        onTap: () {
                          try {
                            //Navigator.pop(context);
                            _showBackEasyLoading();
                            CancelOrder();
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenAdapter.width(180),
                          height: ScreenAdapter.height(80),
                          //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((5.0)),
                          ),
                          child: Text(
                            GString.getToString(this._checkLanguage, "settlement_back"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#2D2D2D"),
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenAdapter.width(80)),
                    _showPrintButton == true
                        ? (
                        _is_allow_receipt == "1"
                            ? Container(
                          margin: EdgeInsets.only(
                              left: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(540),
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              if (_allowClick == true) {
                                setState(() {
                                  _allowClick = false;
                                });

                                _showEasyLoading();

                                doPrintOrderMenu("1");
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(20)),
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
                                borderRadius:
                                new BorderRadius.circular((5.0)),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                      GString.getToString(
                                          this._checkLanguage,
                                          "settlement_confirmButton"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(32),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.settlementBtnColor),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        )
                            : Container(
                          width: ScreenAdapter.width(540),
                          margin: EdgeInsets.only(
                              left: ScreenAdapter.width(20)),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_allowClick == true) {
                                    setState(() {
                                      _allowClick = false;
                                    });

                                    _showEasyLoading();

                                    doPrintOrderMenu("1");
                                  }
                                },
                                child: Container(
                                  //margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                                  width: ScreenAdapter.width(220),
                                  height: ScreenAdapter.height(140),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    ColorsUtil.hexToColor("#148DE8"),
                                    //设置圆角
                                    borderRadius:
                                    new BorderRadius.circular((5.0)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      /*Text(
                                      GString.getToString(
                                          this._checkLanguage,
                                          "settlement_confirmButton"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(
                                            32),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor
                                                .settlementBtnColor),
                                      )),*/
                                      Text(
                                          GString.getToString(
                                              this._checkLanguage,
                                              "settlement_confirmButton_yes"),
                                          style: TextStyle(
                                            fontSize:
                                            ScreenAdapter.fontSize(
                                                32),
                                            fontWeight: FontWeight.w600,
                                            color: ColorsUtil.hexToColor(
                                                Gcolor
                                                    .settlementBtnColor),
                                          )),
                                      /*Text(
                                      GString.getToString(
                                          this._checkLanguage,
                                          "settlement_confirmButton_yes"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(
                                            20),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor
                                                .settlementBtnColor),
                                      )),*/
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenAdapter.width(30)),
                              InkWell(
                                onTap: () {
                                  if (_allowClick == true) {
                                    setState(() {
                                      _allowClick = false;
                                      _is_query_receipt = "2";
                                    });

                                    if (_machineMode == "1") {
                                      _showEasyLoading();
                                    } else {
                                      _showSuccessEasyLoading();
                                    }

                                    doPrintOrderMenu("2");
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: ScreenAdapter.width(10)),
                                  width: ScreenAdapter.width(220),
                                  height: ScreenAdapter.height(140),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    ColorsUtil.hexToColor("#67c23a"),
                                    //设置圆角
                                    borderRadius:
                                    new BorderRadius.circular((5.0)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      /*Text(
                                      GString.getToString(
                                          this._checkLanguage,
                                          "settlement_confirmButton"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(
                                            32),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor
                                                .settlementBtnColor),
                                      )),*/
                                      Text(
                                          GString.getToString(
                                              this._checkLanguage,
                                              "settlement_confirmButton_no2"),
                                          style: TextStyle(
                                            fontSize:
                                            ScreenAdapter.fontSize(
                                                32),
                                            fontWeight: FontWeight.w600,
                                            color: ColorsUtil.hexToColor(
                                                Gcolor
                                                    .settlementBtnColor),
                                          )),
                                      /* Text(
                                      GString.getToString(
                                          this._checkLanguage,
                                          "settlement_confirmButton_no"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(
                                            20),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor
                                                .settlementBtnColor),
                                      )),*/
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    )
                        : Container(
                      margin:
                      EdgeInsets.only(left: ScreenAdapter.width(20)),
                      width: ScreenAdapter.width(540),
                      height: ScreenAdapter.height(100),
                    ),
                  ],
                ),
              ),
            if (_payment_method_num == "2" ||
                _payment_method_num == "3" ||
                _payment_method_num == "4" ||
                _payment_method_num == "5" ||
                _payment_method_num == "6" ||
                _payment_method_num == "7" ||
                _payment_method_num == "8" ||
                _payment_method_num == "9" ||
                _payment_method_num == "10")
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
                          EasyLoading.dismiss();
                          var paymentMethod = ["3","4","5","6","7","8","9","10"];
                          if (paymentMethod.contains(_payment_method_num) == true) {
                            _getPaymentCancelPosData();
                          }else{
                            Navigator.pop(context);
                          }
                          /*if (_payment_method_num == "3" ||
                              _payment_method_num == "4") {
                            _getPaymentCancelPosData();
                          } else {
                            Navigator.pop(context);
                          }*/


                        } catch (_) {}
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: ScreenAdapter.width(180),
                        height: ScreenAdapter.height(80),
                        //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#FFFFFF"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((5.0)),
                        ),
                        child: Text(
                          GString.getToString(this._checkLanguage, "settlement_back"),
                          style: TextStyle(
                              color: ColorsUtil.hexToColor("#2D2D2D"),
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
    );
  }
}
