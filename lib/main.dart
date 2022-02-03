import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil_init.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/routers/custom_router.dart';
import 'package:foodorder/routers/router.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/SqfliteHelper.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;

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
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
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
        title: GString.mainTitle, //谷町君
        debugShowCheckedModeBanner: false,
        //onGenerateRoute: Application.router.generator,
        //主题
        theme: ThemeData(
          primaryColor: Gcolor.primaryColor,
        ),
        home: MyHomePage(),
        initialRoute: '/',
        onGenerateRoute:onGenerateRoute,

      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String url = "https://jsonplaceholder.typicode.com/posts";
  final sqlHelper = SqfliteHelper();

  var _local_version; //本appversion版本号
  var _activation_code; //激活码


  @override
  void initState() {
    super.initState();
    _getPackageInfo(); //获取版本号并保存,在查看是否引导页还是广告业

    //判断是否第一次打开
    this.getIsFirstOpen();

  }



  //获取版本号
  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      this._local_version = packageInfo.version;
    });

  }

  //保存最新数据到本地数据库
  loaddata() async {
    await sqlHelper.open();
    var res = await http.get(url);
    List l = jsonDecode(res.body);print(l);
    l.forEach((e) async=>await sqlHelper.insert(e));

    Future.delayed(Duration(milliseconds: 600)).then((e) {
      _goMain();
    });
  }

  //判断是否第一次打开 true为以经激活,下载最新数据保存到本地数据库
  getIsFirstOpen() async {
    var isFirst = await HomeServices.getOpenFirstState();
    if(isFirst == true){
      loaddata();

    }
  }

  void _goMain() async {
    Navigator.of(context).pushReplacementNamed('/home');
    //Future.delayed(Duration(milliseconds: 100)).then((e) {
      //Navigator.of(context).pushReplacementNamed('/tab');
      //Navigator.push(context, CustomRoute(HomePage()));
      //Navigator.pushNamed(context, '/home');
    //});

  }

  //发送邮件
  sendActivationCode() async {
    loaddata();
    /*if (this._activation_code == null ||
        this._activation_code.length <= 0) {
      showToast('请输入正确激活码');
    } else {

      var formData = {
        "accountHistoryId": this._activation_code,
      };
      request('voucherToMail',
          method: 'GET',
          parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());

        if (response["code"] == 200) {
          //showToast('发送成功，可能需要几分钟，请注意查收');
          //Navigator.pop(context);
          _goMain();
        } else if (response["code"] == 4001) {
          showToast('服务正在更新，请过几分钟再试重试');
        } else if (response["code"] == 401 || response["code"] == 403) {
          showToast('授权失败，请尝试重新登录');
        } else {
          showToast('送失败，请检查邮箱地址后重试');
        }
      });
    }*/
  }



  @override
  void dispose() {

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("请输入激活码",
                style: TextStyle(fontSize: ScreenAdapter.fontSize(32.0))),
            Container(
              width: ScreenAdapter.width(150.0),
              padding: EdgeInsets.only(left: 10.0, right: 10, top: 0, bottom: 10),
              child: TextField(
                keyboardType: TextInputType.text,
                //controller: _emailEditController,
                decoration: InputDecoration(
                    hintText: "请输入激活码",
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(1),
                      borderSide: BorderSide(
                        ///设置边框的颜色
                        color: Colors.black12,

                        ///设置边框的粗细
                        width: 0.5,
                      ),
                    )
                ),
                onChanged: (value) {
                  setState(() {
                    this._activation_code = value;
                  });
                },
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
            ),
          ],
        ),
      ),
    );

  }

}
