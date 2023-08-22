import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:paycube/paycube.dart';
import 'EventBus.dart';

void main() {
  runApp(MyApp());
}

//测试现金机在首页打开，其他页面监听投币任务
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "谷町君现金机", //谷町君
      debugShowCheckedModeBanner: false,
      //onGenerateRoute: Application.router.generator,
      //主题
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: MyHomePage(),
      initialRoute: '/',
      //onGenerateRoute:onGenerateRoute,

    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();

    //进入页面后打开现金机
    OpenPayCube();

    //监听增加打开现金机的广播
    eventBus.on<PayCubeEvent>().listen((event) {
      OpenPayCube();
    });

  }


  @override
  void dispose() {

    super.dispose();
  }


  //打开打印机
  OpenPayCube() async {
    String checkStatus = await Paycube.CheckPayCubeStatus;

    //如果检测现金机打开错误，则重新打开一下
    if(checkStatus == "openError"){
      String openStatus = await Paycube.openPayCube;
      print("机器未打开lib未null，重新打开并连接了");
    }else{
      await Paycube.setReceiveEvent;
      print("机器已打开，并setreceive");
    }

    //await Paycube.endTrade;

  }


  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            TextButton(
              child: Container(
                width:120,
                height:100,
                color:Colors.red,
                child:Text(
                  "首页-》进入下一个页面",
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 45.0),
                )
              ),
              onPressed: () async {
                Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                  return new PayPage();
                }));
              },
            ),
          ],
        ),
      ),
    );

  }

}

class PayPage extends StatefulWidget {
  @override
  _PayPageState createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  String _chargingStatus = 'Ready to start.'; //顶部提示

  Timer timer;
  Timer outtimer;
  Timer machinetimer;
  Timer allowtimer;
  Timer stoptimer;
  Timer outmoneytimer;
  Timer getoutmoneytimer;
  Timer endtimer;
  Timer OutMoneytimer;

  var openStatus;
  var _openStatus;
  var _allowStatus;
  var _stopStatus;
  var _outStatus;
  var _endStatus;
  var _getPutMoney; //投币金额
  var _getOutMoney; //出金金额
  var _outMoney = "0";
  var _payMoney = 0; //收款金额
  var isEnd = false;
  var closeTime = false;
  var _machineStatus = "";//机器状态
  var _currencyString = ""; //出金币种
  var outStringMoney; //找零金额

  @override
  void initState() {
    super.initState();
    this._payMoney = 1;
    Starttoubi();

    //OpenPayCube();
    //machinetimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      //getPayCubeMachineStatus();
      // 循环一定要记得设置取消条件，手动取消
      //if(closeTime == true){
        //machinetimer.cancel();
      //}
    //});
  }

