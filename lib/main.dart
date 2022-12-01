import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:appset/appset.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:foodorder/routers/router.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/Storage.dart';
import 'package:paycube/paycube.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/colorsUtil.dart';
import 'config/index.dart';

Future<void> main() async {

  runZonedGuarded(() async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    WidgetsFlutterBinding.ensureInitialized(); //强制竖屏必须要添加这个进行初始化 否则下面会错误
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
      runApp(MyApp());
      //runApp(GetMaterialApp(home: Home()));
    });

    //隐藏状态栏导航栏
    SystemChrome.setEnabledSystemUIOverlays([]);


  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1080, 1920), //Size(1080, 1920),
      builder: (context, child){
        return MaterialApp(
          navigatorKey: Global.navigatorKey,
          title: "券売君", //谷町君
          debugShowCheckedModeBanner: false,
          //onGenerateRoute: Application.router.generator,
          //主题
          theme: ThemeData(
            primaryColor: Gcolor.primaryColor,
            //fontFamily: 'MeiryoUI',
          ),
          home: child,
          initialRoute: '/',
          onGenerateRoute:onGenerateRoute,
          builder: EasyLoading.init(),
        );
      },
      child: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //final sqlHelper = SqfliteHelper();
  TextEditingController _activationCodeController = new TextEditingController();
  FocusNode _activationCodeFocusNode = FocusNode();

  var _activation_code; //激活码
  Timer allowtimer;
  Timer stoptimer;
  Timer stopChecktimer;
  Timer closetimer;

  var _allowStatus;
  var _stopStatus;
  var _closeStatus;

  @override
  void initState() {
    super.initState();
    requestPermission();


    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..progressColor = Colors.grey
      ..backgroundColor = Colors.white
      ..indicatorColor = Colors.transparent
      ..textColor = Colors.transparent
      ..loadingStyle = EasyLoadingStyle.custom;



  }

  @override
  void dispose() {
    // TODO: implement dispose
    allowtimer?.cancel();
    stopChecktimer?.cancel();
    closetimer?.cancel();
    super.dispose();
  }

  Future requestPermission() async {
    //霸屏隐藏状态栏导航栏
    await Appset.hideBullyScreen;
    /// 权限检测
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus != PermissionStatus.granted) {
      storageStatus = await Permission.storage.request();
      if (storageStatus != PermissionStatus.granted) {
        //showToast("权限申请被拒绝");
        //print("权限申请被拒绝");
      }else{

        //第一步，链接现金机，并打开现金机
        OpenPayCube();
      }
    }else{

      OpenPayCube();
    }
  }




  //打开现金机
  OpenPayCube() async {
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(450),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        Text("テスト中です、しばらくお待ちください。",
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          )),
            Text("1、釣銭機を開けています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("2、現金機を閉じています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(250),
              child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
    String checkStatus = await Paycube.CheckPayCubeStatus;

    //如果检测现金机打开错误，则重新打开一下
    if(checkStatus == "openError"){
      String openStatus = await Paycube.openPayCube;
      //print("机器未打开lib未null，重新打开并连接了");
    }else{
      await Paycube.setReceiveEvent;
      //print("机器已打开，并setreceive");
    }
    Starttoubi();
    //await Paycube.endTrade;
  }

  //现金机开始 打开现金机，准备开始投币
  Starttoubi() async {
    EasyLoading.dismiss();
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(450),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("テスト中です、しばらくお待ちください。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("1、釣銭機を開けています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                )),
            Text("2、釣銭機を閉じています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),

            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(250),
              child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
    //入金开始
    int connectCount = 0;
    String strartPayCube = await Paycube.strartPayCube;
    await Paycube.setReceiveEvent;
    allowtimer?.cancel();
    allowtimer = Timer.periodic(Duration(milliseconds: 150), (Timer allowt) async {
      _allowStatus =  await Paycube.getPayCubeAllowCashStatus;
      connectCount++;
      if(connectCount > 50){
        //退出关闭
        exit(0);
      }
      //print("链接次数${}");
      // 循环一定要记得设置取消条件，手动取消
      if (_allowStatus == "AllowSuccess") {
        stopPaycube();
        allowt.cancel();

      }else if (_allowStatus == "Error-F0--16") {
        await Paycube.endTrade;
        //sleep(Duration(milliseconds: 200));
        await Paycube.strartPayCube;
      }else if (_allowStatus == "Error-A0--02") {
        //sleep(Duration(milliseconds: 300));
      }else{

        await Paycube.strartPayCube;
        //print("_allowStatus:$_allowStatus");

      }

    });


  }
  stopPaycube() async {
    EasyLoading.dismiss();
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(450),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("テスト中です、しばらくお待ちください。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("1、釣銭機を開けています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("2、釣銭機を閉じています。",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                )),
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(250),
              child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stopChecktimer?.cancel();
    stopChecktimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopcheck) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        closePaycube();
        stopcheck.cancel();

      }else if(_stopStatus == "Error-A0--02"){
        //处理中
        sleep(Duration(milliseconds: 200));
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
      if (_closeStatus == "EndSuccess" ) {
        //现金机打开一次后，判断是否第一次打开
        prohibitOneCash();

        closecheck.cancel();
      }else{

        await Paycube.endTrade;
      }
    });
  }

  //禁用一元入金和出金
  prohibitOneCash() async {
    var prohibitOneCashStatus =  await Paycube.prohibitOneCash;

    //判断是否第一次打开
    //getIsFirstOpen();
    _getSmartweSystemSettingInfo();
  }


  //获取就餐类型信息
  _getDiningTypeInfo() async {
    var DiningTypeInfo = await HomeServices.getDiningTypeInfo();
    if (DiningTypeInfo == "" || null==DiningTypeInfo) {

      Storage.setString('diningType', "1");//1 堂食  2 外袋  0 两种都可

    }
  }

  //获取菜单方向
  _getMenuDirection() async {
    var menuDirectionInfo = await HomeServices.getMenuDirectionInfo();
    if (menuDirectionInfo == "" || null==menuDirectionInfo) {
      Storage.setString('menuDirection', "1");//1 默认顶部横向  2 左侧纵向
    }
  }

  //获取打印纸
  _getPrintPaperSize() async {
    var PrintPaperSizeInfo = await HomeServices.getPrintPaperSizeInfo();
    if (PrintPaperSizeInfo == "" || null==PrintPaperSizeInfo) {
      Storage.setString('printPaperSize', "1");//1 默认58mm  2 宽纸80mm
    }
  }

  //获取菜单方向
  _getIsAllowReceiptInfo() async {
    var menuDirectionInfo = await HomeServices.getIsAllowReceiptInfo();
    if (menuDirectionInfo == "" || null==menuDirectionInfo) {
      Storage.setString('isAllowReceipt', "1");//1 默认顶部横向  2 左侧纵向
    }
  }

