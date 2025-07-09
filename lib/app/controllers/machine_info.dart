import 'package:foodorder/app/services/HomeServices.dart';
import 'package:get/get.dart';

enum MachineType { new_panel, new_panel_max, old_panel }

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

  late String wlan_print_ip;
  late String wlan_print_port;

  late String wlan_print_ip_two;
  late String wlan_print_port_two;

  late String is_allow_wlanPrint_continuous;
  late String is_allow_wlanPrint_continuous_two;

  late int showPrintType;

  String paymentMethod = '0';

  late String pos_ip;
  late String pos_port;

  @override
  Future<void> onInit() async {
    print('loadMachineSettingInfo onInit');
    //await loadMachineSettingInfo();
    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('loadMachineSettingInfo dispose');
    super.dispose();
  }

  Future updateMachineSettingInfo(Map settingInfo) async {
    systemSettingInfo = settingInfo;
    await loadMachineSettingInfo();
  }

  Future loadMachineSettingInfo() async {
    print('loadMachineSettingInfo');
    receiptPrintType = '1';
    mealType = false;
    var machineCodeString = await HomeServices.getMachineInfo();
    if (machineCodeString != "") {
      machineCode = machineCodeString;
      shopCode = await HomeServices.getShopCode();
    }
    print('loadMachineSettingInfo 0');

    diningType = systemSettingInfo['diningType'];
    print('loadMachineSettingInfo diningType : $diningType');
    mealType = diningType == '2' ? true : false;
    isAllowPos = systemSettingInfo['isAllowPos'];
    isAllowReceipt = systemSettingInfo['isAllowReceipt'];
    String panelType = systemSettingInfo['panelType'] ?? 'Mini';
    machineMode = systemSettingInfo["machineMode"];

    showReceiptPage = isAllowReceipt == "1" ? false : true;
    isReceiptPageShow = isAllowReceipt == "1" ? false : true;

    menu_direction = (systemSettingInfo["menuDirection"] != "" &&
            systemSettingInfo["menuDirection"] != null)
        ? systemSettingInfo["menuDirection"]
        : "1";
    machineType = panelTypes[panelType] ?? MachineType.new_panel;

    showPrintType = int.parse(systemSettingInfo['showPrintType']); // 0:普通 1:贴纸

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
    print('loadMachineSettingInfo 1');
    Map machineActivateData = await HomeServices.getMachineActivateData();
    isAllowCash = machineActivateData['showCash'];
    showCash = isAllowCash && cashOn;
    showWechat = machineActivateData['showWechat'];
    showAlipay = machineActivateData['showAlipay'];
    showPayPay = machineActivateData['showPayPay'];
    showCreditCard = machineActivateData['showCreditCard'];
    print('loadMachineSettingInfo 2');
    showAuPay = machineActivateData['au_Pay'];
    showDPay = machineActivateData['d_Pay'];
    showRPay = machineActivateData['R_Pay'];
    showMPay = machineActivateData['m_Pay'];
    print('loadMachineSettingInfo 3');
    showPosEdy = machineActivateData['pos_Edy'];
    showPosiD = machineActivateData['pos_iD'];
    showPosIC = machineActivateData['pos_IC'];
    showPosQUICPay = machineActivateData['pos_QUICPay'];
    showPosWAON = machineActivateData['pos_WAON'];
    showPosnanaco = machineActivateData['pos_nanaco'];
    print('loadMachineSettingInfo 4');
    showVisa = machineActivateData['show_visa'];
    showMaster = machineActivateData['show_master'];
    showJcb = machineActivateData['show_jcb'];
    showUnionPay = machineActivateData['show_unionPay'];
    showAmericanExpress = machineActivateData['show_americanExpress'];
    showDinersClub = machineActivateData['show_dinersClub'];
    showDiscover = machineActivateData['show_discover'];
    print('loadMachineSettingInfo 5');
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    pos_ip = posSettingInfo['posIp'] ?? "";
    pos_port = posSettingInfo['posPort'] ?? "";
    Map wlanPrintPanelSettingInfo =
        await HomeServices.getWlanPanelPrintSettingInfo();
    wlan_panel_print_ip = wlanPrintPanelSettingInfo['wlanPrintIp'] ?? "";
    wlan_panel_print_port = wlanPrintPanelSettingInfo['wlanPrintPort'] ?? "";

    Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
    wlan_print_ip = wlanPrintSettingInfo['wlanPrintIp'] ?? '';
    wlan_print_port = wlanPrintSettingInfo['wlanPrintPort'] ?? '';

    Map wlanPrintSettingTwoInfo =
        await HomeServices.getWlanPrintSettingTwoInfo();
    wlan_print_ip_two = wlanPrintSettingTwoInfo['wlanPrintTwoIp'] ?? '';
    wlan_print_port_two = wlanPrintSettingTwoInfo['wlanPrintTwoPort'] ?? '';

    printerList = await HomeServices.getPrinterListInfo();
    sseSettingList = await HomeServices.getSSESettingList();

    print('loadMachineSettingInfo 6');
  }
}
