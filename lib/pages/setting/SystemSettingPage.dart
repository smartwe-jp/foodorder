import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
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

import 'package:foodorder/services/GetxStorage.dart';
import 'package:foodorder/services/showToast.dart';
import 'SetPassword.dart';
import 'SetPosIp.dart';

class SystemSettingPage extends StatefulWidget {
  Map arguments;

  SystemSettingPage({Key key, this.arguments}) : super(key: key);

  _SystemSettingPageState createState() => _SystemSettingPageState();
}

class _SystemSettingPageState extends State<SystemSettingPage> {

  String _machineCode = "";
  var progressValue = 0.0;

  var _dining_type = "1"; //1 堂食  2 外袋  0 两种都可
  var _menu_direction = "1";//1 默认顶部横向  2 左侧纵向
  var _print_paper_size = "1";//1 默认58mm  2 宽纸80mm
  var _is_allow_receipt = "1";//1 必须打印  2 不必须打印
  var _machine_mode = "1";//1 普通点餐券卖机  2 精算机（结账机）
  var _isReservation = "0";// 0 不开启  1开启
  var _is_allow_attendance = "0";//0 不开启  1 开启
  //券卖机设置里面也设置开启并设置好ip，则展示图标及请求pos支付的相关数据
  var _is_allow_pos = "0";//0 不开启  1 开启
  var _pos_ip = "";
  var _pos_port = "";

  //券卖机设置里面也设置开启并设置好ip，则展示图标及请求wlan print的相关数据
  var _is_allow_wlanPrint = "0";//0 不开启  1 开启
  var _wlan_print_ip = "";
  var _wlan_print_port = "9100";

  var _is_allow_wlanPrint_Two = "0";//0 不开启  1 开启
  var _wlan_print_ip_Two = "";
  var _wlan_print_port_Two = "9100";

  var _actuarial = false; //是否开启精算
  var _lineup = false; //是否开启排队
  //监听页面销毁的事件
  dispose() {
    eventBus.fire(new setAttendanceCodeEvent('支付成功...'));
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    this._machineCode = widget.arguments['machineCode'];
    EasyLoading.dismiss();

    _getSystemSettingInfo();


  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
    Map wlanPrintSettingInfoTwo = await HomeServices.getWlanPrintSettingTwoInfo();
    //var billButtonList = await HomeServices.getSmartweCheckOutBillData();
    var smartweMachineSetting = await HomeServices.getSmartweMachineSettingData();
    setState(() {
      _dining_type = systemSettingInfo['diningType'];
      _menu_direction = systemSettingInfo['menuDirection'];
      _print_paper_size = systemSettingInfo['printPaperSize'];
      _is_allow_receipt = systemSettingInfo['isAllowReceipt'];
      _machine_mode = systemSettingInfo['machineMode'];
      _isReservation = systemSettingInfo['isReservation'];
      _is_allow_attendance = systemSettingInfo['isAllowAttendance'];
      _is_allow_pos = systemSettingInfo['isAllowPos'];
      _is_allow_wlanPrint = systemSettingInfo['isAllowWlanPrint'];
      _is_allow_wlanPrint_Two = systemSettingInfo['isAllowWlanPrintTwo'];

      if(posSettingInfo['posIp'] !=null && posSettingInfo['posIp'] !="" && posSettingInfo['posPort'] !=null && posSettingInfo['posPort'] !=""){
        _pos_ip = posSettingInfo['posIp'];
        _pos_port = posSettingInfo['posPort'];
      }
      if(wlanPrintSettingInfo['wlanPrintIp'] !=null && wlanPrintSettingInfo['wlanPrintIp'] !="" && wlanPrintSettingInfo['wlanPrintPort'] !=null && wlanPrintSettingInfo['wlanPrintPort'] !=""){
        _wlan_print_ip = wlanPrintSettingInfo['wlanPrintIp'];
        _wlan_print_port = wlanPrintSettingInfo['wlanPrintPort'];
      }
      if(wlanPrintSettingInfoTwo['wlanPrintIp'] !=null && wlanPrintSettingInfoTwo['wlanPrintIp'] !="" && wlanPrintSettingInfoTwo['wlanPrintPort'] !=null && wlanPrintSettingInfoTwo['wlanPrintPort'] !=""){
        _wlan_print_ip_Two = wlanPrintSettingInfoTwo['wlanPrintIp'];
        _wlan_print_port_Two = wlanPrintSettingInfoTwo['wlanPrintPort'];
      }
      if(smartweMachineSetting != null){
       _actuarial = smartweMachineSetting["machineActuarial"];
       _lineup = smartweMachineSetting["machineLineup"];
      }
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
              child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
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
                                AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));


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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":checkedType,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

    setState(() {
      _is_allow_receipt = checkedType;
    });

  }

