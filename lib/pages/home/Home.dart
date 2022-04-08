import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:paycube/paycube.dart';
import 'package:get/get.dart';
import 'package:foodorder/controller/homePageController.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController controller = Get.put(HomePageController());
  //HomePageController controller = Get.find<HomePageController>();

  Timer checkTimer;
  Timer stopChecktimer;
  Timer closetimer;

  var _stopStatus;
  var _closeStatus;

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();
    //进入页面后打开现金机
    //OpenPayCube();

    //监听增加打开现金机的广播
    eventBus.on<PayCubeEvent>().listen((event) {
      CheckPayCube();
    });

    _clearCartList();
    //监听清除购物车的广播
    eventBus.on<clearCartEvent>().listen((event) {
      _clearCartList();
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


  _clearCartList() {

  //if(controller.cartItems.length >0){
    controller.removeAllFromCart();

  //}
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
                image: AssetImage("assets/images/home.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Container(
              padding: EdgeInsets.only(top:ScreenAdapter.height(1450),bottom: ScreenAdapter.height(50)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _clearCartList();
                      Navigator.pushNamed(context, '/menuPage',arguments: {"checkLanguage": "JP"});
                    },
                    child: Container(
                      width: ScreenAdapter.width(217),
                      height: ScreenAdapter.height(90),
                      decoration: BoxDecoration(
                        //color: Color(0x11111111),
                        image: DecorationImage(
                            //alignment: Alignment.topCenter,
                            image: AssetImage('assets/images/home_button.png'),
                            fit: BoxFit.fill),
                      ),
                      child: Center(
                        //加上Center让文字居中
                        child: Text(
                          '日本語',
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
                      _clearCartList();
                      Navigator.pushNamed(context, '/menuPage',arguments: {"checkLanguage": "CH"});
                    },
                    child: Container(
                      width: ScreenAdapter.width(217),
                      height: ScreenAdapter.height(90),
                      decoration: BoxDecoration(
                        //color: Color(0x11111111),
                        image: DecorationImage(
                            //alignment: Alignment.topCenter,
                            image: AssetImage('assets/images/home_button.png'),
                            fit: BoxFit.fill),
                      ),
                      child: Center(
                        //加上Center让文字居中
                        child: Text(
                          '中文',
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
                      _clearCartList();
                      Navigator.pushNamed(context, '/menuPage',arguments: {"checkLanguage": "EN"});
                    },
                    child: Container(
                      width: ScreenAdapter.width(217),
                      height: ScreenAdapter.height(90),
                      decoration: BoxDecoration(
                        //color: Color(0x11111111),
                        image: DecorationImage(
                            //alignment: Alignment.topCenter,
                            image: AssetImage('assets/images/home_button.png'),
                            fit: BoxFit.fill),
                      ),
                      child: Center(
                        //加上Center让文字居中
                        child: Text(
                          'English',
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
          ),
          ),
    );
  }
}
