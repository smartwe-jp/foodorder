import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/plugins/appset/lib/appset.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';

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
  var _cashList = [];
  var _lastTotalList = [];
  var _depositData = {};

  var _local_version; //本appversion
  var progressValue = 0.0;

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

    //_clearCartList();

    _getPackageInfo();

  }

  //获取版本号
  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      this._local_version = packageInfo.version+"+"+packageInfo.buildNumber;
    });
  }

  showDownloadingAlert() {
    //支付状态
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
                    child:  Text("アップデートのお知らせ",style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                ),
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(650),

                    child: Column(
                      children: <Widget>[
                        /*SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text("确定已经接收到更新App的通知？",
                              style: TextStyle(fontSize: ScreenAdapter.fontSize(28))),
                          alignment: Alignment(0, 0),
                        ),*/
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
                                  "キャンセル",
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
                                  "アップデート",
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () async {
                                  //widget.confirmCallback('确定');
                                  Navigator.pop(context);
                                  //https://app.gutingjun.com/kanran-release.apk
                                  downloadAndroid("https://app.gutingjun.com/smartwe_ticket_machine.apk");
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

  /// 下载安卓更新包
  Future<String> downloadAndroid(String url) async {
    final permissions = await Permission.storage.status;
    //print('permission $permissions');
    if (!permissions.isGranted) {
      final permission = await Permission.storage.request();
      //print('permission $permission');
    } else {
      //print('permission granted');
    }

    startDownLoad(url);
  }

  ///开始下载
  startDownLoad(String url) async{
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
            Text("アップデート中……",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor("#000000"),
                )),
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(400),
              child: Image.asset('assets/images/newloading.gif',fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

    /// 创建存储文件
    //print(url);
    Directory storageDir = await getTemporaryDirectory();
    String storagePath = storageDir.path;
    final path = storagePath + '/kanranBooking.apk';
    try {
      var dio = Dio();
      final Response response =  await dio.download(url, path, onReceiveProgress: (int count, int total) {
        if (total == -1) {
          progressValue = 0.1;
        } else {
          progressValue = count / total.toDouble();
        }
        //print('progress: $progressValue');
        setState(() {});
        if (progressValue == 1) {
          //下载完成，跳转到程序安装界面
          openApk(path);
        }
      });
      //print(response.data);

    } catch (e) {
      print('$e');
      progressValue = 0;
    }
  }

//打开apk 开始安装
  openApk(String path) async {
    EasyLoading.dismiss();

    final openResult = await OpenFile.open(path);
    //print('openResult:${openResult.type}');
    if (openResult.type == ResultType.error) {
    } else if (openResult.type == ResultType.permissionDenied) {
    } else if (openResult.type == ResultType.fileNotFound) {
    } else if (openResult.type == ResultType.noAppToOpen) {
    } else {
      //if (widget.forceUpdate) Navigator.pop(context);
      //print('open result done');
    }
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
                            Navigator.pop(context);
                            Future.delayed(Duration(milliseconds: 100), () {
                              Navigator.pushNamed(context, '/home');
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
                        InkWell(
                          onTap: () {
                            showDownloadingAlert();
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
                            child: Text("アップデート",
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
                ],
              ),
            ),
          ],
        ));
  }
}
