import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/fontSize.dart';
import 'package:foodorder/config/index.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:get/get.dart';
import 'package:paycube/paycube.dart';

import 'SettlementCashPage.dart';
import 'SettlementQrCodePage.dart';

class SettlementPage extends StatefulWidget {
  Map arguments;
  SettlementPage({Key key, this.arguments}) : super(key: key);

  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  final HomePageController controller = Get.put(HomePageController());

  TextEditingController _scanQrCodeController;
  final FocusNode _scanQrCodeFocusNode = FocusNode();

  bool checkboxSelected = true;

  String _machineCode = "";

  //默认语言包选择
  var _checkLanguage = "JP";

  var _orderId;
  var _scanQrCode = "";

  var _totalPrice = "";
  var _getPutMoney = "0"; //投币金额
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

  var _allowStatus;
  var _stopStatus;
  var _outStatus;
  var _endStatus;
  var outStringMoney = "0"; //找零金额
  var _currencyString; // 出金币种
  var _isPrint = true; //是否打印小票，默认打印，如果取消订单则不打印。

  var _showPrintButton = false; //如果投币金额不足，则不显示打印按钮

  @override
  void initState() {
    super.initState();

    this._checkLanguage = widget.arguments['checkLanguage'];
    this._machineCode = widget.arguments['machineCode'];

    _doSubmitOrder();
    _scanQrCodeController = TextEditingController();


    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    //打开现金机
    Starttoubi();
    //CancelOrder();
    //newendtradepay();

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
    eventBus.fire(new PayCubeEvent('支付成功...'));
    eventBus.fire(new clearCartEvent('支付成功...'));

    super.dispose();
  }


  //购物车
/*
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
              top: BorderSide(color: Colors.grey.shade100, width: 1.0),
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: Container(
              padding: EdgeInsets.only(left: ScreenAdapter.width(5)),
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
                      TextSpan(
                        text: " X ${d.goodsNum}",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.cartListTitleCount),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                      TextSpan(
                        text: d.optionVoListMsg,
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
              child: Text(
                "￥ ${d.currentPrice.toString()}",
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
*/
  getItemTotal(List items) {
    int sum = 0;
    items.forEach((e) {
      sum += e.currentPrice;
    });
    return sum;
  }
  //提交订单
  _doSubmitOrder(){
    if(_machineCode !=""){
      var cartItems = controller.getcartItems;
      List selectedItem = [];


      for(var oneItem in cartItems){
        var optionMap = {};
        if(oneItem["optionGroupVoList"] == ""){
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "qty": oneItem["goodsNum"]
          };
        }else{
          var optionGroupVoList = oneItem["optionGroupVoList"];
          var itemsOption = optionGroupVoList.split(',');
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "optionList": itemsOption,
            "qty": oneItem["goodsNum"]
          };
        }
        selectedItem.add(optionMap);
      }
      var orderTotlaPrice = getItemTotal(controller.cartItems);
      var formData = {
        "language": this._checkLanguage,
        "machineCode": _machineCode,
        "orderLineList": selectedItem,
        "total": orderTotlaPrice
      };
      request('webBootOrder', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());

