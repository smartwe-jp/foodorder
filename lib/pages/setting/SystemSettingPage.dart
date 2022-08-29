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


import 'package:get/get.dart' hide Response;
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SystemSettingPage extends StatefulWidget {
  Map arguments;

  SystemSettingPage({Key key, this.arguments}) : super(key: key);

  _SystemSettingPageState createState() => _SystemSettingPageState();
}

class _SystemSettingPageState extends State<SystemSettingPage> {

  String _machineCode = "";
  var progressValue = 0.0;

  var _shopInfo = "kanran";
  var _dining_type = "1"; //1 堂食  2 外袋  0 两种都可
  var _menu_direction = "1";//1 默认顶部横向  2 左侧纵向
  var _print_paper_size = "1";//1 默认58mm  2 宽纸80mm
  var _is_allow_receipt = "1";//1 必须打印  2 不必须打印
  var _machine_mode = "1";//1 普通点餐券卖机  2 精算机（结账机）
  var _isReservation = "0";// 0 不开启  1开启

  //监听页面销毁的事件
  dispose() {
    //eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    this._machineCode = widget.arguments['machineCode'];
    this._shopInfo = widget.arguments['shopInfo'];
    EasyLoading.dismiss();

    //_getDiningTypeInfo();
    //_getMenuDirection();
    //_getPrintPaperSize();
    _getSystemSettingInfo();


  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
print(systemSettingInfo);
    setState(() {
      _dining_type = systemSettingInfo['diningType'];
      _menu_direction = systemSettingInfo['menuDirection'];
      _print_paper_size = systemSettingInfo['printPaperSize'];
      _is_allow_receipt = systemSettingInfo['isAllowReceipt'];
      _machine_mode = systemSettingInfo['machineMode'];
      _isReservation = systemSettingInfo['isReservation'];
    });
  }

  //获取就餐类型信息
  _getDiningTypeInfo() async {
    var DiningTypeInfo = await HomeServices.getDiningTypeInfo();
    if (DiningTypeInfo != "") {
      setState(() {
        _dining_type = DiningTypeInfo;

      });
    }else{
      Storage.setString('diningType', "1");//1 堂食  2 外袋  0 两种都可
    }
  }

  //获取菜单方向
  _getMenuDirection() async {
    var menuDirectionInfo = await HomeServices.getMenuDirectionInfo();
    if (menuDirectionInfo != "") {
      setState(() {
        _menu_direction = menuDirectionInfo;
      });
    }else{
      Storage.setString('menuDirection', "1");//1 默认顶部横向  2 左侧纵向
    }
  }