//获取机器信息
  _getShopInfo() async {
    var shopInfo = await HomeServices.getShopInfo();
    if (""==shopInfo|| null ==shopInfo) {
      Storage.setString('shopInfo', "kanran");
    }
    _goMain();
  }

  _getSmartweSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();
    //print(SystemSettingInfo.isEmpty);

    //if (SystemSettingInfo.isEmpty) {
    var DiningTypeInfo = await HomeServices.getDiningTypeInfo();//showToast("main====:::::${DiningTypeInfo}");
      var systemSettingData = {
        "diningType": (SystemSettingInfo["diningType"] !="" && SystemSettingInfo["diningType"]!=null) ? SystemSettingInfo["diningType"] :((DiningTypeInfo !="" && DiningTypeInfo!=null) ? DiningTypeInfo : "1"), //1堂食 2外带
        "menuDirection":(SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1",//1顶部横向 2左侧竖
        "printPaperSize":(SystemSettingInfo["printPaperSize"] !="" && SystemSettingInfo["printPaperSize"]!=null) ? SystemSettingInfo["printPaperSize"] :"1",//1 58mm 2 80mm
        "isAllowReceipt":(SystemSettingInfo["isAllowReceipt"] !="" && SystemSettingInfo["isAllowReceipt"]!=null) ? SystemSettingInfo["isAllowReceipt"] :"1",//1必须打印小票 2不必须
        "machineMode":(SystemSettingInfo["machineMode"] !="" && SystemSettingInfo["machineMode"]!=null) ? SystemSettingInfo["machineMode"] :"1",//1 普通点餐券卖机  2 精算机（结账机）
        "isReservation":(SystemSettingInfo["isReservation"] !="" && SystemSettingInfo["isReservation"]!=null) ? SystemSettingInfo["isReservation"] :"0",//是否开启预约 0不开启 1开启
        "isAllowAttendance":(SystemSettingInfo["isAllowAttendance"] !="" && SystemSettingInfo["isAllowAttendance"]!=null) ? SystemSettingInfo["isAllowAttendance"] :"0",//0 不开考勤 1开考勤
        "isAllowPos":(SystemSettingInfo["isAllowPos"] !="" && SystemSettingInfo["isAllowPos"]!=null) ? SystemSettingInfo["isAllowPos"] :"0",//0 不开pos 1开pos

      };
      Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));//1 默认58mm  2 宽纸80mm
    //}

    //判断是否第一次打开
    sleep(Duration(milliseconds: 500));
    getIsFirstOpen();

  }

  //判断是否第一次打开 true为以经激活,下载最新数据保存到本地数据库
  getIsFirstOpen() async {

    /*_getDiningTypeInfo();
    sleep(Duration(milliseconds: 200));
    _getMenuDirection();
    sleep(Duration(milliseconds: 200));
    _getPrintPaperSize();
    sleep(Duration(milliseconds: 200));
    _getIsAllowReceiptInfo();*/
    //_getSmartweSystemSettingInfo();
    //sleep(Duration(milliseconds: 500));
    EasyLoading.dismiss();

    var isFirst = await HomeServices.getOpenFirstState();
    if(isFirst == true){
      _getShopInfo();

      //loaddata();
    }else{
      _goActivation();
    }
  }

  void _goMain() async {

    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/transitPage');
    });

  }

  void _goActivation() async {

    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/activation');
    });

  }

  //把机器码保存到本地
  /*sendActivationCode() async {

    if (this._activation_code == null ||
        this._activation_code.length <= 0) {
      showToast('请输入正确激活码');
    } else {


      //保存机器信息
      Storage.setString('machineInfo', _activation_code);
      Storage.setBool('homeOpen', true);

      _goMain();
    }
  }*/

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*Text("请输入激活码",
                style: TextStyle(fontSize: ScreenAdapter.fontSize(32.0))),*/
            /*Container(
              width: ScreenAdapter.width(250.0),
              padding: EdgeInsets.only(left: 10.0, right: 10, top: 0, bottom: 10),
              child: TextField(
                //keyboardType: TextInputType.text,
                autofocus: true,
                showCursor: true, // 显示光标
                //readOnly: true,
                controller: _activationCodeController,
                focusNode: _activationCodeFocusNode,
                decoration: InputDecoration(
                  hintText: "请输入激活码",
                  //border: InputBorder.none,
                  isDense: true,
                ),
                style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                obscureText: false,
                onChanged: (value) {
                  //print(value);
                },
                onSubmitted: (value){//print(value);
                //showToast(value);
                  setState(() {
                    this._activation_code = value;
                  });

                  sendActivationCode();

                },

                /// 扫码密码
              ),),
            Divider(
              thickness: 1.0,
              color: Colors.black12,
            ),
            TextButton(
              child: Text(
                "确定激活",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: ScreenAdapter.fontSize(32.0)),
              ),
              onPressed: () async {
                sendActivationCode();
              },
            ),*/
          ],
        ),
      ),
    );

  }

}