        if (response['code'] == 200) {
          setState(() {
            _orderId = response['data'];
            _totalPrice = orderTotlaPrice.toString();
          });
          /*if(paymentMethod == "cash"){
            doShowSettlementCashPage(response['data'],orderTotlaPrice);
          }else if(paymentMethod == "qrCode"){
            doShowSettlementQrCodePage(response['data'],orderTotlaPrice);
          }*/


        }
      });
    }
  }


  //扫码支付
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
          doPrintOrderMenu();
          /*if(response['data'] == true){
            doPrintOrderMenu();
            setState(() {
              _payStatus = "支付成功，等待打印小票";
            });
          }else{
            _payStatus = "支付失败请重试";
          }*/
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
    var formData = {
      "orderId": this._orderId,
    };print(formData);
    request('webBootToPrint', method: 'GET', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      print("print$response");
      if (response['code'] == 200) {
        //去打印小票
        //doPrintOrderMenu();
        showToast("打印小票");
        sleep(Duration(milliseconds: 3000));
        gotonewMyhome();
      } else {

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
        print("准许投币");

        allowt.cancel();

      }else if (_allowStatus == "Error-F0--16") {
        await Paycube.endTrade;
        sleep(Duration(milliseconds: 200));
        await Paycube.strartPayCube;
      }else if (_allowStatus == "Error-A0--02") {
        sleep(Duration(milliseconds: 300));
      }else{

        await Paycube.strartPayCube;
        print("_allowStatus:$_allowStatus");

      }
    });


  }

  //获取投入金额
  getPutInMoney() async {
    await Paycube.setReceiveEvent;
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) async {
      var result = await Paycube.getPayCubeMoney;print("投币金额result--------$result");
      if (int.parse(result) > 0) {
        setState(() {
          _getPutMoney = result;
        });
        if(int.parse(result) >= int.parse(this._totalPrice)){
          setState(() {
            _showPrintButton = true;
          });
        }
      }
    });
  }

  //入金开始-入金结束-交易结束-出金开始-交易结束  中间可set
  Endtoubi() async {
    setState(() {
      timer?.cancel();
    });
    print("aaaaaa");
    int putMoney = int.parse(this._getPutMoney); //投币金额
    //如果投币金额大于等于收款金额，则判断找零或结束
    if (putMoney > int.parse(this._totalPrice)) {

      setState(() {
        var outMoney = putMoney - int.parse(this._totalPrice); //找零金额
        _showOutMoney = outMoney.toString(); //找零金额
      });
      await Paycube.setReceiveEvent;
      var endStatus = await Paycube.endPayCube;
      stoptimer?.cancel();
      stoptimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopt) async {
        print("bbbbbbb");
        _stopStatus =  await Paycube.getPayCubeStopCashStatus;
        //await Paycube.setReceiveEvent;
        // 循环一定要记得设置取消条件，手动取消
        if (_stopStatus == "StopSuccess") {
          startOutPutMoney(putMoney);
          print("不准投币");
          stopt.cancel();

        }else if(_stopStatus == "Error-A0--02"){
          //处理中
          sleep(Duration(milliseconds: 350));
          await Paycube.endPayCube;
          print("ccccccc");
        }else{
          sleep(Duration(milliseconds: 350));
          await Paycube.endPayCube;
          print("_stopStatus:$_stopStatus");
        }
      });

    } else if (putMoney == int.parse(this._totalPrice)) {
      //结束入金
      var endStatus = await Paycube.endPayCube;
      await Paycube.setReceiveEvent;
      stoptimer?.cancel();
      stoptimer = Timer.periodic(Duration(milliseconds: 300), (Timer stopt) async {
        _stopStatus =  await Paycube.getPayCubeStopCashStatus;
        // 循环一定要记得设置取消条件，手动取消
        if (_stopStatus == "StopSuccess") {
          //结束交易
          newendtradepay();
          stopt.cancel();

        }else{
          sleep(Duration(milliseconds: 150));
          await Paycube.endPayCube;
          print("_stopStatus:$_stopStatus");
        }
      });


    } else {
      showToast("请继续投币");
    }
  }

  startOutPutMoney(putMoney) async {
    setState(() {

      //print("找零outMoney:${outMoney}");
      outStringMoney = _showOutMoney;
      print("outStringMoney找零金额:${outStringMoney}");
    });
    await Paycube.setReceiveEvent;

    String outResult = await Paycube.outPayCubeMoney(outStringMoney);print(outResult);

    outmoneytimer?.cancel();
    outmoneytimer = Timer.periodic(Duration(milliseconds: 200), (Timer outmoneyt) async {
      _outStatus =  await Paycube.getPayCubeOutMoneyStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_outStatus == "OutSuccess") {
        //获取出金金额
        sleep(Duration(milliseconds: 100));
        //getPayCubeoutMoney();
        //结束交易
        newendtradepay();
        print("开始出币了");
        outmoneyt.cancel();

      }else if(_outStatus == "Error-A0--02"){
        //await Paycube.setReceiveEvent;
        sleep(Duration(milliseconds: 200));
        //await Paycube.getPayCubeOutMoneyStatus;
        print("_outStatus处理中:$_outStatus");
      }else{
        sleep(Duration(milliseconds: 200));
        await Paycube.outPayCubeMoney(outStringMoney);
        print("_outStatus:$_outStatus");
      }
    });

  }


  gotonewMyhome(){
    Navigator.pop(context);

    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  newendtradepay() async {
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    await Paycube.setReceiveEvent;print("88888");
    endtimer?.cancel();
    endtimer = Timer.periodic(Duration(milliseconds: 200), (Timer endtradet) async {
      _endStatus =  await Paycube.getPayCubeEndTradeStatus;print("777777");
      // 循环一定要记得设置取消条件，手动取消
      if (_endStatus == "EndSuccess" || _endStatus == "Error-A0--02") {

        //如果出金金额大于0 则先获取出金币种，否则跳转
        if(int.parse(outStringMoney) >0){
          _getPayCubeOutMoney();
        }else{
          if(_isPrint == true){
            //去打印小票
            doPrintOrderMenu();
          }else{
            showToast("投币后已取消订单");
            sleep(Duration(milliseconds: 3000));
            gotonewMyhome();
          }
        }

        print("交易结束关闭了");
        endtradet.cancel();


      }else{


        await Paycube.endTrade;
        print("_endStatus:$_endStatus");
      }
    });
  }

  _getPayCubeOutMoney() async {print("tongjichujin");
  //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
  OutMoneytimer?.cancel();
  await Paycube.setReceiveEvent;
  OutMoneytimer = Timer.periodic(Duration(milliseconds: 200), (Timer outMoneyTime) async {
    // 循环一定要记得设置取消条件，手动取消
    String currencyString = await Paycube.getPayCubeOutMoneyCurrency;
    if(currencyString !=""){
      setState(() {
        _currencyString = currencyString;

      });
      print("_currencyString现金机出款币种:${currencyString}");
      print("出金币种获取到了交易结束关闭了");
      if(_isPrint == true){
        //汇报出金币种然后去打印小票
        reportOutMoney();
      }else{
        showToast("投币后已取消订单");
        sleep(Duration(milliseconds: 3000));
        gotonewMyhome();
      }


      //gotonewMyhome();
      outMoneyTime.cancel();
    }

  });
  }

  //汇报出金币种,请求后台
  reportOutMoney(){
    var formData = {
      "changeInfo": this._currencyString.trim(),
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "price": int.parse(this._getPutMoney)
    };print(formData);
    request('webBootToReport', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      print("huibao$response");
      if (response['code'] == 200) {
        //去打印小票
        doPrintOrderMenu();
      } else {

      }
    });


  }




  //取消购买 要判断是否投入现金，如果投入现金则现金机出金，出已投金额，否则直接取消退回首页
  CancelOrder(){
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
  }


  //弹窗加载新widget页面
