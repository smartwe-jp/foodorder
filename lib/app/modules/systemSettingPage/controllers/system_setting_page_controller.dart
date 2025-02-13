import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart'  hide Response,FormData,MultipartFile;
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:print_image_generate_tool/print_image_generate_tool.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../config/printer_info.dart';
import '../../../plugins/paycube/lib/paycube.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/Storage.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../../OrderHome/controllers/order_home_controller.dart';
import '../../settlement/views/label_constrained_box.dart';
import '../../settlement/views/receipt_constrained_box.dart';
import '../views/showSpeed.dart';

class SystemSettingPageController extends GetxController with StateMixin {
  //TODO: Implement SystemSettingPageController

  RxString local_version = "".obs; //本appversion
  RxString machineCode = "".obs;

  RxString dining_type = "1".obs; //1 堂食  2 外袋  3 两种都可
  RxBool dining_type_one = false.obs; //false无堂食 true 堂食
  RxBool dining_type_two = false.obs; //false无外卖  true 外卖
  RxString menu_direction = "1".obs;//1 默认顶部横向  2 左侧纵向
  RxString print_paper_size = "1".obs;//1 默认58mm  2 宽纸80mm
  RxString print_paper_txt_size = "1".obs;//1 普通　2大　3特大
  RxString is_allow_receipt = "1".obs;//1 必须打印  2 不必须打印
  RxString is_allow_receipt_menu = "1".obs;//1 必须打印  2 不要
  RxString machine_mode = "1".obs;//1 普通点餐券卖机  2 精算机（结账机）
  RxString isReservation = "0".obs;// 0 不开启  1开启
  RxString is_allow_attendance = "0".obs;//0 不开启  1 开启
  RxString is_allow_settlementhome = "0".obs;//0 不开启  1 开启
  RxString is_allow_oneyen = "0".obs;//0 禁用  1 允许
  RxString is_allow_backhome = "0".obs;//0 返回  1 返回菜单
  RxString is_allow_rejishime = "0".obs;//0 不开启  1 开启
  //券卖机设置里面也设置开启并设置好ip，则展示图标及请求pos支付的相关数据
  RxString is_allow_pos = "0".obs;//0 不开启  1 开启
  RxString pos_ip = "".obs;
  RxString pos_port = "".obs;

  //券卖机设置里面也设置开启并设置好ip，则展示图标及请求wlan print的相关数据
  RxString is_allow_wlanPrint = "0".obs;//0 不开启  1 开启
  RxString is_allow_wlanPrint_continuous = "0".obs;//0 单票  1 连票  Print Continuous
  RxString wlan_print_ip = "".obs;
  RxString wlan_print_port = "9100".obs;

  RxInt showPrintType =0.obs; //0 receipt   1Lable

  RxString is_allow_wlanPrint_Two = "0".obs;//0 不开启  1 开启
  RxString is_allow_wlanPrint_Two_continuous = "0".obs;//0 单票  1 连票  Print Continuous
  RxString wlan_print_ip_Two = "".obs;
  RxString wlan_print_port_Two = "9100".obs;

  RxBool actuarial = false.obs; //是否开启精算
  RxBool  lineup = false.obs; //是否开启排队

  RxDouble downloadProgress = 0.0.obs;

  RxBool printDirection = false.obs;
  RxBool printTwoDirection = false.obs;
  RxBool printThreeDirection = false.obs;
  RxDouble printLabelWidth = 400.0.obs;

  @override
  void onInit() {
    machineCode.value = Get.arguments['machineCode'];
    _getPackageInfo();

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  //获取版本号
  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version;//+"+"+packageInfo.buildNumber

    _getSystemSettingInfo();
  }

  //获取系统设置信息
  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
    Map wlanPrintSettingInfoTwo = await HomeServices.getWlanPrintSettingTwoInfo();
    printDirection.value = await HomeServices.getPrintDirection() == "1" ? true : false;
    printTwoDirection.value = await HomeServices.getPrintTwoDirection() == "1" ? true : false;
    printThreeDirection.value = await HomeServices.getPrintThreeDirection() == "1" ? true : false;
    printLabelWidth.value = await HomeServices.getLabelPrintWidth();
    //var billButtonList = await HomeServices.getSmartweCheckOutBillData();
    var smartweMachineSetting = await HomeServices.getSmartweMachineSettingData();

