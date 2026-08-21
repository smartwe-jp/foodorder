import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/config/http_conf.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/printer_list_page.dart';
import 'package:foodorder/app/plugins/appset/lib/appset.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/models/sse_subscription_setting.dart';
import 'package:foodorder/app/modules/CheckoutPage/controllers/checkout_page_controller.dart';
import 'package:foodorder/app/services/sse_service.dart';
import 'package:foodorder/app/services/sse_subscription_manager.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:android_usb_printer/android_usb_printer.dart';
import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/printer_info.dart';
import '../../../controllers/app_config.dart';
import '../../../services/HomeServices.dart';
import '../../../services/machine_runtime_service.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/Storage.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../settlement/views/label_constrained_box.dart';
import '../../settlement/views/receipt_constrained_box.dart';
import '../views/SetPosIp.dart';
import '../views/set_subprinter.dart';
import '../views/showSpeed.dart';

class SystemSettingPageController extends GetxController with StateMixin {

  AppConfig appConfig = Get.find();
  PrintService printService = Get.find<PrintService>();
  SseService sseService = Get.find<SseService>();
  SseSubscriptionManager sseManager = Get.find<SseSubscriptionManager>();
  final machineInfo = Get.find<MachineInfoController>();
  get payCube => appConfig.payCube;

  RxString local_version = "".obs; //本appversion

  RxBool actuarial = false.obs; //是否开启精算
  RxBool lineup = false.obs; //是否开启排队

  RxDouble downloadProgress = 0.0.obs;

  List<String> panelTypes = ['Mini', 'Max'];
  //String panelType = "Mini";
  // bool isAllow10000 = true;
  // bool isAllow5000 = true;

  final baseUrl = "https://app.smartwe.co.jp/";

  String get installFileName {
    String androidName = appConfig.isAndroid11 ? "_android11.apk" : "_android7.apk";
    String extraName = Platform.isAndroid ? androidName : ".exe";
    String name = "smartwe_ticket_machine${extraName}";
    return name;
  }

  final Map subPrinterInfos = {
    '拡張プリンター(1)': 21,
    '拡張プリンター(2)': 22,
    '拡張プリンター(3)': 23,
    '拡張プリンター(4)': 24,
    '拡張プリンター(5)': 25,
  };

  //Map machineModeInfo = {};

  List subPrinterList = [];

  final Map defaultPrinterInfo = {
    'キッチン': 10,
    'センター': 11,
    'カウンター': 12,
  };

  Map get notSelectedPrinterMap {
    return subPrinterInfos.map((key, value) {
      // 检查 printerList 中是否包含该 type
      bool isSelected = machineInfo.printerList.any((item) => item['type'] == value);
      return MapEntry(key, isSelected ? null : value);
    })
      ..removeWhere((key, value) => value == null);
  }

  Map get usbDevice => machineInfo.usbDevice;

  @override
  void onInit() {
    _getPackageInfo();

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("---SettingController onReady---");
    ever(sseService.subscriptions, (value) {
      update();
    });
  }

  @override
  void onClose() {
    super.onClose();
    debugPrint("---SettingController onClose---");
  }

  //获取版本号
  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    local_version.value = packageInfo.version;//+"+"+packageInfo.buildNumber

