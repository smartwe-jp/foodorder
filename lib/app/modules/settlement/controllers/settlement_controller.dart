import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:widget_to_image/widget_to_image.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/printer_info.dart';
import '../../../config/string.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../plugins/flutter_plugin_msprint/lib/flutter_plugin_msprinter.dart';
import '../../../plugins/paycube/lib/paycube.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/cashMoneyParser.dart';
import '../../../services/formatMoney.dart';
import '../../../services/logUtil.dart';
import '../../../widget/DialogUtils.dart';
import '../../../widget/NumberCircle.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../../OrderHome/controllers/order_home_controller.dart';
import '../../SelfCheckoutscanningcode/controllers/self_checkoutscanningcode_controller.dart';
import '../../menuPage/controllers/menu_page_controller.dart';
import '../views/label_constrained_box.dart';
import '../views/receipt_constrained_box.dart';

class SettlementController extends GetxController with StateMixin {
  //TODO: Implement SettlementController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  RxString machineCode = "".obs;

  //默认语言包选择
  RxString checkLanguage = "JP".obs;

  RxString is_query_receipt = "1".obs; //1 要领収书  2 不要领収书
  RxString is_allow_receipt = "1".obs; //1 必须打印  2 不必须
  RxString is_allow_receipt_menu = "1".obs;//1 必须打印  2 不要
  RxString print_paper_txt_size = "1".obs;//1普通　2大　3特大
  RxString is_back_home = "0".obs; //0 返回home  1 返回菜单
  RxString machineMode = "1".obs; //机器类型 1普通券卖机 2精算机
  RxString is_allow_oneyen = "0".obs;//0 禁用  1 允许

  RxString orderId = "".obs;
  RxString scanQrCode = "".obs;
  RxString totalPrice = "0".obs;
  RxString getPutMoney = "0".obs; //投币金额
  RxString getPutMoneyCurrency = "".obs; //投币金额币种
  RxString showOutMoney = "0".obs; //展示应出金金额
  RxBool allowClick = true.obs;
  RxBool isReportCash = false.obs; //是否已汇报过现金

  RxBool getOutMoneyString = true.obs; //是否允许获取出金金额字符串
  RxInt outMonyNum = 0.obs;
  RxBool getputMoneyString = true.obs; //是否允许获取入金金额字符串
  RxInt putMonyNum = 0.obs;

  Timer? timer;
  Timer? allowtimer;
  Timer? stoptimer;
  Timer? outmoneytimer;
  Timer? getoutmoneytimer;
  Timer? endtimer;
  Timer? OutMoneytimer;
  Timer? putMoneyCurrencytimer;

  Timer? ScanCodeConfirmTimer;

  RxString allowStatus = "".obs;
  RxString stopStatus = "".obs;
  RxString outStatus = "".obs;
  RxString endStatus = "".obs;
  RxInt giveChangeMoney = 0.obs;
  RxString outStringMoney = "0".obs; //找零金额
  RxString currencyString = "".obs; // 出金币种
  RxBool isPrint = true.obs; //是否打印小票，默认打印，如果取消订单则不打印。
  RxBool isPrintClick = false.obs; //是否点击了打印小票。
  RxBool isCancelClick = false.obs; //是否点击了取消。


  RxBool showPrintButton = false.obs;  //如果投币金额不足，则不显示打印按钮


  RxString isAllowPos = "0".obs;
  RxString pos_ip = "".obs;
  RxString pos_port = "".obs;
  RxString payment_method_num = "0".obs; //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc
  RxMap posResultReportData = {}.obs;
  RxInt showPrintType =0.obs; //0 receipt   1Lable
  RxString wlan_print_ip = "".obs;
  RxString wlan_print_port = "".obs;
  RxString is_allow_wlanPrint_continuous = "0".obs;//0 单票  1 连票  Print Continuous
  RxString wlan_print_ip_two = "".obs;
  RxString wlan_print_port_two = "".obs;
  RxString is_allow_wlanPrint_Two_continuous = "0".obs;//0 单票  1 连票  Print Continuous

  RxString printLogoImage = "".obs;

  //顶部展示支付类型
  RxBool showWechat = false.obs;
  RxBool showAlipay = false.obs;
  RxBool showPayPay = false.obs;
  RxBool showCreditCard = false.obs;

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

  RxBool showVisa = false.obs;
  RxBool showMaster = false.obs;
  RxBool showJcb = false.obs;
  RxBool showUnionPay = false.obs;
  RxBool showAmericanExpress = false.obs;
  RxBool showDinersClub = false.obs;

  //用于控制返回是否多关闭页面
  RxBool showOpenPayment = false.obs;

  //60秒内未接收现金机正确通知，则进行下一步操作
  Timer? showCashTimer;
  RxInt seconds = 60.obs;
  Socket? _socket; //socket对象
  RxBool socketState = false.obs; //连接状态

  RxBool isReportOutMoney = false.obs; //新处理 默认不汇报出金信息  先汇报入金信息在汇报出金信息
  RxBool isCancel = false.obs; //新增加  取消默认为false

  RxBool isPayConfirmOrderId = false.obs; //现金支付后，判断是否需要重新请求confirm orderid

  RxInt CashStep = 1.obs;
  RxInt socketNumberTimes = 0.obs;
  RxBool socketPosCancel = false.obs;


  @override
  void onInit() {
    readyQueryData();
    Future.delayed(const Duration(),() => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    //Get.focusScope.unfocus();
    //Get.focusScope.requestFocus(scanQrCodeFocusNode);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    if (socketState.value == true) {
      this._socket?.close();
    }
    Paycube.stopListening();
    allowtimer?.cancel();
    timer?.cancel();
    stoptimer?.cancel();
    //outtimer?.cancel();
    outmoneytimer?.cancel();
    getoutmoneytimer?.cancel();
    endtimer?.cancel();
    OutMoneytimer?.cancel();
    putMoneyCurrencytimer?.cancel();
    ScanCodeConfirmTimer?.cancel();
    showCashTimer?.cancel();

    super.onClose();
  }

  readyQueryData(){
    checkLanguage.value =Get.arguments['checkLanguage'];
    machineCode.value = Get.arguments['machineCode'];
    orderId.value = Get.arguments['orderId'];
    //this._machineMode = widget.arguments['machineMode'];
    totalPrice.value = Get.arguments['totalPrice'];
    isAllowPos.value = Get.arguments['isAllowPos'];
    pos_ip.value = Get.arguments['posIp'];
    pos_port.value = Get.arguments['posPort'];
    payment_method_num.value = Get.arguments['paymentMethod'];

    showWechat.value = Get.arguments['showWechat'];
    showAlipay.value = Get.arguments['showAlipay'];
    showPayPay.value = Get.arguments['showPayPay'];
    showCreditCard.value = Get.arguments['showCreditCard'];

    showauPay.value = Get.arguments['showauPay'];
    showdPay.value = Get.arguments['showdPay'];
    showrPay.value = Get.arguments['showrPay'];
    showmPay.value= Get.arguments['showmPay'];
    showPosEdy.value = Get.arguments['showPosEdy'];
    showPosiD.value = Get.arguments['showPosiD'];
    showPosIC.value = Get.arguments['showPosIC'];
    showPosQUICPay.value = Get.arguments['showPosQUICPay'];
    showPosWAON.value = Get.arguments['showPosWAON'];
    showPosnanaco.value = Get.arguments['showPosnanaco'];

    showVisa.value = Get.arguments["showVisa"];
    showMaster.value = Get.arguments["showMaster"];
    showJcb.value = Get.arguments["showJcb"];
    showUnionPay.value = Get.arguments["showUnionPay"];
    showAmericanExpress.value = Get.arguments["showAmericanExpress"];
    showDinersClub.value = Get.arguments["showDinersClub"];

    showOpenPayment.value = Get.arguments['showOpenPayment'];

    //0 1适用之前旧版本，可适用现金机，同时也可以扫码  2只可扫码，不在打开现金机 3、4只支持刷卡，不在打开现金机
    if (payment_method_num.value == "0" || payment_method_num.value == "1") {
      //打开现金机
      _countDownTimer("1");
      Starttoubi();
    } /*else if (payment_method_num.value == "2") {
    //检测是否需要连接socket
    checkpayconnectSocker();
  }*/ else if (payment_method_num.value == "3" ||
        payment_method_num.value == "4" ||
        payment_method_num.value == "5" ||
        payment_method_num.value == "6" ||
        payment_method_num.value == "7" ||
        payment_method_num.value == "8" ||
        payment_method_num.value == "9" ||
        payment_method_num.value == "10"
    ) {
      //1链接socker 2 请求接口获得支付数据发送给pos机 3监听
      if(pos_ip.value != "" && pos_port.value != ""){
        showPosEasyLoading();
        payconnectSocker();
      }
    }

    _getSystemSettingInfo();

  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();

    is_allow_receipt.value = systemSettingInfo['isAllowReceipt'];
    is_allow_receipt_menu.value = systemSettingInfo['isAllowReceiptMenu'];
    print_paper_txt_size.value = systemSettingInfo['printPaperTxtSize'];
    is_back_home.value = systemSettingInfo['isAllowBackHome'];
    //新版精算模式也可点外带
    machineMode.value = systemSettingInfo['machineMode'];
    showPrintType.value = int.parse(systemSettingInfo['showPrintType']); //0 receipt   1Lable
    is_allow_oneyen.value = systemSettingInfo['isAllowOneYen'];

    if(systemSettingInfo['isAllowWlanPrint'] == "1"){
      is_allow_wlanPrint_continuous.value = systemSettingInfo['isAllowWlanPrintContinuous'];
      Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
      if(wlanPrintSettingInfo['wlanPrintIp'] !=null && wlanPrintSettingInfo['wlanPrintIp'] !="" && wlanPrintSettingInfo['wlanPrintPort'] !=null && wlanPrintSettingInfo['wlanPrintPort'] !=""){
        wlan_print_ip.value = wlanPrintSettingInfo['wlanPrintIp'];
        wlan_print_port.value = wlanPrintSettingInfo['wlanPrintPort'];
      }
    }

    if(systemSettingInfo['isAllowWlanPrintTwo'] == "1"){
      is_allow_wlanPrint_Two_continuous.value = systemSettingInfo['isAllowWlanPrintTwoContinuous'];
      Map wlanPrintSettingTwoInfo = await HomeServices.getWlanPrintSettingTwoInfo();
      if(wlanPrintSettingTwoInfo['wlanPrintIp'] !=null && wlanPrintSettingTwoInfo['wlanPrintIp'] !="" && wlanPrintSettingTwoInfo['wlanPrintPort'] !=null && wlanPrintSettingTwoInfo['wlanPrintPort'] !=""){
        wlan_print_ip_two.value = wlanPrintSettingTwoInfo['wlanPrintIp'];
        wlan_print_port_two.value = wlanPrintSettingTwoInfo['wlanPrintPort'];
      }
    }


    _getPrintLogoImageData();
  }