      dining_type.value = systemSettingInfo['diningType'];
      if(dining_type.value == "1"){
        dining_type_one.value= true;
        dining_type_two.value = false;
      }else if(dining_type.value == "2"){
        dining_type_one.value= false;
        dining_type_two.value = true;
      }else if(dining_type.value == "3"){
        dining_type_one.value= true;
        dining_type_two.value = true;
      }
      menu_direction.value = systemSettingInfo['menuDirection'];
      // _print_paper_size = systemSettingInfo['printPaperSize'];
      print_paper_txt_size.value = systemSettingInfo['printPaperTxtSize'];

      is_allow_receipt.value = systemSettingInfo['isAllowReceipt'];
      is_allow_receipt_menu.value = systemSettingInfo['isAllowReceiptMenu'];
      machine_mode.value = systemSettingInfo['machineMode'];
      isReservation.value = systemSettingInfo['isReservation'];
      is_allow_attendance.value = systemSettingInfo['isAllowAttendance'];
      is_allow_oneyen.value = systemSettingInfo['isAllowOneYen'];
      is_allow_backhome.value = systemSettingInfo['isAllowBackHome'];
      is_allow_rejishime.value = systemSettingInfo['isAllowRejishime'] ?? "0";
      is_allow_pos.value = systemSettingInfo['isAllowPos'];
      is_allow_wlanPrint.value = systemSettingInfo['isAllowWlanPrint'];
      is_allow_wlanPrint_continuous.value = systemSettingInfo['isAllowWlanPrintContinuous'];
      showPrintType.value = int.parse(systemSettingInfo['showPrintType']);
      is_allow_wlanPrint_Two.value = systemSettingInfo['isAllowWlanPrintTwo'];
      is_allow_wlanPrint_Two_continuous.value = systemSettingInfo['isAllowWlanPrintTwoContinuous'];

