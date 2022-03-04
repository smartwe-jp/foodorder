import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/plugins/appset/lib/appset.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:get/get.dart';
import 'package:foodorder/controller/homePageController.dart';

class SettingPage extends StatefulWidget {
  Map arguments;
  SettingPage({Key key, this.arguments}) : super(key: key);

  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  final HomePageController controller = Get.put(HomePageController());

  String _machineCode = "";
  var _cashList = [];

  //监听页面销毁的事件
  dispose() {
    eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    this._machineCode = widget.arguments['machineCode'];

      //查看机器零钱状态
    _getPaycubeChangeState();

    _clearCartList();
  }

  //获取菜单
  _getPaycubeChangeState() {
    var formData = {
      "machineCode": _machineCode,
    };
    request('webBootChangeState', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200 && null != response['data']) {
        setState(() {
          _cashList = response['data'];
        });
      } else {

      }
    });

    //print(_menuOption);
  }

  _clearCartList() async {print("是否清空购物车了");
  if(controller.cartItems.length >0){print("是否清空购物车了222");
  Get.find<HomePageController>().removeAllFromCart();
  }


    //controller.getCardList();
  }

  //隐藏状态栏导航栏
  hideBullyScreen() async {
    await Appset.hideBullyScreen;
  }

  //显示状态栏导航栏
  showBullyScreen() async {
    await Appset.showBullyScreen;
  }

  getCashListShow(){
    return this._cashList.length > 0
        ? ListView.builder(
        shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
        physics: NeverScrollableScrollPhysics(), //禁用滑动事件
        itemCount: this._cashList.length,
        itemBuilder: (context, index) {
          var _detail = this._cashList[index];

          return Container(
            padding: EdgeInsets.only(top:ScreenAdapter.height(15)),
            child: Column(
              children: [
                (index == 0) ? Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        child: Text(
                            "币种",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        child: Text(
                            "最小枚数",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        child: Text(
                            "初期枚数",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        child: Text(
                            "使用枚数",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                    ],
                  ),
                ):Container(height: 0,),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1.0),
                        //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(40),
                        margin: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        child: Text(
                            _detail['name'],
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w500,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(40),
                        margin: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        child: Text(
                            _detail['warm'].toString(),
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w500,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(40),
                        margin: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        child: Text(
                            _detail['standard'].toString(),
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w500,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(40),
                        margin: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        child: Text(
                            _detail['used'].toString(),
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w500,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        })
        : Text("");
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title:Text("设置")),
        body: ListView(
          children: <Widget>[
            Container(
              height: 0,
            ),

            Container(
              decoration: new BoxDecoration(color: Colors.white),
              margin:EdgeInsets.only(top: ScreenAdapter.height(15.0),),
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                top: ScreenAdapter.height(5.0),
                left: ScreenAdapter.width(20.0),
                right: ScreenAdapter.width(20.0),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        new MaterialPageRoute(
                          builder: (BuildContext context) {
                            return new HomePage();
                          },
                        ),
                            (Route route) => false,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(10),right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(120),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(

                        color: ColorsUtil.hexToColor("#67c23a"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text(
                          "回到首页",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      hideBullyScreen();
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(10),right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(280),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(

                        color: ColorsUtil.hexToColor("#8f9398"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text(
                          "隐藏状态栏、导航栏",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),

                  InkWell(
                    onTap: (){
                      showBullyScreen();
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(10),right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(280),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(

                        color: ColorsUtil.hexToColor("#409eff"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text(
                          "显示状态栏、导航栏",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      //退出关闭
                      exit(0);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(10),right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(180),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(

                        color: ColorsUtil.hexToColor("#e6a23c"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text(
                          "退出App",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),
                ],
              ),
            ),


            Container(
              decoration: new BoxDecoration(color: Colors.white),
              margin:EdgeInsets.only(top: ScreenAdapter.height(15.0),),
              padding: EdgeInsets.only(
                top: ScreenAdapter.height(10.0),
                left: ScreenAdapter.width(20.0),
                right: ScreenAdapter.width(20.0),
              ),
              child: Column(
                children: [
                  getCashListShow(),


                ],
              ),
            ),


          ],
        ));
  }
}