/*  doShowSettlementCashPage(orderId, totalPrice) async {
    var result = await showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (context) {
          return SettlementCashPage(arguments: {"orderId": orderId, "totalPrice":totalPrice, "machineCode":_machineCode});

        });
  }

  doShowSettlementQrCodePage(orderId, totalPrice) async {

    var result = await showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (context) {
          return SettlementQrCodePage(
              arguments: {"orderId": orderId, "totalPrice":totalPrice, "machineCode":_machineCode});
        });
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtil.hexToColor("#D8D8D8"),
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
              width: ScreenAdapter.getScreenWidth(),
              height: ScreenAdapter.height(95),
              padding: EdgeInsets.only(left: ScreenAdapter.width(10),right: ScreenAdapter.width(20)),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#000000"),
                image: new DecorationImage(
                  alignment: Alignment.centerRight,
                  //fit: BoxFit.fitWidth,
                  image: AssetImage('assets/images/logo.png'),
                ),
              ),
            ),

            //顶部支持支付类型
            Container(
              height: ScreenAdapter.height(350),
              padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(50), bottom: ScreenAdapter.height(50)),
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(GString.getToString(this._checkLanguage, "settlement_payment_method"),
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(36),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                      )),
                  SizedBox(height: ScreenAdapter.height(20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(5), right: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset('assets/images/settlement_cash.png',
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

                      Container(
                          padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(5), right: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset('assets/images/settlement_alipay.png',
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
                      Container(
                          padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(5), right: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset(
                                  'assets/images/settlement_wechat.png',
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

                      Container(
                          padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(5), right: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset('assets/images/settlement_paypay.png',
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

                    ],
                  ),

                ],
              ),
            ),

            SizedBox(
              height: ScreenAdapter.height(15),
            ),
            //选择结算方式
            Container(
              //height: ScreenAdapter.height(750),
              padding: EdgeInsets.only(
              left: ScreenAdapter.width(20),
              top: ScreenAdapter.height(20),
              right: ScreenAdapter.width(20),
                bottom: ScreenAdapter.height(30),
              ),
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: ScreenAdapter.height(15),
                    bottom: ScreenAdapter.height(15)),
                alignment: Alignment.centerLeft,
                child: Text(GString.getToString(this._checkLanguage, "settlement_payment_method_title"),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(48),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(Gcolor.settlementTitleColor),
                    )),
              ),
              SizedBox(
                width: ScreenAdapter.height(30),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(10),
                        bottom: ScreenAdapter.height(25)),
                    width: ScreenAdapter.width(500),
                    height: ScreenAdapter.height(660),
                    alignment: Alignment.center,
                    child: Container(
                        width: ScreenAdapter.width(500),
                        height: ScreenAdapter.height(620),
                        child: Image.asset(
                            'assets/images/settlement_zhinan_cash.gif')),
                  ),
                  SizedBox(
                    width: ScreenAdapter.width(30),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(10),
                        bottom: ScreenAdapter.height(25)),
                    width: ScreenAdapter.width(500),
                    height: ScreenAdapter.height(660),
                    alignment: Alignment.center,
                    child: Container(
                        width: ScreenAdapter.width(500),
                        height: ScreenAdapter.height(620),
                        child: Image.asset(
                            'assets/images/settlement_zhinan_qr.gif')),
                  ),

                ],
              ),

            ],
              ),
            ),
            SizedBox(
              height: ScreenAdapter.height(15),
            ),
            Container(
              //width: ScreenAdapter.width(240),
              height: ScreenAdapter.height(230),
             // margin: EdgeInsets.only(left: ScreenAdapter.width(60),top: ScreenAdapter.width(50)),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(20),
                  top: ScreenAdapter.height(20),
                  right: ScreenAdapter.width(20),
                  bottom: ScreenAdapter.height(20)
              ),
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              alignment: Alignment.center,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: ScreenAdapter.width(80),
                        top: ScreenAdapter.height(20),
                        right: ScreenAdapter.width(80),
                        bottom: ScreenAdapter.height(20)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("注文金額",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(25),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Text(this._totalPrice,
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(52),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
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
                        left: ScreenAdapter.width(80),
                        top: ScreenAdapter.height(20),
                        right: ScreenAdapter.width(80),
                        bottom: ScreenAdapter.height(20)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("預り金",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(25),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Text(this._getPutMoney,
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(52),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
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
                        left: ScreenAdapter.width(80),
                        top: ScreenAdapter.height(20),
                        right: ScreenAdapter.width(80),
                        bottom: ScreenAdapter.height(20)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("おつり",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(25),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
                        SizedBox(height: ScreenAdapter.height(10)),
                        Text(_showOutMoney,
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(52),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ScreenAdapter.height(15),
            ),
            Expanded(
                child: Container(
              width: ScreenAdapter.width(1080),
              padding: EdgeInsets.only(left: ScreenAdapter.width(40)),
              alignment: Alignment.centerLeft,
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              child: InkWell(
                onTap: (){
                  Navigator.pop(context);

                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamed(context, '/menuPage',arguments: {"checkLanguage": this._checkLanguage});
                  });

                },
                child: Row(
                  children: [
                    Container(
                      width: ScreenAdapter.width(240),
                      height: ScreenAdapter.height(90),
                      margin: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.width(50)),
                      //spadding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                        image: AssetImage('assets/images/settlement_back.png'),
                      ),
                      ),
                      child: Text(GString.getToString(this._checkLanguage, "settlement_back"),
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(48),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                          )),
                    ),
                    _showPrintButton == true ? InkWell(
                      onTap: (){
                        Endtoubi();
                      },
                      child: Center(
                          child: Container(
                            width: ScreenAdapter.width(250),
                            height: ScreenAdapter.height(80),
                            color: Colors.blue,
                            child: Text("投币结束，打印小票"),
                          )
                      ),
                    ) : Container(child: Text("请继续投币"),),
                  ],
                ),
              ),
            )
            ),

          ],
        ),
      ),
    );
  }
}