    _getSystemSettingInfo();
  }

  //获取系统设置信息
  _getSystemSettingInfo() async {
    await _checkAndInitialPrinters();
    var smartweMachineSetting =
        await HomeServices.getSmartweMachineSettingData();
    if (smartweMachineSetting != null) {
      actuarial.value = smartweMachineSetting["machineActuarial"];
      lineup.value = smartweMachineSetting["machineLineup"];
    }

    // wlan_panel_print_ip = wlanPanelPrintSettingInfo['wlanPrintIp'] ?? "";
    // wlan_panel_print_port = wlanPanelPrintSettingInfo['wlanPrintPort'] ?? "";
    change(null, status: RxStatus.success());
    update();
  }

  late Map<String, dynamic> systemSettingData = {
    //"diningType": dining_type.value, //1堂食 2外带
    "menuDirection": machineInfo.menu_direction, //1顶部横向 2左侧竖
    //"printPaperSize": _print_paper_size, //1 58mm 2 80mm
    "printPaperTxtSize": machineInfo.print_paper_txt_size, //1 普通　2大　3特大
    "isAllowReceipt": machineInfo.isAllowReceipt, //1必须打印小票 2不必须
    "isAllowReceiptMenu": machineInfo.isPrintReceipt, //1必须 2 不要
    //"machineMode": machine_mode.value, //1普通券卖机 2 精算机
    "isReservation": machineInfo.isReservation, //是否开启预约服务
    //"isAllowAttendance": is_allow_attendance.value, //0不开启 1开启
    "isAllowOneYen": machineInfo.is_allow_oneyen, //0禁用1元 1不禁用
    "isAllow5000": machineInfo.isAllow5000 ? "1" : "0",
    "isAllow10000": machineInfo.isAllow10000 ? "1" : "0",
    "isAllow5": machineInfo.isAllow5,
    "isAllow10": machineInfo.isAllow10,
    "isAllowRejishime": machineInfo.isAllowRejishime, //0不开启 1开启
    "isBackHome": machineInfo.isBackHome, //0返回home 1返回到菜单
    "isAllowPos": machineInfo.isAllowPos, //0不开启 1开启
    // "isAllowWlanPrint": is_allow_wlanPrint.value, //0不开启 1开启
    // "isAllowWlanPrintContinuous": is_allow_wlanPrint_continuous.value,
    // "showPrintType": showPrintType.value.toString(), //0receipt 1label
    // "isAllowWlanPrintTwo": is_allow_wlanPrint_Two.value, //0不开启 1开启
    // "isAllowWlanPrintTwoContinuous": is_allow_wlanPrint_Two_continuous.value,
    "panelType": machineInfo.panelType,
    // "isAllowWlanPanelPrint": is_allow_wlanPanelPrint ?? "0",
  };

  _checkAndInitialPrinters() async {
    //printerList.value = await HomeServices.getPrinterListInfo();
    if (machineInfo.printerList.isEmpty) {
      //如果没有打印机信息，则添加默认打印机
      machineInfo.printerList.add({
        'name': 'キッチン',
        'type': 10,
        'receipt': 0,
        'labelWidth': 0,
        'continuous': 0,
        'isOff': true,
        'isDefault': true,
        'printIp': '',
        'printPort': '9100',
        'option': true,
        'direction': 0,
      });
      machineInfo.printerList.add({
        'name': 'キッチン (ラベル)',
        'type': 10,
        'receipt': 1,
        'labelWidth': 384,
        'continuous': 0,
        'isOff': true,
        'isDefault': true,
        'printIp': '',
        'printPort': '9100',
        'option': true,
        'direction': 0,
      });
      machineInfo.printerList.add({
        'name': 'センター',
        'type': 11,
        'receipt': 0,
        'labelWidth': 0,
        'continuous': 0,
        'isOff': true,
        'isDefault': true,
        'printIp': '',
        'printPort': '9100',
        'option': true,
        'direction': 0,
      });
      machineInfo.printerList.add({
        'name': 'カウンター',
        'type': 12,
        'receipt': 0,
        'labelWidth': 0,
        'continuous': 0,
        'isOff': true,
        'isDefault': true,
        'printIp': '',
        'printPort': '9100',
        'option': true,
        'direction': 0,
      });
    }
    //save
    await HomeServices.setPrinterListInfo(machineInfo.printerList);

    //machineModeInfo = await HomeServices.getMachineModeInfo();
    if (machineInfo.machineModeInfo.isEmpty) {
      final defaultModes = Map<String, dynamic>.from(
        MachineRuntimeService.defaultMachineModeInfo,
      );
      machineInfo.machineModeInfo = defaultModes;
      await HomeServices.setMachineModeInfo(defaultModes);
    }
  }

  void showAddSseSubscriptionDialog() {
    Get.dialog(
      SimpleDialog(
        title: const Text('SSEタイプを選択してください'),
        children: SseSubscriptionType.values.map((type) {
          return ListTile(
            title: Text(type.displayName),
            subtitle: Text(type == SseSubscriptionType.smartWe
                ? '現在の端末番号を使用します'
                : 'identifyの入力が必要です'),
            onTap: () {
              Get.back();
              if (type == SseSubscriptionType.smartWe) {
                addSSESubscription(type);
              } else {
                _showPandaIdentifyInput();
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _showPandaIdentifyInput() {
    Get.dialog(
      SimpleInputAlert(
        title: 'Panda SSEのIDを入力してください',
        onConfirmClick: (value) async {
          await addSSESubscription(
            SseSubscriptionType.panda,
            identify: value,
          );
        },
      ),
    );
  }


  Future<void> addSSESubscription(
    SseSubscriptionType type, {
    String identify = '',
  }) async {
    final added = await sseManager.add(type, identify: identify);
    if (!added) {
      showToast(identify.trim().isEmpty && type == SseSubscriptionType.panda
          ? 'IDを入力してください'
          : '同じSSE購読が既に登録されています');
    }
    update();
  }

  void editSSESetting(SseSubscriptionSetting setting) {
    Get.dialog(
      SimpleInputAlert(
        title: '${setting.name}のIDを入力してください',
        originValue: setting.identify,
        onConfirmClick: (value) async {
          final updated = await sseManager.update(setting.key, identify: value);
          if (!updated) showToast('IDが空か、既に登録されています');
          update();
        },
      ),
    );
  }

  Future<void> updateSSESetting(
    String key, {
    bool? isOn,
    bool? centerOn,
    bool? printOption,
    bool? printSeat,
  }) async {
    await sseManager.update(
      key,
      isEnabled: isOn,
      centerOn: centerOn,
      printOption: printOption,
      printSeat: printSeat,
    );
    update();
  }

  void removeSSESetting(String key) {
    SseSubscriptionSetting? setting;
    for (final item in sseManager.settings) {
      if (item.key == key) {
        setting = item;
        break;
      }
    }
    if (setting == null) return;

    Get.dialog(
      DialogUtils.alert(
        'このSSE購読設定を削除しますか？\n${setting.name}  ID：${setting.identify}',
        title: '削除確認',
        canceltitle: 'キャンセル',
        confirmtitle: '削除',
        cancle: () => Get.back(),
        confirm: () async {
          Get.back();
          await sseManager.remove(key);
          update();
        },
      ),
    );
  }

  addCustomPrinter() async {
    if (machineInfo.printerList.length >= 9 ||
        notSelectedPrinterMap.isEmpty) {
      return;
    }
    Get.dialog(SetPrinterView(
        isAdd: true, notSelectedPrinterMap: notSelectedPrinterMap));
  }

  addSubPrinter(int printerType, String name) {
    if (!subPrinterList.contains(printerType)) {
      subPrinterList.add(printerType);
    }
    machineInfo.printerList.add({
      'name': name, //打印机名称
      'type': printerType,
      'receipt': 0, //0 小票 1 标签
      'labelWidth': 0, //标签宽度
      'continuous': 0, //0 单票 1 连票
      'isOff': true, //是否开启
      'isDefault': false, //是否默认打印机
      'printIp': '',
      'printPort': '9100',
      'direction': 0,
    });
    //存打印机列表
    HomeServices.setPrinterListInfo(machineInfo.printerList);
    //machineInfo.printerList = machineInfo.printerList;
    update();
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   _scrollToBottom();
    // });
  }

  removePrinter(Map printer) {
    if (machineInfo.printerList.isNotEmpty) {
      machineInfo.printerList.removeWhere((item) => item['type'] == printer['type']);
      HomeServices.setPrinterListInfo(machineInfo.printerList);
      machineInfo.updateMachineSettingInfo();
      update();
    }
  }

  editPrinterInfo(int printerType, int continuousType, bool isOff,
      {String name = "", String printIp = ""}) {
    if (machineInfo.printerList.isNotEmpty) {
      for (var i = 0; i < machineInfo.printerList.length; i++) {
        if (machineInfo.printerList[i]['type'] == printerType) {
          machineInfo.printerList[i]['isOff'] = isOff;
          machineInfo.printerList[i]['continuous'] = continuousType;
          machineInfo.printerList[i]['printIp'] = printIp;
        }
      }
      HomeServices.setPrinterListInfo(machineInfo.printerList);
    }
    update();
  }

  showDownloadingAlert() {
    //支付状态

    Get.dialog(Container(
      //width: ScreenAdapter.width(950),
      child: SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Align(
              alignment: Alignment.center,
              child: Text("アップデートのお知らせ",
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(28),
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w600))),
          children: <Widget>[
            Container(
              width: ScreenAdapter.width(500),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 1.0,
                    color: Colors.black12,
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
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
                        ),
                        //垂直分割线

                        VerticalDivider(
                          thickness: 1.0,
                          color: Colors.black12,
                        ),

                        Expanded(
                          child: Container(
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
                                Get.dialog(showSpeedView());
                                //https://app.gutingjun.com/kanran-release.apk

                                downloadAndroid(baseUrl + installFileName);
                                //testReadAndInstall();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
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
    /// 创建存储文件
    //print(url);
    Directory storageDir = await getTemporaryDirectory();
    String storagePath = storageDir.path;
    final path = storagePath + '/' +installFileName;
    try {
      var dio = Dio();
      final Response response = await dio.download(url, path,
          onReceiveProgress: (received, total) async {
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
          if (Platform.isAndroid) {
            await openApk(path);
          } else {
            await installExe(path);
          }
        }
      });
      //print(response.data);
    } catch (e) {
      print('$e');
      //progressValue = 0;
    }
  }

  Future<Uint8List> loadAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<File> writeAssetToFile(Uint8List data, String filename) async {
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/$filename');
    return file.writeAsBytes(data, flush: true);
  }

  Future<void> testReadAndInstall() async {
    final Uint8List assetData = await loadAsset('assets/smartwe.exe');
    final File file = await writeAssetToFile(assetData, 'smartwe.exe');
    print('File written to ${file.path}');

    Get.back();
    // 执行安装
    if (Platform.isAndroid) {
      await openApk(file.path);
    } else {
      await installExe(file.path);
    }
  }

  /// 安装 EXE 文件
  installExe(String path) async {
    try {
      ProcessResult result = await Process.run(path, []);

      if (result.exitCode == 0) {
        //print('Installation completed successfully.');
        showUpgradeResult('インストールが完了しました、券売君アプリを再起動する必要があります。');
      } else {
        //print('インストールエラー: ${result.exitCode}');
        showUpgradeResult('インストールエラー: ${result.exitCode}', success: false);
      }
    } catch (e) {
      //print('インストール中にエラーが発生しました: $e');
      showUpgradeResult('インストール中にエラーが発生しました: $e', success: false);
    }
  }

  showUpgradeResult(msg, {success = true}) {
    Get.dialog(
        DialogUtils.alertOneButton(msg, confirm: () {
          if (success) {
            //restart
            Appset.restartApp;
          } else {
            Get.back();
          }
        }),
        barrierDismissible: false);
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

  updateMachineMode(
      {bool? sell, bool? takeout, bool? checkout, bool? scanbuy}) {
      if (sell != null) {
        machineInfo.machineModeInfo['sell'] = sell;
        if (sell) machineInfo.machineModeInfo['scanbuy'] = false;
      }

      if (takeout != null) machineInfo.machineModeInfo['takeout'] = takeout;

      if (checkout != null) {
        machineInfo.machineModeInfo['checkout'] = checkout;
        //if (checkout) machineModeInfo['scanbuy'] = false;
      }

      if (scanbuy != null) {
        machineInfo.machineModeInfo['scanbuy'] = scanbuy;
        if (scanbuy) machineInfo.machineModeInfo['sell'] = false;
      }

      HomeServices.setMachineModeInfo(machineInfo.machineModeInfo);
      final mainController = Get.find<CheckoutPageController>();
      mainController.update();
      update();
  }

  checkMenuDirection(checkedType) {
    machineInfo.menu_direction = checkedType;
    _updateSystemSetting("menuDirection", checkedType);
    //if(Get.isRegistered<OrderHomeController>())
    //Get.find<OrderHomeController>().getSystemSettingInfo();
  }

  checkPanelType(String type) {
    machineInfo.panelType = type;
    _updateSystemSetting("panelType", type);
  }

  checkPrintPaperTxtSize(checkedType) async {
    machineInfo.print_paper_txt_size = checkedType;
    _updateSystemSetting("printPaperTxtSize", checkedType);
  }

  checkIsAllowReceipt(checkedType) async {
    machineInfo.isAllowReceipt = checkedType;
    _updateSystemSetting("isAllowReceipt", checkedType);
  }

  Future<void> checkCashMachineEnabled(bool enabled) async {
    machineInfo.cashMachineEnabled = enabled;
    await Get.find<MachineRuntimeService>()
        .updateCashMachineEnabled(enabled);
    update();
  }

  checkIsAllowPrintReceiptOptions(checkedType) async {
    machineInfo.printReceiptOptions = checkedType;
    _updateSystemSetting("printReceiptOptions", checkedType);
  }

  checkIsAllowReceiptMenu(checkedType) async {
    machineInfo.isPrintReceipt = checkedType;
    _updateSystemSetting("isAllowReceiptMenu", checkedType);
  }

  // checkMachineMode(checkedType) async {
  //   machine_mode.value = checkedType;
  //   _updateSystemSetting("machineMode", checkedType);
  // }

  checkIsReservation(checkedType) async {
    machineInfo.isReservation = checkedType;
    _updateSystemSetting("isReservation", checkedType);
  }

  checkIsAllowPos(checkedType) async {
    var posSettingData;
    if (checkedType == "1") {
      posSettingData = {
        "posIp": machineInfo.pos_ip, //ip
        "posPort": machineInfo.pos_port, //port
      };
    } else {
      posSettingData = {
        "posIp": "", //ip
        "posPort": "", //port
      };

      machineInfo.pos_port = "";
      machineInfo.pos_ip = "";
    }

    Storage.setString('smartwe_posSetting', json.encode(posSettingData));
    GetxStorage.setData('smartwe_posSetting', json.encode(posSettingData));

    machineInfo.isAllowPos = checkedType;
    _updateSystemSetting("isAllowPos", checkedType);
  }

  UsbDeviceInfo? get curUsbPrinter {
    if (usbDevice.isEmpty) {
      debugPrint('usbDevice is empty');
      return null;
    }

    // ignore: invalid_use_of_protected_member
    return UsbDeviceInfo.fromMap(Map<String, dynamic>.from(usbDevice));
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

    machineInfo.usbDevice = data;

    await HomeServices.updateUsbPrintSettingInfo(data);

    update();
  }

  showPrintSettingDialog(int type, int receipt, int continueType,
      {String printerIp = '', String port = ''}) async {
    Get.dialog(SetPosIpPage(
      posIp: printerIp,
      posPort: port,
      onConfrimClick: (String printIp, String printPort) {
        if (printIp != "") {
          updatePrinterInfo(type, receipt,
              isOff: false,
              continuous: continueType,
              printerIp: printIp,
              port: printPort);
        }
      },
    ));
  }

  updatePrinterState(int type, int receipt, bool isOff) async {
    if (machineInfo.printerList.isNotEmpty) {
      for (var i = 0; i < machineInfo.printerList.length; i++) {
        if (machineInfo.printerList[i]['type'] == type &&
            machineInfo.printerList[i]['receipt'] == receipt) {
          machineInfo.printerList[i]['isOff'] = isOff;
          if (!isOff && type == 10) {
            //find the first printer of type 10 and receipt != receipt, set isOff = true
            for (var j = 0; j < machineInfo.printerList.length; j++) {
              if (machineInfo.printerList[j]['type'] == 10 &&
                  machineInfo.printerList[j]['receipt'] != receipt) {
                machineInfo.printerList[j]['isOff'] = true;
              }
            }
          }
        }
      }
      HomeServices.setPrinterListInfo(machineInfo.printerList);
      //machineInfo.printerList = printerList;
    }
    //machineInfo.updateMachineSettingInfo();
    update();
  }

  updatePrinterInfo(int type, int receipt,
      {bool? isOff, int? continuous, String? printerIp, String? port, String? printSize, int? direction, bool? option,
        bool? printCategory, bool? printHead, bool? printOptionCode}) async {

    if (machineInfo.printerList.isNotEmpty) {
      for (var i = 0; i < machineInfo.printerList.length; i++) {
        if (machineInfo.printerList[i]['type'] == type && machineInfo.printerList[i]['receipt'] == receipt) {
          if(isOff != null) machineInfo.printerList[i]['isOff'] = isOff;
          if(continuous != null) machineInfo.printerList[i]['continuous'] = continuous;
          if(printerIp != null) machineInfo.printerList[i]['printIp'] = printerIp;
          if(port != null) machineInfo.printerList[i]['printPort'] = port;
          if(printSize != null) machineInfo.printerList[i]['labelSize'] = printSize;
          if(direction != null) machineInfo.printerList[i]['direction'] = direction;
          if(option != null) machineInfo.printerList[i]['option'] = option;
          if(printCategory != null) machineInfo.printerList[i]['printCategory'] = printCategory;
          if(printHead != null) machineInfo.printerList[i]['printHead'] = printHead;
          if(printOptionCode != null) machineInfo.printerList[i]['printOptionCode'] = printOptionCode;
          if (type == 10 && !(isOff ?? true)) {
            //find the first printer of type 10 and receipt != receipt, set isOff = true
            for (var j = 0; j < machineInfo.printerList.length; j++) {
              if (machineInfo.printerList[j]['type'] == 10 &&
                  machineInfo.printerList[j]['receipt'] != receipt) {
                machineInfo.printerList[j]['isOff'] = true;
              }
            }
          }
        }
      }
      HomeServices.setPrinterListInfo(machineInfo.printerList);
      //machineInfo.updateMachineSettingInfo();
      //machineInfo.printerList = machineInfo.printerList;
    }
    update();
  }

  updateMachinePrintWidth(double width) async {
    machineInfo.machinePrintWidth = width;
    await HomeServices.setMachinePrintWidth(width);
    update();
  }


  posTest(posIp, posPort) async {
    _showEasyLoading(text: "POS Test Start");
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
      showTestResultDialog("POS Test Connected");

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
    //只有是当前View才显示对话框
    if(!Get.isRegistered<SystemSettingPageController>()) {
      return;
    }
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

  checkIsAllowWlanPanelPrint(checkedType) async {

    if (checkedType == "0") {
      machineInfo.wlan_panel_print_ip = "";
      machineInfo.wlan_panel_print_port = "";
      machineInfo.isAllowScreenCall = false;
    } else {
      machineInfo.isAllowScreenCall = true;
    }

    
    Map wlanPrintSettingData =  {
      "wlanPrintIp": machineInfo.wlan_panel_print_ip,
      "wlanPrintPort": machineInfo.wlan_panel_print_port,
      "isAllowScreenCall": machineInfo.isAllowScreenCall,
    };

    HomeServices.updateWlanPanelPrintSettingInfo(wlanPrintSettingData);
    update();

  }

  //printType=0 receipt 1label
  printTest(type, printIp, printPort, {printType = 0, double labelWidth = 384}) async {
    // ignore: invalid_use_of_protected_member
    print("type:$type");
    final printerInfo = type == SearchType.net
        ? PrinterInfo(ip: printIp)
        : PrinterInfo(
            usbDevice:
                UsbDeviceInfo.fromMap(usbDevice as Map<String, dynamic>));

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
          tempWidget: testLabel(printIp, labelWidth) as ATempWidget,
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
                      fontFamily: 'NotoSansJP',
                      color: ColorsUtil.hexToColor("#000000"),
                    ))),
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


  testLabel(printIp, double labelWidth) {
    return LabelConstrainedBox(
      pagerWidth: labelWidth,
        Column(
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
                    ))),
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
    if (checkedType == "0") {
      await payCube.prohibitOneCash;
    } else {
      await payCube.allowOneCash;
    }
    machineInfo.is_allow_oneyen = checkedType;

    _updateSystemSetting("isAllowOneYen", checkedType);
  }

  settingAllowCash(checkedType, keyString, cashValue) async {
    _showEasyLoading();
    try {
      await payCube.setAcceptCash(checkedType, cashValue, onSuccess: (){
        switch (cashValue) {
          case 5:
            machineInfo.isAllow5 = checkedType;
            break;
          case 10:
            machineInfo.isAllow10 = checkedType;
            break;
          case 5000:
            machineInfo.isAllow5000 = checkedType;
            break;
          case 10000:
            machineInfo.isAllow10000 = checkedType;
            break;
        }
        _updateSystemSetting(keyString, checkedType);
        EasyLoading.dismiss();
      }, catchError: (error){
        EasyLoading.dismiss();
        handleMassageAlert('設定が失敗した場合に再試行するかどうか。', confirm: (){
          Get.back();
          settingAllowCash(checkedType, keyString, cashValue);
        });
      });
    } catch (e) {
      EasyLoading.dismiss();
      handleMassageAlert('設定が失敗した場合に再試行するかどうか。', confirm: (){
        Get.back();
        settingAllowCash(checkedType, keyString, cashValue);
      });
    } 
    
  }


  checkIsAllow5Yen(checkedType) async {
    _showEasyLoading();
    await payCube.setAcceptCash(checkedType, 5, onSuccess: (){
      machineInfo.isAllow5 = checkedType;
      _updateSystemSetting("isAllow5", checkedType);
    }, catchError: (error){
      handleMassageAlert('設定が失敗した場合に再試行するかどうか。', confirm: (){
        Get.back();
        checkIsAllow5Yen(checkedType);
      });
    });
    EasyLoading.dismiss();
  }

  checkIsAllow10Yen(checkedType) async {
    _showEasyLoading();
    await payCube.setAcceptCash(checkedType, 10, onSuccess: (){
      machineInfo.isAllow10 = checkedType;
      _updateSystemSetting("isAllow10", checkedType);
    }, catchError: (error){
      handleMassageAlert('設定が失敗した場合に再試行するかどうか。', confirm: (){
        Get.back();
        checkIsAllow10Yen(checkedType);
      });
    });
    EasyLoading.dismiss();
  }

  checkIsAllow5000Yen(checkedType) async {
    _showEasyLoading();
    await payCube.setAcceptCash(checkedType, 5000, onSuccess: () {
      machineInfo.isAllow5000 = checkedType;
      _updateSystemSetting("isAllow5000", checkedType ? "1" : "0");
    }, catchError: (error) {
      handleMassageAlert('設定が失敗した場合に再試行するかどうか。', confirm: () {
        Get.back();
        checkIsAllow5000Yen(checkedType);
      });
    });
    EasyLoading.dismiss();
  }

  checkIsAllow10000Yen(checkedType) async {
    _showEasyLoading();
    await payCube.setAcceptCash(checkedType, 10000, onSuccess: () {
      machineInfo.isAllow10000 = checkedType;
      _updateSystemSetting("isAllow10000", checkedType ? "1" : "0");
    }, catchError: (error) {
      handleMassageAlert('設定が失敗した場合に再試行するかどうか。', confirm: () {
        Get.back();
        checkIsAllow10000Yen(checkedType);
      });
    });
    EasyLoading.dismiss();
  }

  handleMassageAlert(String message, {GestureTapCallback? confirm}) {
    Get.dialog(
      DialogUtils.alert(message,
          confirm: confirm ??
              () {
                Get.back();
              }, cancle: () {
        Get.back();
      }),
      barrierDismissible: false,
    );
  }

  checkIsAllowRejishime(checkedType) async {
    machineInfo.isAllowRejishime = checkedType;
    _updateSystemSetting("isAllowRejishime", checkedType);
  }

  // setPrintDirection(direction, index) async {
  //   if (index == 1) {
  //     await HomeServices.setPrintDirection(direction);
  //     printDirection.value = direction == "1" ? true : false;
  //   } else if (index == 2) {
  //     await HomeServices.setPrintTwoDirection(direction);
  //     printTwoDirection.value = direction == "1" ? true : false;
  //   } else if (index == 3) {
  //     await HomeServices.setPrintThreeDirection(direction);
  //     printThreeDirection.value = direction == "1" ? true : false;
  //   }
  //   update();
  // }

  // setLabelPrintSize(width) async {
  //   printLabelWidth.value = width;
  //   await HomeServices.setLabelPrintWidth(width);
  //   update();
  // }

  void _updateSystemSetting(String key, dynamic value) async {
    final systemSettingData = await HomeServices.getSystemSettingInfo();
    debugPrint(
        "_updateSystemSetting: key=$key, value=$value, currentData=$systemSettingData");
    //if (systemSettingData.containsKey(key)) {
      systemSettingData[key] = value;
      await HomeServices.updateSystemSettingInfo(systemSettingData);
    // } else {
    //   print('Key $key does not exist in systemSettingData.');
    // }
    //machineInfo.updateMachineSettingInfo(settingInfo: systemSettingData);
    update();
  }

  checkIsAllowBackHome(bool checkedType) async {
    machineInfo.isBackHome = checkedType;
    _updateSystemSetting("isBackHome", checkedType);
  }

  // checkIsEditMode(mode) async {
  //   is_edit_mode.value = mode;
  //   await HomeServices.setEditMode(mode);
  //   update();
  // }

  //上传现金机log
  uploadErrorLog() async {
    _showEasyLoading(text: "Uploading...");
    var logfile = "/mnt/sdcard/Android/data/comlib/log/COMLibLog.txt";

    FormData formData = FormData.fromMap({
      "machineCode": machineInfo.machineCode,
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

  _showEasyLoading({String text = ""}) {
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
        child: InkWell(
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
                  child: Image.asset(
                      GImage.getImageString("imgpublic", "printticketloading"),
                      fit: BoxFit.fitHeight),
                ),
              ],
            )),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  showRestartDialog(Function saveAction) => Get.dialog(DialogUtils.alert(
      'この設定を変更すると、アプリケーションを再起動する必要があります。今すぐ再起動しますか？',

      title: "tag_title".tr,
      confirmtitle: "reboot_app".tr,
      cancle: () {
        Get.back();
      },
      confirm: () {
        saveAction();
        Get.back();
        Future.delayed(Duration(milliseconds: 500), () async {
          Appset.restartApp;
        });
      })
  );
}
