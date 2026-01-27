import 'package:foodorder/app/services/HomeServices.dart';
import 'package:get/get.dart';

import '../services/CustomLogerHandler.dart';

enum MachineType { new_panel, new_panel_max, old_panel }

enum MachineMode { sell, takeout, checkout, scan }

class MachineInfoController extends GetxController {
  Map systemSettingInfo;
  MachineInfoController(this.systemSettingInfo);

  MachineType get  machineType {
    return panelTypes[panelType] ?? MachineType.new_panel;
  }

  Map<String, MachineType> panelTypes = {
    'Mini': MachineType.new_panel,
    'Max': MachineType.new_panel_max
  };
  bool isChecking = false;
  //base info
  late bool isBackHome;
  late String machineCode;
  late String shopCode;
  //late bool mealType;
  //late String diningType;
  late String isAllowPos;
  late String isAllowReceipt;
  late String isPrintReceipt;
  String receiptPrintType = '1';

  late List homeList;
  late List headImageList;
  late String menu_direction;
  late List supportLanguages;
  //bool isReceiptPageShow = false;
  late String printLogoImageData;
  late String printLogoImageUrl;
  //String machineMode = '1'; //1 券卖机  2 精算机 3 自助收银
  late List printerList;
  late List sseSettingList;

  late bool isAllowCash;
  late bool isAllowReimburse;
  late bool cashOn;
  late bool taxSystem;

  late Map machineModeInfo;
  late String isAllowRejishime;
  late bool actuarial;

  //settings
  double machinePrintWidth = 385.0;
  late String print_paper_txt_size;
  late String isReservation;
  late String panelType;
  bool isAllow10000 = true;
  bool isAllow5000 = true;
  bool isAllow10 = true;
  bool isAllow5 = true;
  String is_allow_oneyen = "0";
  bool showReceiptPage = false;
  bool printReceiptOptions = false;

  //theme info
  int themeColor = 0xFF1B5E20;
  bool is_dark_theme = true;

  //payment info
  //late bool showCash;
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

  // late String wlan_print_ip;
  // late String wlan_print_port;
  //
  // late String wlan_print_ip_two;
  // late String wlan_print_port_two;
  //
  // late String is_allow_wlanPrint_continuous;
  // late String is_allow_wlanPrint_continuous_two;

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
  //1 券卖机  2 精算机 3 自助收银
  String get machineMode {
    if (currentMode == MachineMode.checkout) {
      return '2';
    } else if (currentMode == MachineMode.scan) {
      return '3';
    }
    return '1';
  }

  bool get isTakeoutMode {
    return currentMode == MachineMode.takeout || currentMode == MachineMode.scan;
  }

  String get printType {
    String type = "";
    final labelPrinter = printerList.firstWhere(
        (printer) => printer['type'] == 10 && printer['receipt'] == 1 && !printer['isOff'],
        orElse: () => null);

    if (labelPrinter != null) {
      type = 'Label';
    }

    return type;
  }

  // bool get showReceiptPage {
  //   return isAllowReceipt == "1" ? false : true;
  // }

  bool get isReceiptPageShow {
    return isAllowReceipt == "1" ? false : true;
  }

  // bool get mealType {
  //   return diningType == '2' ? true : false;
  // }

  bool get showCash {
    return isAllowCash && cashOn;
  }

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
    //mealType = false;
    var machineCodeString = await HomeServices.getMachineInfo();
    if (machineCodeString != "") {
      machineCode = machineCodeString;
      shopCode = await HomeServices.getShopCode();
    }
    logI('loadMachineSettingInfo 0');

    isBackHome = systemSettingInfo['isBackHome'] ?? true;
    logI('--isBackHome: $isBackHome');
    //diningType = systemSettingInfo['diningType'] ?? '1';
    //logI('loadMachineSettingInfo diningType : $diningType');
    //mealType = diningType == '2' ? true : false;