      if(posSettingInfo['posIp'] !=null && posSettingInfo['posIp'] !="" && posSettingInfo['posPort'] !=null && posSettingInfo['posPort'] !=""){
        pos_ip.value = posSettingInfo['posIp'];
        pos_port.value = posSettingInfo['posPort'];
      }
      if(wlanPrintSettingInfo['wlanPrintIp'] !=null && wlanPrintSettingInfo['wlanPrintIp'] !="" && wlanPrintSettingInfo['wlanPrintPort'] !=null && wlanPrintSettingInfo['wlanPrintPort'] !=""){
        wlan_print_ip.value = wlanPrintSettingInfo['wlanPrintIp'];
        wlan_print_port.value = wlanPrintSettingInfo['wlanPrintPort'];
      }
      if(wlanPrintSettingInfoTwo['wlanPrintIp'] !=null && wlanPrintSettingInfoTwo['wlanPrintIp'] !="" && wlanPrintSettingInfoTwo['wlanPrintPort'] !=null && wlanPrintSettingInfoTwo['wlanPrintPort'] !=""){
        wlan_print_ip_Two.value = wlanPrintSettingInfoTwo['wlanPrintIp'];
        wlan_print_port_Two.value = wlanPrintSettingInfoTwo['wlanPrintPort'];
      }
      if(smartweMachineSetting != null){
        actuarial.value = smartweMachineSetting["machineActuarial"];
        lineup.value = smartweMachineSetting["machineLineup"];
      }
    change(null, status: RxStatus.success());
  }

  late Map<String, dynamic> systemSettingData = {
    "diningType": dining_type.value, //1堂食 2外带
    "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
    //"printPaperSize": _print_paper_size, //1 58mm 2 80mm
    "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
    "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
    "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
    "machineMode": machine_mode.value, //1普通券卖机 2 精算机
    "isReservation": isReservation.value, //是否开启预约服务
    "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
    "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
    "isAllowRejishime": is_allow_rejishime.value, //0不开启 1开启
    "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
    "isAllowPos": is_allow_pos.value, //0不开启 1开启
    "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
    "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
    "showPrintType": showPrintType.value.toString(), //0receipt 1label
    "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
    "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
  };

  showDownloadingAlert() {
    //支付状态
    Get.dialog(
        Container(
          width: ScreenAdapter.width(950),
          child: SimpleDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              title: Align(
                  alignment: Alignment.center,
                  child:  Text("アップデートのお知らせ",style: TextStyle(fontSize:
                  ScreenAdapter.fontSize(28),
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w600))
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
                                    fontFamily: 'NotoSansJP',
                                    fontSize: ScreenAdapter.fontSize(32.0)),
                              ),
                              onPressed: () {
                                //sleep(Duration(milliseconds: 3000));
                                Get.back();

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
                                    fontFamily: 'NotoSansJP',
                                    fontSize: ScreenAdapter.fontSize(32.0)),
                              ),
                              onPressed: () async {
                                //widget.confirmCallback('确定');
                                Get.back();
                                Get.dialog(
                                    showSpeedView()
                                );
                                //https://app.gutingjun.com/kanran-release.apk
                                downloadAndroid("https://app.smartwe.co.jp/smartwe_ticket_machine.apk");
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
        )
    );
  }



  /// 下载安卓更新包
  Future<String?> downloadAndroid(String url) async {
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
    /*EasyLoading.show(
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
    );*/

    /// 创建存储文件
    //print(url);
    Directory storageDir = await getTemporaryDirectory();
    String storagePath = storageDir.path;
    final path = storagePath + '/smartwe_ticket_machine.apk';
    try {
      var dio = Dio();
      final Response response =  await dio.download(url, path, onReceiveProgress: (received, total) {
        /*if (total == -1) {
          progressValue = 0.1;
        } else {
          progressValue = count / total.toDouble();
        }*/
        if (total != -1) {
          downloadProgress.value = received / total;
        }

        if (received / total == 1) {
          Get.back();
          //下载完成，跳转到程序安装界面
          openApk(path);
        }
      });
      //print(response.data);

    } catch (e) {
      print('$e');
      //progressValue = 0;
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

  checkDiningtype(checkedType){
    if(checkedType == "1"){
      dining_type_one.value = !dining_type_one.value;
    }else if(checkedType == "2"){
      dining_type_two.value = !dining_type_two.value;
    }

    var dining_type_tmp = "1";
    if(dining_type_one.value == true && dining_type_two.value == false){
      dining_type_tmp = "1";
    }else if(dining_type_one.value == false && dining_type_two.value == true){
      dining_type_tmp = "2";
    }else if(dining_type_one.value == true && dining_type_two.value == true){
      dining_type_tmp = "3";
    }else{
      dining_type_one.value = true;
      dining_type_tmp = "1";
    }

      dining_type.value = dining_type_tmp;
    _updateSystemSetting("diningType", dining_type_tmp);
    //该处逻辑需要修改，如果切换模式会有获取不到Controller的问题。
    if(machine_mode == "1"){
      //if (Get.isRegistered<OrderHomeController>())
      //Get.find<OrderHomeController>().getSystemSettingInfo();
    }else if(machine_mode == "2"){
      if (Get.isRegistered<CheckoutPageController>())
      Get.find<CheckoutPageController>().getSystemSettingInfo();
    }

  }

  checkMenuDirection(checkedType){

    menu_direction.value = checkedType;
    _updateSystemSetting("menuDirection", checkedType);
    //if(Get.isRegistered<OrderHomeController>())
    //Get.find<OrderHomeController>().getSystemSettingInfo();
  }

  checkPrintPaperTxtSize(checkedType) async {
    print_paper_txt_size.value = checkedType;
    _updateSystemSetting("printPaperTxtSize", checkedType);
  }

  checkIsAllowReceipt(checkedType) async {

    is_allow_receipt.value = checkedType;
    _updateSystemSetting("isAllowReceipt", checkedType);

  }

  checkIsAllowReceiptMenu(checkedType) async {

    is_allow_receipt_menu.value = checkedType;
    _updateSystemSetting("isAllowReceiptMenu", checkedType);

  }

  checkMachineMode(checkedType) async {
    machine_mode.value = checkedType;
    _updateSystemSetting("machineMode", checkedType);
  }

  checkIsReservation(checkedType) async {
    isReservation.value = checkedType;
    _updateSystemSetting("isReservation", checkedType);

  }

  checkIsAllowPos(checkedType) async {
    var posSettingData;
    if(checkedType == "1"){
      posSettingData = {
        "posIp":pos_ip.value, //ip
        "posPort":pos_port.value,//port
      };
    }else{
      posSettingData = {
        "posIp":"", //ip
        "posPort":"",//port
      };

        pos_port.value = "";
        pos_ip.value = "";

    }

    Storage.setString('smartwe_posSetting', json.encode(posSettingData));
    GetxStorage.setData('smartwe_posSetting', json.encode(posSettingData));

    is_allow_pos.value = checkedType;
    _updateSystemSetting("isAllowPos", checkedType);

  }

  checkIsAllowWlanPrint(checkedType) async {

    var wlanPrintSettingData;
    if(checkedType == "1"){
      wlanPrintSettingData = {
        "wlanPrintIp":wlan_print_ip.value, //ip
        "wlanPrintPort":wlan_print_port.value,//port
      };
    }else{
      wlanPrintSettingData = {
        "wlanPrintIp":"", //ip
        "wlanPrintPort":"",//port
      };

        wlan_print_ip.value = "";
        wlan_print_port.value = "";

    }

    Storage.setString('smartwe_wlanPrintSetting', json.encode(wlanPrintSettingData));
    GetxStorage.setData('smartwe_wlanPrintSetting', json.encode(wlanPrintSettingData));

    is_allow_wlanPrint.value = checkedType;

    _updateSystemSetting("isAllowWlanPrint", checkedType);
  }

  checkIsAllowWlanPrintTwo(checkedType) async {

    var wlanPrintSettingData;
    if(checkedType == "1"){
      wlanPrintSettingData = {
        "wlanPrintIp":wlan_print_ip_Two.value, //ip
        "wlanPrintPort":wlan_print_port_Two.value,//port
      };
    }else{
      wlanPrintSettingData = {
        "wlanPrintIp":"", //ip
        "wlanPrintPort":"",//port
      };

        wlan_print_ip_Two.value = "";
        wlan_print_port_Two.value = "";

    }
    Storage.setString('smartwe_wlanPrintSettingTwo', json.encode(wlanPrintSettingData));
    GetxStorage.setData('smartwe_wlanPrintSettingTwo', json.encode(wlanPrintSettingData));



      is_allow_wlanPrint_Two.value = checkedType;
    _updateSystemSetting("isAllowWlanPrintTwo", checkedType);

  }

  posTest(posIp, posPort) async {
    _showEasyLoading("POS Test Start");
    debugPrint("--- posTest ---");
    request('webBootPosTest', method: 'POST')
        .then((val) {
      var response = json.decode(val.toString());
      debugPrint("webBootPosTest: " + response.toString());
      if (response['code'] == 200) {
        payconnectSocker(response['data'], posIp, posPort);
      } else {
        EasyLoading.dismiss();
        showTestResultDialog("Server error");
      }
    });


  }
  RxInt socketNumberTimes = 0.obs;
  Socket? _socket; //socket对象

  payconnectSocker(questData, pos_ip, pos_port) async {

    //判断socket请求次数
    socketNumberTimes.value++;
    if(socketNumberTimes.value>20){
      EasyLoading.dismiss();
      showTestResultDialog("POS Connection Failed");
      return;
    }
    debugPrint("POS机连接${socketNumberTimes.value}");
    Socket.connect(
      pos_ip,
      int.parse(pos_port),
      //timeout: Duration(seconds: 5),
    ).then((Socket socket) {
      debugPrint("POS机连接成功");
      this._socket = socket;

      this._socket?.write(questData);
      EasyLoading.dismiss();
      showTestResultDialog("POS Test Success");

      this._socket?.listen((List<int> event) {
        showTestResultDialog("POS Test All Success");
        EasyLoading.dismiss();
      },
        onDone: () {
          EasyLoading.dismiss();
          showTestResultDialog("POS Test Done");
          print("pos机done了");
        },
        onError: (e) {
          EasyLoading.dismiss();
          showTestResultDialog("POS Test Failed");
          print("pos机错误了");
          //_close();
        },
      );

    }).catchError((e) {
      EasyLoading.dismiss();
      print("Unable to connect: $e");
      print("POS机连接${socketNumberTimes.value}");
      Future.delayed(Duration(seconds: 1), () {
        payconnectSocker(questData, pos_ip, pos_port);
      });
    });

  }

  showTestResultDialog(content) {
    Get.dialog(
        DialogUtils.alertOneButton(content,
            title: "POS Test Result",
            confirmtitle: "はい",
            confirm: () {

              Get.back();
              update();
            }),
        barrierDismissible: false
    );


  }

  //printType=0 receipt 1label
  printTest(printIp,printPort,{printType=0}) async {

    if(printType == 0){
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: testReceipt(printIp) as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: PrinterInfo(ip:printIp),
        ),
      );
    }else{
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: testLabel(printIp) as ATempWidget,
          printTypeEnum: PrintTypeEnum.label,
          params: PrinterInfo(ip:printIp),
        ),
      );
    }
  }
  testReceipt(printIp) {
    return ReceiptConstrainedBox(Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: Text("Success     ",
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'NotoSansJP',
                      color: ColorsUtil.hexToColor("#000000"),
                    ))
            ),
            Directionality(
                textDirection: TextDirection.rtl,
                child: Text("${printIp}",
                    softWrap: true,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'NotoSansJP',
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
          ],
        )
      ],
    ));
  }
  testLabel(printIp) {
    return LabelConstrainedBox(Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: Text("Success     ",
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'NotoSansJP',
                      color: ColorsUtil.hexToColor("#000000"),
                    ))
            ),
            Directionality(
                textDirection: TextDirection.rtl,
                child: Text("${printIp}",
                    softWrap: true,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'NotoSansJP',
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
          ],
        )
      ],
    ));
  }

  checkIsAllowOneYen(checkedType) async {

    if(checkedType == "0"){
      var prohibitOneCashStatus =  await Paycube.prohibitOneCash;
    }else{
      var allowOneCashStatus =  await Paycube.allowOneCash;
    }
    is_allow_oneyen.value = checkedType;

    _updateSystemSetting("isAllowOneYen", checkedType);

  }

  checkIsAllowRejishime(checkedType) async {
    is_allow_rejishime.value = checkedType;
    _updateSystemSetting("isAllowRejishime", checkedType);
  }

  setPrintDirection(direction,index) async {
    if(index == 1) {
      await HomeServices.setPrintDirection(direction);
      printDirection.value = direction == "1" ? true : false;

    } else if (index == 2) {
      await HomeServices.setPrintTwoDirection(direction);
      printTwoDirection.value = direction == "1" ? true : false;
    } else if (index == 3) {
      await HomeServices.setPrintThreeDirection(direction);
      printThreeDirection.value = direction == "1" ? true : false;
    }
    update();
  }

  setLabelPrintSize(width) async {
    printLabelWidth.value = width;
    await HomeServices.setLabelPrintWidth(width);
    update();
  }

  void _updateSystemSetting(String key, dynamic value) {
    if (systemSettingData.containsKey(key)) {
      systemSettingData[key] = value;
      Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
      GetxStorage.setData('smartwe_systemSetting', json.encode(systemSettingData));
    } else {
      print('Key $key does not exist in systemSettingData.');
    }
    update();
  }

  checkIsAllowBackHome(checkedType) async {

    is_allow_backhome.value = checkedType;
    _updateSystemSetting("isAllowBackHome", checkedType);
  }

  //上传现金机log
  uploadErrorLog() async {
    _showEasyLoading("Uploading...");
    var logfile="/mnt/sdcard/Android/data/comlib/log/COMLibLog.txt";

    FormData formData = FormData.fromMap({
      "machineCode": machineCode.value,
      "file": await MultipartFile.fromFile(logfile),
    });

    request(
        'webBootLogUpload',
        method: 'POST',
        parameters: formData
    ).then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();
      if (response["code"] == 200) {

        showToast('上传成功~~');
      } else {
        showToast('上传失败!');
      }
    });


  }

  _showEasyLoading(text){
    var _showTag;
    _showTag = Text(text,
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child:InkWell(
            onLongPress: () {
              EasyLoading.dismiss();
            },
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
            ),
          ],
        )),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

}
