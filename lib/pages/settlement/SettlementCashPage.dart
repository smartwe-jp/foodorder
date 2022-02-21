import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:paycube/paycube.dart';

class SettlementCashPage extends StatefulWidget {
  Map arguments;
  SettlementCashPage({Key key, this.arguments}) : super(key: key);

  _SettlementCashPageState createState() => _SettlementCashPageState();
}

class _SettlementCashPageState extends State<SettlementCashPage> {

  var _orderId;
  var _totalPrice = "";
  String _machineCode = "";
  var _getPutMoney = "0"; //投币金额
  var _getOutMoney = "0"; //出金金额

  Timer timer;
  //Timer outtimer;
  //Timer machinetimer;
  Timer allowtimer;
  Timer stoptimer;
  Timer outmoneytimer;
  Timer getoutmoneytimer;
  Timer endtimer;

  var _allowStatus;
  var _stopStatus;
  var _outStatus;
  var _endStatus;
  var outStringMoney; //找零金额
  var _currencyString; // 出金币种

  var _showPrintButton = false; //如果投币金额不足，则不显示打印按钮


  @override
  void initState() {
    super.initState();

    this._orderId = widget.arguments['orderId'];
    this._machineCode = widget.arguments['machineCode'];
    this._totalPrice = widget.arguments['totalPrice'].toString();
print(this._totalPrice );
    //打开现金机
    Starttoubi();
  }

  @override
  void dispose() {
    allowtimer?.cancel();
    timer?.cancel();
    stoptimer?.cancel();
    //outtimer?.cancel();
    outmoneytimer?.cancel();
    getoutmoneytimer?.cancel();
    endtimer?.cancel();
    eventBus.fire(new PayCubeEvent('支付成功...'));
    eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();
  }

  //现金机开始 打开现金机，准备开始投币
  Starttoubi() async {
    //入金开始
    String strartPayCube = await Paycube.strartPayCube;
    await Paycube.setReceiveEvent;
    allowtimer?.cancel();
    allowtimer = Timer.periodic(Duration(milliseconds: 300), (Timer allowt) async {
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

    int putMoney = int.parse(this._getPutMoney); //投币金额
    //如果投币金额大于等于收款金额，则判断找零或结束
    if (putMoney > int.parse(this._totalPrice)) {

      var endStatus = await Paycube.endPayCube;
      await Paycube.setReceiveEvent;
      stoptimer?.cancel();
      stoptimer = Timer.periodic(Duration(milliseconds: 300), (Timer stopt) async {

        _stopStatus =  await Paycube.getPayCubeStopCashStatus;
        //await Paycube.setReceiveEvent;
        // 循环一定要记得设置取消条件，手动取消
        if (_stopStatus == "StopSuccess") {
          startOutPutMoney(putMoney);
          print("不准投币");
          stopt.cancel();
          /*setState(() {
            stoptimer?.cancel();
          });*/

        }else{
          sleep(Duration(milliseconds: 150));
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
      var outMoney = putMoney - int.parse(this._totalPrice); //找零金额
      print("找零outMoney:${outMoney}");
      outStringMoney = outMoney.toString();
      print("outStringMoney找零金额:${outStringMoney}");
    });
    String outResult = await Paycube.outPayCubeMoney(outStringMoney);print(outResult);
    await Paycube.setReceiveEvent;
    outmoneytimer?.cancel();
    outmoneytimer = Timer.periodic(Duration(milliseconds: 300), (Timer outmoneyt) async {
      _outStatus =  await Paycube.getPayCubeOutMoneyStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_outStatus == "OutSuccess") {
        //获取出金金额
        sleep(Duration(milliseconds: 300));
        getPayCubeoutMoney();
        print("开始出币了");
        outmoneyt.cancel();

      }else if(_outStatus == "Error-A0--02"){
        await Paycube.setReceiveEvent;
        sleep(Duration(milliseconds: 500));
        await Paycube.getPayCubeOutMoneyStatus;
        print("_outStatus处理中:$_outStatus");
      }else{
        sleep(Duration(milliseconds: 200));
        await Paycube.outPayCubeMoney(outStringMoney);
        print("_outStatus:$_outStatus");
      }
    });

  }

  getPayCubeoutMoney() async {
    getoutmoneytimer?.cancel();
    getoutmoneytimer = Timer.periodic(Duration(milliseconds: 300), (Timer getoutmoneyt) async {
      String result = await Paycube.getPayCubeOutMoney;
      // 循环一定要记得设置取消条件，手动取消
      if (int.parse(result) > 0) {
        setState(() {
          _getOutMoney = result;
        });
        print("result ========= outStringMoney-------$result == $outStringMoney");
        //如果出金金额与找零金额相同，则关闭机器
        if (result == outStringMoney) {
          //出金币种
          sleep(Duration(milliseconds: 100));
          String currencyString = await Paycube.getPayCubeOutMoneyCurrency;
          if(currencyString !=""){
            setState(() {
              _currencyString = currencyString;

            });
            print("_currencyString现金机出款币种:${currencyString}");
          }


          //结束交易
          newendtradepay();

          getoutmoneyt.cancel();


          //outtimer.cancel();
        } else {
          print("出金错误了:${result}");
        }
      }else{
        print("_getOutMoney现金机出款金额:$result");
      }
    });
  }

  newendtradepay() async {
  //取引终了结束交易
  var endTrade = await Paycube.endTrade;
  await Paycube.setReceiveEvent;print("88888");
  endtimer?.cancel();
  endtimer = Timer.periodic(Duration(milliseconds: 500), (Timer endtradet) async {
    _endStatus =  await Paycube.getPayCubeEndTradeStatus;print("777777");
    // 循环一定要记得设置取消条件，手动取消
    if (_endStatus == "EndSuccess" || _endStatus == "Error-A0--02") {

      gotonewMyhome();

      print("交易结束关闭了");
      endtradet.cancel();


    }else{


      await Paycube.endTrade;
      print("_endStatus:$_endStatus");
    }
  });
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
              width: ScreenAdapter.width(640),
              height: ScreenAdapter.height(580),
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

                    child: Column(
                      children: [
                        Center(
                            child: Text("应付金额:$this._totalPrice",style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(38.0),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000")
                            ))
                        ),
                        Center(
                            child: Text("已投金额:$this._getPutMoney",style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(38.0),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000")
                            ))
                        ),
                        _showPrintButton == true ? InkWell(
                          onTap: (){
                            Endtoubi();
                          },
                          child: Center(
                              child: Container(
                                width: 50,
                                height: 15,
                                color: Colors.blue,
                                child: Text("投币结束，打印小票"),
                              )
                          ),
                        ) : Container(child: Text("请继续投币"),),


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
