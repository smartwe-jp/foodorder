import 'dart:async';
import 'dart:convert';


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
  var _shopInfo = "kanran";
  var _menu_direction = "1";//1 默认顶部横向  2 左侧纵向
  var _machineMode = "1";//1 券卖机  2 精算机

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();
    //先获取店铺信息已获取路径用
    _getShopInfo();

    //系统配置
    //_getMenuDirection();
    _getSystemSettingInfo();

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
    if(controller.cartItems.length >0){
      controller.removeAllFromCart();
    }
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
  }

  //获取菜单方向
  _getMenuDirection() async {
    var menuDirectionInfo = await HomeServices.getMenuDirectionInfo();
    if (menuDirectionInfo != "") {
      setState(() {
        _menu_direction = menuDirectionInfo;
      });
    }else{
      Storage.setString('menuDirection', "1");//1 默认顶部横向  2 左侧纵向
    }
  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();

    if (systemSettingInfo.isEmpty) {//print("jinlailehome");
    var DiningTypeInfo = await HomeServices.getDiningTypeInfo();
      var systemSettingData = {
        "diningType":(DiningTypeInfo !="" && DiningTypeInfo!=null) ? DiningTypeInfo : "1", //1堂食 2外带
        "menuDirection":"1",//1顶部横向 2左侧竖
        "printPaperSize":"1",//1 58mm 2 80mm
        "isAllowReceipt":"1",//1必须打印小票 2不必须
        "machineMode":"1",//1券卖机 2精算机
      };
      Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));//1 默认58mm  2 宽纸80mm

    Map systemSettingInfo2 = await HomeServices.getSystemSettingInfo();
    //howToast("systemSettingInfo2====:::::${systemSettingInfo2['diningType']}");
    //print("systemSettingInfo2====:::::${systemSettingInfo2}");
    setState(() {
      _menu_direction = "1";
    });
    }else{//print("diercibuyongzaishezhihome");
      //showToast("diercibuyongzaishezhihome");
      setState(() {
        _menu_direction = systemSettingInfo['menuDirection'];
      });
    }


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
            child: Container(
              padding: EdgeInsets.only(top:ScreenAdapter.height(1250),bottom: ScreenAdapter.height(50)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      //_clearCartList();
                      if(_menu_direction == "1"){
                        Navigator.pushNamed(context, '/menuPage',arguments: {"checkLanguage": "JP","shopInfo":_shopInfo});
                      }else{
                        Navigator.pushNamed(context, '/menuZongPage',arguments: {"checkLanguage": "JP","shopInfo":_shopInfo});
                      }

                    },
                    child: Container(
                      width: ScreenAdapter.width(217),
                      height: ScreenAdapter.height(90),
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
                      //_clearCartList();
                      if(_menu_direction == "1"){
                        Navigator.pushNamed(context, '/menuPage',arguments: {"checkLanguage": "CH","shopInfo":_shopInfo});
                      }else{
                        Navigator.pushNamed(context, '/menuZongPage',arguments: {"checkLanguage": "CH","shopInfo":_shopInfo});
                      }
                    },
                    child: Container(
                      width: ScreenAdapter.width(217),
                      height: ScreenAdapter.height(90),
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
                      //_clearCartList();
                      if(_menu_direction == "1"){
                        Navigator.pushNamed(context, '/menuPage',arguments: {"checkLanguage": "EN","shopInfo":_shopInfo});
                      }else{
                        Navigator.pushNamed(context, '/menuZongPage',arguments: {"checkLanguage": "EN","shopInfo":_shopInfo});
                      }
                    },
                    child: Container(
                      width: ScreenAdapter.width(217),
                      height: ScreenAdapter.height(90),
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
