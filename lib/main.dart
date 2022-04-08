import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/screenutil_init.dart';

import 'package:foodorder/routers/router.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/Storage.dart';
import 'package:paycube/paycube.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/colorsUtil.dart';
import 'config/index.dart';

void main() {
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  WidgetsFlutterBinding.ensureInitialized(); //强制竖屏必须要添加这个进行初始化 否则下面会错误
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
    //runApp(GetMaterialApp(home: Home()));
  });

  //显示底部栏(隐藏顶部状态栏)
    SystemChrome.setEnabledSystemUIOverlays([]);
  //显示顶部栏(隐藏底部栏)
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  //隐藏底部栏和顶部状态栏
  //SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1080, 1920), //Size(1080, 1920),
      allowFontScaling: false,
      builder: () => MaterialApp(
        navigatorKey: Global.navigatorKey,
        title: "甘蘭牛肉面", //谷町君
        debugShowCheckedModeBanner: false,
        //onGenerateRoute: Application.router.generator,
        //主题
        theme: ThemeData(
          primaryColor: Gcolor.primaryColor,
          //fontFamily: 'MeiryoUI',
        ),
        home: MyHomePage(),
        initialRoute: '/',
        onGenerateRoute:onGenerateRoute,
        builder: EasyLoading.init(),
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

  var _allowStatus;
  var _stopStatus;
  var _closeStatus;

  @override
  void initState() {
    super.initState();
    requestPermission();


    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..progressColor = Colors.transparent
      ..backgroundColor = Colors.transparent
      ..indicatorColor = Colors.grey
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
        //showToast("权限申请通过");
        //print("权限申请通过");
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
        Text("正在测试现金机，请稍候~",
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          )),
            Text("1、正在打开现金机",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("2、正在关闭现金机",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(350),
              child: Image.asset('assets/images/newloading.gif',fit: BoxFit.fitHeight),
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
            Text("正在测试现金机，请稍候~",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("1、正在打开现金机",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                )),
            Text("2、正在关闭现金机",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),

            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(350),
              child: Image.asset('assets/images/newloading.gif',fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
    //入金开始
    String strartPayCube = await Paycube.strartPayCube;
    await Paycube.setReceiveEvent;
    allowtimer?.cancel();
    allowtimer = Timer.periodic(Duration(milliseconds: 150), (Timer allowt) async {
      _allowStatus =  await Paycube.getPayCubeAllowCashStatus;
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
            Text("正在测试现金机，请稍候~",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("1、正在打开现金机",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                )),
            Text("2、正在关闭现金机",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                )),
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(350),
              child: Image.asset('assets/images/newloading.gif',fit: BoxFit.fitHeight),
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
    closetimer = Timer.periodic(Duration(milliseconds: 700), (Timer closecheck) async {
      _closeStatus =  await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_closeStatus == "EndSuccess" ) {
        //现金机打开一次后，判断是否第一次打开
        //判断是否第一次打开
        getIsFirstOpen();
        closecheck.cancel();
      }else{
        sleep(Duration(milliseconds: 200));
        await Paycube.endTrade;
      }
    });
  }






  //判断是否第一次打开 true为以经激活,下载最新数据保存到本地数据库
  getIsFirstOpen() async {
    EasyLoading.dismiss();

    var isFirst = await HomeServices.getOpenFirstState();
    if(isFirst == true){
      _goMain();
      //loaddata();
    }else{
      _goActivation();
    }
  }

  void _goMain() async {

    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/home');
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
