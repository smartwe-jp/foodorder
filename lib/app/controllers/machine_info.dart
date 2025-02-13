import 'package:foodorder/app/services/HomeServices.dart';
import 'package:get/get.dart';

class MachineInfoController extends GetxController {
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
  late String menu_direction;

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

  String paymentMethod = '0';

  late String pos_ip;
  late String pos_port;

  @override
  Future<void> onInit() async {
    print('loadMachineSettingInfo onInit');
    await loadMachineSettingInfo();
    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('loadMachineSettingInfo dispose');
    super.dispose();
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
    Map systemSettingInfo0 = await HomeServices.getSystemSettingInfo();
    diningType = systemSettingInfo0['diningType'];
    print('loadMachineSettingInfo diningType : $diningType');
    isAllowPos = systemSettingInfo0['isAllowPos'];
    isAllowReceipt = systemSettingInfo0['isAllowReceipt'];

    showReceiptPage = isAllowReceipt == "1" ? false : true;

    menu_direction = (systemSettingInfo0["menuDirection"] !="" && systemSettingInfo0["menuDirection"]!=null) ? systemSettingInfo0["menuDirection"] :"1";

    final homeImageList = await HomeServices.getSmartweHomeImagesData();

    homeList = homeImageList ?? [];

    print('loadMachineSettingInfo 1');
    Map systemSettingInfo = await HomeServices.getMachineActivateData();
    showCash = systemSettingInfo['showCash'];
    showWechat = systemSettingInfo['showWechat'];
    showAlipay = systemSettingInfo['showAlipay'];
    showPayPay = systemSettingInfo['showPayPay'];
    showCreditCard = systemSettingInfo['showCreditCard'];
    print('loadMachineSettingInfo 2');
    showAuPay = systemSettingInfo['au_Pay'];
    showDPay = systemSettingInfo['d_Pay'];
    showRPay = systemSettingInfo['R_Pay'];
    showMPay = systemSettingInfo['m_Pay'];
    print('loadMachineSettingInfo 3');
    showPosEdy = systemSettingInfo['pos_Edy'];
    showPosiD = systemSettingInfo['pos_iD'];
    showPosIC = systemSettingInfo['pos_IC'];
    showPosQUICPay = systemSettingInfo['pos_QUICPay'];
    showPosWAON = systemSettingInfo['pos_WAON'];
    showPosnanaco = systemSettingInfo['pos_nanaco'];
    print('loadMachineSettingInfo 4');
    showVisa = systemSettingInfo['show_visa'];
    showMaster = systemSettingInfo['show_master'];
    showJcb = systemSettingInfo['show_jcb'];
    showUnionPay = systemSettingInfo['show_unionPay'];
    showAmericanExpress = systemSettingInfo['show_americanExpress'];
    showDinersClub = systemSettingInfo['show_dinersClub'];
    showDiscover = systemSettingInfo['show_discover'];
    print('loadMachineSettingInfo 5');
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    pos_ip = posSettingInfo['posIp'] ?? "";
    pos_port = posSettingInfo['posPort'] ?? "";
    print('loadMachineSettingInfo 6');
  }
}
