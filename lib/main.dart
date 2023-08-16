import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:appset/appset.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:foodorder/routers/router.dart';
import 'package:foodorder/services/GetxStorage.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/Storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:paycube/paycube.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';

import 'config/colorsUtil.dart';
import 'config/index.dart';
import 'config/printer_info.dart';

Future<void> main() async {

  runZonedGuarded(() async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await GetStorage.init();

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    WidgetsFlutterBinding.ensureInitialized(); //强制竖屏必须要添加这个进行初始化 否则下面会错误
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
      runApp(MyApp());
      //runApp(GetMaterialApp(home: Home()));
    });

    //隐藏状态栏导航栏
    SystemChrome.setEnabledSystemUIMode (SystemUiMode.immersive, overlays: []);


  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final easyload = EasyLoading.init();
  final ftoast = FToastBuilder();

  //打印图层生成成功
  Future<void> _onPictureGenerated(PicGenerateResult data) async {
  final imageBytes = data.data;
  final printTask = data.taskItem;

  //指定的打印机
  final printerInfo = printTask.params as PrinterInfo;
  //打印票据类型（标签、小票）
  final printTypeEnum = printTask.printTypeEnum;

  if (imageBytes != null) {
    var printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
      imgData: imageBytes,
      printType: printTypeEnum,
    );
print(printerInfo.ip);
    // 网络 打印
    final conn = printerPlus.NetConn(printerInfo.ip);
    conn.writeMultiBytes(printData);
  }
  }

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
            //fontFamily: 'smartwebW1',
          ),
          home: child,
          initialRoute: '/',
          checkerboardRasterCacheImages: true,
          onGenerateRoute:onGenerateRoute,
          //builder: EasyLoading.init(),
          builder:(context, child) {
            child = easyload(context, child);
            child = ftoast(context, child);
            return child;
          }
        );
      },
      child: Scaffold(
        body: PrintImageGenerateWidget(
          contentBuilder: (context) {
            return MyHomePage();
          },
          onPictureGenerated: _onPictureGenerated,
        ),
      ),
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

  //60秒内未接收现金机正确通知，则进行下一步操作
  Timer showCashTimer;
  int seconds = 60;
  var _isCashState = true;

  var _allowStatus;
  var _stopStatus;
  var _closeStatus;

  @override
  void initState() {
    super.initState();
    requestPermission();
    //checkInterNetStatus();

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
    showCashTimer?.cancel();
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

  //检测网络状态
  checkInterNetStatus() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {print("mobile");
      // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {print("wifi");
      // I am connected to a wifi network.
    } else if (connectivityResult == ConnectivityResult.ethernet) {print("ethernet");
      // I am connected to a ethernet network.
    } else if (connectivityResult == ConnectivityResult.vpn) {print("vpn");
      // I am connected to a vpn network.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
    } else if (connectivityResult == ConnectivityResult.bluetooth) {print("bluetooth");
      // I am connected to a bluetooth.
    } else if (connectivityResult == ConnectivityResult.other) {print("other");
      // I am connected to a network which is not in the above mentioned networks.
    } else if (connectivityResult == ConnectivityResult.none) {print("没有网络");
      // I am not connected to any network.
    }
  }


//倒计时
  _countDownTimer() {
    showCashTimer?.cancel();
    showCashTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      //if(mounted) {
        setState(() {
          this.seconds--;
        });
     // }

      if (this.seconds == 0) {
        //如果60秒未接收返回正确通知，则进行下一步操作
        setState(() {
          _isCashState = false;
        });
        getIsFirstOpen();

        showCashTimer?.cancel(); //清除定时器

      }
    });
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
    //倒计时，一定时间不开启现金机则继续执行下一步
    _countDownTimer();
    String checkStatus = await Paycube.CheckPayCubeStatus;

    //如果检测现金机打开错误，则重新打开一下
    if(checkStatus == "openError"){
      String openStatus = await Paycube.openPayCube;
      //print("机器未打开lib未null，重新打开并连接了");
    }else{
      await Paycube.setReceiveEvent;
    }

    Starttoubi();
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
        //exit(0);
        getIsFirstOpen();
      }
      //print("链接次数${}");
      // 循环一定要记得设置取消条件，手动取消
      if (_allowStatus == "AllowSuccess") {
        setState(() {
          seconds = 60;
        });
        _countDownTimer();

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
        //倒计时，一定时间不开启现金机则继续执行下一步
        setState(() {
          seconds = 60;
        });
        _countDownTimer();
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
        setState(() {
          showCashTimer?.cancel();
          seconds = 60;
        });

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
    //var prohibitOneCashStatus =  await Paycube.prohibitOneCash;

    var cashShowData = {
      "isCash": _isCashState,
    };
    Storage.setString('isCashState', json.encode(cashShowData));
    GetxStorage.setData('isCashState', json.encode(cashShowData));
    //判断是否第一次打开
    Future.delayed(Duration(milliseconds: 300), () {
      getIsFirstOpen();
    });
  }

  //判断是否第一次打开 true为以经激活,下载最新数据保存到本地数据库
  getIsFirstOpen() async {

    EasyLoading.dismiss();

    var isFirst = await HomeServices.getOpenFirstState();
    if(isFirst == true){
      _goMain();

    }else{
      _goActivation();
    }
  }

  void _goMain() async {

    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.pushNamed(context,"/transitPage");
      //Navigator.of(context).pushReplacementNamed('/transitPage');
    });

  }

  void _goActivation() async {

    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.pushNamed(context,"/activation");
      //Navigator.of(context).pushReplacementNamed('/activation');
    });

  }



  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

          ],
        ),
      ),
    );

  }

}
