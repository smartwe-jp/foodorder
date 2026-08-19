import 'package:foodorder/app/models/sse_subscription_setting.dart';
import 'package:foodorder/app/models/machine_capabilities.dart';
import 'package:foodorder/app/models/machine_activation.dart';
import 'package:foodorder/app/services/sse_subscription_manager.dart';
import 'package:foodorder/app/services/machine_runtime_service.dart';
import 'package:get/get.dart';

import '../services/CustomLogerHandler.dart';

enum MachineType { new_panel, new_panel_max, old_panel }

enum MachineMode { sell, takeout, checkout, scan, spicyHotPot }

class MachineInfoController extends GetxController {
  MachineType get machineType {
    return panelTypes[panelType] ?? MachineType.new_panel;
  }

  Map<String, MachineType> panelTypes = {
    'Mini': MachineType.new_panel,
    'Max': MachineType.new_panel_max
  };
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
  late List<MachineLanguage> languageOptions;
  List<String> get supportLanguages =>
      languageOptions.map((language) => language.code).toList(growable: false);
  //bool isReceiptPageShow = false;
  late String printLogoImageData;
  late String printLogoImageUrl;
  //String machineMode = '1'; //1 券卖机  2 精算机 3 自助收银
  late List printerList;
  Map usbDevice = {};
  List<SseSubscriptionSetting> get sseSettingList =>
      Get.find<SseSubscriptionManager>().settings;

  late bool isAllowReimburse;
  late bool taxSystem;
  late bool cashMachineEnabled;

  late Map machineModeInfo;
  late String isAllowRejishime;
  late bool actuarial;
  late bool showWithdraw;

  bool isShopSpicyHotPot = false;
  bool isSpicyHotPotEnabled = false;
  bool spicyHotPotTakeout = false;

  //settings
  double machinePrintWidth = 385.0;
  late int print_paper_txt_size;
  late String isReservation;
  late String panelType;
  bool isAllow10000 = true;
  bool isAllow5000 = true;
  bool isAllow10 = true;
  bool isAllow5 = true;
  String is_allow_oneyen = "0";
  bool showReceiptPage = false;
  bool printReceiptOptions = false;
  String settingPassword = '';

  //theme info
  int themeColor = 0xFF1B5E20;
  bool is_dark_theme = true;

  //payment info
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

  // late String wlan_print_ip_two;
  // late String wlan_print_port_two;

  // late String is_allow_wlanPrint_continuous;
  // late String is_allow_wlanPrint_continuous_two;

  late int showPrintType;

  String paymentMethod = '0';
  MachineMode currentMode = MachineMode.sell;

  late String pos_ip;
  late String pos_port;
  int get posPort => int.tryParse(pos_port) ?? 0;
  bool get allowPos => isAllowPos == '1';
  MachineRuntimeService get _runtime => Get.find<MachineRuntimeService>();
  String get machineModelCode => _runtime.machineModelCode;
  bool get supportsCashMachine => _runtime.capabilities.supportsCashMachine;
  bool get showCashPayment =>
      cashMachineEnabled && _runtime.capabilities.supportsCashMachine;
  CashMachineDriver get cashMachineDriver =>
      _runtime.capabilities.cashMachineDriver;
  bool get cashPaymentAvailable => _runtime.cashPaymentAvailable;
  bool get isChecking =>
      _runtime.cashMachineStatus == CashMachineRuntimeStatus.checking;
  Map<String, dynamic> get systemSettingInfo => _runtime.systemSettings;
  Map<String, dynamic> posSettingInfo = {};

