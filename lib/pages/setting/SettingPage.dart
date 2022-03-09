import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  var _lastTotalList = [];
  var _depositData = {};

  //监听页面销毁的事件
  dispose() {
    //eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    this._machineCode = widget.arguments['machineCode'];
    EasyLoading.dismiss();
    //查看机器零钱状态
    _getPaycubeChangeState();

    _clearCartList();
  }

  //获取现金机列表
  _getPaycubeChangeState() {
    var formData = {
      "machineCode": _machineCode,
    };
    request('webBootChangeState', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200 && null != response['data']) {
        //print(response['data']);
        setState(() {
          _depositData = response['data'];
          _cashList = response['data']['changeStates'];
          _lastTotalList = response['data']['last7daysTotal'];
        });
      } else {}
    });

    //print(_menuOption);
  }

  _clearCartList() async {
    print("是否清空购物车了");
    if (controller.cartItems.length > 0) {
      print("是否清空购物车了222");
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

  //支付金额展示
  getDepositListShow() {
    return Container(
      margin: EdgeInsets.only(
          top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("待结算明细",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
            padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
            //width: ScreenAdapter.width(620),
            decoration: BoxDecoration(
                color: Colors.white12,
                border: Border(
                  //bottom: BorderSide(color: Colors.grey, width: 1.0),
                  top: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  left: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  right: BorderSide(color: Colors.grey.shade400, width: 1.0),
                )),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade400, width: 1.0),
                        //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: ScreenAdapter.width(250),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("现金",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(250),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("Alipay",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(250),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("PayPay",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(250),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("WechatPay",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade400, width: 1.0),
                        //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: ScreenAdapter.width(250),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              text: _depositData['deposit_crash'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        width: ScreenAdapter.width(250),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              text: _depositData['deposit_alipay'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        width: ScreenAdapter.width(250),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              text: _depositData['deposit_paypay'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        width: ScreenAdapter.width(250),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child:  RichText(
                          text: TextSpan(
                              text: _depositData['deposit_wechat'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getCashListShow() {
    return this._cashList.length > 0
        ? Container(
          margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
          child: Column(
            children: [
              Text("现金机状态",
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(22),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor("#000000"),
                  )),
              Container(
                  //width: ScreenAdapter.width(520),
                margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
                padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border(
                        //bottom: BorderSide(color: Colors.grey, width: 1.0),
                        top: BorderSide(color: Colors.grey.shade400, width: 1.0),
                        left: BorderSide(color: Colors.grey.shade400, width: 1.0),
                        right: BorderSide(color: Colors.grey.shade400, width: 1.0),
                      )),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                        decoration: BoxDecoration(
                            color: Colors.white12,
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.0),
                              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Container(
                              width: ScreenAdapter.width(110),
                              height: ScreenAdapter.height(45),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),
                                  right: ScreenAdapter.width(5)),
                              child: Text("币种",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  )),
                            )),
                            Expanded(child: Container(
                              width: ScreenAdapter.width(120),
                              height: ScreenAdapter.height(45),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),
                                  right: ScreenAdapter.width(5)),
                              child: Text("最小枚数",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  )),
                            )),
                            Expanded(child: Container(
                              width: ScreenAdapter.width(120),
                              height: ScreenAdapter.height(45),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),
                                  right: ScreenAdapter.width(5)),
                              child: Text("初期枚数",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  )),
                            )),
                            Expanded(child: Container(
                              width: ScreenAdapter.width(120),
                              height: ScreenAdapter.height(45),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),
                                  right: ScreenAdapter.width(5)),
                              child: Text("使用枚数",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  )),
                            )),
                          ],
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
                          physics: NeverScrollableScrollPhysics(), //禁用滑动事件
                          itemCount: this._cashList.length,
                          itemBuilder: (context, index) {
                            var _detail = this._cashList[index];
                            /*if (_detail['warm'] is String) {
                              print('str is String');
                            }else if (_detail['warm'] is int) {
                              print('str is int');
                            } else {
                              print('str is another');
                            }*/

                            var _surplusNum = _detail['standard']-int.parse(_detail['used']);
                            var _backColor = (_detail['warm'] > _surplusNum)?"#A61C1C":"#F9F9F9";
                            var _textColor = (_detail['warm'] > _surplusNum)?"#FFFFFF":"#000000";
                            return Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(5)),
                              decoration: BoxDecoration(
                                  color: ColorsUtil.hexToColor(_backColor),
                                  border: Border(
                                    bottom: BorderSide( color: Colors.grey.shade400, width: 1.0),
                                    //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                                  )),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(child: Container(
                                    //width: ScreenAdapter.width(100),
                                    height: ScreenAdapter.height(40),
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(
                                        left: ScreenAdapter.width(15),
                                        right: ScreenAdapter.width(5)),
                                    child: Text(_detail['name'],
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(18),
                                          fontWeight: FontWeight.w500,
                                          color: ColorsUtil.hexToColor(_textColor),
                                        )),
                                  )),
                                  Expanded(child: Container(
                                    //width: ScreenAdapter.width(120),
                                    height: ScreenAdapter.height(40),
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                        left: ScreenAdapter.width(5),
                                        right: ScreenAdapter.width(5)),
                                    child: Text(_detail['warm'].toString(),
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(20),
                                          fontWeight: FontWeight.w500,
                                          color: ColorsUtil.hexToColor(_textColor),
                                        )),
                                  )),
                                  Expanded(child: Container(
                                    //width: ScreenAdapter.width(120),
                                    height: ScreenAdapter.height(40),
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                        left: ScreenAdapter.width(5),
                                        right: ScreenAdapter.width(5)),
                                    child: Text(_detail['standard'].toString(),
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(20),
                                          fontWeight: FontWeight.w500,
                                          color: ColorsUtil.hexToColor(_textColor),
                                        )),
                                  )),
                                  Expanded(child: Container(
                                    //width: ScreenAdapter.width(120),
                                    height: ScreenAdapter.height(40),
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(
                                        left: ScreenAdapter.width(5),
                                        right: ScreenAdapter.width(5)),
                                    child: Text(_detail['used'].toString(),
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(20),
                                          fontWeight: FontWeight.w500,
                                          color: ColorsUtil.hexToColor(_textColor),
                                        )),
                                  )),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                ),
            ],
          ),
        )
        : Text("");
  }

  getLastOrderTotalShow() {
    List<Widget> cashListRows = []; //先建一个数组用于存放循环生成的widget
    for (var _detail in this._lastTotalList) {
      cashListRows.add(Expanded(child: Container(
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        decoration: BoxDecoration(
            color: Colors.white12,
            border: Border(
              right: BorderSide( color: Colors.grey.shade400, width: 1.0),

              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
            )),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              //width: ScreenAdapter.width(140),
              height: ScreenAdapter.height(40),
              padding: EdgeInsets.only(
                  bottom: ScreenAdapter.height(15)),
              decoration: BoxDecoration(
                  color: Colors.white12,
                  border: Border(
                    bottom: BorderSide( color: Colors.grey.shade400, width: 1.0),

                    //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                  )),
              alignment: Alignment.center,
              child: Text(_detail['day'],
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(20),
                    fontWeight: FontWeight.w500,
                    color: ColorsUtil.hexToColor("#000000"),
                  )),
            ),
            Container(
              //width: ScreenAdapter.width(140),
              height: ScreenAdapter.height(25),
              margin: EdgeInsets.only(
                  left: ScreenAdapter.width(5),
                  top: ScreenAdapter.height(16),
                  right: ScreenAdapter.width(5)),
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                    text: _detail['total'].toString(),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(22),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#000000"),
                    ),
                    children: [
                      TextSpan(
                        text: "円",
                        style: TextStyle(
                          fontSize:
                          ScreenAdapter.fontSize(18),
                          fontWeight: FontWeight.w500,
                          color: ColorsUtil.hexToColor(
                              "#000000"),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      )));
    }

    return this._lastTotalList.length > 0
        ? Container(
            margin: EdgeInsets.only(
                top: ScreenAdapter.height(15),
                bottom: ScreenAdapter.height(15)),
            child: Column(
              children: [
                Text("最近7日收入明细",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(22),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#000000"),
                    )),
                Container(
                  //width: ScreenAdapter.width(570),
                  height: ScreenAdapter.height(110),
                  margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
                  //padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border(
                        bottom:BorderSide(color: Colors.grey.shade400, width: 1.0),
                        top:BorderSide(color: Colors.grey.shade400, width: 1.0),
                        left:BorderSide(color: Colors.grey.shade400, width: 1.0),
                        //right:BorderSide(color: Colors.grey.shade400, width: 1.0),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: cashListRows,
                  ),
                ),
              ],
            ),
          )
        : Text("");
  }

  _doResetPaycube(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: ScreenAdapter.width(950),
            child: SimpleDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: Align(
                    alignment: Alignment.center,
                    child:  Text("お知らせ",style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                ),
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(780),

                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text("金庫のお金をすべて回収し、紙幣と硬貨を補充してください",
                              style: TextStyle(fontSize: ScreenAdapter.fontSize(28))),
                          alignment: Alignment(0, 0),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1.0,
                          color: Colors.black12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 70.0),
                              child: TextButton(
                                child: Text(
                                  "いいえ",
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () {
                                  //sleep(Duration(milliseconds: 3000));
                                  Navigator.pop(context);

                                },
                              ),
                            ),
                            //垂直分割线
                            SizedBox(
                              width: 1,
                              height: 40,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.black12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 70.0),
                              child: TextButton(
                                child: Text(
                                  "はい",
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () async {
                                  //widget.confirmCallback('确定');
                                  Navigator.pop(context);
                                  executeResetPaycube();
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          );
        });
  }

  executeResetPaycube(){
    var formData = {
      "machineCode": _machineCode,
    };
    request('webBootChangeReset', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
print(response);
      if (response['code'] == 200 && true == response['data']) {
        _getPaycubeChangeState();
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: Text("设置")),
        body: ListView(
          children: <Widget>[
            /*Container(
              width: ScreenAdapter.getScreenWidth(),
              height: ScreenAdapter.height(95),
              //padding: EdgeInsets.only(right: ScreenAdapter.width(20)),
              alignment: Alignment.bottomRight,
              decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#000000"),
                image: new DecorationImage(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.fitHeight,
                  image: AssetImage('assets/images/logo.png'),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                ],
              ),
            ),*/
            Container(
              decoration: new BoxDecoration(color: Colors.white),
              margin: EdgeInsets.only(
                top: ScreenAdapter.height(30.0),
              ),
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
                      margin: EdgeInsets.only(
                          left: ScreenAdapter.width(10),
                          right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(120),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#67c23a"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text("回到菜单",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),
                  /*InkWell(
                    onTap: () {
                      hideBullyScreen();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: ScreenAdapter.width(10),
                          right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(280),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#8f9398"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text("隐藏状态栏、导航栏",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showBullyScreen();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: ScreenAdapter.width(10),
                          right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(280),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#409eff"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text("显示状态栏、导航栏",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),*/
                  InkWell(
                    onTap: () {
                      showBullyScreen();
                      sleep(Duration(milliseconds: 1500));
                      Navigator.pop(context);
                      //退出关闭
                      exit(0);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: ScreenAdapter.width(10),
                          right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(180),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#e6a23c"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text("退出App",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),
                  /*InkWell(
                    onTap: () {
                      _doResetPaycube();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: ScreenAdapter.width(510),
                          right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(180),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#409eff"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text("金庫リセット",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),*/
                ],
              ),
            ),
            Container(
              decoration: new BoxDecoration(color: Colors.white),
              margin: EdgeInsets.only(
                top: ScreenAdapter.height(15.0),
              ),
              padding: EdgeInsets.only(
                top: ScreenAdapter.height(10.0),
                left: ScreenAdapter.width(18.0),
                right: ScreenAdapter.width(18.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getDepositListShow(),
                  SizedBox(
                    height: ScreenAdapter.height(20),
                  ),
                  getLastOrderTotalShow(),
                  SizedBox(
                    height: ScreenAdapter.height(20),
                  ),
                  getCashListShow(),
                ],
              ),
            ),
          ],
        ));
  }
}