  _getPrintLogoImageData() async {
    String logoImageInfo = await HomeServices.getSmartweLogoImagesData();
    if(logoImageInfo != "" && logoImageInfo != null){
      printLogoImage.value = logoImageInfo;
    }

    change(null, status: RxStatus.success());
  }

  //倒计时
  _countDownTimer(stepState) {
    showCashTimer?.cancel();
    showCashTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds.value--;

      if (this.seconds == 0) {
        //如果60秒未接收返回正确通知，则进行下一步操作
        //eventBus.fire(new setShowCashEvent('支付成功...'));
        showCashTimer?.cancel(); //清除定时器
        if (stepState == "1") {
          gotonewMenuPage();
        } else {
          gotonewMyhome();
        }
      }
    });
  }

  gotonewMenuPage() {
    if(isPayConfirmOrderId.value == true){
      if(payment_method_num.value == "0" || payment_method_num.value == "1"){
        if(machineMode.value == "2") {//精算时候请求
          //print("精算请求了new order id");
          Get.find<CheckoutPageController>().postNewOrderId();
        }else if(machineMode.value == "3"){
          //print("自助精算请求了new order id");
          Get.find<SelfCheckoutscanningcodeController>().postNewOrderId();
        }else{
          //print("普通支付请求了new order id");
          Get.find<MenuPageController>().postNewOrderId();
        }
      }
    }
    EasyLoading.dismiss();
    Get.back();
  }

  gotonewMyhome() {
    ordersqlcontroller.removeAllFromCart();

    EasyLoading.dismiss();
    Get.back();
    if(machineMode.value == "2") {
      Get.delete<CheckoutPageController>(); // 手动删除控制器实例
      //精算页面
      Get.toNamed("/checkout-page");
      //Navigator.pushNamed(context, '/checkOutPage');
    }else if(machineMode.value == "3") {
      Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例
      Get.toNamed("/selfservice-page");
      //Navigator.pushNamed(context, '/selfServiceHomePage');
    } else {
      Get.delete<MenuPageController>(); // 手动删除控制器实例
      Get.toNamed("/order-home");
      //Navigator.pushNamed(context, '/home');
    }
  }

  gotonewBack() {
    ordersqlcontroller.removeAllFromCart();

    EasyLoading.dismiss();
    Get.back();
    if (machineMode.value == "1") {
      if(is_back_home.value == "0"){
        Get.delete<MenuPageController>(); // 手动删除控制器实例
        Get.toNamed("/order-home");
        //Navigator.pushNamed(context, '/home');
      }else{
        // eventBus.fire(new clearCartEvent('支付成功...'));

        //有弹窗选择支付才在关闭一个
        if(showOpenPayment.value == true){
          Get.back();
        }

      }

    }else if (machineMode.value == "3") {
      if(is_back_home.value == "0"){
        Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例
        Get.toNamed("/selfservice-page");
        //Navigator.pushNamed(context, '/selfServiceHomePage');
      }else{
        //eventBus.fire(new clearCartEvent('支付成功...'));

        //有弹窗选择支付才在关闭一个
        if(showOpenPayment.value == true){
          Get.back();
        }

      }

    } else {
      Get.delete<CheckoutPageController>(); // 手动删除控制器实例
      //精算页面
      Get.toNamed("/checkout-page");
      //Navigator.pushNamed(context, '/checkOutPage');
    }
  }

  showEasyLoading() {
    var _showTag;
    if (int.parse(showOutMoney.value) > 0) {
      //_showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_outprice_tag"),
      _showTag = Text(
          GString.getToString(
              checkLanguage.value, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    } else {
      _showTag = Text(
          GString.getToString(
              checkLanguage.value, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    }
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
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),

          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  showSuccessEasyLoading() {
    var _showTag;

    _showTag =
        Text(GString.getToString(checkLanguage.value, "payment_success_title"),
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
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "paymentSuccess"),
                    fit: BoxFit.fitHeight),
              ),
            ),

          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  showBackEasyLoading() {
    var _showTag =
    Text(GString.getToString(checkLanguage.value, "settlement_noprint_tag"),
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
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  _showPosCancelEasyLoading(resultString) {
    EasyLoading.dismiss();
    var _showTag;
    var _showTagContent = "";
    if(resultString =="M10"){//需要从端末点击返回
      _showTag = Align(
        child: Text(GString.getToString(checkLanguage.value, "settlement_posPay_error_connect_worker"),
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(28))),
        alignment: Alignment(0, 0),
      );
      _showTagContent = GString.getToString(checkLanguage.value, "settlement_posPay_error_connect_worker");
    }else if(resultString =="L06"){//需要从端末点击返回
      _showTag = Align(
        child: Text(GString.getToString(checkLanguage.value, "settlement_posPay_error_connect_worker"),
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(28))),
        alignment: Alignment(0, 0),
      );
      _showTagContent = GString.getToString(checkLanguage.value, "settlement_posPay_error_connect_worker");
    }else{
      _showTag = Align(
        child: Text(GString.getToString(checkLanguage.value, "settlement_posPay_error"),
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(28))),
        alignment: Alignment(0, 0),
      );
      _showTagContent = GString.getToString(checkLanguage.value, "settlement_posPay_error");
    }
    Get.dialog(
        DialogUtils.alertOneButton(_showTagContent,
            title: GString.getToString(checkLanguage.value, "tag_title"),
            confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
            confirm: () {
              if(resultString !="M10" && resultString !="L06"){
                getPaymentCancelPosData();
              }

              Get.back();
              showEasyLoading();
              Future.delayed(Duration(milliseconds: 1500),() async {
                CancelOrder();
              });
            })
    );

  }

  _showEasyLoadingScan() {
    var _showTag;
    if (int.parse(showOutMoney.value) > 0) {
      //_showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_outprice_tag"),
      _showTag = Text(
          GString.getToString(
              checkLanguage.value, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    } else {
      _showTag = Text(
          GString.getToString(
              checkLanguage.value, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    }
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
            InkWell(
              onLongPress: () {
                ScanCodeConfirmTimer?.cancel();
                _doScanCodeTimeOutLastQuery();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  showPosEasyLoading() {
    /*var _showTag;
    _showTag = Text(
        GString.getToString(
            checkLanguage.value, "settlement_print_loading_tag"),
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));*/
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 0,),//_showTag
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),

          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  //扫码支付
  doToPay() {
    //不是扫码支付直接return
    if (payment_method_num.value != "2") return;

    /*if (_showWechat == false && _showAlipay == false && _showPayPay == false) {
      _showScanCodeNoOpenDialog(1,"");
      return;
    }

    var _regExpWechat = r"^1[0-5]\d{16}$";
    var _regExpAlipay = r"^(?:2[5-9]|30)\d{14,22}$";
    if (RegExp(_regExpWechat).hasMatch(_scanQrCode) == true &&
        _showWechat == false) {
      _showScanCodeNoOpenDialog(2,"");
      return;
    } else if (RegExp(_regExpAlipay).hasMatch(_scanQrCode) == true &&
        _showAlipay == false) {
      _showScanCodeNoOpenDialog(2,"");
      return;
    } else {
      if (RegExp(_regExpWechat).hasMatch(_scanQrCode) == false &&
          RegExp(_regExpAlipay).hasMatch(_scanQrCode) == false &&
          _showPayPay == false) {
        _showScanCodeNoOpenDialog(2,"");
        return;
      }
    }*/
    //print(scanQrCodeController.text);
    if (machineCode.value != "" && scanQrCodeController.text != "" && orderId.value != null) {
      //_showEasyLoading();
      _showEasyLoadingScan();
      var formData = {
        "auth_code": scanQrCodeController.text,
        "machineCode": machineCode.value,
        "orderId": orderId.value,
        "payType":"",
      };//print(formData);
      request('webBootToPayv2', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200 && response['data'].isNotEmpty) {
          var resultData = response['data'];
          if(resultData["requestInfo"] != ""){
            if(resultData["exceptionMessage"] == ""){
              posResultReportData.value = response['data'];
              //检测是否需要连接socket
              checkpayconnectSocker(questData: resultData["requestInfo"]);
            }else{
              _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
            }
          }else{
            if(resultData["result"] == true){
              doPrintOrderMenu("1");
            }else{
              _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
            }
          }

        } else {
          //扫码后超时，再继续请求后台，1秒一次 20次
          _doScanCodeTimeOut();
        }

      });

    }
  }

  //三种扫码支付都未开通，弹出dialog
  _showScanCodeNoOpenDialog(checknum, showContent,{payType:"qr"}) {
    EasyLoading.dismiss();
    scanQrCodeController.text = "";
    //_scanQrCode = "";
    //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode); // 获取焦点
    scanQrCodeFocusNode.requestFocus();

    var show_dialog_content;

    if (checknum == 1) {
      show_dialog_content = GString.getToString(
          checkLanguage.value, "settlement_scancodenoopen_error");
    } else if (checknum == 2) {
      show_dialog_content = GString.getToString(
          checkLanguage.value, "settlement_scancodenochange_error");
    } else if (checknum == 3) {
      if(showContent != null && showContent!=""){
        show_dialog_content = showContent;
      }else{
        show_dialog_content = GString.getToString(checkLanguage.value, "settlement_nopayment_error");
      }

    }
    //支付状态

    Get.dialog(
        DialogUtils.alertOneButton(show_dialog_content,
            title: GString.getToString(checkLanguage.value, "tag_title"),
            confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
            confirm: () {
              Get.back();
              if(payType == "pos"){
                Get.back();
              }
            })
    );
  }

  //扫码后超时，再继续请求后台，5秒一次 60次
  _doScanCodeTimeOut() {
    int queryCount = 0;
    ScanCodeConfirmTimer?.cancel();
    ScanCodeConfirmTimer = Timer.periodic(Duration(milliseconds: 5000),
            (Timer ConfirmTimer) async {
          queryCount++;
          if (queryCount > 60) {
            //退出关闭
            ConfirmTimer?.cancel();
            _showScanCodeTimeOutDialog();
          }

          var formData = {
            "orderId": orderId.value,
          };
          request('webBootLinePayConfirm', method: 'POST', parameters: formData)
              .then((val) {
            var response = json.decode(val.toString());

            if (response['code'] == 200 && response['data'] == true) {
              //退出关闭
              ConfirmTimer?.cancel();
              doPrintOrderMenu("1");
            }
          });
        });
  }

  _doScanCodeTimeOutLastQuery() {
    var formData = {
      "orderId": orderId.value,
    };
    request('webBootLinePayConfirm', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu("1");
      } else {
        _showScanCodeTimeOutDialog();
      }
    });
  }

  //扫码超时请求20次后依然失败，弹出dialog
  _showScanCodeTimeOutDialog() {
    EasyLoading.dismiss();
    scanQrCodeController.text = "";
    //scanQrCode.value = "";
    //FocusScope.of(context).requestFocus(scanQrCodeFocusNode); // 获取焦点
    scanQrCodeFocusNode.requestFocus();


    var show_dialog_content =
    GString.getToString(checkLanguage.value, "settlement_nopayment_error");


    Get.dialog(
        DialogUtils.alertOneButton(show_dialog_content,
            title: GString.getToString(checkLanguage.value, "tag_title"),
            confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
            confirm: () {
              Get.back();
            })
    );
  }

  //pos机相关
  checkpayconnectSocker({questData=""}) async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();
    var showCreditCard = systemSettingInfo['showCreditCard'];
    if(showCreditCard == true){
      Map posSettingInfo = await HomeServices.getPosSettingInfo();

      if(posSettingInfo.isNotEmpty){
        pos_ip.value = posSettingInfo['posIp'];
        pos_port.value = posSettingInfo['posPort'];
        if(pos_ip.value != "" && pos_port.value != ""){
          payconnectSocker(questData: questData);
        }

      }
    }
  }

  //pos机相关
  payconnectSocker({questData=""}) async {

    //判断socket请求次数
    socketNumberTimes.value++;
    if(socketNumberTimes.value>20){
      _showScanCodeNoOpenDialog(3,GString.getToString(checkLanguage.value, "settlement_posPay_connect_error"),payType: "pos");
      return;
    }

    Socket.connect(
      pos_ip.value,
      int.parse(pos_port.value),
      //timeout: Duration(seconds: 5),
    ).then((Socket socket) {
      print("连接成功了么");
      this._socket = socket;

      //扫码过来的，请求数据不为空时候发送POS请求
      if(questData!=""){
        //判断不为空则POS机
        this._socket?.write(questData);
      }

      //获得pos数据并发送
      var paymentMethod = ["3","4","5","6","7","8","9","10"];
      if (paymentMethod.contains(payment_method_num.value) == true) {
        _getPaymentPosData();
      }

      //扫码后直接打完票后关闭
      if(payment_method_num.value != "2"){
        EasyLoading.dismiss();
      }

      // 监听wifi模块发送的数据
      this._socket?.listen((List<int> event) {
        LogUtil.d(event);
        //if (event.length > 40) event.fillRange(266, 289, 32);
        for(var i=0; i< event.length; i++){
          if(event[i] >127){
            event[i] = 32;
            //print(i);
          }
        }
        var zhuanhuan = Uint8List.fromList(event);
        var eventString = Utf8Codec().decode(zhuanhuan);
        LogUtil.d(eventString);
        //print(Utf8Codec().decode(zhuanhuan));
        //print("event=====${eventString}=====");
        String FirstString = eventString.substring(0, 1);
        String SecondString = eventString.substring(1, 3);
        String transaction_type = eventString.substring(3, 6);
        String resultString = eventString.substring(10, 13);
        String resultMPFSString = eventString.substring(13, 16);
        print("FirstString==${FirstString}");
        print("SecondString==${SecondString}");
        print("transaction_type==${transaction_type}");
        print("resultString==${resultString}");
        print("resultMPFSString==${resultMPFSString}");
        //支付成功 打印，返回首页 除了成功都取消
        if (transaction_type == "900") {
          if (FirstString == "3" && SecondString == "11" && resultString == "000") {print("进来取消了");
          //CancelOrder();
          showEasyLoading();
          }else if(resultString.trim() != ""){

            //T10 交通系等待时间超过30-40后自动返回
            //06 需要密码但是不输入密码直接点击屏幕返回  需要弹框文字
            var posErrorCode = ["L06"];
            if (posErrorCode.contains(resultString) == true) {
              _showPosCancelEasyLoading(resultString);
              /*Future.delayed(Duration(milliseconds: 2500),() async {
                CancelOrder();
              });*/
            }
          }
        } else {
          if (FirstString == "3" && SecondString == "11" && resultString == "000" &&  resultMPFSString == "000") {// &&  resultMPFSString == "000"
            //除了扫码的才显示
            if(payment_method_num.value != "2"){
              showEasyLoading();
            }


            var thincaCloud = ["5","6","7","8","9","10"];
            if (thincaCloud.contains(payment_method_num.value) == true) {
              String reportString = eventString.substring(0, 169);
              CreditCardPayReport(reportString);
            }else{
              CreditCardPayReport(eventString);
            }

          } else {
            if(resultString.trim() != ""){

              //T10 交通系等待时间超过30-40后自动返回
              var posErrorCode = ["L11","T10"];
              if (posErrorCode.contains(resultString) == true) {
                Future.delayed(Duration(milliseconds: 2500),() async {print("来这里取消了么");
                //CancelOrder();
                gotonewMenuPage();
                });
              }else{// if(resultString == "T10")
                _showPosCancelEasyLoading(resultString);
              }
            }
          }
        }
      },
        onDone: () {
          socketState.value = false;
          print("pos机done了");
        },
        onError: (e) {
          socketState.value = false;
          print("pos机错误了");
          //_close();
        },
      );

      socketState.value = true;

    }).catchError((e) {

      socketState.value = false;

      print("Unable to connect: $e");
      print("POS机连接${socketNumberTimes.value}");
      Future.delayed(Duration(milliseconds: 400), () async {
        payconnectSocker(questData:questData);
      });
      //_showScanCodeNoOpenDialog(3,GString.getToString(checkLanguage.value, "settlement_posPay_connect_error"),payType: "pos");
    });

  }

  _getPaymentPosData() {
    var payTypeData = {
      //"3":"CreditCard",
      //"4":"CreditCard",
      "5":"Edy",
      "6":"iD",
      "7":"nanaco",
      "8":"WAON",
      "9":"QUICPay",
      "10":"IC",
    };
    var thincaCloud = ["5","6","7","8","9","10"];
    String? _payType = "";
    if (thincaCloud.contains(payment_method_num.value) == true) {
      _payType = payTypeData[payment_method_num.value];
    }

    var formData = {
      "auth_code": "0000000088888888",
      "machineCode": machineCode.value,
      "orderId": orderId.value,
      "payType":_payType,
    };
    request('webBootToPayv2', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      //print("发送pos请求");LogUtil.d(response);
      if (response['code'] == 200 && response['data'].isNotEmpty) {
        var resultData = response['data'];
        if(resultData["requestInfo"] != null && resultData["requestInfo"] != "" ){
          if(resultData["exceptionMessage"] != null && resultData["exceptionMessage"] == ""){
            posResultReportData.value = response['data'];
            //判断不为空则POS机
            this._socket?.write(resultData["requestInfo"]);
          }else{
            _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
          }
        }else{
          _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
        }

      } else {
        _showScanCodeNoOpenDialog(3,GString.getToString(checkLanguage.value, "settlement_scancodenochange_error"));
      }

    });

  }

  showPosCancelAlert(){
    if(socketPosCancel.value == true) return;

    Future.delayed(Duration(milliseconds: 50),() async {
      Get.dialog(
          DialogUtils.alert(GString.getToString(checkLanguage.value, "settlement_back_alertcontent"),
              title: GString.getToString(checkLanguage.value, "tag_title"),
              canceltitle: GString.getToString(checkLanguage.value, "tag_button_no"),
              confirmtitle: GString.getToString(checkLanguage.value, "tag_button_yes"),
              confirm: () {
                Get.back();
                socketPosCancel.value = true;
                getPaymentCancelPosData();
              },
              cancle: () {
                Get.back();
              }),
          barrierDismissible: false
      );

    });
  }
  getPaymentCancelPosData() {
  //if(socketPosCancel.value == true) return;

  var formData = {
    "machineCode": machineCode.value,
    "orderId": orderId.value,
  };

  request("webBootCreditCardCancel", method: 'POST', parameters: formData)
      .then((val) async {
    var response = json.decode(val.toString());//print("发送取消请求");LogUtil.d(response);
    //EasyLoading.dismiss();
    if (response['code'] == 200) {
      //var _queryString =       "2101500001       00509                  000000120221114093225";
      this._socket?.write(response['data']);
    }
  });
  }
//刷卡机nfc支付汇报
  CreditCardPayReport(eventString) {
    //showEasyLoading();
    posResultReportData.value["result"] = true;
    posResultReportData.value["paymentInfo"] = eventString;//LogUtil.d("huibaohhhhhh===${_posResultReportData}");
    request('webBootPosPayReport', method: 'POST', parameters: posResultReportData.value).then((val) {
      var response = json.decode(val.toString());//print(response);

      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu("1");
      } else {
        //扫码后超时，再继续请求后台，1秒一次 20次
        //_doScanCodeTimeOut();
        _showPosCancelEasyLoading("900");
      }
    });

  }

  CancelOrder() {
    /*var formData = {
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "model": (_machineMode == "1") ? "0" : "1",
    };
    request('webBootCancelV1', method: 'POST', parameters: formData);*/

    if (payment_method_num.value == "1" || payment_method_num.value == "0") {
      isCancel.value = true;
      isPayConfirmOrderId.value = true;
      //已投钱
      if (int.parse(getPutMoney.value) > 0) {
        isPrint.value = false;
        totalPrice.value = "0";
        showPrintButton.value = false;

        //如果现金机投币大于0后取消，则直接关机出金
        Endtoubi();
      } else {
        isPrint.value = false;
        totalPrice.value = "0";
        getPutMoney.value = "0";
        showPrintButton.value = false;
        //如果现金机投币大于0后取消，则直接关机出金
        Endtoubi();
      }
    } else {
      //返回上一级菜单页面
      gotonewMenuPage();
    }
  }

  //去打印小票
  doPrintOrderMenu(printType) async {
    var printStatus = await FlutterPluginMsprinter.getPrintStatus();
    if (printStatus == "0" || printStatus == "8") {
      var formData = {
        "orderId": orderId.value,
        "payAmount": getPutMoney.value,
        "machineCode":machineCode.value,
        "printType":(showPrintType.value ==1 && wlan_print_ip.value !="")?"Label":""
      };
      /*var formData = {
        "orderId": "442800657845387264",
        "payAmount": "1000",
        "machineCode":"X3V9YPJABVZGAELIZ9",
        "printType":(_showPrintType ==1 && _wlan_print_ip !="")?"Label":""
      };print(formData);print(_wlan_print_ip);*/
      var queryUrl;
      //queryUrl = "webBootToPrintV4";
      //queryUrl = "webBootToPrintV5";
      //queryUrl = "webBootToPrintV6"; //23新修改小票
      queryUrl = "webBootToPrintV7"; //230704新修改小票


      request(queryUrl, method: 'POST', parameters: formData).then((val) async {
        var response = json.decode(val.toString());
        //LogUtil.d(response);
        if (response['code'] == 200) {
          //receipt
          if(response['data']["printInfoMapStruct"] != null && response['data']["printInfoMapStruct"].isNotEmpty){
          _wifiNetworkPrintData(response['data']["serialNumber"],response['data']["printInfoMapStruct"],response['data']["takeOut"],response['data']["orderTime"]);
          }

          //label打印
          if(showPrintType.value ==1 && wlan_print_ip.value !="" && response['data']["printInfoListStruct"].length>0){
            _wifiNetworkLabelPrintData(response['data']["printInfoListStruct"]);
          }
          //printType 1 打印菜+领収书 2 只打印菜
          //orderType 1 打印菜并根据printtype来判断是否打印领収书。orderType 2不打印菜
          if(response['data']["orderType"] == 1 && is_allow_receipt_menu.value == "1"){

            _tpPrintnew(response['data'], printType);

          }else{
            if (printType == "1") {
              _tpPrintReceipt(response['data']);
            }
          }



          Future.delayed(Duration(milliseconds: 300),() async {
            if (machineMode.value == "1") {
              //eventBus.fire(new clearCartEvent('支付成功...'));
              Get.find<OrderHomeController>().clearCartList();
              Get.find<MenuPageController>().clearCartList();
              //Get.find<MenuPageController>().getBookingBootMenu();
            }else if(machineMode.value == "3"){
              Get.find<SelfCheckoutscanningcodeController>().clearCartList();
            }

            //先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
            if (payment_method_num.value == "1") {
              nextOper();
            } else {
              gotonewMyhome();
            }

          });

        } else {
          //错误后重新调用一次
          doPrintOrderMenu(printType);
          //EasyLoading.dismiss();

        }
      });
    } else {
      EasyLoading.dismiss();

      var show_dialog_content = "";
      if (printStatus == "7") {
        show_dialog_content = GString.getToString(
            checkLanguage.value, "tag_print_content_paper_shortage");
      } else {
        show_dialog_content = GString.getToString(
            checkLanguage.value, "tag_print_content_paper_error");
      }
      //小票状态
      Get.dialog(
          DialogUtils.alert(show_dialog_content,
              title: GString.getToString(checkLanguage.value, "tag_title"),
              canceltitle: GString.getToString(checkLanguage.value,"tag_print_button_no"),
              confirmtitle: GString.getToString(checkLanguage.value,"tag_print_button_yes"),
              confirm: () {
                Get.back();
                doPrintOrderMenu(printType);
              },
              cancle: () {
                Get.back();
                gotonewMyhome();
              })
      );
    }
  }


  //现金及支付
  //现金机开始 打开现金机，准备开始投币
  Starttoubi() async {
    //入金开始
    String strartPayCube = await Paycube.strartPayCube;
    await Paycube.setReceiveEvent;
    //调用插件的监听
    Paycube.getPayCubeListener();

    allowtimer?.cancel();
    allowtimer = Timer.periodic(Duration(milliseconds: 250), (Timer allowt) async {
      allowStatus.value = await Paycube.getPayCubeAllowCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (allowStatus.value == "AllowSuccess") {
        //如果打开了现金机，则去掉倒计时监听
        showCashTimer?.cancel();
        seconds.value = 120;

        getPutInMoney();
        //getPayCubeBackDataInfo();

        allowt.cancel();
      } else if (allowStatus.value == "Error-F0--16") {
        await Paycube.endTrade;
        //sleep(Duration(milliseconds: 200));
        await Paycube.strartPayCube;
      } else if (allowStatus.value == "Error-A0--02") {
        //sleep(Duration(milliseconds: 300));
      } else {
        await Paycube.strartPayCube;
      }
    });
  }


  //获取投入金额
  getPutInMoney() async {
  await Paycube.setReceiveEvent;
  timer?.cancel();
  timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) async {
    var result = await Paycube.getPayCubeMoney;
    if (int.parse(result) > 0) {
      getPutMoney.value = result;
      scanQrCodeFocusNode.unfocus();
      int totalPriceResult = int.tryParse(totalPrice.value) ?? 0;
      //if (int.parse(result) >=int.parse(totalPrice.value, onError: (source) => -1)) {
      if(int.parse(result) >= totalPriceResult){
        if(isCancel.value == false){
          showPrintButton.value = true;
        }else{
          showPrintButton.value = false;
        }

        var outMoney = int.parse(result) - int.parse(totalPrice.value); //找零金额
        showOutMoney.value = outMoney.toString(); //找零金额

      } else {
        showOutMoney.value = "0"; //找零金额

      }
      update();
    }
  });
  }

  //入金开始-入金结束-交易结束-出金开始-交易结束  中间可set
  Endtoubi() async {
    sleep(Duration(milliseconds: 300));
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    //开启倒计时
    _countDownTimer("2");

    stoptimer?.cancel();
    stoptimer =
        Timer.periodic(Duration(milliseconds: 950), (Timer stopt) async {
          stopStatus.value = await Paycube.getPayCubeStopCashStatus;
          // 循环一定要记得设置取消条件，手动取消
          if (stopStatus.value == "StopSuccess") {
            showCashTimer?.cancel();
            seconds.value = 180;
            timer?.cancel();
            if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
              giveChangeMoney.value = int.parse(getPutMoney.value) - int.parse(totalPrice.value);
              if (isPrint.value == false) {
                startOutPutMoney(giveChangeMoney.value);
              }
            } else if (int.parse(getPutMoney.value) == int.parse(totalPrice.value)) {
              if (isPrint.value == false) {
                //已经结束入金，处理取引终了
                payCubeCloseTransaction();
              }
            }/* else {
          showToast(
              GString.getToString(this._checkLanguage, "show_put_money_error"));
        }*/

            stopt.cancel();
          } else {
            await Paycube.endPayCube;
          }
        });
  }

  //打印小票之后在关闭现金机，所以不考虑_isPrint
  nextOper() async {
    CashStep.value = 2;
    //sleep(Duration(milliseconds: 50));
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    //开启倒计时
    _countDownTimer("3");
    stoptimer?.cancel();
    stoptimer =Timer.periodic(Duration(milliseconds: 450), (Timer stopt) async {
      stopStatus.value = await Paycube.getPayCubeStopCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (stopStatus.value == "StopSuccess") {
        showCashTimer?.cancel();
        seconds.value = 180;
        timer?.cancel();
        //如果投币金额大于待支付总金额
        if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
          giveChangeMoney.value = int.parse(getPutMoney.value) - int.parse(totalPrice.value);

          //找零
          startOutPutMoney(giveChangeMoney.value);
        } else {
          //已经结束入金，处理取引终了
          payCubeCloseTransaction();
        }

        stopt.cancel();
      }else {
        await Paycube.endPayCube;
      }
    });
  }

  startOutPutMoney(outMoney) async {
    CashStep.value = 3;
    outStringMoney.value = outMoney.toString();
    await Paycube.setReceiveEvent;

    String outResult = await Paycube.outPayCubeMoney(outStringMoney.value);
    _countDownTimer("6");

    outmoneytimer?.cancel();
    outmoneytimer = Timer.periodic(Duration(milliseconds: 350), (Timer outmoneyt) async {
        outStatus.value = await Paycube.getPayCubeOutMoneyStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (outStatus.value == "OutSuccess") {
        //如果打开了现金机，则去掉倒计时监听
        showCashTimer?.cancel();
        seconds.value = 180;
        //如果取消不汇报，则出金后直接关闭 ？？？？？？
        _getPayCubeOutMoney();

        outmoneyt?.cancel();
      } else if (outStatus.value == "Error-A0--02" || outStatus.value == "Error") {
        //await Paycube.setReceiveEvent;
        //sleep(Duration(milliseconds: 200));
        //await Paycube.getPayCubeOutMoneyStatus;
        //print("_outStatus处理中:$_outStatus");
      } else {
        await Paycube.outPayCubeMoney(outStringMoney.value);
      }
      });
  }

  _getPayCubeOutMoney() async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    OutMoneytimer?.cancel();
    await Paycube.setReceiveEvent;
    _countDownTimer("7");

    var queryTimes = 0;
    // 循环一定要记得设置取消条件，手动取消
    //String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;

    OutMoneytimer = Timer.periodic(Duration(milliseconds: 350), (Timer outMoneyTime) async {

        if(queryTimes>150){
          //如果打开了现金机，则去掉倒计时监听
          showCashTimer?.cancel();
          seconds.value = 180;
          getOutMoneyString.value == false;

          OutMoneytimer?.cancel();
          //汇报出金币种
          reportOutMoney();
        }

        if(getOutMoneyString.value == true){
          // 循环一定要记得设置取消条件，手动取消
          String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;
          if (currencyStringresult.trim().length > 50) {
          var outtotalAmount = MoneyParser.calculateTotalAmount(currencyStringresult.trim());
          //print("计算现金机出金金额与实际投入是否相等${outtotalAmount.toString()}");
          //print("计算现金机出金金额与实际投入是否相等${currencyStringresult}");

          if(outtotalAmount == int.parse(outStringMoney.value)){
            //如果打开了现金机，则去掉倒计时监听
            showCashTimer?.cancel();
            seconds.value = 180;
            currencyString.value = currencyStringresult;
            getOutMoneyString.value == false;

            OutMoneytimer?.cancel();
            //汇报出金币种
            reportOutMoney();
          }

          }
        }
        outMonyNum.value++;
        queryTimes++;
        });
  }


  //汇报出金币种,请求后台
  reportOutMoney() {
    isReportOutMoney.value = true;
    payCubeCloseTransaction();
  }

  payCubeCloseTransaction() async {
    if (int.parse(getPutMoney.value) > 0) {
      //汇报入金币种
      _getPayCubePutMoneyCurrency();
    }
    CashStep.value = 4;
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    //开启倒计时
    _countDownTimer("5");
    await Paycube.setReceiveEvent;
     endtimer?.cancel();
    endtimer = Timer.periodic(Duration(milliseconds: 250), (Timer endtradet) async {
      endStatus.value = await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消 || _endStatus == "Error-A0--02"
      if (endStatus.value == "EndSuccess") {
        showCashTimer?.cancel();
        seconds.value = 180;
        //关闭机器后的跳转
        if (isPrint.value == true) {
          gotonewBack();
        } else {
          gotonewMenuPage();
        }

        endtradet.cancel();
      }else {
        //sleep(Duration(milliseconds: 200));
        await Paycube.endTrade;
      }
    });
  }

  _getPayCubePutMoneyCurrency() async {
    //_putcurrencyString现金机出款币种:61 00 00 62 00 00 63 00 00
    putMoneyCurrencytimer?.cancel();
    await Paycube.setReceiveEvent;
    _countDownTimer("8");
    var putQueryNum = 0;
    putMoneyCurrencytimer = Timer.periodic(Duration(milliseconds: 350),(Timer putMoneyCurrencyTime) async {

      if(putQueryNum >100){
        showCashTimer?.cancel();
        putMoneyCurrencyTime.cancel();
        getputMoneyString.value = false;
        //汇报入金币种
        reportPutMoneyCurrency();
      }
      if(getputMoneyString.value == true){
        // 循环一定要记得设置取消条件，手动取消
        String putcurrencyString = await Paycube.getPayCubePutMoneyCurrency;
        if (putcurrencyString.trim().length > 60) {
          var totalAmount = MoneyParser.calculateTotalAmount(putcurrencyString.trim());
          if(totalAmount == int.parse(getPutMoney.value)){
            showCashTimer?.cancel();
            seconds.value = 180;
            getPutMoneyCurrency.value = putcurrencyString;
            putMoneyCurrencyTime.cancel();
            getputMoneyString.value = false;
            //汇报入金币种
            reportPutMoneyCurrency();
          }
        }
      }
      putQueryNum++;
      putMonyNum.value++;
    });
  }

  //汇报入金币种,请求后台
  reportPutMoneyCurrency() {

    if(isReportCash.value == true){print("已汇报过");
    return;
    }

    isReportCash.value = true;
    //operation  0 确认支付  1 取消返回(券売機)　2 取消返回(精算機、自助结算)
    var operation = 0;
    if (isCancel.value == true) {
      if(machineMode.value == "1") {
        operation = 1;
      }else{
        operation = 2;
      }
    }

    var formData = {
      "paymentInfo": getPutMoneyCurrency.value.trim(),
      "changeInfo": currencyString.value.trim(),
      "machineCode": machineCode.value,
      "orderId": orderId.value,
      "price": int.parse(getPutMoney.value),
      "operation": operation,
      "coinForbidden":int.parse(is_allow_oneyen.value)
    };//print("webBootToReportV1==${formData}");
    request('webBootToReportV1', method: 'POST', parameters: formData)
        .then((value) {
      var response = json.decode(value.toString());
      // if (response['code'] == 200) {
      ///if (isReportOutMoney.value == true) {
      //已经结束入金，处理取引终了
      //reportOutMoneyCurrency();
      //}
      //}
    });
  }

  reportOutMoneyCurrency() {
    if (giveChangeMoney.value > 0) {
      var formData = {
        "changeInfo": currencyString.value.trim(),
        "machineCode": machineCode.value,
        "orderId": orderId.value,
        "price": giveChangeMoney.value,
        "coinForbidden":int.parse(is_allow_oneyen.value)
      };//print(formData);
      request('webBootToReportV1', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200) {
        } else {}
      });
    }
  }


  //打印甘蘭
  _tpPrintnew(printData, printType) async {
    var categoryVos = printData["printInfoListStruct"];
    var print_menu_txt_size = 28.0;
    var wrapNum = 10;
    int oneRowHeight = 48;
    if(print_paper_txt_size.value == "1"){
      print_menu_txt_size = 28.0;
      wrapNum = 12;
      oneRowHeight = 38;
    }else if(print_paper_txt_size.value == "2"){
      print_menu_txt_size = 33.0;
      wrapNum = 10;
      oneRowHeight = 44;
    }else if(print_paper_txt_size.value == "3"){
      print_menu_txt_size = 40.0;
      wrapNum = 8;
      oneRowHeight = 55;
    }

    List<Widget> categoryMenus = [];
    var lineHight = 125;
    var menuNum = 0;
    var optionNum = 0;
    var addRowHight = 0;

    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["numberTip"]}",
                style: TextStyle(
                  fontSize: 28,
                  //fontFamily: 'JetBrainsMonoRegular',
                  fontWeight: FontWeight.w200,
                  color: ColorsUtil.hexToColor("#000000"),
                ))),
      ),
    );
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["serialNumber"]}",
                style: TextStyle(
                  fontSize: 32,
                  //fontFamily: 'JetBrainsMonoRegular',
                  fontWeight: FontWeight.w200,
                  color: ColorsUtil.hexToColor("#000000"),
                ))),
      ),
    );

    int categoryNum = categoryVos.length;
    int categoryshowNum = 0;

    for (var m = 0; m < categoryVos.length; m++) {
      var lineItem = categoryVos[m];
      var optionVoList = lineItem["optionVoListMsgMap"];
      // 计算菜品标题长度
      var menuLength = lineItem["mainTitle"].length;
      var menuLine = menuLength / wrapNum;
      int menuRowNum = menuLine.ceil();
      optionNum = 0;

      categoryMenus.add(
        _publicGoodsTwoColumnsTxt("${lineItem["mainTitle"]}", print_menu_txt_size,
            FontWeight.w200, "${lineItem["qty"]}", print_menu_txt_size, FontWeight.w200),
      );
      if (optionVoList != null && optionVoList.isNotEmpty) {
        optionVoList.forEach((key, value) {
          // 计算菜品标题长度
          var groupNameLength = key.length;
          var optionNameLength = value[0].length;
          var optionLine = (groupNameLength + optionNameLength) / wrapNum;
          var countLine = 0;//optionLine.ceil();

          //处理option 开始-----------
          if((key.length+value[0].length) >(wrapNum-2)){
            var newLineNum = 0.0;
            //if(groupNameLength >wrapNum){
            newLineNum = groupNameLength / (wrapNum-2);
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;
            //if(optionNameLength >wrapNum){
            var newLineNumLength = 0.0;
            newLineNumLength = optionNameLength / (wrapNum-2);
            //}
            countLine += newLineNumLength.ceil();
            optionLine += newLineNum;

            categoryMenus.add(Column(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(
                              child:Text("${key}",
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: print_menu_txt_size,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: 'ZenKakuGothicAntique',
                                    color: ColorsUtil.hexToColor("#000000"),
                                  ))
                          )
                      ),

                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(50)),
                  child: Row(
                    mainAxisAlignment: (value[0].length >(wrapNum-2) ) ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(
                            child: Text("${value[0]}",
                                softWrap: true,
                                textAlign: (value[0].length >(wrapNum-2)) ? TextAlign.left : TextAlign.right,
                                style: TextStyle(
                                  fontSize: print_menu_txt_size,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'ZenKakuGothicAntique',
                                  color: ColorsUtil.hexToColor("#000000"),
                                )),
                          )),
                    ],
                  ),
                ),
              ],
            ));
          }else{
            countLine += 1;

            categoryMenus.add(Container(
              height: oneRowHeight.toDouble(),
              padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text("${key}",
                          softWrap: true,
                          style: TextStyle(
                            fontSize: print_menu_txt_size,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'ZenKakuGothicAntique',
                            color: ColorsUtil.hexToColor("#000000"),
                          ))
                  ),
                  Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text("${value[0]}",
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: print_menu_txt_size,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'ZenKakuGothicAntique',
                            color: ColorsUtil.hexToColor("#000000"),
                          ))),
                ],
              ),
            ));
          }

          var newOptionSonLine = 0.0;
          if(value.length>1){
            List<Widget> optionSons = [];
            for (var j = 1; j < value.length; j++) {
              //print(value[j]);
              newOptionSonLine += value[j].length / (wrapNum-2);
              var oneOptionlength = 0.0;
              oneOptionlength = value[j].length / (wrapNum-2);
              countLine += oneOptionlength.ceil();

              optionSons.add(
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(50)),
                    child: Row(
                      mainAxisAlignment: (value[j].length >(wrapNum-2)) ? MainAxisAlignment.start : MainAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(child: Text("${value[j]}",
                            textDirection: TextDirection.ltr,
                            textAlign: (value[j].length >(wrapNum-2)) ? TextAlign.left : TextAlign.right,
                            style: TextStyle(
                              fontSize: print_menu_txt_size,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'ZenKakuGothicAntique',
                              color: ColorsUtil.hexToColor("#000000"),
                              //fontWeight: FontWeight.w600
                            ))),
                      ],
                    ),
                  )
              );
            }

            categoryMenus.add(Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              textDirection: TextDirection.rtl,
              children: optionSons,
            ));
          }


          //处理option结束-----------
          var optionRowNum = 0.0;
          optionRowNum = optionLine + newOptionSonLine;
          //addRowHight += 52 * optionRowNum;
          addRowHight += oneRowHeight*countLine+(countLine-1)*10;
          menuNum += optionRowNum.ceil();
          optionNum++;
        });

        addRowHight += oneRowHeight * menuRowNum+(menuRowNum-1)*10;
        menuNum += menuRowNum;
      } else {
        addRowHight += oneRowHeight * menuRowNum+(menuRowNum-1)*10;
        menuNum += menuRowNum;
      }

      //分割线
      if (machineMode.value == "1" || machineMode.value == "3") {
        addRowHight += 20;
        categoryMenus.add(
          _publicSplitLine(),
        );
      }
    }
    //print("总行数${menuNum}");
    var totalHight = addRowHight + lineHight;
    if (menuNum == 1) {
      totalHight += 15;
    }
    ByteData byteData = await WidgetToImage.widgetToImage(Container(
      width: 385,
      height: totalHight.toDouble(),
      padding: EdgeInsets.only(left: 0.5, right: 0.5),
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: categoryMenus,
      ),
    ),
        size: Size(385, totalHight.toDouble())
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //Future.delayed(Duration(milliseconds: 50), () async {
    String base64Image = base64Encode(imageBytes);
    //LogUtil.d(base64Image);
    if (printType == "1") {
      // print("打印小菜来了-开始打印小菜lalala：${DateTime.now()}");
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "0"," ");
      Future.delayed(Duration(milliseconds: 300), () async {
        await FlutterPluginMsprinter.sendPrintCut("1");
        _tpPrintReceipt(printData);
      });
    } else {
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", "0"," ");
      Future.delayed(Duration(milliseconds: 300), () async {
        await FlutterPluginMsprinter.sendPrintCut("0");
      });
    }

    //});
  }

  _wifiNetworkPrintData(serialNumber,extendPrintVo,takeOut,orderTime){
    var printData = [];
    extendPrintVo.forEach((k,v){
      printData = [];
      if(v.length>0){
        for(var i=0; i<v.length; i++){
          v[i]["checked"] = false;
          //判断是否有需要打印的数据
          if(v[i]["print"] == true){
            printData.add(v[i]);
          }
        }
        //QueueUtil.get("smartwe_taks_wifi_print")?.addTask(() {
        return wifiNetPrintnew(serialNumber,k,printData,takeOut,orderTime);
        //});
      }
    });

  }

  wifiNetPrintnew(serialNumber,printType,printData,takeOut,orderTime) async {
    //如果整理的数据打印机不是10或11就返回
    if(printType != "10" && printType != "12"){
      return;
    }

    //判断是否有打印机ip
    Map printerIpInfo = {"printer_ip":"","printer_port":"",};
    if(printType == "10"){
      if(wlan_print_ip.value != null && wlan_print_ip.value != ""){
        printerIpInfo = {"printer_ip":wlan_print_ip.value,"printer_port":wlan_print_port.value,};
        if(is_allow_wlanPrint_continuous.value =="1"){
          _wifiNetworkReceiptPrintContinuousData(serialNumber,printData,takeOut,orderTime,wlan_print_ip.value);
        }else{
          _wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,wlan_print_ip.value);
        }

      }else{
        return;
      }
    }else if(printType == "12"){
      if(wlan_print_ip_two.value != null && wlan_print_ip_two.value != ""){
        printerIpInfo = {"printer_ip":wlan_print_ip_two.value,"printer_port":wlan_print_port_two.value,};
        if(is_allow_wlanPrint_Two_continuous.value =="1"){
          _wifiNetworkReceiptPrintContinuousData(serialNumber,printData,takeOut,orderTime,wlan_print_ip_two.value);

        }else{
        _wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,wlan_print_ip_two.value);
        }
      }else{
        return;
      }
    }else{
      return;
    }
    //print(printData);
    //_wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,printerIpInfo["printer_ip"]);

  }

  //单票
  _wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,printer_ip){
    for(var i=0;i<printData.length;i++){
      // wifiNetPrintReceiptnew(serialNumber,printData[i],takeOut,orderTime,printer_ip);

      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: wifiNetPrintReceiptnew(serialNumber,printData[i],takeOut,orderTime,printer_ip) as ATempWidget,
          printTypeEnum: PrintTypeEnum.receipt,
          params: PrinterInfo(ip:printer_ip),
        ),
      );

    }
  }
  Widget wifiNetPrintReceiptnew(serialNumber,orderprintData,takeOut,orderTime,printer_ip) {
    var lineHight = 120;
    int menuNum = 0;
    var optionNum = 0;
    int addRowHight = 0;

    List<Widget> printMenus = [];
    printMenus.add(
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child:
                RichText(
                  text: TextSpan(
                      text: (takeOut == true) ?"☆︎":"",//${printData["takeOut"]}
                      style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      ),
                      children: [
                        TextSpan(
                          text: "${serialNumber.toString()}",
                          style: TextStyle(
                            fontSize: 50,
                            fontFamily: 'JetBrainsMonoRegular',
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#000000"),
                          ),
                        ),
                      ]),
                )
            ),
            Directionality(
                textDirection: TextDirection.ltr,
                child: Text("${orderTime}",
                    style: TextStyle(
                      fontSize: 45,
                      //fontFamily: 'JetBrainsMonoRegular',
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#000000"),
                    ))
            ),
          ],
        ),
      ),
    );
    printMenus.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.ltr,
        children: [
          Directionality(
              textDirection: TextDirection.ltr,
              child: Expanded(
                  child: Text("${orderprintData["mainTitle"]}",
                      style: TextStyle(
                        fontSize: 45,
                        //fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.hexToColor("#000000"),
                      ))
              )
          ),
          Container(
            width: 50,
            alignment: Alignment.centerRight,
            child: Directionality(
                textDirection: TextDirection.ltr,
                child: (int.parse(orderprintData["qtyBack"]) >1) ? NumberCircle(
                  number: int.parse(orderprintData["qtyBack"]),
                  circleColor: ColorsUtil.hexToColor("#000000"),
                  circleSize: 50.0,
                  numberStyle: TextStyle(
                    fontSize: 42,
                    fontFamily: 'JetBrainsMonoRegular',
                    fontWeight: FontWeight.w400,
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                ) :Text("${orderprintData["qty"]}",
                    textAlign: TextAlign.right,//${printData["takeOut"]}
                    style: TextStyle(
                      fontSize: 42,
                      fontFamily: 'JetBrainsMonoRegular',
                      fontWeight: FontWeight.w400,
                      color: ColorsUtil.hexToColor("#000000"),
                    ))
            ),
          ),
        ],
      ),
    );

    var mainTitleLine = orderprintData["mainTitle"].length / 10;
    int mainTitleRowNum = mainTitleLine.ceil();
    optionNum = 0;


    var optionVoListMap = orderprintData["optionVoListMsgMap"] ?? {};
    if (optionVoListMap != null && optionVoListMap.isNotEmpty) {
      optionVoListMap.forEach((key, value) {
        // 计算菜品标题长度
        var groupNameLength = key.length;
        var optionNameLength = value[0].length;
        var optionLine = (groupNameLength + optionNameLength) / 10;
        var countLine = 0;

        //处理option 开始-----------
        if((key.length+value[0].length)>10){

          printMenus.add(Column(
            textDirection: TextDirection.rtl,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Expanded(
                          child:Text("    ${key}",
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'JetBrainsMonoRegular',
                                color: ColorsUtil.hexToColor("#000000"),
                              ))
                      )
                  ),

                ],
              ),
              Container(
                padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                child: Row(
                  mainAxisAlignment: (value[0].length >10 ) ? MainAxisAlignment.start : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.rtl,
                        child: Expanded(
                          child: Text("${value[0]}",
                              softWrap: true,
                              textAlign: (value[0].length >10) ? TextAlign.left : TextAlign.right,
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'JetBrainsMonoRegular',
                                color: ColorsUtil.hexToColor("#000000"),
                              )),
                        )),
                  ],
                ),
              ),
            ],
          ));
        }else{
          printMenus.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("    ${key}",
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'JetBrainsMonoRegular',
                        color: ColorsUtil.hexToColor("#000000"),
                      ))
              ),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text("${value[0]}",
                      softWrap: true,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'JetBrainsMonoRegular',
                        color: ColorsUtil.hexToColor("#000000"),
                      ))),
            ],
          ));
        }

        var newOptionSonLine = 0.0;
        if(value.length>1){
          List<Widget> optionSons = [];
          for (var j = 1; j < value.length; j++) {

            optionSons.add(
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                  child: Row(
                    mainAxisAlignment: (value[j].length >10) ? MainAxisAlignment.start : MainAxisAlignment.end,
                    textDirection: TextDirection.ltr,
                    children: [
                      Expanded(child: Text("${value[j]}",
                          textDirection: TextDirection.ltr,
                          textAlign: (value[j].length >10) ? TextAlign.left : TextAlign.right,
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'JetBrainsMonoRegular',
                            color: ColorsUtil.hexToColor("#000000"),
                            //fontWeight: FontWeight.w600
                          ))),
                    ],
                  ),
                )
            );
          }

          printMenus.add(Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            textDirection: TextDirection.rtl,
            children: optionSons,
          ));
        }

      });

    }

    // 生成打印图层任务，指定任务类型为标签
    return ReceiptConstrainedBox(Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: printMenus,
    ));



  }

  //连票
  _wifiNetworkReceiptPrintContinuousData(serialNumber,printData,takeOut,orderTime,printer_ip){
    PictureGeneratorProvider.instance.addPicGeneratorTask(
      PicGenerateTask<PrinterInfo>(
        tempWidget: organizeData(serialNumber,printData,takeOut,orderTime,printer_ip) as ATempWidget,
        printTypeEnum: PrintTypeEnum.receipt,
        params: PrinterInfo(ip:printer_ip),
      ),
    );
  }
  organizeData(serialNumber,printData,takeOut,orderTime,printer_ip) {
    var categoryVos = printData;
    List<Widget> categoryMenus = [];
    var lineHight = 230;
    int menuNum = 0;
    var optionNum = 0;
    int addRowHight = 0;



    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child:
            RichText(
              text: TextSpan(
                  text: (takeOut == true) ?"☆︎":"",//${printData["takeOut"]}
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'JetBrainsMonoRegular',
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor("#000000"),
                  ),
                  children: [
                    TextSpan(
                      text: "${serialNumber.toString()}",
                      style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'JetBrainsMonoRegular',
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      ),
                    ),
                  ]),
            )
        ),
      ),
    );

    for(var i=0; i<categoryVos.length; i++){
      var lineVos = categoryVos[i];
      var optionVoList = categoryVos[i]["optionVoListMsgMap"] ?? {};

      // 计算菜品标题长度
      var mainTitleLength = lineVos["mainTitle"].length;
      var mainTitleLine = mainTitleLength / 10;
      int mainTitleRowNum = mainTitleLine.ceil();
      optionNum = 0;

      categoryMenus.add(
        Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              margin: EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Expanded(
                        child: Text("${lineVos["mainTitle"]}",
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'JetBrainsMonoRegular',
                              color: ColorsUtil.hexToColor("#000000"),)),
                      )
                  ),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text("${lineVos["qty"]}",
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'JetBrainsMonoRegular',
                            color: ColorsUtil.hexToColor("#000000"),
                            //fontWeight: FontWeight.w600
                          )
                      )
                  ),
                ],
              ),
            )),
      );

      if (optionVoList != null && optionVoList.isNotEmpty) {
        optionVoList.forEach((key, value) {
          // 计算菜品标题长度
          var groupNameLength = key.length;
          var optionNameLength = value[0].length;
          var optionLine = (groupNameLength + optionNameLength) / 12;
          var countLine = 0;


          //处理option 开始-----------
          if((key.length+value[0].length)>12){
            var newLineNum = 0.0;
            //if(groupNameLength >6){
            newLineNum = groupNameLength / 12;
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;
            //if(optionNameLength >6){
            newLineNum = optionNameLength / 12;
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;

            categoryMenus.add(Column(
              textDirection: TextDirection.rtl,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(
                            child:Text("    ${key}",
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'JetBrainsMonoRegular',
                                  color: ColorsUtil.hexToColor("#000000"),
                                ))
                        )
                    ),

                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                  child: Row(
                    mainAxisAlignment: (value[0].length >10 ) ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.rtl,
                          child: Expanded(
                            child: Text("${value[0]}",
                                softWrap: true,
                                textAlign: (value[0].length >10) ? TextAlign.left : TextAlign.right,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'JetBrainsMonoRegular',
                                  color: ColorsUtil.hexToColor("#000000"),
                                )),
                          )),
                    ],
                  ),
                ),
              ],
            ));
          }else{
            countLine += 1;
            categoryMenus.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("    ${key}",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'JetBrainsMonoRegular',
                          color: ColorsUtil.hexToColor("#000000"),
                        ))
                ),
                Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text("${value[0]}",
                        softWrap: true,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'JetBrainsMonoRegular',
                          color: ColorsUtil.hexToColor("#000000"),
                        ))),
              ],
            ));
          }

          var newOptionSonLine = 0.0;
          if(value.length>1){
            List<Widget> optionSons = [];
            for (var j = 1; j < value.length; j++) {
              // print(value[j]);
              newOptionSonLine += value[j].length / 10;
              var oneOptionlength = 0.0;
              oneOptionlength = value[j].length / 10;
              countLine += oneOptionlength.ceil();

              optionSons.add(
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(70)),
                    child: Row(
                      mainAxisAlignment: (value[j].length >10) ? MainAxisAlignment.start : MainAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(child: Text("${value[j]}",
                            textDirection: TextDirection.ltr,
                            textAlign: (value[j].length >10) ? TextAlign.left : TextAlign.right,
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'JetBrainsMonoRegular',
                              color: ColorsUtil.hexToColor("#000000"),
                              //fontWeight: FontWeight.w600
                            ))),
                      ],
                    ),
                  )
              );
            }

            categoryMenus.add(Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              textDirection: TextDirection.rtl,
              children: optionSons,
            ));
          }


          //处理option结束-----------
          var optionRowNum = 0.0;
          optionRowNum = optionLine + newOptionSonLine;
          //addRowHight += 52 * optionRowNum;
          addRowHight += 66*countLine;
          menuNum += optionRowNum.ceil();
          optionNum++;
        });

        //addRowHight += 59 * mainTitleRowNum;
        //menuNum += mainTitleRowNum;
      } else {
        addRowHight += 65 * mainTitleRowNum;
        menuNum += mainTitleRowNum;
      }

      addRowHight += 10;
      categoryMenus.add(
        Directionality(
            textDirection: TextDirection.ltr,
            child:Container(
              margin: EdgeInsets.only(top: 5,bottom: 5),
              height: 2.5,
              color:ColorsUtil.hexToColor("#000000"),
              width: 550,
            )
        ),
      );
    }

    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 5),
        alignment: Alignment.centerRight,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child:
            Text(
              "${orderTime}",//${printData["takeOut"]}
              style: TextStyle(
                fontSize: 45,
                fontFamily: 'JetBrainsMonoRegular',
                fontWeight: FontWeight.w500,
                color: ColorsUtil.hexToColor("#000000"),
              ),
            )
        ),
      ),
    );

    var totalHight = addRowHight+lineHight;
    if(menuNum == 1){
      totalHight +=15;
    }

    /*return Container(
      width: 550,
      height: totalHight.toDouble(),
      padding: EdgeInsets.only(left: 0.5, right: 0.5),
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: categoryMenus,
      ),
    );*/

    return ReceiptConstrainedBox(Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: categoryMenus,
    ));



  }

  //打印label
  _wifiNetworkLabelPrintData(extendPrintVo){
    var printData = [];
    for(var i=0;i<extendPrintVo.length;i++){
      // 生成打印图层任务，指定任务类型为标签
      PictureGeneratorProvider.instance.addPicGeneratorTask(
        PicGenerateTask<PrinterInfo>(
          tempWidget: menuData(extendPrintVo[i]) as ATempWidget,
          printTypeEnum: PrintTypeEnum.label,
          params: PrinterInfo(ip:wlan_print_ip.value),
        ),
      );
      /*QueueUtil.get("smartwe_taks_wifi_print")?.addTask(() {
        return wifiNetPrintLabelnew(extendPrintVo[i]);
      });*/
    }
  }

  wifiNetPrintLabelnew(orderprintData) async {

    Future.delayed(Duration(milliseconds: 1200),() async {
      ByteData byteData = await WidgetToImage.widgetToImage(
          menuData(orderprintData)
      );

      Uint8List imageBytes = byteData.buffer.asUint8List();
      var printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
        imgData: imageBytes,
        printType: PrintTypeEnum.label,
      );
      // 网络 打印
      final conn = printerPlus.NetConn(wlan_print_ip.value);
      conn.writeMultiBytes(printData);

    });

  }

  Widget menuData(orderprintData){
    return LabelConstrainedBox(
        Padding(
          padding: const EdgeInsets.only(
            //left: 5,
            top: 2,
            //right: 5,
          ),
          child: Container(

            child: Column(
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [

                Container(
                  decoration: BoxDecoration(
                    //color: Colors.red,
                    border: Border(
                      bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:MainAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(400),
                              minHeight: ScreenAdapter.height(30),
                              maxHeight: ScreenAdapter.height(75),
                            ),
                            child: AutoSizeText(
                              "${orderprintData["printTitleText"]}",
                              style: GoogleFonts.zenKakuGothicAntique(fontSize: ScreenAdapter.fontSize(32),fontWeight: FontWeight.w500),
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                          )
                      ),
                    ],
                  ),
                ),

                Expanded(
                    child: Row(
                      mainAxisAlignment:MainAxisAlignment.start,
                      textDirection: TextDirection.ltr,
                      children: [
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Expanded(child: Container(
                              /*constraints: BoxConstraints(
                            minWidth: ScreenAdapter.width(20),
                            maxWidth: ScreenAdapter.width(400),
                            minHeight: ScreenAdapter.height(30),
                            maxHeight: ScreenAdapter.height(210),
                          ),*/
                              child: Text(
                                orderprintData["printText"],
                                style: GoogleFonts.zenKakuGothicAntique(fontSize: ScreenAdapter.fontSize(26),fontWeight: FontWeight.w500),
                                maxLines: 4,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                            )
                        ),
                      ],
                    )
                ),

              ],
            ),
          ),
        )
    );
    /*return LabelConstrainedBox(
        Padding(
          padding: const EdgeInsets.only(
            //left: 5,
            top: 5,
            //right: 5,
          ),
          child: Container(

            child: Column(
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [

                Container(
                  decoration: BoxDecoration(
                    //color: Colors.red,
                    border: Border(
                      bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 2.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:MainAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(400),
                              minHeight: ScreenAdapter.height(30),
                              maxHeight: ScreenAdapter.height(70),
                            ),
                            child: AutoSizeText(
                              "${orderprintData["printTitleText"]}",
                              style: GoogleFonts.zenKakuGothicAntique(fontSize: ScreenAdapter.fontSize(32),fontWeight: FontWeight.w500),
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                          )
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment:MainAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: ScreenAdapter.width(20),
                            maxWidth: ScreenAdapter.width(400),
                            minHeight: ScreenAdapter.height(30),
                            maxHeight: ScreenAdapter.height(210),
                          ),
                          child: AutoSizeText(
                            orderprintData["printText"],
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: ScreenAdapter.fontSize(26),fontWeight: FontWeight.w500),
                            maxLines: 4,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                        )
                    ),
                  ],
                ),

              ],
            ),
          ),
        )
    );*/
  }

  _tpPrintReceipt(printData) async {
    List<Widget> categoryMenus = [];
    var menuVos = printData["details"];
    var lineHight = 580;
    var lineZeng = 0;
    int addRowHight = 0;

    //店铺标题
    /*categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["shopName"]}",
              style: GoogleFonts.zenKakuGothicAntique(fontSize: 34,fontWeight: FontWeight.w400,color: Colors.black87),

            )),
      ),
    );*/

    //日期 地址 电话
    //地址
    // 计算菜品标题长度
    var newAddress = printData["address"].replaceAll("%%", "\n");
    var addressLength = printData["address"].length;//print(printData["address"]);//print(newAddress);
    var addressLine = addressLength / 15;
    var addressRowNum = 0;
    addressRowNum = addressLine.ceil();
    addRowHight += addressRowNum*33+(addressRowNum-1)*10;
    categoryMenus.add(_publicOneColumnTxtNew("${newAddress}", 26.0, FontWeight.w300));

    categoryMenus.add(SizedBox(height: 5,));
    //登录番号
    if(printData["ntaNo"] != null && printData["ntaNo"] != ""){
      addRowHight += 38;
      categoryMenus.add(_publicOneColumnTxtNew(
          "登録番号:${printData["ntaNo"]}", 26.0, FontWeight.w300));
      categoryMenus.add(SizedBox(height: 5,));
    }
    categoryMenus.add(Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text("${printData["orderDate"]}",
            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),
          )),
    ));
    if (machineMode.value == "1" || machineMode.value == "3") {
      addRowHight += 38;
      categoryMenus.add(_publicOneColumnTxtNew("${printData["numberTip"]}${printData["serialNumber"]}", 26.0, FontWeight.w300));
    }
    //注文番号
    categoryMenus.add(_publicOneColumnTxtNew(
        "注文番号:${printData["order"]}", 26.0, FontWeight.w300));
    /*categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  width: ScreenAdapter.width(160),
                  child: Expanded(
                    child: Text("${printData["orderDate"]}",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000"))),
                  ),
                )),
            Expanded(child: Column(
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("${printData["shopAddress"]}",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000")))),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("登録番号 T12356757656",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000")))),
              ],
            )),
          ],
        ),
      ),
    );*/
    //领収书标题
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              padding: EdgeInsets.only(top: ScreenAdapter.height(5.0),bottom: ScreenAdapter.height(5.0),left:ScreenAdapter.width(20.0),right:ScreenAdapter.width(20.0)),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  left: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  right: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                ),
              ),
              child: Text("領 収 書",
                style: GoogleFonts.zenKakuGothicAntique(fontSize: 50,color: Colors.black,),

              ),
            )),
      ),
    );


    int categoryNum = menuVos.length;
    int linNum = 0;
    for (var i = 0; i < menuVos.length; i++) {

      var lineVosList = menuVos[i];

      // 计算菜品标题长度
      var groupNameLength = lineVosList["menuName"].length;
      var menuLine = groupNameLength / 10;
      var menuRowNum = menuLine.ceil();
      //linNum+=menuRowNum;
      var takeoutTag = (printData["takeOut"] == true) ? "*":"";
      if(groupNameLength>10){
        linNum+=2;
        addRowHight += 76;
        categoryMenus.add(
          Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: 76,
                //margin: EdgeInsets.only(bottom: 3),
                child: Column(
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Expanded(
                              child: Text("${lineVosList["menuName"]}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                              ),
                            )
                        ),
                        (printData["takeOut"] == true) ? Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text("${takeoutTag}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                            )
                        ):Container(width: 0,),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              width: ScreenAdapter.width(30),
                              alignment: Alignment.centerRight,
                              child: Text("${lineVosList["menuQty"]}",
                                style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                              ),
                            )
                        ),
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              width: ScreenAdapter.width(105),
                              alignment: Alignment.centerRight,
                              child: Text("￥${formatMoney(lineVosList["price"])}",
                                style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                              ),
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        );
      }else{
        addRowHight += 33;
        linNum+=1;
        categoryMenus.add(
          Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: 33,
                //margin: EdgeInsets.only(bottom: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(
                          child: Text("${lineVosList["menuName"]}${takeoutTag}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        )
                    ),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          width: ScreenAdapter.width(30),
                          alignment: Alignment.centerRight,
                          child: Text("${lineVosList["menuQty"]}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        )
                    ),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          width: ScreenAdapter.width(105),
                          alignment: Alignment.centerRight,
                          child: Text("￥${formatMoney(lineVosList["price"])}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        )
                    ),
                  ],
                ),
              )),
        );
      }


    }
    //print("总行数${menuNum}");
    //addRowHight += 33 * linNum;
    categoryMenus.add(SizedBox(height: 10,));
