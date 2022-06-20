import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/cupertino.dart';

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

import 'SettlementCashPage.dart';
import 'SettlementQrCodePage.dart';

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

  var _orderId;
  var _scanQrCode = "";

  var _totalPrice = "";
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

  //顶部展示支付类型
  var _showWechat = true;
  var _showAlipay = true;
  var _showPayPay = true;

  @override
  void initState() {
    super.initState();

    this._checkLanguage = widget.arguments['checkLanguage'];
    this._shopInfo = widget.arguments['shopInfo'];
    this._machineCode = widget.arguments['machineCode'];
    this._orderId = widget.arguments['orderId'];
    this._totalPrice = widget.arguments['totalPrice'];

    this._showWechat = widget.arguments['showWechat'];
    this._showAlipay = widget.arguments['showAlipay'];
    this._showPayPay = widget.arguments['showPayPay'];

    EasyLoading.dismiss();

    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    //打开现金机
    Starttoubi();


    //CancelOrder();
    //newendtradepay();
    //payCubeCloseTransaction();

   _getPrintTicketData();

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

  //进入结算页面获取小票数据
  _getPrintTicketData(){
    var formData = {
      "orderId": this._orderId,
    };
    request('webBootToPrint', method: 'GET', parameters: formData).then((val) async {
      var response = json.decode(val.toString());
      if (response['code'] == 200) {
//print(response);
        setState(() {
          _ticketData = json.encode(response['data']);
        });


      } else {

      }
    });
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
    if (_machineCode != "" && _scanQrCode !="" && _orderId !=null) {
      _showEasyLoading();
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
            doPrintOrderMenu();


        } else {
          //扫码后超时，再继续请求后台，1秒一次 20次
          _doScanCodeTimeOut();


        }
      });

    }
  }

  //扫码后超时，再继续请求后台，1秒一次 20次
  _doScanCodeTimeOut(){
    int queryCount = 0;
    ScanCodeConfirmTimer?.cancel();
    ScanCodeConfirmTimer = Timer.periodic(Duration(milliseconds: 2000), (Timer ConfirmTimer) async {
      queryCount++;
      if(queryCount > 20){
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
          doPrintOrderMenu();


        }
      });



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
  doPrintOrderMenu() async {
    var printStatus = await FlutterPluginMsprinter.getPrintStatus();
    if(printStatus == "0" || printStatus == "8"){
      //print("打印小票来了");
      if(_ticketData != null){//print("先请求了小票数据打印小票来了");

        await FlutterPluginMsprinter.sendPrint(_ticketData,_shopInfo);


        //先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
      if(_scanCode == true){
        //已经结束入金，处理取引终了
        payCubeEndDeposit();
      }else{
        nextOper();
      }

      }else{
        var formData = {
          "orderId": this._orderId,
        };
        request('webBootToPrint', method: 'GET', parameters: formData).then((val) async {
          var response = json.decode(val.toString());

          if (response['code'] == 200) {

            await FlutterPluginMsprinter.sendPrint(json.encode(response['data']),_shopInfo);

            sleep(Duration(milliseconds: 500));
            //先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
            if(_scanCode == true){
              //已经结束入金，处理取引终了
              payCubeCloseTransaction();
            }else{
              nextOper();
            }


          } else {

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
                                    doPrintOrderMenu();
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

  nextOper() async {
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
            //doPrintOrderMenu();
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
        if(int.parse(result) >= int.parse(this._totalPrice)){
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
  Endtoubi() async {
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
          //print("_stopStatus:$_stopStatus");
        }
      });


    } else {
      showToast(GString.getToString(this._checkLanguage, "show_put_money_error"));
    }
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
    Navigator.pushNamed(context, '/home');

  }

  gotonewMenuPage(){
    EasyLoading.dismiss();
    Navigator.pop(context);
    Navigator.pushNamed(context, '/menuPage', arguments: {"checkLanguage": this._checkLanguage,"shopInfo":_shopInfo});

  }

  gotonewSettingPage(){
    EasyLoading.dismiss();
    Navigator.pop(context);
    Navigator.pushNamed(context, '/settingPage', arguments: {"machineCode": this._machineCode,"shopInfo":_shopInfo});


  }

  newendtradepay() async {
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    await Paycube.setReceiveEvent;
    endtimer?.cancel();
    endtimer = Timer.periodic(Duration(milliseconds: 500), (Timer endtradet) async {
      _endStatus =  await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消 _endStatus == "Error-A0--02"
      if (_endStatus == "EndSuccess") {
        //如果出金金额大于0 则先获取出金币种，否则跳转
        if(int.parse(outStringMoney) >0){
          _getPayCubeOutMoney();
        }else{
          if(_isPrint == true){

            gotonewMyhome();

          }else{
            if(_doSetting == true){
              gotonewSettingPage();
            }else{
              gotonewMenuPage();
            }
          }
        }
        //print("交易结束关闭了");
        endtradet.cancel();
      }else{
        await Paycube.endTrade;

      }
    });
  }

  _getPayCubeOutMoney() async {
  //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
  OutMoneytimer?.cancel();
  await Paycube.setReceiveEvent;
  OutMoneytimer = Timer.periodic(Duration(milliseconds: 400), (Timer outMoneyTime) async {
    // 循环一定要记得设置取消条件，手动取消
    String currencyString = await Paycube.getPayCubeOutMoneyCurrency;
    if(currencyString !=""){
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
    var formData = {
      "changeInfo": this._currencyString.trim(),
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "price": int.parse(this._getPutMoney)
    };
    request('webBootToReport', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      if (response['code'] == 200) {

          //已经结束入金，处理取引终了
          payCubeCloseTransaction();



      } else {

      }
    });


  }


  //扫码支付后，直接结束入金，取引终了
  payCubeEndDeposit() async {
    setState(() {
      timer?.cancel();
    });
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stoptimer?.cancel();
    stoptimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopt) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      //await Paycube.setReceiveEvent;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        //print("扫码成功结束");
        payCubeCloseTransaction();
        stopt.cancel();

      }else{
        sleep(Duration(milliseconds: 150));
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
    endtimer = Timer.periodic(Duration(milliseconds: 500), (Timer endtradet) async {
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
        sleep(Duration(milliseconds: 200));
        await Paycube.endTrade;
      }
    });
  }


  //取消购买 要判断是否投入现金，如果投入现金则现金机出金，出已投金额，否则直接取消退回首页
  CancelOrder(){
    var formData = {
      "machineCode": _machineCode,
      "orderId": this._orderId,
    };
    //不用查看返回
    request('webBootCancel', method: 'POST', parameters: formData);

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

  _getPayCubePutMoneyCurrency() async {
    //_putcurrencyString现金机出款币种:61 00 00 62 00 00 63 00 00
    putMoneyCurrencytimer?.cancel();
    await Paycube.setReceiveEvent;
    putMoneyCurrencytimer = Timer.periodic(Duration(milliseconds: 400), (Timer putMoneyCurrencyTime) async {
      // 循环一定要记得设置取消条件，手动取消
      String putcurrencyString = await Paycube.getPayCubePutMoneyCurrency;
      if(putcurrencyString !=""){
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
    var formData = {
      "paymentInfo": this._getPutMoneyCurrency.trim(),
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "price": int.parse(this._getPutMoney)
    };
    request('webBootToReport', method: 'POST', parameters: formData);


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
          decoration: BoxDecoration(
            //设置边框
            border: new Border.all(color: ColorsUtil.hexToColor("#F9F9F9"), width: 0.5),
            //背景颜色
            color: Colors.white,
            //设置圆角
            borderRadius: new BorderRadius.circular((15.0)),
            //设置阴影
            boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#949191"), offset: Offset(1.0, 1.0), blurRadius: 1.5, spreadRadius: 1.5), ],
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
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
        decoration: BoxDecoration(
          //设置边框
          border: new Border.all(color: ColorsUtil.hexToColor("#F9F9F9"), width: 0.5),
          //背景颜色
          color: Colors.white,
          //设置圆角
          borderRadius: new BorderRadius.circular((15.0)),
          //设置阴影
          boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#949191"), offset: Offset(1.0, 1.0), blurRadius: 1.5, spreadRadius: 1.5), ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
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
    var _settlement_payment_method = GString.getToString(this._checkLanguage, "settlement_payment_method");

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
                      //print("onSubmitted 点击了键盘的确定按钮，输出的信息是：${value}");
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
              alignment: Alignment.bottomRight,
              decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#000000"),
                image: new DecorationImage(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.fitHeight,
                  image: AssetImage(GImage.getImageString(_shopInfo, "logo")),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*InkWell(
                        onTap: () {
                          Navigator.pop(context);

                          Future.delayed(Duration.zero, () {
                            Navigator.of(context).pushReplacementNamed('/home');
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: ScreenAdapter.width(80),bottom: ScreenAdapter.height(5)),
                          width: ScreenAdapter.width(110),
                          height: ScreenAdapter.height(55),
                          decoration: BoxDecoration(
                            image: new DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage('assets/images/backbutton_top.png'),
                            ),
                          ),
                          child: Center(
                            //加上Center让文字居中
                            child: Text(
                              GString.getToString(this._checkLanguage, "top_back_button"),
                              style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(26),
                                  color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      )*/
                  InkWell(
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
                          image: AssetImage(GImage.getImageString(_shopInfo, "settlement_back")),
                        ),
                      ),
                      child: Text(GString.getToString(this._checkLanguage, "settlement_back"),
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(30),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                          )),
                    ),
                  ),

                  /*InkWell(
                    onLongPress: (){
                      _showBackEasyLoading();
                      setState(() {
                        _doSetting = true;
                      });
                      //sleep(Duration(milliseconds: 800));
                      CancelOrder();
                    },
                    child: Container(
                      width: ScreenAdapter.width(180),
                      height: ScreenAdapter.height(85),
                      margin: EdgeInsets.only(top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(10)),
                      //spadding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        //color: Colors.red,
                      ),
                    ),
                  ),*/
                ],
              ),
            ),

            //顶部支持支付类型
            Container(
              height: ScreenAdapter.height(250),
              padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(15),right: ScreenAdapter.width(20),  bottom: ScreenAdapter.height(15)),
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
                              Image.asset(GImage.getImageString(_shopInfo, "settlement_cash"),
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

                      if(_showAlipay == true)
                        Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(50), right: ScreenAdapter.width(50)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset(GImage.getImageString(_shopInfo, "settlement_alipay"),
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
                      if(_showWechat == true)
                      Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(50), right: ScreenAdapter.width(50)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset(
                                  GImage.getImageString(_shopInfo, "settlement_wechat"),
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

                      if(_showPayPay == true)
                      Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(50), right: ScreenAdapter.width(50)),
                          width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(140),
                          child: Column(
                            children: [
                              Image.asset(GImage.getImageString(_shopInfo, "settlement_paypay"),
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
              height: ScreenAdapter.height(5),
            ),
            //选择结算方式
            Container(
              //height: ScreenAdapter.height(750),
              padding: EdgeInsets.only(
                left: ScreenAdapter.width(20),
                top: ScreenAdapter.height(15),
                right: ScreenAdapter.width(20),
                bottom: ScreenAdapter.height(15),
              ),
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(15),
                        bottom: ScreenAdapter.height(5)),
                    alignment: Alignment.centerLeft,
                    child: Text(GString.getToString(this._checkLanguage, "settlement_payment_method_title"),
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(34),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(Gcolor.settlementTitleColor),
                        )),
                  ),
                  /*SizedBox(
                    height: ScreenAdapter.height(10),
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Container(
                            padding: EdgeInsets.only(
                                bottom: ScreenAdapter.height(25)),
                            width: ScreenAdapter.width(450),
                            //height: ScreenAdapter.height(580),
                            alignment: Alignment.center,
                            child: Container(
                                width: ScreenAdapter.width(350),
                                //height: ScreenAdapter.height(620),
                                child: Image.asset(
                                    GImage.getImageString(_shopInfo, "saoma"))),
                          ),
                        ],
                      ),

                      SizedBox(
                        width: ScreenAdapter.width(30),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                bottom: ScreenAdapter.height(25)),
                            width: ScreenAdapter.width(450),
                            //height: ScreenAdapter.height(620),
                            alignment: Alignment.center,
                            child: Container(
                                width: ScreenAdapter.width(350),
                                //height: ScreenAdapter.height(620),
                                child: Image.asset(GImage.getImageString(_shopInfo, "xianjin"))),
                          ),
                        ],
                      ),

                    ],
                  ),

                ],
              ),
            ),
            SizedBox(
              height: ScreenAdapter.height(8),
            ),
            Container(
              //width: ScreenAdapter.width(240),
              height: ScreenAdapter.height(200),
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
                      mainAxisAlignment: MainAxisAlignment.end,
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
                                text: this._totalPrice,//GString.getToString(this._checkLanguage, "show_price_front"),
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
                                    text: this._getPutMoney,//" 円",
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
                                    text: this._showOutMoney,//" 円",
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

                  _showPrintButton == true ? InkWell(
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
                      height: ScreenAdapter.height(120),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#148DE8"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text(GString.getToString(this._checkLanguage, "settlement_confirmButton"),
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(30),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                          )),
                    ),
                  ) : Container(
                    margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                    width: ScreenAdapter.width(260),
                    height: ScreenAdapter.height(120),
                  ),
                ],
              ),
            ),
            SizedBox(
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
                    child: Container(
                      width: ScreenAdapter.width(1030),
                      height: ScreenAdapter.height(620),
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
                    ),
                  ),
                ),

              ),

            ),

          ],
        ),
      ),
    );
  }
}
