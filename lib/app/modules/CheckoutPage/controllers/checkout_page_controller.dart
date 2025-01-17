import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../menuPage/views/SelectPayment.dart';
import '../../scan_detail_page/logic.dart';
import '../../scan_detail_page/view.dart';

class CheckoutPageController extends GetxController with StateMixin {
  //TODO: Implement CheckoutPageController
  TextEditingController scanQrCodeHomeController = new TextEditingController();
  FocusNode scanQrCodeHomeFocusNode = FocusNode();

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  RxString machineCode = "".obs;
  RxList homeList = [].obs;

  RxBool actuarial = false.obs;
  RxBool lineup = false.obs;
  RxBool takeOut = false.obs; //是否允许外带
  RxString menu_direction = "1".obs;//1 默认顶部横向  2 左侧纵向
  RxString isReservation = "0".obs;

  RxString isAllowPos = "0".obs; //1 使用信用卡刷卡  0 不可使用
  RxString isAllowReceipt = "2".obs; //1 直接打印領収書  ２ 实现打印領収書菜单
  RxString receiptPrintType = "2".obs; //1 打印領収書  ２ 不打印領収書
  RxString pos_ip = "".obs;
  RxString pos_port = "".obs;

  RxList machineLanguagesList = [].obs;

  //顶部展示支付类型
  RxBool showWechat = false.obs;
  RxBool showAlipay = false.obs;
  RxBool showPayPay = false.obs;
  RxBool showCreditCard = false.obs;
  RxBool showCash = false.obs;

  RxBool showauPay = false.obs;
  RxBool showdPay = false.obs;
  RxBool showrPay = false.obs;
  RxBool showmPay = false.obs;

  RxBool showPosEdy = false.obs;
  RxBool showPosiD = false.obs;
  RxBool showPosIC = false.obs;
  RxBool showPosQUICPay = false.obs;
  RxBool showPosWAON = false.obs;
  RxBool showPosnanaco = false.obs;
  RxBool showOpenPayment = false.obs;

  RxBool showVisa = false.obs;
  RxBool showMaster = false.obs;
  RxBool showJcb = false.obs;
  RxBool showUnionPay = false.obs;
  RxBool showAmericanExpress = false.obs;
  RxBool showDinersClub = false.obs;
  RxBool showDiscover = false.obs;

  RxString orderId = "".obs;
  RxString totlaPrice = "0".obs;
  RxString tableNum = "0".obs;

  RxString payment_method_num = "0".obs; //支付类型选择
  RxString checkLanguage = "JP".obs;
  bool isFirstPage = false;


  RxMap orderInfoMap = {}.obs;
  late String scanTextValue;

  @override
  void onInit() {
    debugPrint("CheckoutPageController init");
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    //Get.focusScope.unfocus();
    //Get.focusScope.requestFocus(scanQrCodeFocusNode);
    getMachineInfo();
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


//获取机器信息
  getMachineInfo() async {
    var machineCodestr = await HomeServices.getMachineInfo();
    if (machineCodestr != "") {
        machineCode.value = machineCodestr;

    }
    //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点

    getHomeImageList();
  }

  getHomeImageList() async {
    List homeimageList = await HomeServices.getSmartweHomeImagesData();
    homeList.value = homeimageList;

    getSmartweMachineSettingData();
    update();
  }

  getSmartweMachineSettingData() async {
    var smartweMachineSetting = await HomeServices.getSmartweMachineSettingData();
    actuarial.value = smartweMachineSetting["machineActuarial"];
    lineup.value = smartweMachineSetting["machineLineup"];

    getSystemSettingInfo();
  }

  getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

      menu_direction.value = (SystemSettingInfo["menuDirection"] !="" && SystemSettingInfo["menuDirection"]!=null) ? SystemSettingInfo["menuDirection"] :"1";
      isReservation.value = SystemSettingInfo["isReservation"];
      isAllowPos.value = SystemSettingInfo['isAllowPos'];
      isAllowReceipt.value = SystemSettingInfo['isAllowReceipt'];
      takeOut.value = (SystemSettingInfo['diningType'] == "2" || SystemSettingInfo['diningType'] == "3") ? true : false;

    getmenchineLanguages();

  }

  getmenchineLanguages() async {
    var menchineLanguagesData = await HomeServices.getMachineLanguages();

      machineLanguagesList.value = menchineLanguagesData;

    getMachineActivateInfo();
  }

  //获取展示支付方式
  getMachineActivateInfo() async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();

    showCash.value = systemSettingInfo['showCash'];
    showWechat.value = systemSettingInfo['showWechat'];
    showAlipay.value = systemSettingInfo['showAlipay'];
    showPayPay.value = systemSettingInfo['showPayPay'];
    showCreditCard.value = systemSettingInfo['showCreditCard'];

    showauPay.value = systemSettingInfo['au_Pay'];
    showdPay.value = systemSettingInfo['d_Pay'];
    showrPay.value = systemSettingInfo['R_Pay'];
    showmPay.value = systemSettingInfo['m_Pay'];

