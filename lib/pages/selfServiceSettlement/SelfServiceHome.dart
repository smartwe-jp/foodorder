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
import '../../config/color.dart';
import '../../config/string.dart';

class selfServiceHomePage extends StatefulWidget {
  selfServiceHomePage({Key key}) : super(key: key);

  _selfServiceHomePageState createState() => _selfServiceHomePageState();
}

class _selfServiceHomePageState extends State<selfServiceHomePage> {
  HomePageController controller = Get.put(HomePageController());
  //HomePageController controller = Get.find<HomePageController>();

  Timer checkTimer;
  Timer stopChecktimer;
  Timer closetimer;

  String _machineCode = "";

  var _stopStatus;
  var _closeStatus;
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
    _getMachineInfo();
    //首页图片
    //_getHomeImageList();


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

  //获取机器信息
  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      setState(() {
        _machineCode = machineCode;
      });

    }
    //首页图片
    _getHomeImageList();
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

  //选择是否要袋子
  _showSelectBagDialog(checkedLanguage) async {
    var dialogContext = context;
    await showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: dialogContext,
        builder: (BuildContext context) {

          return SimpleDialog(
              contentPadding: EdgeInsets.only(top: 0,bottom: 0,left: 0,right: 0),
              backgroundColor: ColorsUtil.hexToColor("#DCDCDC"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              children: <Widget>[
                Container(
                  color: ColorsUtil.hexToColor("#FFFFFF"),
                  width: ScreenAdapter.width(1000),
                  padding: EdgeInsets.only(top: ScreenAdapter.height(20),bottom: ScreenAdapter.height(0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                        Container(
                          padding: EdgeInsets.only(left: ScreenAdapter.width(30),top: ScreenAdapter.height(25),right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(30)),
                          //width: ScreenAdapter.width(650),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                //"是否需要袋子",
                                GString.getToString(checkedLanguage, "select_selfservice_bag_title"),
                                style: TextStyle(
                                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScreenAdapter.fontSize(34.0)),
                              ),
                              SizedBox(height: ScreenAdapter.height(30),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  InkWell(
                                    onTap: (){
                                      Navigator.pushNamed(context, "/selfServiceScanCodePage",arguments: {"checkLanguage": checkedLanguage,"isBag":""});
                                    },
                                    child: Container(
                                      width: ScreenAdapter.width(250),
                                      height: ScreenAdapter.height(270),
                                      padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        //设置圆角
                                        borderRadius: new BorderRadius.circular((5.0)),
                                        //设置阴影
                                        boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: ScreenAdapter.height(210),
                                            padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                            child: Image.asset(GImage.getImageString("imgpublic", "dining_in_checked"),
                                              //width: ScreenAdapter.width(120),
                                              height: ScreenAdapter.height(140),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                          //SizedBox(height: ScreenAdapter.height(20),),
                                          Text(
                                            //"不要",
                                            GString.getToString(checkedLanguage, "select_selfservice_nobag_title"),
                                            style: TextStyle(
                                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScreenAdapter.fontSize(34.0)),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenAdapter.width(15),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      Navigator.pushNamed(context, "/selfServiceScanCodePage",arguments: {"checkLanguage": checkedLanguage,"isBag":"M"});


                                    },
                                    child: Container(
                                      width: ScreenAdapter.width(250),
                                      height: ScreenAdapter.height(270),
                                      padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        //设置圆角
                                        borderRadius: new BorderRadius.circular((5.0)),
                                        //设置阴影
                                        boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: ScreenAdapter.height(210),
                                            padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                            child: Image.asset(GImage.getImageString("imgpublic", "dining_away_checked"),
                                              //width: ScreenAdapter.width(120),
                                              height: ScreenAdapter.height(140),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                          //SizedBox(height: ScreenAdapter.height(20),),
                                          Text(
                                            "M",
                                            //GString.getToString(checkedLanguage, "menu_dingtype_takeout"),
                                            style: TextStyle(
                                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScreenAdapter.fontSize(34.0)),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenAdapter.width(15),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      Navigator.pushNamed(context, "/selfServiceScanCodePage",arguments: {"checkLanguage": checkedLanguage,"isBag":"L"});

                                    },
                                    child: Container(
                                      width: ScreenAdapter.width(250),
                                      height: ScreenAdapter.height(270),
                                      padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        //设置圆角
                                        borderRadius: new BorderRadius.circular((5.0)),
                                        //设置阴影
                                        boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: ScreenAdapter.height(210),
                                            padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                            child: Image.asset(GImage.getImageString("imgpublic", "dining_away_checked"),
                                              //width: ScreenAdapter.width(120),
                                              height: ScreenAdapter.height(140),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                          //SizedBox(height: ScreenAdapter.height(20),),
                                          Text(
                                            "L",
                                            //GString.getToString(checkedLanguage, "menu_dingtype_takeout"),
                                            style: TextStyle(
                                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScreenAdapter.fontSize(34.0)),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: ScreenAdapter.height(20),),
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
                                  GString.getToString(checkedLanguage, "settlement_back"),
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
                ),
              ]
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
                right: ScreenAdapter.width(0),
                top: ScreenAdapter.height(20),
                child: InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/middlewareSettingPage', arguments: {"machineCode": this._machineCode});
                  },
                  child: Container(
                    height: ScreenAdapter.height(150),
                    width: ScreenAdapter.width(200),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(top:ScreenAdapter.height(20),left: ScreenAdapter.width(20),right: ScreenAdapter.width(20),bottom: ScreenAdapter.height(20)),
                    child: Center(
                      //加上Center让文字居中
                      child: Text(
                        "",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(48.0),
                            color: ColorsUtil.hexToColor("#F9F9F9"),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
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
                            _showSelectBagDialog("JP");


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

                            _showSelectBagDialog("CH");
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
                            _showSelectBagDialog("EN");
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
                            _showSelectBagDialog("KO");
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
