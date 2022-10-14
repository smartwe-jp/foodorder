import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_plugin_msprinter/flutter_plugin_msprinter.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/plugins/appset/lib/appset.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/Storage.dart';

import 'package:foodorder/controller/homePageController.dart';
import 'package:get/get.dart' hide Response;
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingPage extends StatefulWidget {
  Map arguments;

  SettingPage({Key key, this.arguments}) : super(key: key);

  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final HomePageController controller = Get.put(HomePageController());

  String _machineCode = "";
  String _shopCode = "";
  var _cashList = [];
  var _lastTotalList = [];
  var _depositData = {};

  var _local_version; //本appversion
  var progressValue = 0.0;

  var _shopInfo = "kanran";
  var _attendanceCode ="";
  var _is_allow_attendance = "0";//0 不开启  1 开启

  //监听页面销毁的事件
  dispose() {
    //eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    this._machineCode = widget.arguments['machineCode'];
    //this._shopCode = widget.arguments['shopCode'];
    this._shopInfo = widget.arguments['shopInfo'];
    EasyLoading.dismiss();
    //查看机器零钱状态
    _getPaycubeChangeState();

    //_clearCartList();

    _getPackageInfo();

    //获取系统配置来判断是否获取打卡激活码
    _getSystemSettingInfo();
    //监听清除购物车的广播
    eventBus.on<setAttendanceCodeEvent>().listen((event) {
      _getSystemSettingInfo();
    });


  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    if(systemSettingInfo['isAllowAttendance'] !="" && systemSettingInfo['isAllowAttendance'] !=null) {
      setState(() {
        _is_allow_attendance = systemSettingInfo['isAllowAttendance'];
      });
      if (_is_allow_attendance == "1") {
        _getAttendanceCode();
      }
    }
  }

  _getAttendanceCode() async {
    var attendanceCode = await HomeServices.getAttendanceCode();
    if (attendanceCode != "" && attendanceCode != null) {
      setState(() {
        _attendanceCode = attendanceCode;
      });

    }
  }


  //获取版本号
  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      this._local_version = packageInfo.version+"+"+packageInfo.buildNumber;
      //this._local_version = packageInfo.version;
    });
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
       // print(response['data']);
        setState(() {
          _depositData = response['data'];
          _cashList = response['data']['changeStates'];
          _lastTotalList = response['data']['last7daysTotal'];
        });
      } else {}
    });

    //print(_menuOption);
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
          Text("売上",
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
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("預り金",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("買上",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
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
                        width: ScreenAdapter.width(200),
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
                        width: ScreenAdapter.width(200),
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
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              text: _depositData['deposit_payment'].toString(),
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
                        width: ScreenAdapter.width(200),
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
                        width: ScreenAdapter.width(200),
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
                        width: ScreenAdapter.width(200),
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
                        width: ScreenAdapter.width(200),
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
              Text("お釣り状態(NO.${_machineCode})",
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
                              child: Text("使った枚数",
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
                              child: Text("残り枚数",
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

                            var _surplusNum = _detail['standard']-int.parse(_detail['used']);
                            //var _backColor = (_detail['warm'] > _surplusNum)?"#A61C1C":"#F9F9F9";
                            var _textColor = (_detail['warm'] > _surplusNum)?"#A61C1C":"#000000";
                            return Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(5)),
                              decoration: BoxDecoration(
                                  color: ColorsUtil.hexToColor("#F9F9F9"),
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
                                    child: Text(_detail['used'].toString(),
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
                                    child: Text(_detail['remainder'].toString(),
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
                Text("一週間売上報告",
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
                  Container(
                    width: ScreenAdapter.width(820.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            /*Navigator.of(context).pushAndRemoveUntil(
                              new MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return new HomePage();
                                },
                              ),
                              (Route route) => false,
                            );*/
                            controller.removeAllFromCart();
                            sleep(Duration(milliseconds: 200));
                            Navigator.pop(context);
                            Future.delayed(Duration(milliseconds: 100), () {
                              Navigator.pushNamed(context, '/transitPage');
                            });
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
                            child: Text("戻る",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            controller.removeAllFromCart();
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
                            child: Text("ログアウト",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                        ),

                        if(_is_allow_attendance == "1")
                          InkWell(
                          onTap: () {
                            if(_attendanceCode !="" && _attendanceCode != null){
                              Navigator.of(context).pushNamed('/attendance',arguments: {
                                "machineCode": this._machineCode,
                                "attendanceCode": this._attendanceCode
                              });
                            }else{
                              Navigator.of(context).pushNamed('/setAttendanceCode',arguments: {
                                "machineCode": this._machineCode,
                              });
                            }

                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(10),
                                right: ScreenAdapter.width(10)),
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(65),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#078E42"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            //签到打卡
                            child: Text("チェックイン",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/systemSettingPage', arguments: {"machineCode": this._machineCode,"shopInfo":_shopInfo});
                            //showDownloadingAlert();
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(10),
                                right: ScreenAdapter.width(10)),
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(65),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#409eff"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            child: Text("システム設定",
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
                    padding:
                    EdgeInsets.only(right: ScreenAdapter.width(18)),
                    child: Text(
                      "Version：${this._local_version}",
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: ScreenAdapter.fontSize(20.0)),
                    ),
                  )
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
                left: ScreenAdapter.width(14.0),
                right: ScreenAdapter.width(14.0),
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
                  SizedBox(
                    height: ScreenAdapter.height(20),
                  ),

                ],
              ),
            ),
          ],
        ));
  }
}
