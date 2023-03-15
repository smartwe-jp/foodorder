import 'dart:async';
import 'dart:convert';


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
import 'package:foodorder/services/showImage.dart';
import 'package:foodorder/services/GetxStorage.dart';
import 'SelectDiningMethod.dart';

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
  var _dining_type = "0"; //就餐类型选择 1店内 2外卖 3全可以

  var _machineLanguages_JP = false;
  var _machineLanguages_CH = false;
  var _machineLanguages_EN = false;
  var _machineLanguages_KO = false;

  var _homeList = [];

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();
    //先获取店铺信息已获取路径用
    _getShopInfo();




    //监听增加打开现金机的广播
    eventBus.on<PayCubeEvent>().listen((event) {
      CheckPayCube();
    });

    //_clearCartList();
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
      GetxStorage.setData('shopInfo', "kanran");
    }

    //首页图片
    _getHomeImageList();
  }

  _getHomeImageList() async {
    var homeimageList = await HomeServices.getSmartweHomeImagesData();
    //print(homeimageList);

    setState(() {
      _homeList = homeimageList;
    });

    _getSystemSettingInfo();

  }

  _getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();


    setState(() {
      _menu_direction = (SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1";
      _dining_type = (SystemSettingInfo["diningType"] !="" && SystemSettingInfo["diningType"]!=null) ? SystemSettingInfo["diningType"] :"1";
    });

    _getmenchineLanguages();

  }

  _getmenchineLanguages() async {
    var languageJP = false;
    var languageCH = false;
    var languageEN = false;
    var languageKO = false;
    var menchineLanguagesData = await HomeServices.getMachineLanguages();
    for (var item in menchineLanguagesData) {
      if(item == "JP"){
        languageJP = true;
      }else if(item == "CH"){
        languageCH = true;
      }else if(item == "EN"){
        languageEN = true;
      }else if(item == "KO"){
        languageKO = true;
      }
    }

    setState(() {
      _machineLanguages_JP = languageJP;
      _machineLanguages_CH = languageCH;
      _machineLanguages_EN = languageEN;
      _machineLanguages_KO = languageKO;
    });

  }

  //选择食用方式和支付方式
  _showSelectMealTypeDialog(checkedLanguage, menu_direction) async {
    var dialogContext = context;
    await showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: dialogContext,
        builder: (BuildContext context) {

          return SelectDiningMethodPage(
            checkLanguage: checkedLanguage,
            dining_type: _dining_type,
            shopInfo:_shopInfo,
            menu_direction:_menu_direction,
            onConfrimClick: (bool mealType, String dining_type_num, String menuDirection) {
              print(mealType);
              print(dining_type_num);
              print(menuDirection);

              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": checkedLanguage,"shopInfo":_shopInfo,"mealType":mealType});

            },
          );
        });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: Stack(
            children: [
              /*Container(
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
                      if(_machineLanguages_JP == true)
                        InkWell(
                          onTap: () {
                            //_clearCartList();
                            if(_dining_type =="1" || _dining_type =="2"){
                              var mealType = (_dining_type == "2") ? true: false;
                              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
                              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": "JP","shopInfo":_shopInfo,"mealType":mealType});

                            }else{
                              _showSelectMealTypeDialog("JP", _menu_direction);
                            }


                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
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
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(_machineLanguages_CH == true)
                        InkWell(
                          onTap: () {

                            if(_dining_type =="1" || _dining_type =="2"){
                              var mealType = (_dining_type == "2") ? true: false;
                              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
                              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": "CH","shopInfo":_shopInfo,"mealType":mealType});

                            }else{
                              _showSelectMealTypeDialog("CH", _menu_direction);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
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
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(_machineLanguages_EN == true)
                        InkWell(
                          onTap: () {
                            if(_dining_type =="1" || _dining_type =="2"){
                              var mealType = (_dining_type == "2") ? true: false;
                              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
                              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": "EN","shopInfo":_shopInfo,"mealType":mealType});

                            }else{
                              _showSelectMealTypeDialog("EN", _menu_direction);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
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
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(_machineLanguages_KO == true)
                        InkWell(
                          onTap: () {
                            if(_dining_type =="1" || _dining_type =="2"){
                              var mealType = (_dining_type == "2") ? true: false;
                              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
                              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": "KO","shopInfo":_shopInfo,"mealType":mealType});

                            }else{
                              _showSelectMealTypeDialog("KO", _menu_direction);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                  fit: BoxFit.fill),
                            ),
                            child: Center(
                              //加上Center让文字居中
                              child: Text(
                                '한국말',
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
              ),*/
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Swiper(
                  //itemHeight: 200,
                  itemBuilder: (BuildContext context,int index){
                    // 配置图片地址
                    return publicShowMenuImage(imgPath:_homeList[index],imgWidth: 1080.0,imgHeight: 1920.0);
                  },
                  // 配置图片数量
                  itemCount: _homeList.length,
                  // 底部分页器
                  //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
                  // 左右箭头
                  //control: new SwiperControl(),
                  // 无限循环
                  loop: (_homeList.length >1) ?true :false,
                  duration: 1000,
                  autoplayDelay:12000,
                  // 自动轮播
                  autoplay: (_homeList.length >1) ?true :false,
                ),
              ),
              Positioned(
                top: ScreenAdapter.height(1450),
                child: Container(
                  width: ScreenAdapter.width(1080),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if(_machineLanguages_JP == true)
                        InkWell(
                          onTap: () {
                            //_clearCartList();
                            if(_dining_type =="1" || _dining_type =="2"){
                              var mealType = (_dining_type == "2") ? true: false;
                              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
                              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": "JP","shopInfo":_shopInfo,"mealType":mealType});

                            }else{
                              _showSelectMealTypeDialog("JP", _menu_direction);
                            }


                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
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
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(_machineLanguages_CH == true)
                        InkWell(
                          onTap: () {

                            if(_dining_type =="1" || _dining_type =="2"){
                              var mealType = (_dining_type == "2") ? true: false;
                              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
                              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": "CH","shopInfo":_shopInfo,"mealType":mealType});

                            }else{
                              _showSelectMealTypeDialog("CH", _menu_direction);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
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
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(_machineLanguages_EN == true)
                        InkWell(
                          onTap: () {
                            if(_dining_type =="1" || _dining_type =="2"){
                              var mealType = (_dining_type == "2") ? true: false;
                              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
                              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": "EN","shopInfo":_shopInfo,"mealType":mealType});

                            }else{
                              _showSelectMealTypeDialog("EN", _menu_direction);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
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
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(_machineLanguages_KO == true)
                        InkWell(
                          onTap: () {
                            if(_dining_type =="1" || _dining_type =="2"){
                              var mealType = (_dining_type == "2") ? true: false;
                              var jumpUrl = (_menu_direction == "1") ? "/menuPage" :"/menuZongPage";
                              Navigator.pushNamed(context, jumpUrl,arguments: {"checkLanguage": "KO","shopInfo":_shopInfo,"mealType":mealType});

                            }else{
                              _showSelectMealTypeDialog("KO", _menu_direction);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                  fit: BoxFit.fill),
                            ),
                            child: Center(
                              //加上Center让文字居中
                              child: Text(
                                '한국말',
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
              )

            ],
          ),
          ),
    );
  }
}
