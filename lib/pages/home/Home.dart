import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final HomePageController controller = Get.put(HomePageController());

  @override
  void initState() {
    super.initState();

    //进入页面后打开现金机
    OpenPayCube();

    //监听增加打开现金机的广播
    eventBus.on<PayCubeEvent>().listen((event) {
      OpenPayCube();
    });

    //监听清除购物车的广播
    eventBus.on<clearCartEvent>().listen((event) {
      _clearCartList();
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
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

  _clearCartList() async {
    Get.find<HomePageController>().removeAllFromCart();

    controller.getCardList();
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