  //设置机器类型
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

    setState(() {
      _machine_mode = checkedType;
    });

  }

  //设置是否开启预约
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

    setState(() {
      _isReservation = checkedType;
    });

  }
  
  //设置是否开启摄像头
  setIsAllowAttendance() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("チェックインの設定",
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
                    checkIsAllowAttendance("0");
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
                        child: Text("OFF",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_is_allow_attendance == "0")
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                    checkIsAllowAttendance("1");
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
                        child: Text("ON",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_is_allow_attendance == "1")
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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

  checkIsAllowAttendance(checkedType) async {

    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
      "isAllowAttendance":checkedType,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

    setState(() {
      _is_allow_attendance = checkedType;
    });

  }

  //设置是否开启pos刷卡
  setIsAllowPos() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("Pos設定",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    checkIsAllowPos("0");
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
                        child: Text("OFF",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_is_allow_pos == "0")
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                    //if(_pos_ip == ""){
                    _showPosSettingDialog();

                    //}
                    /*else{
                      checkIsAllowPos("1");
                    }*/
                  },
                  child: Stack(
                    children: [
                      Column(
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
                            child: Text("ON",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                          (_pos_ip != "" && _pos_port != "") ? Row(
                            children: [
                              Text(
                                "ip:${_pos_ip}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              ),
                              Text(
                                  "端口:${_pos_port}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              )
                            ],
                          ) : Container(height: 0,)
                        ],
                      ),
                      //绝对定位 盖章
                      (_is_allow_pos == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(45),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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

  checkIsAllowPos(checkedType) async {
    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":checkedType,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

    var posSettingData;
    if(checkedType == "1"){
      posSettingData = {
        "posIp":_pos_ip, //ip
        "posPort":_pos_port,//port
      };
    }else{
      posSettingData = {
        "posIp":"", //ip
        "posPort":"",//port
      };
      setState(() {
        _pos_port = "";
        _pos_ip = "";
      });
    }

    Storage.setString('smartwe_posSetting', json.encode(posSettingData));
    GetxStorage.setData('smartwe_posSetting', json.encode(posSettingData));

    setState(() {
      _is_allow_pos = checkedType;
    });

  }

  //预约弹出框
  _showPosSettingDialog() async {
    await showDialog(
        context: context,
        barrierDismissible: true, //表示点击灰色背景的时候是否消失弹出框
        builder: (BuildContext context) {
          return SetPosIpPage(
            posIp: _pos_ip,
            posPort: _pos_port,
            onConfrimClick: (String posIp, String posPort) {
              if(posIp != ""){
                setState(() {
                  _pos_ip = posIp;
                  _pos_port = posPort;

                });
                checkIsAllowPos("1");
              }

            },
          );
        });
  }

  //设置是否开启打印机
  setIsAllowWlanPrint() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("チキンプリンター",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    checkIsAllowWlanPrint("0");
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
                        child: Text("OFF",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_is_allow_wlanPrint == "0")
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                    //if(_pos_ip == ""){
                    _showWlanPrintSettingDialog();

                    //}
                    /*else{
                      checkIsAllowPos("1");
                    }*/
                  },
                  child: Stack(
                    children: [
                      Column(
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
                            child: Text("ON",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                          (_wlan_print_ip != "" && _wlan_print_port != "") ? Row(
                            children: [
                              Text(
                                  "ip:${_wlan_print_ip}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              ),
                              Text(
                                  "端口:${_wlan_print_port}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              )
                            ],
                          ) : Container(height: 0,)
                        ],
                      ),
                      //绝对定位 盖章
                      (_is_allow_wlanPrint == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(45),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                if(_wlan_print_ip != "" && _wlan_print_port != "")
                InkWell(
                  onTap: () {
                    _printTest(_wlan_print_ip,_wlan_print_port);
                  },
                  child: Stack(
                    children: [
                      Column(
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
                            child: Text("测试打印",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                        ],
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

  checkIsAllowWlanPrint(checkedType) async {
    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":checkedType,//0不开启 1开启
      "isAllowWlanPrintTwo":_is_allow_wlanPrint_Two,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

    var wlanPrintSettingData;
    if(checkedType == "1"){
      wlanPrintSettingData = {
        "wlanPrintIp":_wlan_print_ip, //ip
        "wlanPrintPort":_wlan_print_port,//port
      };
    }else{
      wlanPrintSettingData = {
        "wlanPrintIp":"", //ip
        "wlanPrintPort":"",//port
      };
      setState(() {
        _wlan_print_ip = "";
        _wlan_print_port = "";
      });
    }

    Storage.setString('smartwe_wlanPrintSetting', json.encode(wlanPrintSettingData));
    GetxStorage.setData('smartwe_wlanPrintSetting', json.encode(wlanPrintSettingData));


    setState(() {
      _is_allow_wlanPrint = checkedType;
    });

  }

  //设置网络打印机ip
  _showWlanPrintSettingDialog() async {
    await showDialog(
        context: context,
        barrierDismissible: true, //表示点击灰色背景的时候是否消失弹出框
        builder: (BuildContext context) {
          return SetPosIpPage(
            posIp: _wlan_print_ip,
            posPort: _wlan_print_port,
            onConfrimClick: (String printIp, String printPort) {
              if(printIp != ""){
                setState(() {
                  _wlan_print_ip = printIp;
                  _wlan_print_port = printPort;

                });
                checkIsAllowWlanPrint("1");
              }

            },
          );
        });
  }

  //设置是否开启打印机
  setIsAllowWlanPrintTwo() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("センタープリンター",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    checkIsAllowWlanPrintTwo("0");
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
                        child: Text("OFF",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_is_allow_wlanPrint_Two == "0")
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                    //if(_pos_ip == ""){
                    _showWlanPrintSettingDialogTwo();

                    //}
                    /*else{
                      checkIsAllowPos("1");
                    }*/
                  },
                  child: Stack(
                    children: [
                      Column(
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
                            child: Text("ON",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                          (_wlan_print_ip_Two != "" && _wlan_print_port_Two != "") ? Row(
                            children: [
                              Text(
                                  "ip:${_wlan_print_ip_Two}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              ),
                              Text(
                                  "端口:${_wlan_print_port_Two}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              )
                            ],
                          ) : Container(height: 0,)
                        ],
                      ),
                      //绝对定位 盖章
                      (_is_allow_wlanPrint_Two == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(45),
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
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
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
                if(_wlan_print_ip_Two != "" && _wlan_print_port_Two != "")
                  InkWell(
                    onTap: () {
                      _printTest(_wlan_print_ip_Two,_wlan_print_port_Two);
                    },
                    child: Stack(
                      children: [
                        Column(
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
                              child: Text("测试打印",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(24),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )),
                            ),
                          ],
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

  checkIsAllowWlanPrintTwo(checkedType) async {
    var systemSettingData = {
      "diningType":_dining_type, //1堂食 2外带
      "menuDirection":_menu_direction,//1顶部横向 2左侧竖
      "printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "isAllowReceipt":_is_allow_receipt,//1必须打印小票 2不必须
      "machineMode":_machine_mode,//1普通券卖机 2 精算机
      "isReservation":_isReservation, //是否开启预约服务
      "isAllowAttendance":_is_allow_attendance,//0不开启 1开启
      "isAllowPos":_is_allow_pos,//0不开启 1开启
      "isAllowWlanPrint":_is_allow_wlanPrint,//0不开启 1开启
      "isAllowWlanPrintTwo":checkedType,//0不开启 1开启
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));

    var wlanPrintSettingData;
    if(checkedType == "1"){
      wlanPrintSettingData = {
        "wlanPrintIp":_wlan_print_ip_Two, //ip
        "wlanPrintPort":_wlan_print_port_Two,//port
      };
    }else{
      wlanPrintSettingData = {
        "wlanPrintIp":"", //ip
        "wlanPrintPort":"",//port
      };
      setState(() {
        _wlan_print_ip_Two = "";
        _wlan_print_port_Two = "";
      });
    }
    Storage.setString('smartwe_wlanPrintSettingTwo', json.encode(wlanPrintSettingData));
    GetxStorage.setData('smartwe_wlanPrintSettingTwo', json.encode(wlanPrintSettingData));


    setState(() {
      _is_allow_wlanPrint_Two = checkedType;
    });

  }

  //设置网络打印机ip
  _showWlanPrintSettingDialogTwo() async {
    await showDialog(
        context: context,
        barrierDismissible: true, //表示点击灰色背景的时候是否消失弹出框
        builder: (BuildContext context) {
          return SetPosIpPage(
            posIp: _wlan_print_ip_Two,
            posPort: _wlan_print_port_Two,
            onConfrimClick: (String printIp, String printPort) {
              if(printIp != ""){
                setState(() {
                  _wlan_print_ip_Two = printIp;
                  _wlan_print_port_Two = printPort;

                });
                checkIsAllowWlanPrintTwo("1");
              }

            },
          );
        });
  }

  _printTest(printIp,printPort) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);
    final PosPrintResult res = await printer.connect(printIp, port: int.parse(printPort));
    //final PosPrintResult res = await printer.connect(_kitchenPointIp, port: 9100);
    if (res == PosPrintResult.success) {
      // DEMO RECEIPT
      await testReceipt(printer,printIp);
      // TEST PRINT
      // await testReceipt(printer);
      printer.disconnect();
    }else{
      showToast(res.msg);
      sleep(Duration(milliseconds: 5000));
    }
  }
  testReceipt(NetworkPrinter printer,printIp) {
    printer.text(
        'Success');
    printer.text("${printIp}",
        styles: PosStyles(codeTable: 'CP1252'));
    printer.text('Success',
        styles: PosStyles(codeTable: 'CP1252'));

    printer.text('Bold text', styles: PosStyles(bold: true));

    printer.feed(2);
    printer.cut();
  }

  showSettingPassword() async {
    await showDialog(
        context: context,
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        builder: (BuildContext context) {
      return SetPasswordPage();
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
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          showSettingPassword();
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
                          child: Text("パスワード",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(24),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )),
                        ),
                      ),
                      SizedBox(width: 30,),
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
                  //setPrintPaperSize(),//打印纸大小
                  setIsAllowReceipt(),//设置是否允强制必须打印领収书
                  (_actuarial == true) ? setMachineMode() : Container(height: 0,), //设置机器类型
                  (_lineup == true) ? setIsReservation() : Container(height: 0,),  //是否开启预约服务
		              setIsAllowAttendance(),//是否开启签到
                  setIsAllowPos(),//是否开启pos机刷卡
                  setIsAllowWlanPrint(),//是否开启网络打印机
                  setIsAllowWlanPrintTwo(),//第二台打印机
                ],
              ),
            ),
          ],
        ));
  }
}