  //获取菜单方向
  _getPrintPaperSize() async {
    var printPaperSizeInfo = await HomeServices.getPrintPaperSizeInfo();
    if (printPaperSizeInfo != "") {
      setState(() {
        _print_paper_size = printPaperSizeInfo;
      });
    }else{
      Storage.setString('printPaperSize', "1");//1 默认58mm  2 宽纸80mm
    }
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
        height:ScreenAdapter.height(450),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("アップデート中……",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor("#000000"),
                )),
            SizedBox(height: ScreenAdapter.height(30),),
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString(_shopInfo, "printticketloading"),fit: BoxFit.fitHeight),
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
    final path = storagePath + '/smartwe_ticket_machine.apk';
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

  //设置就餐类型
  setDiningtype() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("利用形式",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Text("(お持帰りと店内のご利用で税率が異なります。)",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    checkDiningtype("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("店内のみ",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_dining_type == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                            width: ScreenAdapter.width(40),
                            height: ScreenAdapter.height(40),
                            padding: EdgeInsets.only(
                                top: ScreenAdapter.height(4),
                                left: ScreenAdapter.width(10)),
                            //alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              image: DecorationImage(
                                image:
                                AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                                fit: BoxFit.fill,
                              ),
                            ),
                            ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    checkDiningtype("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(220),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("テイクアウトのみ",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_dining_type == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    checkDiningtype("3");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("両方可",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_dining_type == "3")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
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

  checkDiningtype(checkedType){
    var systemSettingData = {
      "diningType":checkedType, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));

    //Storage.setString('diningType', checkedType);//1 堂食  2 外袋  0 两种都可
    setState(() {
      _dining_type = checkedType;
    });
  }

  //设置菜单方向
  setMenuDirection() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("メニューバーの表示",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    checkMenuDirection("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("上部横並び",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_menu_direction == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    checkMenuDirection("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("左側縦表示",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_menu_direction == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
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

  checkMenuDirection(checkedType){
    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":checkedType,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));

    //Storage.setString('menuDirection', checkedType);//1 默认顶部横向  2 左侧纵向
    setState(() {
      _menu_direction = checkedType;
    });
  }

  //设置打印纸大小
  setPrintPaperSize() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("レシートの幅",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Text("（セッティングしたレシート用紙をお選びください）",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    checkPrintPaperSize("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("58mm",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_print_paper_size == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    checkPrintPaperSize("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("80mm",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_print_paper_size == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
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

  checkPrintPaperSize(checkedType) async {
    /*var printstatus;
    if(checkedType == "1"){
      printstatus = await FlutterPluginMsprinter.setPrintPaperSizefiftyeight();
    }else{
      printstatus = await FlutterPluginMsprinter.setPrintPaperSizeeighty();
    }
    sleep(Duration(milliseconds: 500));
    print(printstatus);*/
    //if("success" == printstatus){
      /*var checkprintStatus = await FlutterPluginMsprinter.getPrintStatus();print(checkprintStatus);
      sleep(Duration(milliseconds: 500));
      await FlutterPluginMsprinter.setPrintPaperSizePrintTest();*/

    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":checkedType,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));

      //Storage.setString('printPaperSize', checkedType);//1 58  2 80
      setState(() {
        _print_paper_size = checkedType;
      });
    //}
  }

  //设置是否必须打印领収书
  setIsAllowReceipt() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("領収書の発行の設定",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Text("（必須を選ぶ場合は、領収書が自動的に印刷されます。）",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    checkIsAllowReceipt("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("必須",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_is_allow_receipt == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    checkIsAllowReceipt("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("要確認",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_is_allow_receipt == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
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

  checkIsAllowReceipt(checkedType) async {

    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":checkedType,//1必须打印小票 2不必须
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));

    //Storage.setString('isAllowReceipt', checkedType);//1 必须  2 不必须
    setState(() {
      _is_allow_receipt = checkedType;
    });

  }

  //设置是否必须打印领収书
  setMachineMode() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("マシンモード設定",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    checkMachineMode("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("券売機モード",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_machine_mode == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    checkMachineMode("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("精算機モード",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_machine_mode == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
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

  checkMachineMode(checkedType) async {

    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
      "machineMode":checkedType,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));

    //Storage.setString('isAllowReceipt', checkedType);//1 必须  2 不必须
    setState(() {
      _machine_mode = checkedType;
    });

  }

  //设置是否必须打印领収书
  setIsReservation() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("予約サービス設定",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    checkIsReservation("0");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("停止",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_isReservation == "0")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    checkIsReservation("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("起動",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_isReservation == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString(_shopInfo, "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
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

  checkIsReservation(checkedType) async {

    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":checkedType, //是否开启预约服务
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));

    //Storage.setString('isAllowReceipt', checkedType);//1 必须  2 不必须
    setState(() {
      _isReservation = checkedType;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("システム設定")),
        body: ListView(
          children: <Widget>[

            Container(
              decoration: new BoxDecoration(color: Colors.white),
              width: ScreenAdapter.width(820.0),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      /*Future.delayed(Duration(milliseconds: 100), () {
                        Navigator.pushNamed(context, '/home');
                      });*/
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

                  SizedBox(
                    height: ScreenAdapter.height(20),
                  ),
                  setDiningtype(),//食事のタイプ
                  setMenuDirection(),//菜单方向
                  setPrintPaperSize(),//打印纸大小
                  setIsAllowReceipt(),//设置是否允强制必须打印领収书
                  setMachineMode(), //设置机器类型
                  setIsReservation(),  //是否开启预约服务
                ],
              ),
            ),
          ],
        ));
  }
}
