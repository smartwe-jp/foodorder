import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_extension.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_ui_extension.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/string.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../plugins/cash_changer/lib/cash_changer.dart';
import '../../../plugins/flutter_plugin_msprinter/lib/flutter_plugin_msprinter.dart';
import '../../../plugins/paycube/lib/paycube.dart';
import '../../../routes/app_pages.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/cashMoneyParser.dart';
import '../../../services/logUtil.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../../OrderHome/controllers/order_home_controller.dart';
import '../../SelfCheckoutscanningcode/controllers/self_checkoutscanningcode_controller.dart';
import '../../menuPage/controllers/menu_page_controller.dart';

class SettlementController extends GetxController with StateMixin {
  //TODO: Implement SettlementController
  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());
  CreatePrintImageController createPrintImageController =
      Get.put(CreatePrintImageController());

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  RxString machineCode = "".obs;

  //默认语言包选择
  RxString checkLanguage = "JP".obs;

  RxString is_query_receipt = "1".obs; //1 要领収书  2 不要领収书
  RxString is_allow_receipt = "1".obs; //1 必须打印  2 不必须
  RxString is_allow_receipt_menu = "1".obs; //1 必须打印  2 不要
  RxString receiptPrintType = "2".obs; //1 打印  2 不打印
  RxString print_paper_txt_size = "1".obs; //1普通　2大　3特大
  RxString is_back_home = "0".obs; //0 返回home  1 返回菜单
  RxString machineMode = "1".obs; //机器类型 1普通券卖机 2精算机
  RxString is_allow_oneyen = "0".obs; //0 禁用  1 允许

  RxString orderId = "".obs;
  RxString scanQrCode = "".obs;
  RxString totalPrice = "0".obs;
  RxString getPutMoney = "0".obs; //投币金额
  RxString getPutMoneyCurrency = "".obs; //投币金额币种
  RxString showOutMoney = "0".obs; //展示应出金金额
  RxBool allowClick = true.obs;
  RxBool isReportCash = false.obs; //是否已汇报过现金
  RxBool get801Flag = false.obs; //是否已获取801

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

  RxBool showPrintButton = false.obs; //如果投币金额不足，则不显示打印按钮

  RxString isAllowPos = "0".obs;
  RxString pos_ip = "".obs;
  RxString pos_port = "".obs;
  RxString eventReportString = "".obs;
  RxString payment_method_num = "0".obs; //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc
  RxMap posResultReportData = {}.obs;
  RxInt showPrintType = 0.obs; //0 receipt   1Lable
  RxString wlan_print_ip = "".obs;
  RxString wlan_print_port = "".obs;
  RxString is_allow_wlanPrint_continuous =
      "0".obs; //0 单票  1 连票  Print Continuous
  RxString wlan_print_ip_two = "".obs;
  RxString wlan_print_port_two = "".obs;
  RxString is_allow_wlanPrint_Two_continuous =
      "0".obs; //0 单票  1 连票  Print Continuous

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
  RxBool showDiscover = false.obs;

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

  int timeOffset = 0;
  bool posTest = false;

  @override
  void onInit() {
    readyQueryData();
    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
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
    if (Platform.isAndroid) {
      Paycube.stopListening();
    } else {
      CashChanger.removeEventsListener();
    }

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

  readyQueryData() {
    checkLanguage.value = Get.arguments['checkLanguage'];
    machineCode.value = Get.arguments['machineCode'];
    orderId.value = Get.arguments['orderId'];
    //this._machineMode = widget.arguments['machineMode'];
    totalPrice.value = Get.arguments['totalPrice'];
    isAllowPos.value = Get.arguments['isAllowPos'];
    receiptPrintType.value = Get.arguments['receiptPrintType'];
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
    showmPay.value = Get.arguments['showmPay'];
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
    showDiscover.value = Get.arguments["showDiscover"];
    showOpenPayment.value = Get.arguments['showOpenPayment'];

    //0 1适用之前旧版本，可适用现金机，同时也可以扫码  2只可扫码，不在打开现金机 3、4只支持刷卡，不在打开现金机
    if (payment_method_num.value == "0" || payment_method_num.value == "1") {
      //打开现金机
      if (Platform.isAndroid) {
        _countDownTimer("1");
        Starttoubi();
      } else {
        CashChanger.setEventsListener();
        startDeposit();
      }
    } /*else if (payment_method_num.value == "2") {
    //检测是否需要连接socket
    checkpayconnectSocker();
  }*/
    else if (payment_method_num.value == "3" ||
        payment_method_num.value == "4" ||
        payment_method_num.value == "5" ||
        payment_method_num.value == "6" ||
        payment_method_num.value == "7" ||
        payment_method_num.value == "8" ||
        payment_method_num.value == "9" ||
        payment_method_num.value == "10") {
      //1链接socker 2 请求接口获得支付数据发送给pos机 3监听
      if (pos_ip.value != "" && pos_port.value != "") {
        showEasyLoading();
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
    showPrintType.value =
        int.parse(systemSettingInfo['showPrintType']); //0 receipt   1Lable
    is_allow_oneyen.value = systemSettingInfo['isAllowOneYen'];

    if (systemSettingInfo['isAllowWlanPrint'] == "1") {
      is_allow_wlanPrint_continuous.value =
          systemSettingInfo['isAllowWlanPrintContinuous'];
      Map wlanPrintSettingInfo = await HomeServices.getWlanPrintSettingInfo();
      if (wlanPrintSettingInfo['wlanPrintIp'] != null &&
          wlanPrintSettingInfo['wlanPrintIp'] != "" &&
          wlanPrintSettingInfo['wlanPrintPort'] != null &&
          wlanPrintSettingInfo['wlanPrintPort'] != "") {
        wlan_print_ip.value = wlanPrintSettingInfo['wlanPrintIp'];
        wlan_print_port.value = wlanPrintSettingInfo['wlanPrintPort'];
      }
    }

    if (systemSettingInfo['isAllowWlanPrintTwo'] == "1") {
      is_allow_wlanPrint_Two_continuous.value =
          systemSettingInfo['isAllowWlanPrintTwoContinuous'];
      Map wlanPrintSettingTwoInfo =
          await HomeServices.getWlanPrintSettingTwoInfo();
      if (wlanPrintSettingTwoInfo['wlanPrintIp'] != null &&
          wlanPrintSettingTwoInfo['wlanPrintIp'] != "" &&
          wlanPrintSettingTwoInfo['wlanPrintPort'] != null &&
          wlanPrintSettingTwoInfo['wlanPrintPort'] != "") {
        wlan_print_ip_two.value = wlanPrintSettingTwoInfo['wlanPrintIp'];
        wlan_print_port_two.value = wlanPrintSettingTwoInfo['wlanPrintPort'];
      }
    }

    change(null, status: RxStatus.success());
  }

  /////////////////////////////////*********************************//////////////////////////////////////
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
          goToNewMyHome();
        }
      }
    });
  }

  gotonewMenuPage() {
    if (isPayConfirmOrderId.value == true) {
      if (payment_method_num.value == "0" || payment_method_num.value == "1") {
        if (machineMode.value == "2") {
          //精算时候请求
          //print("精算请求了new order id");
          Get.find<CheckoutPageController>().postNewOrderId(orderIdIfTakeOut: orderId.value);
        }else if(machineMode.value == "3"){
          //print("自助精算请求了new order id");
          Get.find<SelfCheckoutscanningcodeController>().postNewOrderId();
        } else {
          //print("普通支付请求了new order id");
          Get.find<MenuPageController>().postNewOrderId();
        }
      }
    }
    EasyLoading.dismiss();
    Get.back();
  }

  goToNewMyHome() {
    ordersqlcontroller.removeAllFromCart();

    EasyLoading.dismiss();
    Get.back();
    if (machineMode.value == "2") {
      Get.delete<CheckoutPageController>(); // 手动删除控制器实例
      //精算页面
      Future.delayed(Duration(milliseconds: 100), () {
        Get.toNamed("/checkout-page");
      });
      //Navigator.pushNamed(context, '/checkOutPage');
    } else if (machineMode.value == "3") {
      Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例
      Get.toNamed("/selfservice-page");
      //Navigator.pushNamed(context, '/selfServiceHomePage');
    } else {
      print("过来删除menu了");
      Get.delete<MenuPageController>(); // 手动删除控制器实例
      Get.toNamed("/entry-home");
      //Navigator.pushNamed(context, '/home');
    }
  }

  gotonewBack() {
    ordersqlcontroller.removeAllFromCart();
    EasyLoading.dismiss();
    Get.back();
    if (machineMode.value == "1") {
      if (is_back_home.value == "0") {
        Get.delete<MenuPageController>(); // 手动删除控制器实例
        Get.toNamed("/entry-home");
        //Navigator.pushNamed(context, '/home');
      } else {
        // eventBus.fire(new clearCartEvent('支付成功...'));
        //有弹窗选择支付才在关闭一个
        Get.find<MenuPageController>().getCartPriceTotal();
        if(showOpenPayment.value == true){
          Get.back();
        }
      }

    }else if (machineMode.value == "3") {
      Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例
      Get.toNamed("/selfservice-page");
      // if(is_back_home.value == "0"){
      //   Get.delete<SelfCheckoutscanningcodeController>(); // 手动删除控制器实例
      //   Get.toNamed("/selfservice-page");
      //   //Navigator.pushNamed(context, '/selfServiceHomePage');
      // }else{
      //   //eventBus.fire(new clearCartEvent('支付成功...'));
      //
      //   //有弹窗选择支付才在关闭一个
      //   if(showOpenPayment.value == true){
      //     Get.back();
      //   }
      //
      // }

    } else {
      Get.delete<CheckoutPageController>();// 手动删除控制器实例
      //精算页面
      Future.delayed(Duration(milliseconds: 100), () {
        Get.toNamed("/checkout-page");
      });
      //Navigator.pushNamed(context, '/checkOutPage');
    }
  }

  //扫码支付T
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
    if (machineCode.value != "" &&
        scanQrCodeController.text != "" &&
        orderId.value != null) {
      //_showEasyLoading();
      showEasyLoadingScan();
      var formData = {
        "auth_code": scanQrCodeController.text,
        "machineCode": machineCode.value,
        "orderId": orderId.value,
        "payType": "",
      }; //print(formData);
      request('webBootToPayv2', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200 && response['data'].isNotEmpty) {
          var resultData = response['data'];
          LogUtil.d(resultData);
          if (resultData["requestInfo"] != "") {
            EasyLoading.dismiss();
            if (resultData["exceptionMessage"] == "") {
              showPosEasyLoading();
              posResultReportData.value = response['data'];
              //检测是否需要连接socket
              checkpayconnectSocker(questData: resultData["requestInfo"]);
            } else {
              _showScanCodeNoOpenDialog(3, resultData["exceptionMessage"]);
            }
          } else {
            if (resultData["result"] == true) {
              doPrintOrderMenu(receiptPrintType.value);
            } else {
              _showScanCodeNoOpenDialog(3, resultData["exceptionMessage"]);
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
  _showScanCodeNoOpenDialog(checknum, showContent, {payType: "qr"}) {
    EasyLoading.dismiss();
    scanQrCodeController.text = "";
    //_scanQrCode = "";
    //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode); // 获取焦点
    scanQrCodeFocusNode.requestFocus();

    var showDialogContent;

    if (checknum == 1) {
      showDialogContent = GString.getToString(
          checkLanguage.value, "settlement_scancodenoopen_error");
    } else if (checknum == 2) {
      showDialogContent = GString.getToString(
          checkLanguage.value, "settlement_scancodenochange_error");
    } else if (checknum == 3) {
      if (showContent != null && showContent != "") {
        showDialogContent = showContent;
      } else {
        showDialogContent = GString.getToString(
            checkLanguage.value, "settlement_nopayment_error");
      }
    }
    //支付状态

    Get.dialog(DialogUtils.alertOneButton(showDialogContent,
        title: GString.getToString(checkLanguage.value, "tag_title"),
        confirmtitle:
            GString.getToString(checkLanguage.value, "tag_button_yes"),
        confirm: () {
      Get.back();
      if (payType == "pos") {
        Get.back();
      }
    }));
  }

  //扫码后超时，再继续请求后台，5秒一次 60次
  _doScanCodeTimeOut() {
    int queryCount = 0;
    ScanCodeConfirmTimer?.cancel();
    ScanCodeConfirmTimer = Timer.periodic(Duration(milliseconds: 5000),
        (Timer confirmTimer) async {
      queryCount++;
      if (queryCount > 60) {
        //退出关闭
        confirmTimer.cancel();
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
          confirmTimer.cancel();
          doPrintOrderMenu(receiptPrintType.value);
        }
      });
    });
  }

  doScanCodeTimeOutLastQuery() {
    var formData = {
      "orderId": orderId.value,
    };
    request('webBootLinePayConfirm', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu(receiptPrintType.value);
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

    var showDialogContent =
        GString.getToString(checkLanguage.value, "settlement_nopayment_error");

    Get.dialog(DialogUtils.alertOneButton(showDialogContent,
        title: GString.getToString(checkLanguage.value, "tag_title"),
        confirmtitle:
            GString.getToString(checkLanguage.value, "tag_button_yes"),
        confirm: () {
      Get.back();
    }));
  }

  //pos机相关
  checkpayconnectSocker({questData = ""}) async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();
    var showCreditCard = systemSettingInfo['showCreditCard'];
    if (showCreditCard == true) {
      Map posSettingInfo = await HomeServices.getPosSettingInfo();

      if (posSettingInfo.isNotEmpty) {
        pos_ip.value = posSettingInfo['posIp'];
        pos_port.value = posSettingInfo['posPort'];
        if (pos_ip.value != "" && pos_port.value != "") {
          payconnectSocker(questData: questData);
        }
      }
    }
  }

  //pos机相关
  payconnectSocker({questData = ""}) async {
    //判断socket请求次数
    socketNumberTimes.value++;
    if (socketNumberTimes.value > 20) {
      _showScanCodeNoOpenDialog(
          3,
          GString.getToString(
              checkLanguage.value, "settlement_posPay_connect_error"),
          payType: "pos");
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
      if (questData != "") {
        //判断不为空则POS机
        this._socket?.write(questData);
      }

      //获得pos数据并发送
      var paymentMethod = ["3", "4", "5", "6", "7", "8", "9", "10"];
      if (paymentMethod.contains(payment_method_num.value) == true) {
        _getPaymentPosData();
      }

      //扫码后直接打完票后关闭
      if (payment_method_num.value != "2") {
        print("进来关闭弹窗");
        Future.delayed(Duration(milliseconds: 1300), () async {
          EasyLoading.dismiss();
        });
      }

      // 监听wifi模块发送的数据
      this._socket?.listen(
        (List<int> event) {
          //LogUtil.d(event);
          //if (event.length > 40) event.fillRange(266, 289, 32);
          for (var i = 0; i < event.length; i++) {
            if (event[i] > 127) {
              event[i] = 32;
              //print(i);
            }
          }
          var zhuanhuan = Uint8List.fromList(event);
          var eventString = Utf8Codec().decode(zhuanhuan);
          eventReportString.value += eventString;
          LogUtil.d(eventReportString.value);
          //print(Utf8Codec().decode(zhuanhuan));
          //print("event=====${eventString}=====");
          String FirstString = eventReportString.value.substring(0, 1);
          String SecondString = eventReportString.value.substring(1, 3);
          String transactionType = eventReportString.value.substring(3, 6);
          String resultString = eventReportString.value.substring(10, 13);
          String resultMPFSString = eventReportString.value.substring(13, 16);
          //
          print("FirstString==${FirstString}");
          print("SecondString==${SecondString}");
          print("transaction_type==${transactionType}");
          print("resultString==${resultString}");
          print("resultMPFSString==${resultMPFSString}");
          print(eventReportString.value.length);

          if (posTest) {
            //测试代码 发版时posTest必需为false
            String errorString = eventReportString.value.substring(130, 133);
            print("errorString==${errorString}");
            if (errorString == "801") {
              if (get801Flag.value == false) {
                LogUtil.d("Get 801 Send 491");
                get801Flag.value = true;
                showCheckLoading();
                this._socket?.write(create491Message());
              } else {
                EasyLoading.dismiss();
                _showScanCodeNoOpenDialog(
                    3,
                    GString.getToString(checkLanguage.value,
                        "settlement_posPay_error_connect_worker"),
                    payType: "pos");
              }

              return;
            } else if (errorString == "803" || errorString == "802") {
              Get.dialog(DialogUtils.alertOneButton(
                  "取引が不明な状態で終了しました（コード${errorString}）。端末の指示に従って操作してください。",
                  title: GString.getToString(checkLanguage.value, "tag_title"),
                  confirmtitle: GString.getToString(
                      checkLanguage.value, "tag_button_yes"), confirm: () {
                Get.back();
              }));
              return;
            }
          }

          //支付成功 打印，返回首页 除了成功都取消
          if (transactionType == "900") {
            if (FirstString == "3" &&
                SecondString == "11" &&
                resultString == "000" &&
                eventReportString.value.length == 40) {
              print("进来取消了");
              CancelOrder();
              //showEasyLoading();
            } else if (resultString.trim() != "000") {
              //T10 交通系等待时间超过30-40后自动返回
              //06 需要密码但是不输入密码直接点击屏幕返回  需要弹框文字
              var posErrorCode = ["L06"];
              if (posErrorCode.contains(resultString) == true) {
                showPosCancelEasyLoading(resultString,
                    resultPFSString: resultMPFSString);
              }
            }
          } else if ((transactionType == "600" || transactionType == "601") &&
              eventReportString.value.length > 4800) {
            //print("eventReportString.value.length==${eventReportString.value.length}");
            if (FirstString == "3" &&
                SecondString == "11" &&
                resultString == "000" &&
                resultMPFSString == "000") {
              // &&  resultMPFSString == "000"
              //除了扫码的才显示
              if (payment_method_num.value != "2") {
                showEasyLoading();
              }

              var thincaCloud = ["5", "6", "7", "8", "9", "10"];
              if (thincaCloud.contains(payment_method_num.value) == true) {
                String reportString = eventString.substring(0, 169);
                CreditCardPayReport(reportString);
              } else {
                CreditCardPayReport(eventReportString.value);
              }
            } else {
              if (resultString.trim() != "") {
                showPosCancelEasyLoading(resultString,
                    resultPFSString: resultMPFSString);
                //T10 交通系等待时间超过30-40后自动返回
                /*var posErrorCode = ["L11","T10"];
              if (posErrorCode.contains(resultString) == true) {
                Future.delayed(Duration(milliseconds: 2500),() async {
                //CancelOrder();
                gotonewMenuPage();
                });
              }else{// if(resultString == "T10")

                showPosCancelEasyLoading(resultString,resultPFSString:resultMPFSString);
              }*/
            }
          }
        } else if (transactionType != "900" &&transactionType != "600" && transactionType != "601") {
          //除了扫码的才显示
          if(payment_method_num.value != "2"){
            showPosEasyLoading();
          }
          if (FirstString == "3" && SecondString == "11" && resultString == "000" &&  resultMPFSString == "000") {// &&  resultMPFSString == "000"
            var thincaCloud = ["5","6","7","8","9","10"];
            if (thincaCloud.contains(payment_method_num.value) == true) {
              String reportString = eventString.substring(0, 169);
              CreditCardPayReport(reportString);
            }else{
              CreditCardPayReport(eventString);
            }

          } else {
            if(resultString.trim() != ""){
              debugPrint("---Recorde error to firebase old---");
              var reportData = "${orderId.value}:${machineCode.value}";
              var errorString = "None";
              if (eventReportString.value.length > 133) {
                errorString = eventReportString.value.substring(130, 133);
              }
              // FirebaseAnalytics.instance.logEvent(name: "pos_charge_error_old",parameters: {
              //   "reportInfo":reportData,
              //   "FirstString":FirstString,
              //   "SecondString":SecondString,
              //   "transactionType":transactionType,
              //   "resultString":resultString,
              //   "resultMPFSString":resultMPFSString,
              //   "errorString":errorString,
              // });
              //T10 交通系等待时间超过30-40后自动返回
              var posErrorCode = ["L11","T10"];
              if (posErrorCode.contains(resultString) == true) {
                Future.delayed(Duration(milliseconds: 2500),() async {print("来这里取消了么");
                //CancelOrder();
                gotonewMenuPage();
                });
              }else{// if(resultString == "T10")
                showPosCancelEasyLoading(resultString,resultPFSString:resultMPFSString);
              }
            }
          }
        }
        else {
          debugPrint("---Recorde error to firebase---");
          var reportData = "${orderId.value}:${machineCode.value}";
          var errorString = "None";
          if (eventReportString.value.length > 133) {
            errorString = eventReportString.value.substring(130, 133);
          }
          // FirebaseAnalytics.instance.logEvent(name: "pos_charge_error",parameters: {
          //   "reportInfo":reportData,
          //   "FirstString":FirstString,
          //   "SecondString":SecondString,
          //   "transactionType":transactionType,
          //   "resultString":resultString,
          //   "resultMPFSString":resultMPFSString,
          //   "errorString":errorString,
          // });
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
        payconnectSocker(questData: questData);
      });
      //_showScanCodeNoOpenDialog(3,GString.getToString(checkLanguage.value, "settlement_posPay_connect_error"),payType: "pos");
    });
  }

  _getPaymentPosData() {
    var payTypeData = {
      //"3":"CreditCard",
      //"4":"CreditCard",
      "5": "Edy",
      "6": "iD",
      "7": "nanaco",
      "8": "WAON",
      "9": "QUICPay",
      "10": "IC",
    };
    var thincaCloud = ["5", "6", "7", "8", "9", "10"];
    String? _payType = "";
    if (thincaCloud.contains(payment_method_num.value) == true) {
      _payType = payTypeData[payment_method_num.value];
    }

    var formData = {
      "auth_code": "0000000088888888",
      "machineCode": machineCode.value,
      "orderId": orderId.value,
      "payType": _payType,
    };
    request('webBootToPayv2', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      //print("发送pos请求");LogUtil.d(response);
      if (response['code'] == 200 && response['data'].isNotEmpty) {
        var resultData = response['data'];
        if (resultData["requestInfo"] != null &&
            resultData["requestInfo"] != "") {
          if (resultData["exceptionMessage"] != null &&
              resultData["exceptionMessage"] == "") {
            //EasyLoading.dismiss();
            print("刷卡到这里了么？");
            //showPosEasyLoading();

            posResultReportData.value = response['data'];
            //判断不为空则POS机
            this._socket?.write(resultData["requestInfo"]);
          } else {
            _showScanCodeNoOpenDialog(3, resultData["exceptionMessage"]);
          }
        } else {
          _showScanCodeNoOpenDialog(3, resultData["exceptionMessage"]);
        }
      } else {
        _showScanCodeNoOpenDialog(
            3,
            GString.getToString(
                checkLanguage.value, "settlement_scancodenochange_error"));
      }
    });
  }

  showPosCancelAlert() {
    if (socketPosCancel.value == true) return;

    Future.delayed(Duration(milliseconds: 50), () async {
      Get.dialog(
          DialogUtils.alert(
              GString.getToString(
                  checkLanguage.value, "settlement_back_alertcontent"),
              title: GString.getToString(checkLanguage.value, "tag_title"),
              canceltitle:
                  GString.getToString(checkLanguage.value, "tag_button_no"),
              confirmtitle:
                  GString.getToString(checkLanguage.value, "tag_button_yes"),
              confirm: () {
            Get.back();
            socketPosCancel.value = true;
            getPaymentCancelPosData();
          }, cancle: () {
            Get.back();
          }),
          barrierDismissible: false);
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
      var response = json.decode(val.toString()); //print("发送取消请求");
      LogUtil.d(response);
      if (response['code'] == 200) {
        //var _queryString =       "2101500001       00509                  000000120221114093225";
        this._socket?.write(response['data']);
      }
    });
  }

//刷卡机nfc支付汇报
  CreditCardPayReport(eventString) {

    posResultReportData.value["result"] = true;
    posResultReportData.value["paymentInfo"] =
        eventString; //LogUtil.d("huibaohhhhhh===${_posResultReportData}");
    request('webBootPosPayReport',
            method: 'POST', parameters: posResultReportData.value)
        .then((val) {
      var response = json.decode(val.toString()); //print(response);

      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu(receiptPrintType.value);
      } else {
        //扫码后超时，再继续请求后台，1秒一次 20次
        //_doScanCodeTimeOut();
        showPosCancelEasyLoading("900");
      }
    });
  }

  CancelOrder() async {
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
      if (Platform.isWindows) {
        await endDeposit();
      } else {
        Endtoubi();
      }
        
      } else {
        isPrint.value = false;
        totalPrice.value = "0";
        getPutMoney.value = "0";
        showPrintButton.value = false;
        //如果现金机投币大于0后取消，则直接关机出金
        if (Platform.isWindows) {
          await endDeposit();
        } else {
          Endtoubi();
        }
      }
    } else {
      //返回上一级菜单页面
      gotonewMenuPage();
    }
  }

  getCurrentTime() {
    int milliseconds = DateTime.now().millisecondsSinceEpoch;

    DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

    String formatted = formatter.format(date);

    return formatted;
  }

  //去打印小票
  doPrintOrderMenu(printType,{retry = true}) async {
    debugPrint("doPrintOrderMenu");
    //判断全局设置是否强制打印小票
    if (is_allow_receipt.value == "1") {
      printType = "1";
    }

    //判断是否允许打印小票
    var printStatus = "0";
    if (Platform.isWindows) {
      printStatus = "8";
    } else {
      //printStatus = await FlutterPluginMsprinter.getPrintStatus();
    }

    if (retry && (payment_method_num.value == "0" || payment_method_num.value == "1")) {
      printGoNext();
      await Future.delayed(Duration(milliseconds: 2000));
    }

    if (printStatus == "0" || printStatus == "8") {
      var formData = {
        "orderId": orderId.value,
        "payAmount": getPutMoney.value,
        "machineCode": machineCode.value,
        "printType": (showPrintType.value == 1 && wlan_print_ip.value != "")
            ? "Label"
            : ""
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
        debugPrint("doPrintOrderMenu==val");
        var response = json.decode(val.toString());
        //LogUtil.d(response);
        if (response['code'] == 200) {
          //receipt
          if (response['data']["printInfoMapStruct"] != null &&
              response['data']["printInfoMapStruct"].isNotEmpty) {
            _wifiNetworkPrintData(
                response['data']["serialNumber"],
                response['data']["printInfoMapStruct"],
                response['data']["takeOut"],
                response['data']["orderTime"]);
          }

          //label打印
          if (showPrintType.value == 1 &&
              wlan_print_ip.value != "" &&
              response['data']["printInfoListStruct"].length > 0) {
            wifiNetworkLabelPrintData(response['data']["printInfoListStruct"]);
          }
          //printType 1 打印菜+领収书 2 只打印菜
          //orderType 1 打印菜并根据printtype来判断是否打印领収书。orderType 2不打印菜
          if (response['data']["orderType"] == 1 &&
              is_allow_receipt_menu.value == "1") {
            //debugPrint("response['data']====${response['data']}");
            //_tpPrintnew(response['data'], printType);
            createPrintImageController.tpPrintnew(
                print_paper_txt_size, response['data'], printType);
          } else {
            if (printType == "1") {
              //_tpPrintReceipt(response['data']);
              createPrintImageController.tpPrintReceipt(
                  print_paper_txt_size, response['data']);
            }
          }

          if ((payment_method_num.value != "0" && payment_method_num.value != "1")) {
            printGoNext();
          }
        } else {
          //错误后重新调用一次
          if (retry) {
            doPrintOrderMenu(printType,retry: false);
          }
        }
      })
      .catchError((e) {
        //错误后重新调用一次
        if (retry) {
          doPrintOrderMenu(printType,retry: false);
        } else {
          _checkOutErrorHandle(GString.getToString(
              checkLanguage.value, "tag_print_content_paper_error"));
        }

      });
    } else {

      EasyLoading.dismiss();
      var showDialogContent = "";
      if (printStatus == "7") {
        showDialogContent = GString.getToString(
            checkLanguage.value, "tag_print_content_paper_shortage");
      } else {
        showDialogContent = GString.getToString(
            checkLanguage.value, "tag_print_content_paper_error");
      }
      //小票状态
      Get.dialog(DialogUtils.alert(showDialogContent,
          title: GString.getToString(checkLanguage.value, "tag_title"),
          canceltitle:
              GString.getToString(checkLanguage.value, "tag_print_button_no"),
          confirmtitle:
              GString.getToString(checkLanguage.value, "tag_print_button_yes"),
          confirm: () {
        Get.back();
        doPrintOrderMenu(printType);
      }, cancle: () {
        Get.back();
        //goToNewMyHome();
        if (payment_method_num.value == "1") {
          nextOper();
        } else {
          goToNewMyHome();
        }
      }));
    }
  }

  _checkOutErrorHandle(showDialogContent) async {
    EasyLoading.dismiss();
    Get.dialog(
        DialogUtils.alert(showDialogContent,
            title: GString.getToString(checkLanguage.value, "tag_title"),
            canceltitle: GString.getToString(checkLanguage.value,"cancel_order"),
            confirmtitle: GString.getToString(checkLanguage.value,"show_del_cart_item_yes"),
            confirm: () {
              // Get.back();
              // doPrintOrderMenu(printType);
              //发邮件和播放感谢语
              _sendEmailAndPlayVoice();
            },
            cancle: () {
              Get.back();
              showEasyLoading();
              CancelOrder();
            })
    );
  }

  _sendEmailAndPlayVoice() async {
    showToast(GString.getToString(checkLanguage.value,"error_tips_thanks"));
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/12248.wav"),
      autoStart: true,
      volume: 0.5,
    );
  }


  //
  printGoNext() async {
    debugPrint("printGoNext");
    Future.delayed(Duration(milliseconds: 300), () async {
      if (machineMode.value == "1") {
        //eventBus.fire(new clearCartEvent('支付成功...'));
        Get.find<OrderHomeController>().clearCartList();
        //Get.find<MenuPageController>().clearCartList();print("再次开启了meu");
        //Get.find<MenuPageController>().getBookingBootMenu();

      } else if (machineMode.value == "3"){

        Get.find<SelfCheckoutscanningcodeController>().clearCartList(hideLoading: false);

      } else if (machineMode.value == "2") {
        if (Get.isRegistered<MenuPageController>()) {
          MenuPageController controller = Get.find<MenuPageController>();
          if (controller.mealType.value) {
            controller.clearCartList();
          }
        }
      }

      //先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
      if (payment_method_num.value == "1") {
        nextOper();
      } else {
        goToNewMyHome();
      }
    });
  }

  //现金及支付
  //现金机开始 打开现金机，准备开始投币
  Starttoubi() async {
    //入金开始
    debugPrint("Starttoubi");
    var _startCount = 0;
    var connectCount = 0;
    for (var i = 0; i < 5; i++) {
      String startPayCube = await Paycube.strartPayCube;
      debugPrint("startPayCube==$startPayCube");
      _startCount++;
      debugPrint("打开次数$_startCount");
      if (startPayCube == "startSuccess") {
        break;
      } else if (_startCount == 5) {
        //打开失败
        if (Platform.isAndroid) {
          FirebaseAnalytics.instance.logEvent(name: "cash_start_error",parameters: {
            "machineCode":machineCode.value,
            "orderId":orderId.value,
          });
        }
        showCashTimer?.cancel();
        Get.toNamed(Routes.ERROR_PAGE);
        return;
      }
    }
    debugPrint("打开现金机成功");
    await Paycube.setReceiveEvent;
    //调用插件的监听
    Paycube.getPayCubeListener();

    allowtimer?.cancel();
    allowtimer =
        Timer.periodic(Duration(milliseconds: 250), (Timer allowt) async {
      allowStatus.value = await Paycube.getPayCubeAllowCashStatus;
      debugPrint("allowStatus==$allowStatus");

      debugPrint("重试等待次数$connectCount");
      connectCount++;
      if(connectCount > 50){
        allowt.cancel();
        showCashTimer?.cancel();
        //上报错误。。。
        // FirebaseAnalytics.instance.logEvent(name: "cash_start_error",parameters: {
        //   "machineCode":machineCode.value,
        //   "orderId":orderId.value,
        // });
        Get.toNamed(Routes.ERROR_PAGE);
        return;
      }

      // 循环一定要记得设置取消条件，手动取消
      if (allowStatus.value == "AllowSuccess") {
        //如果打开了现金机，则去掉倒计时监听
        allowt.cancel();
        showCashTimer?.cancel();
        seconds.value = 120;

        getPutInMoney();
        //getPayCubeBackDataInfo();

        //allowt.cancel();
      } else if (allowStatus.value == "Error-F0--16") {
        //allowt.cancel();
        await Paycube.endTrade;
        //sleep(Duration(milliseconds: 200));
        // await Future.delayed(Duration(milliseconds: 200));
        // Starttoubi();
       String startPayCube = await Paycube.strartPayCube;
       debugPrint("startPayCube--==$startPayCube");
      } else if (allowStatus.value == "Error-A0--02" || "Error" == allowStatus.value) {
         if (allowStatus.value == "Error") {
           await Paycube.strartPayCube;
         }
        //sleep(Duration(milliseconds: 300));
      } else {
        _startCount++;
        if (_startCount == 10) {
          //10次打开失败 退出
          allowt.cancel();
          showCashTimer?.cancel();
          //上报错误。。。
          // FirebaseAnalytics.instance
          //     .logEvent(name: "cash_start_error", parameters: {
          //   "machineCode": machineCode.value,
          //   "orderId": orderId.value,
          // });
          Get.toNamed(Routes.ERROR_PAGE);
          return;
        }
        // await Paycube.endTrade;
        // await Paycube.strartPayCube;
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
        if (int.parse(result) >= totalPriceResult) {
          if (isCancel.value == false) {
            showPrintButton.value = true;
          } else {
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
          giveChangeMoney.value =
              int.parse(getPutMoney.value) - int.parse(totalPrice.value);
          if (isPrint.value == false) {
            startOutPutMoney(giveChangeMoney.value);
          }
        } else if (int.parse(getPutMoney.value) ==
            int.parse(totalPrice.value)) {
          if (isPrint.value == false) {
            //已经结束入金，处理取引终了
            payCubeCloseTransaction();
          }
        } /* else {
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
    //await Future.delayed(Duration(milliseconds: 300));
    var executeCount = 0;
    CashStep.value = 2;
    if (Platform.isWindows) {
      await gloryNextOper();
      return;
    }
    //sleep(Duration(milliseconds: 50));
    await Paycube.setReceiveEvent;
    //await Future.delayed(Duration(milliseconds: 350));
    timeOffset = DateTime.now().millisecondsSinceEpoch;
    final endStatus = await Paycube.endPayCube;
    debugPrint("endStatus==$endStatus");
    //开启倒计时
    _countDownTimer("3");
    stoptimer?.cancel();

    stoptimer =Timer.periodic(Duration(milliseconds: 570), (Timer stopt) async {
      stopStatus.value = await Paycube.getPayCubeStopCashStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (stopStatus.value == "StopSuccess") {
        debugPrint("现金机关闭耗时 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
        showCashTimer?.cancel();
        seconds.value = 180;
        timer?.cancel();
        stopt.cancel();
        //如果投币金额大于待支付总金额
        if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
          giveChangeMoney.value = int.parse(getPutMoney.value) - int.parse(totalPrice.value);
          //gotonewMenuPage();
          //找零
          startOutPutMoney(giveChangeMoney.value);
        } else {
          //已经结束入金，处理取引终了
          payCubeCloseTransaction();
        }
      } else if (stopStatus.value == "Error-A0--02") {
        debugPrint("stopStatus Error-A0--02");
        if (executeCount == 1) {
          await Paycube.sendPutCashDetail;
        } else {
          await Paycube.endPayCube;
        }
        executeCount++;
      } else if (stopStatus.value == "Sending") {
        debugPrint("Sending just wait");
      } else {
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
    outmoneytimer =
        Timer.periodic(Duration(milliseconds: 350), (Timer outmoneyt) async {
      outStatus.value = await Paycube.getPayCubeOutMoneyStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (outStatus.value == "OutSuccess") {
        debugPrint("现金机出金耗时 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
        //如果打开了现金机，则去掉倒计时监听
        showCashTimer?.cancel();
        seconds.value = 180;
        //如果取消不汇报，则出金后直接关闭 ？？？？？？
        _getPayCubeOutMoney();

        outmoneyt?.cancel();
      } else if (outStatus.value == "Error-A0--02" || outStatus.value == "Error") {
        //该错误暂不处理，等待出金成功
        //await Paycube.setReceiveEvent;
        //sleep(Duration(milliseconds: 200));
        //await Paycube.getPayCubeOutMoneyStatus;
        //print("_outStatus处理中:$_outStatus");
      } else if (outStatus.value == "Error-A0--21" ||  outStatus.value == "Error-A0--22" || outStatus.value == "Error-A0--23" ) {
        //出金失败,弹出提示框
        _checkOutErrorHandle(GString.getToString(checkLanguage.value, "tag_out_money_error"));

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

    OutMoneytimer =
        Timer.periodic(Duration(milliseconds: 350), (Timer outMoneyTime) async {
      if (queryTimes > 150) {
        //如果打开了现金机，则去掉倒计时监听
        showCashTimer?.cancel();
        seconds.value = 180;
        getOutMoneyString.value == false;

        OutMoneytimer?.cancel();
        //汇报出金币种
        reportOutMoney();
      }

      if (getOutMoneyString.value == true) {
        // 循环一定要记得设置取消条件，手动取消
        String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;
        if (currencyStringresult.trim().length > 50) {
          var outtotalAmount =
              MoneyParser.calculateTotalAmount(currencyStringresult.trim());
          //print("计算现金机出金金额与实际投入是否相等${outtotalAmount.toString()}");
          //print("计算现金机出金金额与实际投入是否相等${currencyStringresult}");

          if (outtotalAmount == int.parse(outStringMoney.value)) {
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
    endtimer =
        Timer.periodic(Duration(milliseconds: 250), (Timer endtradet) async {
      endStatus.value = await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消 || _endStatus == "error-A0--02"
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
      } else if (endStatus.value == "Sending") {
        debugPrint("Sending just wait");
      } else {
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
    putMoneyCurrencytimer = Timer.periodic(Duration(milliseconds: 350),
        (Timer putMoneyCurrencyTime) async {
      if (putQueryNum > 100) {
        showCashTimer?.cancel();
        putMoneyCurrencyTime.cancel();
        getputMoneyString.value = false;
        //汇报入金币种
        reportPutMoneyCurrency();
      }
      if (getputMoneyString.value == true) {
        // 循环一定要记得设置取消条件，手动取消
        String putcurrencyString = await Paycube.getPayCubePutMoneyCurrency;
        if (putcurrencyString.trim().length > 60) {
          var totalAmount =
              MoneyParser.calculateTotalAmount(putcurrencyString.trim());
          if (totalAmount == int.parse(getPutMoney.value)) {
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
  reportPutMoneyCurrency({retry = true}) {

    if(isReportCash.value == true){
      debugPrint("已汇报过");
      return;
    }

    isReportCash.value = true;
    //operation  0 确认支付  1 取消返回(券売機)　2 取消返回(精算機、自助结算)
    var operation = 0;
    if (isCancel.value == true) {
      if (machineMode.value == "1") {
        operation = 1;
      } else {
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
      "coinForbidden": int.parse(is_allow_oneyen.value)
    }; //print("webBootToReportV1==${formData}");
    request('webBootToReportV1', method: 'POST', parameters: formData)
        .then((value) {
          debugPrint("----上报订单成功----");
      //var response = json.decode(value.toString());
      // if (response['code'] == 200) {
      ///if (isReportOutMoney.value == true) {
      //已经结束入金，处理取引终了
      //reportOutMoneyCurrency();
      //}
      //}
    }).catchError((e) {
        //后期优化，上报失败存储本地，下次再上报。
        debugPrint("----上报订单失败----");
        if (!retry) {
          FirebaseAnalytics.instance.logEvent(
              name: "cash_report_error", parameters: {
            "machineCode": machineCode.value,
            "orderId": orderId.value,
          });
          //发送邮件计划
        }
        if (retry) {
          isReportCash.value = false;
          reportPutMoneyCurrency(retry: false);
        }
    });
  }

  reportOutMoneyCurrency() {
    if (giveChangeMoney.value > 0) {
      var formData = {
        "changeInfo": currencyString.value.trim(),
        "machineCode": machineCode.value,
        "orderId": orderId.value,
        "price": giveChangeMoney.value,
        "coinForbidden": int.parse(is_allow_oneyen.value)
      }; //print(formData);
      request('webBootToReportV1', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200) {
        } else {}
      });
    }
  }

  _wifiNetworkPrintData(serialNumber, extendPrintVo, takeOut, orderTime) {
    var printData = [];
    extendPrintVo.forEach((k, v) {
      printData = [];
      if (v.length > 0) {
        for (var i = 0; i < v.length; i++) {
          v[i]["checked"] = false;
          //判断是否有需要打印的数据
          if (v[i]["print"] == true) {
            printData.add(v[i]);
          }
        }
        //QueueUtil.get("smartwe_taks_wifi_print")?.addTask(() {
        return wifiNetPrintnew(serialNumber, k, printData, takeOut, orderTime);
        //});
      }
    });
  }

  wifiNetPrintnew(
      serialNumber, printType, printData, takeOut, orderTime) async {
    //如果整理的数据打印机不是10或11就返回
    if (printType != "10" && printType != "12") {
      return;
    }

    //判断是否有打印机ip

    Map printerIpInfo = {"printer_ip":"","printer_port":"",};
    if(printType == "10"){
      if(wlan_print_ip.value != null && wlan_print_ip.value != ""){

        final rotate = await HomeServices.getPrintDirection() == "1" ? pi : 0.0;

        printerIpInfo = {"printer_ip":wlan_print_ip.value,"printer_port":wlan_print_port.value,};
        if(is_allow_wlanPrint_continuous.value =="1"){
          wifiNetworkReceiptPrintContinuousData(serialNumber,printData,takeOut,orderTime,wlan_print_ip.value,rotate);
        }else{
          wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,wlan_print_ip.value,rotate);
        }
      } else {
        return;
      }
    }else if(printType == "12"){
      if(wlan_print_ip_two.value != null && wlan_print_ip_two.value != ""){
        final rotate = await HomeServices.getPrintTwoDirection() == "1" ? pi : 0.0;
        printerIpInfo = {"printer_ip":wlan_print_ip_two.value,"printer_port":wlan_print_port_two.value,};
        if(is_allow_wlanPrint_Two_continuous.value =="1"){
          wifiNetworkReceiptPrintContinuousData(serialNumber,printData,takeOut,orderTime,wlan_print_ip_two.value,rotate);

        }else{
          wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,wlan_print_ip_two.value,rotate);
        }
      } else {
        return;
      }
    } else {
      return;
    }
    //print(printData);
    //_wifiNetworkReceiptPrintData(serialNumber,printData,takeOut,orderTime,printerIpInfo["printer_ip"]);
  }

  create491Message() {
    var _queryString =
        "2104910001       00497                  000000010231130162425";
    for (var i = 0; i < 72; i++) {
      _queryString += " ";
    }
    var querycode = "0006";
    _queryString += querycode; //

    for (var i = 0; i < 400; i++) {
      _queryString += " ";
    }

    return _queryString;
  }
}