  @override
  void dispose() {
    allowtimer?.cancel();
    timer?.cancel();
    stoptimer?.cancel();
    outtimer?.cancel();
    outmoneytimer?.cancel();
    getoutmoneytimer?.cancel();
    endtimer?.cancel();
    OutMoneytimer?.cancel();
    eventBus.fire(new PayCubeEvent('支付成功...'));
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
        /*setState(() {
          allowtimer?.cancel();
        });*/

      }else if (_allowStatus == "Error-F0--16") {
        await Paycube.endTrade;
        sleep(Duration(milliseconds: 200));
        await Paycube.strartPayCube;
      }else{
        //await Paycube.setReceiveEvent;
        //sleep(Duration(milliseconds: 200));

        //await Paycube.endTrade;
        //sleep(Duration(milliseconds: 200));
        await Paycube.strartPayCube;
      print("_allowStatus:$_allowStatus");

      }
    });


  }

  getPutInMoney() async {
    await Paycube.setReceiveEvent;
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) async {
      var result = await Paycube.getPayCubeMoney;print("投币金额result--------$result");
      if (int.parse(result) > 0) {
        setState(() {
          isEnd = true;
          _getPutMoney = result;
        });
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
    if (putMoney > this._payMoney) {

      var endStatus = await Paycube.endPayCube;
      await Paycube.setReceiveEvent;
      stoptimer?.cancel();
      stoptimer = Timer.periodic(Duration(milliseconds: 300), (Timer stopt) async {

        _stopStatus =  await Paycube.getPayCubeStopCashStatus;
        //await Paycube.setReceiveEvent;
        // 循环一定要记得设置取消条件，手动取消
        if (_stopStatus == "StopSuccess") {
          startoutPutMoney(putMoney);
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



    } else if (putMoney == this._payMoney) {
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
            /*setState(() {
            stoptimer?.cancel();
          });*/

          }else{
            sleep(Duration(milliseconds: 150));
            await Paycube.endPayCube;
            print("_stopStatus:$_stopStatus");
          }
        });


    } else {
      setState(() {
        _chargingStatus = "请继续投币";
      });
    }
  }

  startoutPutMoney(putMoney) async {
    setState(() {
      _chargingStatus = "开始找零";
      var outMoney = putMoney - this._payMoney;
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
          /*sleep(Duration(milliseconds: 100));
          String currencyString = await Paycube.getPayCubeOutMoneyCurrency;
          if(currencyString !=""){
            setState(() {
              _currencyString = currencyString;

            });
            print("_currencyString现金机出款币种:${currencyString}");
          }*/


          //结束交易
          newendtradepay();

          getoutmoneyt.cancel();


          //outtimer.cancel();
        } else {
          print("出金错误了:${result}");
          //setState(() {
          //_chargingStatus = "出金金额与找零金额不一致";
          //});
        }
      }else{
        print("_getOutMoney现金机出款金额:$result");
      }
    });



  }

  newendtradepay() async {print("9999999");

    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    await Paycube.setReceiveEvent;print("88888");
  endtimer?.cancel();
    endtimer = Timer.periodic(Duration(milliseconds: 500), (Timer endtradet) async {
      _endStatus =  await Paycube.getPayCubeEndTradeStatus;print("777777");
      // 循环一定要记得设置取消条件，手动取消
      if (_endStatus == "EndSuccess" || _endStatus == "Error-A0--02") {
        setState(() {
          _chargingStatus = "出金金额与找零金额一直，找零结束交易结束";
          isEnd = false;
          closeTime = true;

          //machinetimer.cancel();

          //结束后，各设置清空，跳转回首页
          _getPutMoney = "0"; //投币金额
          _getOutMoney = "0"; //出金金额
          //_outMoney = "0";
          _payMoney = 0; //收款金额
          //outStringMoney = "0"; //找零金额
          //_currencyString = "";//出金币种


        });
        //如果出金金额大于0 则先获取出金币种，否则跳转
        if(int.parse(outStringMoney) >0){
          _getPayCubeOutMoney();
        }else{
          gotonewMyhome();
        }



        print("交易结束关闭了");
        endtradet.cancel();


      }/*else if(_endStatus == "Error-A0--02"){
        await Paycube.setReceiveEvent;
        sleep(Duration(milliseconds: 500));
        print("_endStatus关机中:$_endStatus");
      }*/else{


        await Paycube.endTrade;
        print("_endStatus:$_endStatus");
      }
    });
  }

  _getPayCubeOutMoney(){print("tongjichujin");
    OutMoneytimer?.cancel();
    OutMoneytimer = Timer.periodic(Duration(milliseconds: 500), (Timer outMoneyTime) async {
      // 循环一定要记得设置取消条件，手动取消
      String currencyString = await Paycube.getPayCubeOutMoneyCurrency;
      if(currencyString !=""){
        setState(() {
          _currencyString = currencyString;

        });
        print("_currencyString现金机出款币种:${currencyString}");
        print("出金币种获取到了交易结束关闭了");
        gotonewMyhome();
        outMoneyTime.cancel();
      }

    });
  }

  gotonewMyhome() async {
    setState(() {
      _currencyString = "";//出金币种
      outStringMoney = "0"; //找零金额
    });
    Navigator.pop(context);

    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new MyHomePage();
    }));
  }



  //循环获取金额
  getPutMoney() async {
    String result = await Paycube.getPayCubeMoney;print("投币金额result--------$result");
    if (int.parse(result) > 0) {
      setState(() {
        isEnd = true;
        _getPutMoney = result;
      });
    }
  }