    isAllowPos = systemSettingInfo['isAllowPos'] ?? '0'; // 0 不开pos 1开pos
    isAllowReceipt = systemSettingInfo['isAllowReceipt'] ?? '1';
    isPrintReceipt = systemSettingInfo['isAllowReceiptMenu'] ?? '1';
    panelType = systemSettingInfo['panelType'] ?? 'Mini';
    //machineMode = systemSettingInfo["machineMode"] ?? '0';
    isAllowRejishime = systemSettingInfo['isAllowRejishime'] ?? '0';
    is_dark_theme = systemSettingInfo['isDarkTheme'] ?? true;
    themeColor = systemSettingInfo['themeColor'] ?? 0xFF1B5E20;

    print_paper_txt_size = systemSettingInfo['printPaperTxtSize'] ?? '1';
    isReservation = systemSettingInfo['isReservation'] ?? '0';
    isAllow10000 = (systemSettingInfo['isAllow10000'] ?? '1') == '1';
    isAllow5000 = (systemSettingInfo['isAllow5000'] ?? '1') == '1';
    isAllow10 = systemSettingInfo['isAllow10'] ?? true;
    isAllow5 = systemSettingInfo['isAllow5'] ?? true;
    is_allow_oneyen = systemSettingInfo['isAllowOneyen'] ?? '0';
    printReceiptOptions = systemSettingInfo['printReceiptOptions'] ?? false;

    showReceiptPage = isAllowReceipt == "1" ? false : true;
    //isReceiptPageShow = isAllowReceipt == "1" ? false : true;

    menu_direction = systemSettingInfo['menuDirection'] ?? '1';

    showPrintType = int.parse(systemSettingInfo['showPrintType'] ?? '0'); // 0:普通 1:贴纸

    //await HomeServices.updateSystemSettingInfo(systemSettingInfo);

    // is_allow_wlanPrint_continuous =
    //     systemSettingInfo['isAllowWlanPrintContinuous'] ?? '0';
    // is_allow_wlanPrint_continuous_two =
    //     systemSettingInfo['isAllowWlanPrintContinuousTwo'] ?? '0';

    final homeImageList = await HomeServices.getSmartweHomeImagesData();

    homeList = homeImageList ?? [];

    headImageList = await HomeServices.getSmartweHeaderImagesData() ?? [];

    isAllowReimburse = await HomeServices.getSmartweReimburseData() == '1' ? true : false;
    logI('--isAllowReimburse: $isAllowReimburse');

    supportLanguages = await HomeServices.getMachineLanguages();

    printLogoImageData = await HomeServices.getSmartweLogoImage() ?? "";

    printLogoImageUrl = await HomeServices.getSmartweLogoImagesData() ?? "";

    Map smartweMachineSetting =
        await HomeServices.getSmartweMachineSettingData() ?? {};
    actuarial = smartweMachineSetting['actuarial'] ?? false;

    Map cashInfo = await HomeServices.getIsShowCash();
    cashOn = cashInfo['isCash'] ?? false;
    logI('loadMachineSettingInfo 1');
    Map machineActivateData = await HomeServices.getMachineActivateData();
    taxSystem = machineActivateData['taxSystem'] ?? false;
    isAllowCash = machineActivateData['showCash'] ?? false;
    //showCash = isAllowCash && cashOn;

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
    //allowPos = posSettingInfo['allowPos'] ?? false;
    //isAllowPos = allowPos ? '1' : '0';
    screenCallSetting = await HomeServices.getWlanPanelPrintSettingInfo();
    wlan_panel_print_ip = screenCallSetting['wlanPrintIp'] ?? "";
    wlan_panel_print_port = screenCallSetting['wlanPrintPort'] ?? "";
    isAllowScreenCall = screenCallSetting['isAllowScreenCall'] ?? false;

    machinePrintWidth = await HomeServices.getMachinePrintWidth();

    // Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
    // wlan_print_ip = wlanPrintSettingInfo['wlanPrintIp'] ?? '';
    // wlan_print_port = wlanPrintSettingInfo['wlanPrintPort'] ?? '';
    //
    // Map wlanPrintSettingTwoInfo =
    //     await HomeServices.getWlanPrintSettingTwoInfo();
    // wlan_print_ip_two = wlanPrintSettingTwoInfo['wlanPrintTwoIp'] ?? '';
    // wlan_print_port_two = wlanPrintSettingTwoInfo['wlanPrintTwoPort'] ?? '';

    print('loadMachineSettingInfo 6');
  }
}