    showPosEdy.value = systemSettingInfo['pos_Edy'];
    showPosiD.value = systemSettingInfo['pos_iD'];
    showPosIC.value = systemSettingInfo['pos_IC'];
    showPosQUICPay.value = systemSettingInfo['pos_QUICPay'];
    showPosWAON.value = systemSettingInfo['pos_WAON'];
    showPosnanaco.value = systemSettingInfo['pos_nanaco'];

    showVisa.value = systemSettingInfo['show_visa'];
    showMaster.value = systemSettingInfo['show_master'];
    showJcb.value = systemSettingInfo['show_jcb'];
    showUnionPay.value = systemSettingInfo['show_unionPay'];
    showAmericanExpress.value = systemSettingInfo['show_americanExpress'];
    showDinersClub.value = systemSettingInfo['show_dinersClub'];
    showDiscover.value = systemSettingInfo['show_discover'];
    update();
    change(null, status: RxStatus.success());
  }


  showOrderEasyLoading(){
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onLongPress: (){
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

  }


  requestOrderList(String scanText, {goDetail = true, firstPage = false}) async {
    isFirstPage = firstPage;
    debugPrint('qrCodeString: $scanText');
    scanTextValue = scanText;
    String orderKey = scanText;
    if (orderKey.isEmpty) return;

    if (orderKey.contains('?p=') == true) {
      //正则实现截取'?p='之后的字符串
      orderKey = _getOrderKey(scanText);
    }
    debugPrint('orderKey : $orderKey');
    var formData = {
      "orderKey": orderKey,
      "language": checkLanguage.value,
      "machineCode": machineCode.value
    };

    debugPrint('formData: $formData');

    request('webBootCalculateV2', method: 'POST', parameters: formData)
        .then((val) {
      print('webBootCalculateV2:$val');

      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200 &&
          response["data"] != null &&
          response["data"].isNotEmpty &&
          response["data"]["orderId"] != null
      ) {
        if (response["data"]["totalPrice"] > 0) {

          orderId.value = response["data"]["orderId"].toString();
          totlaPrice.value = response["data"]["totalPrice"].toString();
          tableNum.value = response["data"]["tableNum"].toString();
          orderInfoMap.value = response["data"]["orderInfoMap"] ?? {};

          if (goDetail) {
            debugPrint('/scan-detail');
            Get.to(()=>ScanDetailPagePage());
          } else {
            if (Get.isRegistered<ScanDetailPageLogic>())
              Get.find<ScanDetailPageLogic>().update();
            update();
          }
        } else {
          _resetScanState(false);
        }
      } else {
        _resetScanState(false);
        _showDialogError(response['msg']);
      }
    }).catchError((error) {
      print('webBootCalculateV2 error:${error.toString()}');
    });
  }



  _getOrderKey(qrCodeString) {
    RegExp regExp = new RegExp(r"\?p=(.*)");
    return regExp.stringMatch(qrCodeString).toString().substring(3);
  }



  _showDialogError(msg){
      Get.dialog(DialogUtils.alertOneButton(msg,
      title: GString.getToString(checkLanguage.value, "tag_title"),
      confirmtitle:
      GString.getToString(checkLanguage.value, "tag_button_yes"),
      contentTagImg: "error_public", confirm: () {
        Get.back();
      }));
  }

  //选择食用方式和支付方式
  showSelectMealTypeAndPaymentMethodDialog() async {
    scanQrCodeFocusNode.requestFocus();
    scanQrCodeHomeFocusNode.requestFocus();
    Get.to(
          () =>
        SelectPaymentPage(
            checkLanguage: checkLanguage.value,
            menuCount: 0,
            //mealType:_mealType,
            isAllowPos: isAllowPos.value,
            isAllowReceipt: isAllowReceipt.value,
            payment_method_num: payment_method_num.value,
            showCash: showCash.value,
            showWechat: showWechat.value,
            showAlipay: showAlipay.value,
            showPayPay: showPayPay.value,
            showauPay: showauPay.value,
            showdPay: showdPay.value,
            showrPay: showrPay.value,
            showmPay: showmPay.value,
            showCreditCard: showCreditCard.value,
            showPosEdy: showPosEdy.value,
            showPosiD: showPosiD.value,
            showPosIC: showPosIC.value,
            showPosQUICPay: showPosQUICPay.value,
            showPosWAON: showPosWAON.value,
            showPosnanaco: showPosnanaco.value,
            showVisa: showVisa.value,
            showMaster: showMaster.value,
            showJcb: showJcb.value,
            showUnionPay: showUnionPay.value,
            showAmericanExpress: showAmericanExpress.value,
            showDinersClub:showDinersClub.value,
            showDiscover: showDiscover.value,
            shopCartTotalPrice:totlaPrice.value,
            tableNum: tableNum.value,
            onConfrimClick: (String isAllowPosstr, String payment_method_numcheck, String receiptPrintTypeString) {
                isAllowPos.value = isAllowPosstr;
                payment_method_num.value = payment_method_numcheck;
                receiptPrintType.value = receiptPrintTypeString;
                //checkLanguage.value = "JP";
                // scanQrCodeController.text = "";
                // scanQrCodeHomeController.text = "";
                showOpenPayment.value = true;

              var paymentMethod = ["3","4","5","6","7","8","9","10"];
              if (paymentMethod.contains(payment_method_num.value) == true) {
                getPosSettingInfo();
              }else{
                //postNewOrderId();
                goToSettlement();
              }

            },
            onCancelClick: (String isBack){
              if(isBack == "back"){
                scanQrCodeController.text = "";
                scanQrCodeHomeController.text = "";
              }
              scanQrCodeFocusNode.requestFocus();// 获取焦点
              scanQrCodeHomeFocusNode.requestFocus();// 获取焦点
            }
        ),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      opaque: false,
    );
  }

  postNewOrderId({orderIdIfTakeOut = ""}) {

    if (orderId.value == "") {
      orderId.value = orderIdIfTakeOut;
    }

    var formData = {
      "orderId": orderId.value,
      "machineCode": machineCode.value,
    };
    request('webBootToPayConfirm', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200 && response['data'] !=null && response['data']['orderId'] !=null) {

          orderId.value = response['data']["orderId"];
          print(orderId.value);
          //goToSettlement();
      }else{

        //showToast(response['data']["message"]);
        Get.dialog(
            DialogUtils.alertOneButton("${response['data']["message"]}",
                title: GString.getToString(checkLanguage.value, "tag_title"),
                confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
                confirm: () {
                  Get.back();
                })
        );
      }
    });


  }

  getPosSettingInfo() async {
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    pos_ip.value = posSettingInfo['posIp'];
    pos_port.value = posSettingInfo['posPort'];
    //postNewOrderId();
    goToSettlement();
  }
  goToSettlement() async {
    // scanQrCodeController.text = "";
    // scanQrCodeHomeController.text = "";
    Get.toNamed('/settlement',preventDuplicates: false,
        arguments: {
          "checkLanguage": checkLanguage.value,
          "machineCode": machineCode.value,
          "orderId" : orderId.value,
          "totalPrice" : totlaPrice.value,
          "machineMode":"2",
          "isAllowPos": isAllowPos.value,
          "receiptPrintType": receiptPrintType.value,
          "posIp": pos_ip.value,
          "posPort": pos_port.value,
          "paymentMethod":payment_method_num.value,
          "showWechat": showWechat.value,
          "showAlipay": showAlipay.value,
          "showPayPay": showPayPay.value,
          "showCreditCard": showCreditCard.value,
          "showauPay": showauPay.value,
          "showdPay": showdPay.value,
          "showrPay": showrPay.value,
          "showmPay": showmPay.value,
          "showPosEdy": showPosEdy.value,
          "showPosiD": showPosiD.value,
          "showPosIC": showPosIC.value,
          "showPosQUICPay": showPosQUICPay.value,
          "showPosWAON": showPosWAON.value,
          "showPosnanaco": showPosnanaco.value,
          "showVisa": showVisa.value,
          "showMaster": showMaster.value,
          "showJcb": showJcb.value,
          "showUnionPay": showUnionPay.value,
          "showAmericanExpress": showAmericanExpress.value,
          "showDinersClub": showDinersClub.value,
          "showDiscover": showDiscover.value,
          "showOpenPayment":showOpenPayment.value
        });
    // if (result == true) {
    //   debugPrint('---settlement back---');
    //   if (result == true) {
    //     debugPrint('settlement back');
    //     Get.back();
    //     showOrderEasyLoading();
    //     requestOrderList(scanTextValue, goDetail: false);
    //   }
    // }
  }

  resetStateBack() {
    debugPrint('settlement back');
    Get.back();
    showOrderEasyLoading();
    requestOrderList(scanTextValue, goDetail: false);
  }

  backCheckHome({resetLanguage = false}) {

    final reset = isFirstPage || resetLanguage;
    debugPrint('backCheckHome isFirstPage:$isFirstPage, reset:$resetLanguage');
    if (reset)
    checkLanguage.value = 'JP';

    _resetScanState(resetLanguage);
    Get.back();
  }

  _resetScanState(resetLanguage) {
    if (isFirstPage) {
      debugPrint('isFirstPage = true');
      scanQrCodeHomeController.text = "";
      scanQrCodeHomeFocusNode.requestFocus();
      scanQrCodeFocusNode.unfocus();
    } else {
      debugPrint('isFirstPage = false');
      scanQrCodeController.text = "";
      scanQrCodeFocusNode.requestFocus();// 获取焦点
      if (resetLanguage) {//返回到首页需要重置首页扫码
        scanQrCodeHomeFocusNode.requestFocus();
      } else {
        scanQrCodeHomeFocusNode.unfocus();
      }

    }
  }


}