/*  getOutMoney() async {
    //await Paycube.setReceiveEvent;
    
    String result = await Paycube.getPayCubeOutMoney;
    
    print("_getOutMoney现金机出款金额:${result}");
    if (int.parse(result) > 0) {
      setState(() {
        _getOutMoney = result;
      });
      print("result == outStringMoney-------$result == $outStringMoney");
      //如果出金金额与找零金额相同，则关闭机器
      if (result == outStringMoney) {
        //出金币种
        String currencyString = await Paycube.getPayCubeOutMoneyCurrency;
        if(currencyString !=""){
          setState(() {
            _currencyString = currencyString;
          });
          print("_currencyString现金机出款币种:${currencyString}");
          endtradepay();
        }



        //outtimer.cancel();
      } else {
        //setState(() {
          //_chargingStatus = "出金金额与找零金额不一致";
        //});
      }
    }
    //outtimer?.cancel();
  }*/

  endtradepay() async {
    print("过来关闭机器了");
    //睡眠1秒钟
    //sleep(Duration(seconds: 1));
    await Paycube.setReceiveEvent;
    sleep(Duration(milliseconds: 500));
    
    var endTrade = await Paycube.endTrade;
    
    //await Paycube.endTrade;
    //sleep(Duration(seconds: 1));
    

    if (endTrade == "endtradesuccess") {
      //_machineStatus = await Paycube.getPayCubeMachineStatus;
      //if (_machineStatus == "10") {
        print("gom1000000000000000交易结束后是否关闭了机器$_machineStatus");
        setState(() {
          _chargingStatus = "出金金额与找零金额一直，找零结束交易结束";
          isEnd = false;
          closeTime = true;
          timer.cancel();
          outtimer.cancel();
          //machinetimer.cancel();

          //结束后，各设置清空，跳转回首页
          _getPutMoney = "0"; //投币金额
          _getOutMoney = "0"; //出金金额
          //_outMoney = "0";
          _payMoney = 0; //收款金额
          outStringMoney = "0"; //找零金额
          _currencyString = "";//出金币种



        });
        await Paycube.setReceiveEvent;
        sleep(Duration(seconds: 20));
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
          return new MyHomePage();
        }));



    }else{
      setState((){
        isEnd = false;
        closeTime = true;
        timer.cancel();
        outtimer.cancel();
        print("关闭机器出现问题了，状态不对");
      });
    }
  }

  Future<void> outPayCube(outStringMoney) async {

    String result = await Paycube.outPayCubeMoney(outStringMoney);
  }

  Future<void> getPayCubeMachineStatus() async {

    String result = await Paycube.getPayCubeMachineStatus;

    print("_machineStatus======$result");
    setState(() {
      _machineStatus = result;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_chargingStatus\n',
                  style: TextStyle(color: Colors.red, fontSize: 40.0)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("付款金额",
                    style: TextStyle(color: Colors.black45, fontSize: 20.0)),
                Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "40",
                          contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.blue, //边线颜色为黄色
                              width: 2, //边线宽度为2
                            ),)),
                      keyboardType: TextInputType.number, //数字

                      onChanged: (value) {
                        setState(() {
                          this._payMoney = int.parse(value);
                        });
                      },
                    )
                ),
              ],
            ),


            (isEnd == false) ? Container(
              padding: EdgeInsets.all(20),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("开始入金",
                        style: TextStyle(color: Colors.black45, fontSize: 20.0))
                  ],
                ),
                onTap: () {
                  Starttoubi();
                },
              ),
            ) : Container(
              padding: EdgeInsets.all(20),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("确认结束打印小票找零",
                        style: TextStyle(color: Colors.black45, fontSize: 20.0))
                  ],
                ),
                onTap: () {
                  Endtoubi();
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text("入金金额------>"),
                  Text('$_getPutMoney'),
                ],
              ),
            ),

            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("出金金额",
                    style: TextStyle(color: Colors.black45, fontSize: 20.0)),
                Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "40",
                          contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none)),
                      keyboardType: TextInputType.number, //数字

                      onChanged: (value) {
                        setState(() {
                          this._outMoney = value;
                        });
                      },
                    )
                ),
              ],
            ),*/
            /*Container(
              padding: EdgeInsets.all(20),
              child: InkWell(
                // child: Text("申请提现", style: TextStyle(color: Colors.white)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("出金开始",
                        style: TextStyle(color: Colors.black45, fontSize: 20.0))
                  ],
                ),
                onTap: () {
                  outPayCube("60");
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("结束入金",
                        style: TextStyle(color: Colors.black45, fontSize: 20.0))
                  ],
                ),
                onTap: () {
                  endtoubi();
                },
              ),
            ),

            Container(
              padding: EdgeInsets.all(20),
              child: InkWell(
                // child: Text("申请提现", style: TextStyle(color: Colors.white)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("交易结束",
                        style: TextStyle(color: Colors.black45, fontSize: 20.0))
                  ],
                ),
                onTap: () {
                  endtrade();
                },
              ),
            ),*/

            


          ],
        ),
      ),
    );
  }
}
