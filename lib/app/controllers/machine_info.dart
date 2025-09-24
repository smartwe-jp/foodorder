import 'package:foodorder/app/services/HomeServices.dart';
import 'package:get/get.dart';

import '../services/CustomLogerHandler.dart';

enum MachineType { new_panel, new_panel_max, old_panel }

enum MachineMode { sell, takeout, checkout, scan }

class MachineInfoController extends GetxController {
  Map systemSettingInfo;
  MachineInfoController(this.systemSettingInfo);

  late MachineType machineType;
  Map<String, MachineType> panelTypes = {
    'Mini': MachineType.new_panel,
    'Max': MachineType.new_panel_max
  };
  bool isChecking = false;
  //base info
  late bool isBackHome;
  late String machineCode;
  late String shopCode;
  late bool mealType;
  late String diningType;
  late String isAllowPos;
  late String isAllowReceipt;
  late String receiptPrintType;
  late bool showReceiptPage;
  late List homeList;
  late List headImageList;
  late String menu_direction;
  late List supportLanguages;
  bool isReceiptPageShow = false;
  late String printLogoImageData;
  late String printLogoImageUrl;
  late String machineMode;
  late List printerList;
  late List sseSettingList;

  late bool isAllowCash;
  late bool cashOn;
  late bool taxSystem;

  late Map machineModeInfo;
  late String isAllowRejishime;

  //payment info
  late bool showCash;
  late bool showAlipay;
  late bool showWechat;
  late bool showPayPay;
  late bool showAuPay;
  late bool showDPay;
  late bool showRPay;
  late bool showMPay;
  late bool showCreditCard;
  late bool showPosEdy;
  late bool showPosiD;
  late bool showPosIC;
  late bool showPosID;
  late bool showPosQUICPay;
  late bool showPosWAON;
  late bool showPosnanaco;
  late bool showVisa;
  late bool showMaster;
  late bool showJcb;
  late bool showUnionPay;
  late bool showAmericanExpress;
  late bool showDinersClub;
  late bool showDiscover;

  late String wlan_panel_print_ip;
  late String wlan_panel_print_port;
  late bool isAllowScreenCall;
  late Map screenCallSetting;

  late String wlan_print_ip;
  late String wlan_print_port;

  late String wlan_print_ip_two;
  late String wlan_print_port_two;

  late String is_allow_wlanPrint_continuous;
  late String is_allow_wlanPrint_continuous_two;

  late int showPrintType;

  String paymentMethod = '0';
  MachineMode currentMode = MachineMode.sell;

  late String pos_ip;
  late String pos_port;
  int get posPort => int.tryParse(pos_port) ?? 0;
  bool get allowPos => isAllowPos == '1';
  late Map posSettingInfo;

  bool get isSellOn => machineModeInfo['sell'] ?? false;
  bool get isTakeoutOn => machineModeInfo['takeout'] ?? false;
  bool get isCheckOn => machineModeInfo['checkout'] ?? false;
  bool get isScanbuyOn => machineModeInfo['scanbuy'] ?? false;

  @override
  Future<void> onInit() async {
    logI('loadMachineSettingInfo onInit');
    await loadMachineSettingInfo();
    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    logI('loadMachineSettingInfo dispose');
    super.dispose();
  }

  Future updateMachineSettingInfo({Map settingInfo = const {}}) async {
    if (settingInfo.isEmpty) {
      systemSettingInfo = systemSettingInfo;
    } else {
      systemSettingInfo = settingInfo;
    }
    try {
      await loadMachineSettingInfo();
    } catch (e) {
      logE('updateMachineSettingInfo error: $e');
    }
  }

