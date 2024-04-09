import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/printer_list_page.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:android_usb_printer/android_usb_printer.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/printer_info.dart';
import '../../../plugins/paycube/lib/paycube.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/Storage.dart';
import '../../../services/showToast.dart';
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
  RxString menu_direction = "1".obs; //1 默认顶部横向  2 左侧纵向
  RxString print_paper_size = "1".obs; //1 默认58mm  2 宽纸80mm
  RxString print_paper_txt_size = "1".obs; //1 普通　2大　3特大
  RxString is_allow_receipt = "1".obs; //1 必须打印  2 不必须打印
  RxString is_allow_receipt_menu = "1".obs; //1 必须打印  2 不要
  RxString machine_mode = "1".obs; //1 普通点餐券卖机  2 精算机（结账机）
  RxString isReservation = "0".obs; // 0 不开启  1开启
  RxString is_allow_attendance = "0".obs; //0 不开启  1 开启
  RxString is_allow_settlementhome = "0".obs; //0 不开启  1 开启
  RxString is_allow_oneyen = "0".obs; //0 禁用  1 允许
  RxString is_allow_backhome = "0".obs; //0 返回  1 返回菜单
  //券卖机设置里面也设置开启并设置好ip，则展示图标及请求pos支付的相关数据
  RxString is_allow_pos = "0".obs; //0 不开启  1 开启
  RxString pos_ip = "".obs;
  RxString pos_port = "".obs;

  //券卖机设置里面也设置开启并设置好ip，则展示图标及请求wlan print的相关数据
  RxString is_allow_wlanPrint = "0".obs; //0 不开启  1 开启
  RxString is_allow_wlanPrint_continuous =
      "0".obs; //0 单票  1 连票  Print Continuous
  RxString wlan_print_ip = "".obs;
  RxString wlan_print_port = "9100".obs;

  RxInt showPrintType = 0.obs; //0 receipt   1Lable

  RxString is_allow_wlanPrint_Two = "0".obs; //0 不开启  1 开启
  RxString is_allow_wlanPrint_Two_continuous =
      "0".obs; //0 单票  1 连票  Print Continuous
  RxString wlan_print_ip_Two = "".obs;
  RxString wlan_print_port_Two = "9100".obs;

  RxBool actuarial = false.obs; //是否开启精算
  RxBool lineup = false.obs; //是否开启排队

  RxDouble downloadProgress = 0.0.obs;

  RxMap usbDevice = {}.obs;

  @override
  void onInit() {
    debugPrint("SystemSettingPageController init");
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
    //PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value =
        "2.4.0"; //packageInfo.version;//+"+"+packageInfo.buildNumber

    _getSystemSettingInfo();
  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
    Map wlanPrintSettingInfoTwo =
        await HomeServices.getWlanPrintSettingTwoInfo();
    //var billButtonList = await HomeServices.getSmartweCheckOutBillData();
    var smartweMachineSetting =
        await HomeServices.getSmartweMachineSettingData();
    usbDevice.value = await HomeServices.getUsbPrintSettingInfo();

    dining_type.value = systemSettingInfo['diningType'];
    if (dining_type.value == "1") {
      dining_type_one.value = true;
      dining_type_two.value = false;
    } else if (dining_type.value == "2") {
      dining_type_one.value = false;
      dining_type_two.value = true;
    } else if (dining_type.value == "3") {
      dining_type_one.value = true;
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
    is_allow_pos.value = systemSettingInfo['isAllowPos'];
    is_allow_wlanPrint.value = systemSettingInfo['isAllowWlanPrint'];
    is_allow_wlanPrint_continuous.value =
        systemSettingInfo['isAllowWlanPrintContinuous'];
    showPrintType.value = int.parse(systemSettingInfo['showPrintType']);
    is_allow_wlanPrint_Two.value = systemSettingInfo['isAllowWlanPrintTwo'];
    is_allow_wlanPrint_Two_continuous.value =
        systemSettingInfo['isAllowWlanPrintTwoContinuous'];

    if (posSettingInfo['posIp'] != null &&
        posSettingInfo['posIp'] != "" &&
        posSettingInfo['posPort'] != null &&
        posSettingInfo['posPort'] != "") {
      pos_ip.value = posSettingInfo['posIp'];
      pos_port.value = posSettingInfo['posPort'];
    }
    if (wlanPrintSettingInfo['wlanPrintIp'] != null &&
        wlanPrintSettingInfo['wlanPrintIp'] != "" &&
        wlanPrintSettingInfo['wlanPrintPort'] != null &&
        wlanPrintSettingInfo['wlanPrintPort'] != "") {
      wlan_print_ip.value = wlanPrintSettingInfo['wlanPrintIp'];
      wlan_print_port.value = wlanPrintSettingInfo['wlanPrintPort'];
    }
    if (wlanPrintSettingInfoTwo['wlanPrintIp'] != null &&
        wlanPrintSettingInfoTwo['wlanPrintIp'] != "" &&
        wlanPrintSettingInfoTwo['wlanPrintPort'] != null &&
        wlanPrintSettingInfoTwo['wlanPrintPort'] != "") {
      wlan_print_ip_Two.value = wlanPrintSettingInfoTwo['wlanPrintIp'];
      wlan_print_port_Two.value = wlanPrintSettingInfoTwo['wlanPrintPort'];
    }
    if (smartweMachineSetting != null) {
      actuarial.value = smartweMachineSetting["machineActuarial"];
      lineup.value = smartweMachineSetting["machineLineup"];
    }
    change(null, status: RxStatus.success());
  }

  showDownloadingAlert() {
    //支付状态
    Get.dialog(Container(
      width: ScreenAdapter.width(950),
      child: SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Align(
              alignment: Alignment.center,
              child: Text("アップデートのお知らせ",
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(28),
                      fontWeight: FontWeight.w600))),
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
                                fontSize: ScreenAdapter.fontSize(32.0)),
                          ),
                          onPressed: () async {
                            //widget.confirmCallback('确定');
                            Get.back();
                            Get.dialog(showSpeedView());
                            //https://app.gutingjun.com/kanran-release.apk
                            downloadAndroid(
                                "https://app.gutingjun.com/smartwe_ticket_machine.apk");
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ]),
    ));
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
  startDownLoad(String url) async {
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
      final Response response =
          await dio.download(url, path, onReceiveProgress: (received, total) {
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

  checkDiningtype(checkedType) {
    if (checkedType == "1") {
      dining_type_one.value = !dining_type_one.value;
    } else if (checkedType == "2") {
      dining_type_two.value = !dining_type_two.value;
    }

    var dining_type_tmp = "1";
    if (dining_type_one.value == true && dining_type_two.value == false) {
      dining_type_tmp = "1";
    } else if (dining_type_one.value == false &&
        dining_type_two.value == true) {
      dining_type_tmp = "2";
    } else if (dining_type_one.value == true && dining_type_two.value == true) {
      dining_type_tmp = "3";
    } else {
      dining_type_one.value = true;
      dining_type_tmp = "1";
    }
    var systemSettingData = {
      "diningType": dining_type_tmp, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    dining_type.value = dining_type_tmp;
    update();
    if (machine_mode == "1") {
      Get.find<OrderHomeController>().getSystemSettingInfo();
    } else if (machine_mode == "2") {
      Get.find<CheckoutPageController>().getSystemSettingInfo();
    }
  }

  checkMenuDirection(checkedType) {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": checkedType, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    menu_direction.value = checkedType;
    update();
    Get.find<OrderHomeController>().getSystemSettingInfo();
  }

  checkPrintPaperTxtSize(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":checkedType,//1 58mm 2 80mm
      "printPaperTxtSize": checkedType, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    print_paper_txt_size.value = checkedType;
    update();
  }

  checkIsAllowReceipt(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": checkedType, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    is_allow_receipt.value = checkedType;
    update();
  }

  checkIsAllowReceiptMenu(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": checkedType, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    is_allow_receipt_menu.value = checkedType;
    update();
  }

  checkMachineMode(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": checkedType, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    machine_mode.value = checkedType;
    update();
  }

  checkIsReservation(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": checkedType, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    isReservation.value = checkedType;
    update();
  }

  checkIsAllowPos(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": checkedType, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    var posSettingData;
    if (checkedType == "1") {
      posSettingData = {
        "posIp": pos_ip.value, //ip
        "posPort": pos_port.value, //port
      };
    } else {
      posSettingData = {
        "posIp": "", //ip
        "posPort": "", //port
      };

      pos_port.value = "";
      pos_ip.value = "";
    }

    Storage.setString('smartwe_posSetting', json.encode(posSettingData));
    GetxStorage.setData('smartwe_posSetting', json.encode(posSettingData));

    is_allow_pos.value = checkedType;
    update();
  }

  UsbDeviceInfo? get curUsbPrinter {
    if (usbDevice.value.isEmpty) {
      return null;
    }

    // ignore: invalid_use_of_protected_member
    return UsbDeviceInfo.fromMap(Map<String, dynamic>.from(usbDevice.value));
  }

  setUsbPrinter({UsbDeviceInfo? usbPrinter}) async {
    if (usbPrinter == null) {
      return;
    }

    Map<String, dynamic> data = {
      'productName': usbPrinter.productName,
      'vId': usbPrinter.vId,
      'pId': usbPrinter.pId,
      'sId': usbPrinter.sId,
      'position': usbPrinter.position,
    };

    usbDevice.value = data;

    Storage.setString('smartwe_usbPrintSetting', json.encode(data));
    GetxStorage.setData('smartwe_usbPrintSetting', json.encode(data));

    update();
  }

  _checkType(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": checkedType, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));
  }

  checkIsAllowWlanPrint(checkedType) async {
    _checkType(checkedType);

    var wlanPrintSettingData;
    if (checkedType == "1") {
      wlanPrintSettingData = {
        "wlanPrintIp": wlan_print_ip.value, //ip
        "wlanPrintPort": wlan_print_port.value, //port
      };
    } else {
      wlanPrintSettingData = {
        "wlanPrintIp": "", //ip
        "wlanPrintPort": "", //port
      };

      wlan_print_ip.value = "";
      wlan_print_port.value = "";
    }

    Storage.setString(
        'smartwe_wlanPrintSetting', json.encode(wlanPrintSettingData));
    GetxStorage.setData(
        'smartwe_wlanPrintSetting', json.encode(wlanPrintSettingData));

    is_allow_wlanPrint.value = checkedType;

    update();
  }

  checkIsAllowWlanPrintTwo(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": checkedType, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    var wlanPrintSettingData;
    if (checkedType == "1") {
      wlanPrintSettingData = {
        "wlanPrintIp": wlan_print_ip_Two.value, //ip
        "wlanPrintPort": wlan_print_port_Two.value, //port
      };
    } else {
      wlanPrintSettingData = {
        "wlanPrintIp": "", //ip
        "wlanPrintPort": "", //port
      };

      wlan_print_ip_Two.value = "";
      wlan_print_port_Two.value = "";
    }
    Storage.setString(
        'smartwe_wlanPrintSettingTwo', json.encode(wlanPrintSettingData));
    GetxStorage.setData(
        'smartwe_wlanPrintSettingTwo', json.encode(wlanPrintSettingData));

    is_allow_wlanPrint_Two.value = checkedType;
    update();
  }

  //printType=0 receipt 1label
  printTest(type, printIp, printPort, {printType = 0}) async {

    // ignore: invalid_use_of_protected_member
    final printerInfo = type == SearchType.net ? PrinterInfo(ip: printIp):PrinterInfo(usbDevice: UsbDeviceInfo.fromMap(usbDevice.value as Map<String, dynamic>));

    if (printType == 0) {
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: testReceipt(printIp) as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: printerInfo,
        ),
      );
    } else {
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: testLabel(printIp) as ATempWidget,
          printTypeEnum: PrintTypeEnum.label,
          params: PrinterInfo(ip: printIp),
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
                      fontFamily: 'JetBrainsMonoRegular',
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
            Directionality(
                textDirection: TextDirection.rtl,
                child: Text("${printIp}",
                    softWrap: true,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'JetBrainsMonoRegular',
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
                      fontFamily: 'JetBrainsMonoRegular',
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
            Directionality(
                textDirection: TextDirection.rtl,
                child: Text("${printIp}",
                    softWrap: true,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'JetBrainsMonoRegular',
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
          ],
        )
      ],
    ));
  }

  checkIsAllowOneYen(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": checkedType, //0禁用1元 1不禁用
      "isAllowBackHome": is_allow_backhome.value, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    if (checkedType == "0") {
      var prohibitOneCashStatus = await Paycube.prohibitOneCash;
    } else {
      var allowOneCashStatus = await Paycube.allowOneCash;
    }

    is_allow_oneyen.value = checkedType;
    update();
  }

  checkIsAllowBackHome(checkedType) async {
    var systemSettingData = {
      "diningType": dining_type.value, //1堂食 2外带
      "menuDirection": menu_direction.value, //1顶部横向 2左侧竖
      //"printPaperSize":_print_paper_size,//1 58mm 2 80mm
      "printPaperTxtSize": print_paper_txt_size.value, //1 普通　2大　3特大
      "isAllowReceipt": is_allow_receipt.value, //1必须打印小票 2不必须
      "isAllowReceiptMenu": is_allow_receipt_menu.value, //1必须 2 不要
      "machineMode": machine_mode.value, //1普通券卖机 2 精算机
      "isReservation": isReservation.value, //是否开启预约服务
      "isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
      "isAllowOneYen": is_allow_oneyen.value, //0禁用1元 1不禁用
      "isAllowBackHome": checkedType, //0返回home 1返回到菜单
      "isAllowPos": is_allow_pos.value, //0不开启 1开启
      "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
      "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
      "showPrintType": showPrintType.value.toString(), //0receipt 1label
      "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
      "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    };
    Storage.setString('smartwe_systemSetting', json.encode(systemSettingData));
    GetxStorage.setData(
        'smartwe_systemSetting', json.encode(systemSettingData));

    is_allow_backhome.value = checkedType;

    update();
  }

  //上传现金机log
  uploadErrorLog() async {
    _showEasyLoading();
    var logfile = "/mnt/sdcard/Android/data/comlib/log/COMLibLog.txt";

    FormData formData = FormData.fromMap({
      "machineCode": machineCode.value,
      "file": await MultipartFile.fromFile(logfile),
    });

    request('webBootLogUpload', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();
      if (response["code"] == 200) {
        showToast('上传成功~~');
      } else {
        showToast('上传失败!');
      }
    });
  }

  _showEasyLoading() {
    var _showTag;
    _showTag = Text("Uploading……",
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(
                  GImage.getImageString("imgpublic", "printticketloading"),
                  fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }
}