  bool get isSellOn => machineModeInfo['sell'] ?? false;
  bool get isTakeoutOn => machineModeInfo['takeout'] ?? false;
  bool get isCheckOn => machineModeInfo['checkout'] ?? false;
  bool get isScanbuyOn => machineModeInfo['scanbuy'] ?? false;
  bool get isSpicyHotPotOn =>
      isShopSpicyHotPot && isSpicyHotPotEnabled;
  String get spicyHotPotOrderType => 'normal';
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
    return currentMode == MachineMode.takeout ||
        currentMode == MachineMode.scan ||
        (currentMode == MachineMode.spicyHotPot && spicyHotPotTakeout);
  }

  String get printType {
    String type = "";
    final labelPrinter = printerList.firstWhere(
        (printer) =>
            printer['type'] == 10 &&
            printer['receipt'] == 1 &&
            !printer['isOff'],
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

  @override
  void dispose() {
    logI('loadMachineSettingInfo dispose');
    super.dispose();
  }

  Future<void> updateMachineSettingInfo() async {
    try {
      await loadMachineSettingInfo();
    } catch (e) {
      logE('updateMachineSettingInfo error: $e');
    }
  }

  Future<void> loadMachineSettingInfo() async {
    logI('loadMachineSettingInfo');
    //mealType = false;

    final runtime = Get.find<MachineRuntimeService>();
    final systemSettingInfo = runtime.systemSettings;
    machineCode = runtime.machineCode;
    final activation = runtime.activation;
    final paymentChannels = activation?.paymentChannels;
    shopCode = activation?.shopCode ?? "";

    logI('loadMachineSettingInfo 0');

    isBackHome = systemSettingInfo['isBackHome'] ?? true;
    // diningType = systemSettingInfo['diningType'] ?? '1';
    // logI('loadMachineSettingInfo diningType : $diningType');
    // mealType = diningType == '2' ? true : false;
    isAllowPos = systemSettingInfo['isAllowPos'] ?? '0'; // 0 不开pos 1开pos
    isAllowReceipt = systemSettingInfo['isAllowReceipt'] ?? '1';
    isPrintReceipt = systemSettingInfo['isAllowReceiptMenu'] ?? '1';
    panelType = systemSettingInfo['panelType'] ?? 'Mini';
    //machineMode = systemSettingInfo["machineMode"] ?? '0';
    isAllowRejishime = systemSettingInfo['isAllowRejishime'] ?? '0';
    is_dark_theme = systemSettingInfo['isDarkTheme'] ?? true;
    themeColor = systemSettingInfo['themeColor'] ?? 0xFF1B5E20;

    final printPaperTxtSizeValue = systemSettingInfo['printPaperTxtSize'];
    if (printPaperTxtSizeValue is int) {
      print_paper_txt_size = printPaperTxtSizeValue;
    } else if (printPaperTxtSizeValue is String) {
      print_paper_txt_size = int.tryParse(printPaperTxtSizeValue) ?? 2;
    } else {
      print_paper_txt_size = 2; // default value
    }
    isReservation = systemSettingInfo['isReservation'] ?? '0';
    isAllow10000 = (systemSettingInfo['isAllow10000'] ?? '1') == '1';
    isAllow5000 = (systemSettingInfo['isAllow5000'] ?? '1') == '1';
    isAllow10 = systemSettingInfo['isAllow10'] ?? true;
    isAllow5 = systemSettingInfo['isAllow5'] ?? true;
    is_allow_oneyen = systemSettingInfo['isAllowOneYen'] ??
        systemSettingInfo['isAllowOneyen'] ??
        '0';
    printReceiptOptions = systemSettingInfo['printReceiptOptions'] ?? false;

    showReceiptPage = isAllowReceipt == "1" ? false : true;
    //isReceiptPageShow = isAllowReceipt == "1" ? false : true;

    menu_direction = systemSettingInfo['menuDirection'] ?? '1';

    showPrintType =
        int.parse(systemSettingInfo['showPrintType'] ?? '0'); // 0:普通 1:贴纸

    // is_allow_wlanPrint_continuous =
    //     systemSettingInfo['isAllowWlanPrintContinuous'] ?? '0';
    // is_allow_wlanPrint_continuous_two =
    //     systemSettingInfo['isAllowWlanPrintContinuousTwo'] ?? '0';

    settingPassword = runtime.settingPassword;

    homeList = activation?.homeImages ?? [];

    headImageList = activation?.headerImages ?? [];

    isAllowReimburse = activation?.canReimburse ?? false;

    final configuredLanguages = activation?.languageOptions ?? const [];
    languageOptions = configuredLanguages.isEmpty
        ? const [MachineLanguage.japanese]
        : configuredLanguages;

    printLogoImageData = runtime.printLogoImageData;

    printLogoImageUrl = activation?.logoImage ?? "";

    actuarial = activation?.actuarial ?? false;

    cashMachineEnabled = runtime.cashMachineEnabled;
    logI('loadMachineSettingInfo 1');
    taxSystem = activation?.taxSystem ?? false;

    showWechat = paymentChannels?.wechat ?? false;
    showAlipay = paymentChannels?.alipay ?? false;
    showPayPay = paymentChannels?.payPay ?? false;
    showCreditCard = paymentChannels?.creditCard ?? false;
    logI('loadMachineSettingInfo 2');
    showAuPay = paymentChannels?.auPay ?? false;
    showDPay = paymentChannels?.dPay ?? false;
    showRPay = paymentChannels?.rPay ?? false;
    showMPay = paymentChannels?.mPay ?? false;
    logI('loadMachineSettingInfo 3');
    showPosEdy = paymentChannels?.edy ?? false;
    showPosiD = paymentChannels?.iD ?? false;
    showPosIC = paymentChannels?.ic ?? false;
    showPosQUICPay = paymentChannels?.quicPay ?? false;
    showPosWAON = paymentChannels?.waon ?? false;
    showPosnanaco = paymentChannels?.nanaco ?? false;
    logI('loadMachineSettingInfo 4');
    showVisa = paymentChannels?.visa ?? false;
    showMaster = paymentChannels?.master ?? false;
    showJcb = paymentChannels?.jcb ?? false;
    showUnionPay = paymentChannels?.unionPay ?? false;
    showAmericanExpress = paymentChannels?.americanExpress ?? false;
    showDinersClub = paymentChannels?.dinersClub ?? false;
    showDiscover = paymentChannels?.discover ?? false;
    showWithdraw = activation?.cashMachineWithdraw ?? false;
    logI('loadMachineSettingInfo 5');

    printerList = runtime.printerList;
    await Get.find<SseSubscriptionManager>().initialize(machineCode);

    machineModeInfo = runtime.machineModeInfo;
    logI('machineModeInfo: $machineModeInfo');
    isShopSpicyHotPot = activation?.spicyHotPot ?? false;
    final spicyEnabledValue = systemSettingInfo['spicyHotPotEnabled'];
    final normalizedSpicyEnabled = spicyEnabledValue?.toString().toLowerCase();
    isSpicyHotPotEnabled = spicyEnabledValue == null ||
        spicyEnabledValue == true ||
        normalizedSpicyEnabled == '1' ||
        normalizedSpicyEnabled == 'true';
    logI(
        'isShopSpicyHotPot: $isShopSpicyHotPot, enabled: $isSpicyHotPotEnabled');
    posSettingInfo = runtime.posSettings;

    pos_ip = posSettingInfo['posIp'] ?? "";
    pos_port = posSettingInfo['posPort'] ?? "";

    screenCallSetting = runtime.screenCallSettings;
    wlan_panel_print_ip = screenCallSetting['wlanPrintIp'] ?? "";
    wlan_panel_print_port = screenCallSetting['wlanPrintPort'] ?? "";
    isAllowScreenCall = screenCallSetting['isAllowScreenCall'] ?? false;

    usbDevice = runtime.usbDevice;

    machinePrintWidth = runtime.machinePrintWidth;

    logI('loadMachineSettingInfo 6');
  }
}