  Future loadMachineSettingInfo() async {
    logI('loadMachineSettingInfo');
    receiptPrintType = '1';
    mealType = false;
    var machineCodeString = await HomeServices.getMachineInfo();
    if (machineCodeString != "") {
      machineCode = machineCodeString;
      shopCode = await HomeServices.getShopCode();
    }
    logI('loadMachineSettingInfo 0');

    isBackHome = (systemSettingInfo['isAllowBackHome'] ?? '0') == '1' ? true : false;
    diningType = systemSettingInfo['diningType'] ?? '1';
    logI('loadMachineSettingInfo diningType : $diningType');
    mealType = diningType == '2' ? true : false;
    isAllowPos = systemSettingInfo['isAllowPos'] ?? '0'; // 0 不开pos 1开pos
    isAllowReceipt = systemSettingInfo['isAllowReceipt'] ?? '0';
    String panelType = systemSettingInfo['panelType'] ?? 'Mini';
    machineMode = systemSettingInfo["machineMode"] ?? '0';
    isAllowRejishime = systemSettingInfo['isAllowRejishime'] ?? '0';

    showReceiptPage = isAllowReceipt == "1" ? false : true;
    isReceiptPageShow = isAllowReceipt == "1" ? false : true;

    menu_direction = systemSettingInfo['menuDirection'] ?? '1';
    machineType = panelTypes[panelType] ?? MachineType.new_panel;

    showPrintType = int.parse(systemSettingInfo['showPrintType'] ?? '0'); // 0:普通 1:贴纸

    is_allow_wlanPrint_continuous =
        systemSettingInfo['isAllowWlanPrintContinuous'] ?? '0';
    is_allow_wlanPrint_continuous_two =
        systemSettingInfo['isAllowWlanPrintContinuousTwo'] ?? '0';

    final homeImageList = await HomeServices.getSmartweHomeImagesData();

    homeList = homeImageList ?? [];

    headImageList = await HomeServices.getSmartweHeaderImagesData() ?? [];

    supportLanguages = await HomeServices.getMachineLanguages();

    printLogoImageData = await HomeServices.getSmartweLogoImage() ?? "";

    printLogoImageUrl = await HomeServices.getSmartweLogoImagesData() ?? "";

    Map cashInfo = await HomeServices.getIsShowCash();
    cashOn = cashInfo['isCash'] ?? false;
    logI('loadMachineSettingInfo 1');
    Map machineActivateData = await HomeServices.getMachineActivateData();
    taxSystem = machineActivateData['taxSystem'] ?? false;
    isAllowCash = machineActivateData['showCash'] ?? false;
    showCash = isAllowCash && cashOn;

    showWechat = machineActivateData['showWechat'] ?? false;
    showAlipay = machineActivateData['showAlipay'] ?? false;
    showPayPay = machineActivateData['showPayPay'] ?? false;
    showCreditCard = machineActivateData['showCreditCard'] ?? false;
    logI('loadMachineSettingInfo 2');
    showAuPay = machineActivateData['au_Pay'] ?? false;
    showDPay = machineActivateData['d_Pay'] ?? false;
    showRPay = machineActivateData['R_Pay'] ?? false;
    showMPay = machineActivateData['m_Pay'] ?? false;
    logI('loadMachineSettingInfo 3');
    showPosEdy = machineActivateData['pos_Edy'] ?? false;
    showPosiD = machineActivateData['pos_iD'] ?? false;
    showPosIC = machineActivateData['pos_IC'] ?? false;
    showPosQUICPay = machineActivateData['pos_QUICPay'] ?? false;
    showPosWAON = machineActivateData['pos_WAON'] ?? false;
    showPosnanaco = machineActivateData['pos_nanaco'] ?? false;
    logI('loadMachineSettingInfo 4');
    showVisa = machineActivateData['show_visa'] ?? false;
    showMaster = machineActivateData['show_master'] ?? false;
    showJcb = machineActivateData['show_jcb'] ?? false;
    showUnionPay = machineActivateData['show_unionPay'] ?? false;
    showAmericanExpress = machineActivateData['show_americanExpress'] ?? false;
    showDinersClub = machineActivateData['show_dinersClub'] ?? false;
    showDiscover = machineActivateData['show_discover'] ?? false;
    logI('loadMachineSettingInfo 5');

    printerList = await HomeServices.getPrinterListInfo();
    sseSettingList = await HomeServices.getSSESettingList();

    machineModeInfo = await HomeServices.getMachineModeInfo();
    logI('machineModeInfo: $machineModeInfo');
    Map posSettingInfo = await HomeServices.getPosSettingInfo();

    pos_ip = posSettingInfo['posIp'] ?? "";
    pos_port = posSettingInfo['posPort'] ?? "";

    screenCallSetting = await HomeServices.getWlanPanelPrintSettingInfo();
    wlan_panel_print_ip = screenCallSetting['wlanPrintIp'] ?? "";
    wlan_panel_print_port = screenCallSetting['wlanPrintPort'] ?? "";
    isAllowScreenCall = screenCallSetting['isAllowScreenCall'] ?? false;

    Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
    wlan_print_ip = wlanPrintSettingInfo['wlanPrintIp'] ?? '';
    wlan_print_port = wlanPrintSettingInfo['wlanPrintPort'] ?? '';

    Map wlanPrintSettingTwoInfo =
        await HomeServices.getWlanPrintSettingTwoInfo();
    wlan_print_ip_two = wlanPrintSettingTwoInfo['wlanPrintTwoIp'] ?? '';
    wlan_print_port_two = wlanPrintSettingTwoInfo['wlanPrintTwoPort'] ?? '';

    logI('loadMachineSettingInfo 6');
  }
}