//合计
    categoryMenus.add(
      Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            margin: EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Expanded(
                      child: Text("合計",
                        style: GoogleFonts.zenKakuGothicAntique(fontSize: 28,fontWeight: FontWeight.w300,color: Colors.black87),

                      ),
                    )
                ),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Container(
                      width: ScreenAdapter.width(130),
                      alignment: Alignment.centerRight,
                      child: Text("￥${formatMoney(printData["price"])}",
                        style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                      ),
                    )
                ),
              ],
            ),
          )),
    );

    categoryMenus.add(
      _publicSplitLine(),
    );

    //8%
    categoryMenus.add(
      _publicTwoColumnsTxtNew(
          "8%対象",
          24.0,
          FontWeight.w100,
          (printData["takeOut"] == true) ? "${formatMoney(printData["price"])}" : "0",
          24.0,
          FontWeight.w100,
          true),
    );
    //内消费税
    categoryMenus.add(
      _publicTwoColumnsTxtNew(
          "　  (内    消費税",
          24.0,
          FontWeight.w100,
          (printData["takeOut"] == true) ? "${formatMoney(printData["tax"])})" : "0)",
          24.0,
          FontWeight.w100,
          true),
    );

    //10%
    categoryMenus.add(
      _publicTwoColumnsTxtNew(
          "10%対象",
          24.0,
          FontWeight.w100,
          (printData["takeOut"] == false) ? "${formatMoney(printData["price"])}" : "0",
          24.0,
          FontWeight.w100,
          true),
    );
    //内消费税
    categoryMenus.add(
      _publicTwoColumnsTxtNew(
          "　  (内    消費税",
          24.0,
          FontWeight.w100,
          (printData["takeOut"] == false) ? "${formatMoney(printData["tax"])})" : "0)",
          24.0,
          FontWeight.w100,
          true),
    );


    categoryMenus.add(
      _publicSplitLine(),
    );
    if(printData["payMethod"] != "現金支払"){
      lineZeng += 33;
      categoryMenus.add(
        _publicTwoColumnsTxtNew(printData["payMethod"], 26.0, FontWeight.w200,
            "${formatMoney(printData["payPrice"])}", 26.0, FontWeight.w200, true),
      );
    }

    if (printData["memberNo"] != null && printData["memberNo"] != "") {
      lineZeng += 76;
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("カード番号", 26.0, FontWeight.w200,
            printData["memberNo"], 26.0, FontWeight.w100, false),
      );
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("日期", 26.0, FontWeight.w200, printData["payDate"],
            26.0, FontWeight.w100, false),
      );
      categoryMenus.add(_publicSplitLine());
    }
    if (printData["serialNo"] != null && printData["serialNo"] != "") {
      lineZeng += 76;
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("カード取引通番", 26.0, FontWeight.w200,
            printData["serialNo"], 26.0, FontWeight.w100, false),
      );
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("取引日時", 26.0, FontWeight.w200, printData["payDate"],
            26.0, FontWeight.w100, false),
      );
      categoryMenus.add(_publicSplitLine());
    }

    //轻减税率对象
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: Expanded(
                  child: Container(
                    width: ScreenAdapter.width(180),
                    child: Text("*軽減税率対象",
                      style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                    ),
                  ),
                )
            ),
            Expanded(child: Column(
              children: [
                if(printData["payMethod"] == "現金支払")
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("お預り",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                          Text("￥${formatMoney(printData["payPrice"])}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        ],
                      )),
                if(printData["payMethod"] == "現金支払" && printData["change"] !=null)
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("お釣",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                          Text("￥${formatMoney(printData["change"])}",
                            style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                          ),
                        ],
                      )),
              ],
            )),
          ],
        ),
      ),
    );

    //お明細は上記のとおりです。
    categoryMenus.add(_publicOneColumnTxtNew("お明細は上記のとおりです。", 26.0, FontWeight.w300));

    var totalHight = lineZeng + lineHight+addRowHight;

    ByteData byteData = await WidgetToImage.widgetToImage(Container(
      width: 385,
      padding: EdgeInsets.only(left: ScreenAdapter.width(2),right: ScreenAdapter.width(2)),
      height: totalHight.toDouble(),
      color: Colors.white,
      //alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: categoryMenus,
      ),
    ),
        size: Size(385, totalHight.toDouble())
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //Future.delayed(Duration(milliseconds: 200), () async {
    String base64Image = base64Encode(imageBytes);
    await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "1",printLogoImage.value);
    Future.delayed(Duration(milliseconds: 300), () async {
      await FlutterPluginMsprinter.sendPrintCut("1");
    });
    //});

  }


  //单列文字
  _publicOneColumnTxtNew(txtContext, txtFontSize, txtFontWeight) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                  child: Text("${txtContext}",
                    style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),
                  )
              ),
            ],
          )),
    );
  }

  //两列文字
  _publicTwoColumnsTxtNew(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight, isMoney) {

    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Text("${leftTxtContext}",
                      style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                    ),
                  )),
              (isMoney == true)
                  ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    width: ScreenAdapter.width(120),
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(
                          text: "￥",
                          style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),
                          children: [
                            TextSpan(
                              text: "${rightTxtContext}",
                              style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                            ),
                          ]),
                    ),
                  ))
                  : Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    width: ScreenAdapter.width(120),
                    alignment: Alignment.centerRight,
                    child: Text("${rightTxtContext}",
                      style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                    ),
                  )),
            ],
          ),
        ));
  }

  _publicTwoColumnsTxtNewLine(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight, isMoney) {

    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("${leftTxtContext}",
                    style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                  )),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Container(
                      width: ScreenAdapter.width(120),
                      alignment: Alignment.centerRight,
                      child: Text("${rightTxtContext}",
                        style: GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                      ),
                    ),
                  )),
            ],
          ),
        ));
  }
  //商品双列
  _publicGoodsTwoColumnsTxt(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Text("${leftTxtContext}",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: leftTxtFontSize,
                          fontWeight: leftTxtFontWeight,
                          fontFamily: 'ZenKakuGothicAntique',
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  )),
              //Expanded(child: Container()),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("${rightTxtContext}",
                      style: TextStyle(
                        fontSize: rightTxtFontSize,
                        fontWeight: rightTxtFontWeight,
                        fontFamily: 'ZenKakuGothicAntique',
                        color: ColorsUtil.hexToColor("#000000"),
                        //fontWeight: FontWeight.w600
                      ))),
            ],
          ),
        ));
  }
  //分割线
  _publicSplitLine() {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          height: 0.5,
          color: ColorsUtil.hexToColor("#000000"),
          width: 375,
        ));
  }


  showCashAlert(){print("现金取消");
    Future.delayed(Duration(milliseconds: 50),() async {
      Get.dialog(
          DialogUtils.alert(GString.getToString(checkLanguage.value, "settlement_back_alertcontent"),
              title: GString.getToString(checkLanguage.value, "tag_title"),
              canceltitle: GString.getToString(checkLanguage.value, "tag_button_no"),
              confirmtitle: GString.getToString(checkLanguage.value, "tag_button_yes"),
              confirm: () {
                Get.back();
                showBackEasyLoading();
                CancelOrder();
              },
              cancle: () {
                allowClick.value = true;
                Get.back();
              }),
          barrierDismissible: false
      );

    });
  }


}