import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_ui_extension.dart';
import 'package:foodorder/app/modules/settlement/views/PayResultView.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:foodorder/app/services/PrintInfoService.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/app_config.dart';
import '../../../controllers/machine_info.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../controllers/pos_pay_comtroller.dart';
import '../../../plugins/paycube/lib/paycube.dart';
import '../../../routes/app_pages.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/PosCheckService.dart';
import '../../../services/cashMoneyParser.dart';
import '../../../services/logUtil.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../../OrderHome/controllers/order_home_controller.dart';
import '../../SelfCheckoutscanningcode/controllers/self_checkoutscanningcode_controller.dart';
import '../../menuPage/controllers/menu_page_controller.dart';
import '../views/PayResultView.dart';


class SettlementController extends GetxController with StateMixin {
  //TODO: Implement SettlementController
  OrderSqlController ordersqlcontroller = Get.find();
  CreatePrintImageController createPrintImageController = Get.find();
  final posManager = PosSocketManager();
  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();
  final posCheckService = Get.find<PosCheckService>();

  MachineInfoController machineInfo = Get.find();
  PrintInfoService saveService = Get.find();
  PrintService printService = Get.find();
  AppConfig appConfig = Get.find();
  get payCube => appConfig.payCube;

  //默认语言包选择
  RxString checkLanguage = "JP".obs;

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

  RxBool showOpenPayment = false.obs;

  Timer? ScanCodeConfirmTimer;

  RxInt giveChangeMoney = 0.obs;
  RxString outStringMoney = "0".obs; //找零金额
  RxString currencyString = "".obs; // 出金币种
  RxBool isPrint = true.obs; //是否打印小票，默认打印，如果取消订单则不打印。
  RxBool isPrintClick = false.obs; //是否点击了打印小票。
  RxBool isCancelClick = false.obs; //是否点击了取消。


  RxBool showPrintButton = false.obs;  //如果投币金额不足，则不显示打印按钮


  RxString eventReportString = "".obs;
 //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc
  RxMap posResultReportData = {}.obs;

  RxBool isReportOutMoney = false.obs; //新处理 默认不汇报出金信息  先汇报入金信息在汇报出金信息
  RxBool isCancel = false.obs; //新增加  取消默认为false

  RxBool isPayConfirmOrderId = false.obs; //现金支付后，判断是否需要重新请求confirm orderid

  //RxInt CashStep = 1.obs;
  RxInt socketNumberTimes = 0.obs;
  //RxBool socketPosCancel = false.obs;

  int timeOffset = 0;
  bool posTest = false;
  Timer? paymentTimer;
  bool hasStartPayFlow = false;
  bool isRepayCash = false; //是否退金
  bool canReportFromListen = false; //是否无找零
  bool isScanCheckOut = false; //扫码支付是否精算模式

  @override
  void onInit() {
    readyQueryData();
    posCheckService.updateUseStatus(true);
    Future.delayed(const Duration(),() => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    //Get.focusScope.unfocus();
    //Get.focusScope.requestFocus(scanQrCodeFocusNode);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _startPaymentTimer();
  }

  @override
  Future<void> onClose() async {
    await posManager.closePos();
    posCheckService.updateUseStatus(false);
    payCube.stopListening();
    paymentTimer?.cancel();
    ScanCodeConfirmTimer?.cancel();
    super.onClose();
  }

  readyQueryData(){
    checkLanguage.value =Get.arguments['checkLanguage'];
    orderId.value = Get.arguments['orderId'];
    //this._machineMode = widget.arguments['machineMode'];
    totalPrice.value = Get.arguments['totalPrice'];
    showOpenPayment.value = Get.arguments['showOpenPayment'];
    isScanCheckOut = Get.arguments['isScanCheckOut'] ?? false;

    //0 1适用之前旧版本，可适用现金机，同时也可以扫码  2只可扫码，不在打开现金机 3、4只支持刷卡，不在打开现金机
    if (machineInfo.paymentMethod == "0" || machineInfo.paymentMethod == "1") {
      //打开现金机
      //_countDownTimer("1");
      Starttoubi();
      if (totalPrice.value == '0') {
        if(isCancel.value == false){
          showPrintButton.value = true;
        }else{
          showPrintButton.value = false;
        }
        showOutMoney.value = '0';
        update();
      }
    } /*else if (payment_method_num.value == "2") {
    //检测是否需要连接socket
    checkpayconnectSocker();
  }*/ else if (machineInfo.paymentMethod == "3" ||
        machineInfo.paymentMethod == "4" ||
        machineInfo.paymentMethod == "5" ||
        machineInfo.paymentMethod == "6" ||
        machineInfo.paymentMethod == "7" ||
        machineInfo.paymentMethod == "8" ||
        machineInfo.paymentMethod == "9" ||
        machineInfo.paymentMethod == "10"
    ) {
      //1链接socker 2 请求接口获得支付数据发送给pos机 3监听
      if(machineInfo.pos_ip != "" && machineInfo.pos_port != ""){
        showEasyLoading();
        payConnectSocket();
      }
    }

    _getSystemSettingInfo();
    requestLatestCheckoutInfo();

  }

  _getSystemSettingInfo() async {

    change(null, status: RxStatus.success());

  }

  gotonewMenuPage() {
    logI('---gotonewMenuPage---');
    if(isPayConfirmOrderId.value == true){
      if(machineInfo.paymentMethod == "0" || machineInfo.paymentMethod == "1"){
        if(machineInfo.currentMode == MachineMode.checkout) {//精算时候请求
          logI("精算请求了new order id");
          Get.find<CheckoutPageController>().postNewOrderId(orderIdIfTakeOut: orderId.value);
          Get.find<CheckoutPageController>().resetStateBack();
        }else if(machineInfo.currentMode == MachineMode.scan){
          logI("自助精算请求了new order id");
          Get.find<SelfCheckoutscanningcodeController>().postNewOrderId();
        }else{
          logI("普通支付请求了new order id");
          //Get.find<MenuPageController>().getBookingBootIndexCategory();
          Get.find<MenuPageController>().postNewOrderId();
        }
      }
      posManager.resetState();// if pos reset
    }
    EasyLoading.dismiss();
    Get.back();
  }

  checkOutModeBack() async {
    if (Get.isRegistered<CheckoutPageController>() && machineInfo.currentMode == MachineMode.checkout)
    Get.find<CheckoutPageController>().resetStateBack();
  }

  goToNewMyHome() {
    logI('---goToNewMyHome---');

    safeReturnToHome();
    return;
  }

  Future<void> showSuccessAlert(Function task) async {

    if (EasyLoading.isShow) {
      try {
        await EasyLoading.dismiss();
      } catch (e) {
        logger.warning('EasyLoading.dismiss error: $e');
      }
    }

    try {
      final result = await Get.dialog(
        barrierDismissible: false,
        const PayResultView(),
      );
      logger.infoLog("showSuccessAlert result: $result");
      // result 可用于判断来源，这里忽略
      task();
    } catch (e) {
      // 保障不因异常卡住
      logger.infoLog("showSuccessAlert error: $e");
      task();
    }
  }

  bool _isNavigating = false;

  Future<void> safeReturnToHome({bool success = false}) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      if (Get.isRegistered<MenuPageController>()) {
        await Get.find<MenuPageController>().clearCartList();
      } else {
        await ordersqlcontroller.removeAllFromCart(); // 等待清空
      }

    } catch (e) {
      logger.warning('removeAllFromCart error: $e');
    }

    //if (EasyLoading.isShow) {
      try {
        await EasyLoading.dismiss();
      } catch (e) {
        logger.warning('EasyLoading.dismiss error: $e');
      }
    //}
    if (success) {
      Get.toNamed(Routes.RESULT_PAGE);
    } else {
      resetToHome();
    }

  }

  resetToHome() async {
    logI('---resetToHome---');
    switch (machineInfo.currentMode) {
      case MachineMode.sell:
      case MachineMode.takeout:
        if (machineInfo.isBackHome) {
          await Get.offNamedUntil(Routes.CHECKOUT_PAGE, (route) => route.settings.name == Routes.TRANSIT_PAGE);
        } else {

          Get.until((route) => route.settings.name == Routes.MENU_PAGE);
          //await Get.offNamedUntil(Routes.MENU_PAGE, (route) => route.settings.name == Routes.CHECKOUT_PAGE);
        }
        break;
      case MachineMode.scan:
        //await Get.offNamedUntil(Routes.SELFSERVICE_PAGE, (route) => route.isFirst);
        await Get.offNamedUntil(Routes.CHECKOUT_PAGE, (route) => route.settings.name == Routes.TRANSIT_PAGE);
        break;
      case MachineMode.checkout:
        await Get.offNamedUntil(Routes.CHECKOUT_PAGE, (route) => route.settings.name == Routes.TRANSIT_PAGE);
        break;
    }
  }

  gotonewBack() {
    safeReturnToHome(success: true);
  }

  //扫码支付T
  doToPay() {
    //不是扫码支付直接return
    if (machineInfo.paymentMethod != "2") return;
    logI("doToPay", tag: "ScanPay");
    if (machineInfo.machineCode != "" && scanQrCodeController.text != "") {
      //_showEasyLoading();
      showEasyLoadingScan();
      hasStartPayFlow = true;
      var formData = {
        "auth_code": scanQrCodeController.text,
        "machineCode": machineInfo.machineCode,
        "orderId": orderId.value,
        "payType":"",
      };//print(formData);
      request('webBootToPayv2',
          method: 'POST',
          parameters: formData,
          timeout: const Duration(seconds: 180)
      ).then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200 && response['data'].isNotEmpty) {
          var resultData = response['data'];
          //LogUtil.d(resultData);
          logI("--- doToPay resultData = $resultData ---", tag: "ScanPay");
          hasStartPayFlow = true;
          if(resultData["requestInfo"] != ""){
            EasyLoading.dismiss();
            if(resultData["exceptionMessage"] == ""){
              showPosEasyLoading();
              posResultReportData.value = response['data'];
              //检测是否需要连接socket
              checkpayconnectSocker(questData: resultData["requestInfo"]);
            }else{
              _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
            }
          }else{
            if(resultData["result"] == true){
              doPrintOrderMenu(machineInfo.receiptPrintType);
            }else{
              _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
            }
          }

        } else {
          //扫码后超时，再继续请求后台，1秒一次 20次
          _doScanCodeTimeOut();
        }

      }).timeout(Duration(seconds: 180), onTimeout: () {
        logI("doToPay timeout after 180s", tag: "ScanPay");
        _showScanCodeTimeOutDialog();
      }).catchError((e) {
        if (e is TimeoutException) {
            logI("doToPay DioException timeout: $e", tag: "ScanPay");
            _showScanCodeTimeOutDialog();
            return;
        }
        logI("doToPay error: $e", tag: "ScanPay");
        _showScanCodeNoOpenDialog(3,"");
      });

    }
  }

  //三种扫码支付都未开通，弹出dialog
  _showScanCodeNoOpenDialog(checknum, showContent,{payType:"qr"}) {
    logI("_showScanCodeNoOpenDialog checknum = $checknum");
    EasyLoading.dismiss();
    scanQrCodeController.text = "";
    //_scanQrCode = "";
    //FocusScope.of(context).requestFocus(_scanQrCodeFocusNode); // 获取焦点
    scanQrCodeFocusNode.requestFocus();

    var showDialogContent;

    if (checknum == 1) {
      showDialogContent = "settlement_scancodenoopen_error".tr;
    } else if (checknum == 2) {
      showDialogContent = "settlement_scancodenochange_error".tr;
    } else if (checknum == 3) {
      if(showContent != null && showContent!=""){
        showDialogContent = showContent;
      }else{
        showDialogContent = "settlement_nopayment_error".tr;
      }

    }
    //支付状态

    Get.dialog(
        DialogUtils.alertOneButton(showDialogContent,
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () {
              Get.back();
              if(payType == "pos"){
                Get.back();
              }
            }),
      barrierDismissible: false
    );
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
              doPrintOrderMenu(machineInfo.receiptPrintType);
            }
          });
        });
  }

  //request latest checkout info
  requestLatestCheckoutInfo() async {
    bool goNext = true;
    var formData = {
      "orderId": orderId.value,
    };
    await request('webBootCalculateConfirm',
        method: 'POST', parameters: formData,
        timeout: const Duration(seconds: 15))
        .then((val) {
      var response = json.decode(val.toString());
      debugPrint("webBootCalculateConfirm:$response");
      if (response['code'] == 200 && response['data'] != null) {
        String finalTotal = response['data'].toString();
        debugPrint('finalTotal $finalTotal');
        if (totalPrice.value == finalTotal) {
          goNext = true;
        } else {
          totalPrice.value = finalTotal;
          var outMoney = int.parse(getPutMoney.value) - int.parse(totalPrice.value); //找零金额
          showOutMoney.value = outMoney < 0 ? '0':outMoney.toString();
          goNext = false;
        }
        update();
      }
    }).catchError((e) {
      debugPrint("webBootCalculateConfirm:$e");
      goNext = true;
    });
    return goNext;
  }

  cashPayCheck() async {
    showEasyLoading();
    bool result = await requestLatestCheckoutInfo();

    if (!result) {
      EasyLoading.dismiss();
      allowClick.value = true;
      isPrintClick.value = false;
      showPrintButton.value = false;
      update();
      Get.dialog(
          barrierDismissible: false,
          DialogUtils.alertOneButton("cash_pay_checkout_tips".tr, confirm: () {
            Get.back();
          }));
    } else {
      doPrintOrderMenu(machineInfo.receiptPrintType);
    }
  }

  showUnExpectedErrorDialog() {
    EasyLoading.dismiss();
    allowClick.value = true;
    isPrintClick.value = false;
    Get.dialog(
        barrierDismissible: false,
        DialogUtils.alertOneButton("settlement_unexpected_error".tr,
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr, confirm: () {
              Get.back();
              commonCancel();
            }));
  }

  doScanCodeTimeOutLastQuery() {
    var formData = {
      "orderId": orderId.value,
    };
    request('webBootLinePayConfirm', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu(machineInfo.receiptPrintType);
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


    var showDialogContent = "settlement_nopayment_error".tr;


    Get.dialog(
        DialogUtils.alertOneButton(showDialogContent,
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
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
        machineInfo.pos_ip = posSettingInfo['posIp'];
        machineInfo.pos_port = posSettingInfo['posPort'];
        if(machineInfo.pos_ip != "" && machineInfo.pos_port != ""){
          payConnectSocket(questData: questData);
        } else {
          //提醒未设置POS机 点击返回
          EasyLoading.dismiss();
          Get.dialog(
              barrierDismissible: false,
              DialogUtils.alertOneButton("settlement_posnosetting_error".tr,
                  title: "tag_title".tr,
                  confirmtitle: "tag_button_yes".tr, confirm: () {
                    Get.back();
                    Get.back();
                  }));
        }
      } else {
        //提醒未设置POS机 点击返回
        EasyLoading.dismiss();
        Get.dialog(
            barrierDismissible: false,
            DialogUtils.alertOneButton("settlement_posnosetting_error".tr,
                title: "tag_title".tr,
                confirmtitle: "tag_button_yes".tr, confirm: () {
                  Get.back();
                  Get.back();
                }));
      }
    }
  }

  //pos机相关
  payConnectSocket({questData=""}) async {
    debugPrint('start connect pos');

    final canUsePos = await posCheckService.canUsePos().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        debugPrint('POS机连接超时');
        return false;
      },
    );

    if (!canUsePos) {
      debugPrint('POS机繁忙中');
      //当前不处理 待定 只记录
    }

    posCheckService.updateUseStatus(true);
    logI('start connect pos', tag: 'POS');
    posManager.payConnectSocket(machineInfo.paymentMethod, machineInfo.pos_ip,
        int.parse(machineInfo.pos_port), machineInfo.machineCode, questData: questData,
        onRequestPayData: () {
          debugPrint('onRequestPayData');
          _getPaymentPosData();
        },
        onLoading: (mode) {
          if (mode == 0) {
            showEasyLoading();
          } else {
            showPosEasyLoading();
          }
        },
        onLoadingEnd: () {
          debugPrint('---onLoadingEnd---');
          EasyLoading.dismiss();
        },
        onCancel: (result, msg) =>
            showPosCancelEasyLoading(result, resultPFSString: msg),
        onDone: (action) {
          debugPrint('onDone $action');
          if (action == PosAction.Cancel) {
            cancelOrder();
          }
          else if (action == PosAction.WritePay) {
            //gotonewMenuPage();
            //show error
            _showScanCodeNoOpenDialog(3,"repay_cash_error".tr, payType: "pos");
          }
        },
        onSuccess: (msg) {
          posPayReport(msg);
        },
        onError: (error) {
          EasyLoading.dismiss();
          logI('onError pos $error', tag: 'POS');
          if (error == "L11") {
            gotonewMenuPage();
            return;
          }

          Get.dialog(
              barrierDismissible: false,
              DialogUtils.alertOneButton(error, confirm: () {
                posManager.resetState();
                Get.back();
                cancelOrder();
              }));
        },
        onTimeOut: () {
          logI('onTimeOut', tag: 'POS');
          EasyLoading.dismiss();
          posManager.resetState();
          _showScanCodeNoOpenDialog(
              3,
              "settlement_posPay_connect_error".tr,
              payType: "pos");
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
    if (thincaCloud.contains(machineInfo.paymentMethod) == true) {
      _payType = payTypeData[machineInfo.paymentMethod];
    }

    var formData = {
      "auth_code": "0000000088888888",
      "machineCode": machineInfo.machineCode,
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
            logI("--_getPaymentPosData 刷卡到这里了么？--");
            //showPosEasyLoading();
            hasStartPayFlow = true;
            posResultReportData.value = response['data'];
            //判断不为空则POS机
            //this._socket?.write(resultData["requestInfo"]);
            posManager.posActionWithData(
                PosAction.WritePay,
                resultData["requestInfo"]);
          }else{
            _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
          }
        }else{
          _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
        }

      } else {
        _showScanCodeNoOpenDialog(3,"settlement_scancodenochange_error".tr);
      }

    }).onError((error, stackTrace) {
      debugPrint('_getPaymentPosData : $error');
      commonErrorAlert("network_error_tips".tr);
    });

  }

  commonErrorAlert(String msg) {
    EasyLoading.dismiss();
    Get.dialog(
        barrierDismissible: true,
      DialogUtils.alertOneButton(msg, confirm: (){
        Get.back();
        cancelOrder();
      })
    );
  }

  showPosCancelAlert(){
    //if(socketPosCancel.value == true) return;

    Future.delayed(Duration(milliseconds: 50),() async {
      Get.dialog(
          DialogUtils.alert("settlement_back_alertcontent".tr,
              title: "tag_title".tr,
              canceltitle: "tag_button_no".tr,
              confirmtitle: "tag_button_yes".tr,
              confirm: () {
                Get.back();
                //socketPosCancel.value = true;
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
    var formData = {
      "machineCode": machineInfo.machineCode,
      "orderId": orderId.value,
    };

    request("webBootCreditCardCancel", method: 'POST', parameters: formData)
        .then((val) async {
      var response = json.decode(val.toString());//print("发送取消请求");
      LogUtil.d(response);
      if (response['code'] == 200) {
        //var _queryString =       "2101500001       00509                  000000120221114093225";
        //this._socket?.write(response['data']);
        posManager.posActionWithData(PosAction.Cancel, response['data'], backTask: (){
          gotonewMenuPage();
        });
      }
    }).onError((error, stackTrace) {
      commonErrorAlert("network_error_tips".tr);
    });
  }
//刷卡机nfc支付汇报
  posPayReport(String eventString, {int retryCount = 0}) {
    //debugPrint('posPayReport retryCount = $retryCount');
    logI('posPayReport retryCount = $retryCount', tag: 'POS');
    posResultReportData["result"] = true;
    posResultReportData["paymentInfo"] = eventString;//LogUtil.d("huibaohhhhhh===${_posResultReportData}");
    request('webBootPosPayReport',
        method: 'POST',
        parameters: posResultReportData,
        timeout: const Duration(seconds: 30)
    ).then((val) {
      var response = json.decode(val.toString());//print(response);

      if (response['code'] == 200 && response['data'] == true) {
        doPrintOrderMenu(machineInfo.receiptPrintType);
      } else {
        //扫码后超时，再继续请求后台，1秒一次 20次
        //_doScanCodeTimeOut();
        showPosCancelEasyLoading("900");
      }
    }).catchError((error){
      //TODO 默认重试3次
      if (retryCount < 3) {
        Future.delayed(Duration(milliseconds: 500), (){
          posPayReport(eventString, retryCount: retryCount + 1);
        });
      } else {
        FirebaseAnalytics.instance.logEvent(name: "settlement_report_error",parameters: {
          "machineCode": machineInfo.machineCode,
        });
        _checkOutErrorHandle('pos_report_error_tips'.tr);
      }
    });

  }

  _startPaymentTimer() async {
    logI("startResetTimer");
    paymentTimer?.cancel();
    paymentTimer = Timer(Duration(seconds: 180), () async {
      paymentTimer?.cancel();
      if (hasStartPayFlow) return;
      logI('---cancel Timer trigger---');
      commonCancel();
    });
  }

  commonCancel() async {
    logI('---commonCancel--- paymentMethod = ${machineInfo.paymentMethod}');
    if (machineInfo.paymentMethod == "0" || machineInfo.paymentMethod == "1") {
      showBackEasyLoading();
      cancelOrder();
    } else {
      var paymentMethod = ["3", "4", "5", "6", "7", "8", "9", "10"];
      if (paymentMethod.contains(machineInfo.paymentMethod) == true) {
        //socketPosCancel.value = true;
        // if(posManager.posAction() == PosAction.Cancel
        //     || posManager.posAction() == PosAction.WritePay
        //     ) {
        //   posManager.setPosPadding();
        //   commonErrorAlert(GString.getToString(checkLanguage.value, "pos_notwork_tips"));
        //   return;
        // } else if (posManager.posAction() == PosAction.Connect){
        //   Get.back();
        //   gotonewMenuPage();
        // }
        if (posManager.posAction() == PosAction.Cancel) {
          return;
        } else {
          getPaymentCancelPosData();
        }

      } else {
        if (EasyLoading.isShow) {
          try {
            await EasyLoading.dismiss();
          } catch (e) {
            logger.warning('EasyLoading.dismiss error: $e');
          }
        }
        Get.back();
      }
    }
  }

  cancelOrder() async {
    /*var formData = {
      "machineCode": _machineCode,
      "orderId": this._orderId,
      "model": (_machineMode == "1") ? "0" : "1",
    };
    request('webBootCancelV1', method: 'POST', parameters: formData);*/

    if (machineInfo.paymentMethod == "1" || machineInfo.paymentMethod == "0") {
      isCancel.value = true;
      isPayConfirmOrderId.value = true;
      //已投钱
      if (int.parse(getPutMoney.value) > 0) {
        isPrint.value = false;
        totalPrice.value = "0";
        showPrintButton.value = false;

        //如果现金机投币大于0后取消，则直接关机出金
        await endToubi();
      } else {
        isPrint.value = false;
        totalPrice.value = "0";
        getPutMoney.value = "0";
        showPrintButton.value = false;
        //如果现金机投币大于0后取消，则直接关机出金
        await endToubi();
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
  doPrintOrderMenu(printType,{int times = 0}) async {
    logI("doPrintOrderMenu times = $times", tag: "Print");
    //判断全局设置是否强制打印小票
    if (machineInfo.isAllowReceipt == "1") {
        printType = "1";
    }
    // var printStatus = "0";//await FlutterPluginMsprinter.getPrintStatus();//暂时去掉 默认为"0"
    // if (printStatus == "0" || printStatus == "8") {

    //判断是否允许打印小票
    final formData = {
      "orderId": orderId.value,
      "payAmount": getPutMoney.value,
      "machineCode": machineInfo.machineCode,
      "printType": machineInfo.printType,
    };

    final queryUrl = "webBootToPrintV9";

    try {
      final result = await request(
        queryUrl,
        method: 'POST',
        parameters: formData,
        timeout: Duration(seconds: 15),
      );
      final response = json.decode(result.toString());
      //debugPrint("doPrintOrderMenu== $response");
      LogUtil.d(response);
      if (response['code'] == 200) {
        if (response['data']["printInfo"] != null) {
            printService.printData(response['data']["printInfo"], 
            orderId: response['data']['order'] ?? "", fromSSE: false, shopName: response['data']['shopName'] ?? "");
            saveService.addPrintJob(response['data']);
          }
          if(response['data']["orderType"] == 1 && machineInfo.isPrintReceipt == "1"){
            //debugPrint("response['data']====${response['data']}");
            //_tpPrintnew(response['data'], printType);
            createPrintImageController.tpPrintNew(response['data'], printType);
          }else{
            if (printType == "1") {
              //_tpPrintReceipt(response['data']);
              createPrintImageController.tpPrintReceipt(response['data']);
            }
          }
          //打印小票
          printGoNext();
          //_sendToDisplayPanel(json.encode(response['data']["printInfo"]));

      } else {
        //错误后重新调用一次
        if (times < 3) {
          doPrintOrderMenu(printType, times: times + 1);
        } else {
          //_checkOutErrorHandle("tag_print_content_paper_error".tr);
          _handleOrderResultAlert(printType, times: times);
        }
      }
      
    } catch (e) {
      if (e is TimeoutException) {
        logI('-- doPrintOrderMenu -- timeout: $e');
      } else {
        logI('-- doPrintOrderMenu -- error: $e');
      }
      if (times < 3) {
        doPrintOrderMenu(printType, times: times + 1);
      } else {
        _handleOrderResultAlert(printType, times: times);
      }
    }
  }

  _handleOrderResultAlert(printType,{int times= 0}) {
    EasyLoading.dismiss();
    if (times > 2) {
      Get.dialog(
          DialogUtils.alertOneButton("order_network_error".tr,
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr,
              confirm: () {
                Get.back();
                commonCancel();
                FirebaseAnalytics.instance.logEvent(name: "settlement_order_error",parameters: {
                  "machineCode": machineInfo.machineCode,
                });
              })
      );
      return;
    }

    Get.dialog(
        DialogUtils.alert("settlement_order_error".tr,
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () async {
              Get.back();
              showEasyLoading();
              _startPaymentTimer();
              await Future.delayed(Duration(milliseconds: 1000));
              doPrintOrderMenu(printType, times: times + 1);
            },
            cancle: () {
              Get.back();
              commonCancel();
              FirebaseAnalytics.instance.logEvent(name: "settlement_order_error",parameters: {
                "machineCode": machineInfo.machineCode,
              });
            }
        )
    );
  }

  _checkOutErrorHandle(showDialogContent, {Function? retryAction}) async {
    EasyLoading.dismiss();
    Get.dialog(
        DialogUtils.alert(showDialogContent,
            title: "tag_title".tr,
            canceltitle: "cancel_order".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () {
              Get.back();
              commonCancel();
              //发邮件或者播放感谢语
              // if (retryAction != null) {
              //   retryAction();
              // } else {
              //   _sendEmailAndPlayVoice();
              // }

            },
            cancle: () {
              Get.back();
              commonCancel();
            })
    );
  }

  _sendEmailAndPlayVoice() async {
    showToast("error_tips_thanks".tr);
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/12248.wav"),
      autoStart: true,
      volume: 0.5,
    );
  }


  //
  printGoNext() async {
    logI("printGoNext", tag: "Print");
    if (machineInfo.paymentMethod == "1") {
      nextOper();
    } else {
      gotonewBack();
    }

    // Future.delayed(Duration(milliseconds: 300),() async {
    //   if (machineInfo.currentMode == MachineMode.checkout) {
    //     //eventBus.fire(new clearCartEvent('支付成功...'));
    //
    //     //Get.find<MenuPageController>().clearCartList();print("再次开启了meu");
    //     //Get.find<MenuPageController>().getBookingBootMenu();
    //   } else
    //     if (machineInfo.currentMode == MachineMode.scan){
    //     // if (Get.isRegistered<SelfCheckoutscanningcodeController>())
    //     //   Get.find<SelfCheckoutscanningcodeController>().clearCartList(hideLoading: false);
    //
    //     // if (Get.isRegistered<MenuPageController>()) {
    //     //   MenuPageController controller = Get.find<MenuPageController>();
    //     //   //if (controller.machineInfo.mealType) {
    //     //     controller.clearCartList();
    //     //   //}
    //     // }
    //
    //   } else if (machineInfo.currentMode == MachineMode.takeout || machineInfo.currentMode == MachineMode.sell) {
    //       // if (Get.isRegistered<OrderHomeController>())
    //       //   Get.find<OrderHomeController>().clearCartList();
    //
    //       // if (Get.isRegistered<MenuPageController>()) {
    //       //   MenuPageController controller = Get.find<MenuPageController>();
    //       //   controller.clearCartList();
    //       //   //if (controller.machineInfo.mealType) {
    //       //     //controller.clearCartList();
    //       //   //}
    //       // }
    //   }
    //
    //   //先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
    //   if (machineInfo.paymentMethod == "1") {
    //     nextOper();
    //   } else {
    //
    //     //goToNewMyHome();
    //     //showSuccessAlert(() {
    //       //goToNewMyHome();
    //       gotonewBack();
    //     //});
    //   }
    //
    // });
  }


  //现金及支付
  //现金机开始 打开现金机，准备开始投币
  Starttoubi({int connectCount = 1}) async {
    //入金开始
    debugPrint("Starttoubi $connectCount");
    logI("Start open cash $connectCount");
    await Future.delayed(Duration(milliseconds: 500));
    bool result = await payCube.startPayCube(onSuccess: () {
      debugPrint("onSuccess");
    }, catchError: (error) {
      logI("onError");
    });
    logI("startPayCube==$result");
    if (result) {
      debugPrint("打开现金机成功");
      //调用插件的监听
      _setPayCubeListener();
    } else {
      //打开失败
      FirebaseAnalytics.instance.logEvent(name: "cash_start_error",parameters: {
        "machineCode": machineInfo.machineCode,
        "orderId":orderId.value,
      });
      //showCashTimer?.cancel();
      Get.toNamed(Routes.ERROR_PAGE);
    }
  }

  _setPayCubeListener() async {
    await payCube.setReceiveEvent;
    payCube.getPayCubeListener();
    payCube.onCashInfoChange = (int type, String value) {
      switch (type) {
        case 0:
          //debugPrint("putMoney==$value");
          logI("putMoney==$value");
          _updatePutMoneyInfo(value);
          //_updatePutMoneyInfo(totalPrice.value);
          break;
        case 1:
          //debugPrint("putCurrency==$value");
          logI("putCurrency==$value");
          _getPayCubePutMoneyCurrency(value, canReportFromListen);
          break;
        case 2:
          //debugPrint("currencyString==$value");
          logI("currencyString==$value");
          _getPayCubeOutMoney(value, isRepayCash);
          break;
        default:
          break;
      }
    };
  }

  _updatePutMoneyInfo(String result) {
    debugPrint("_updatePutMoneyInfo==$result");
    if (int.parse(result) > 0) {
      hasStartPayFlow = true;
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
  }

  //入金开始-入金结束-交易结束-出金开始-交易结束  中间可set
  endToubi() async {
    //debugPrint("---endToubi---");
    logI("---endToubi---");
    await Future.delayed(Duration(milliseconds: 500));
    //await Paycube.setReceiveEvent;
    timeOffset = DateTime.now().millisecondsSinceEpoch;
    logI("endTouBi 入金禁止开始执行 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
    bool endStatus = await payCube.endPayCube(onSuccess: () {
      logI("endPayCube onSuccess");
    }, catchError: (error) {
      logI("endPayCube onError");
    });
    logI("endStatus==$endStatus");
    if (endStatus) {
      // showCashTimer?.cancel();
      // seconds.value = 180;
      // timer?.cancel();
      if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
        giveChangeMoney.value = int.parse(getPutMoney.value) - int.parse(totalPrice.value);
        if (isPrint.value == false) {
          await startOutPutMoney(giveChangeMoney.value, isCancel: true);
        }
      } else if (int.parse(getPutMoney.value) == int.parse(totalPrice.value)) {
        if (isPrint.value == false) {
          //已经结束入金，处理取引终了
          payCubeCloseTransaction(true);
        }
      }
    } else {
      cashErrorHandle();
    }
  }

  //打印小票之后在关闭现金机，所以不考虑_isPrint
  nextOper() async {
    //await Future.delayed(Duration(milliseconds: 300));
    timeOffset = DateTime.now().millisecondsSinceEpoch;
    await Future.delayed(Duration(milliseconds: 550));
    logI("入金禁止开始执行 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
    var executeCount = 0;
    //CashStep.value = 2;
    //sleep(Duration(milliseconds: 50));
    //await Paycube.setReceiveEvent;
    bool endStatus = await payCube.endPayCube(onSuccess: () {
      logI("endPayCube onSuccess");
    }, catchError: (error) {
      logI("endPayCube onError");
    });
    logI("endStatus==$endStatus");
    //开启倒计时
    //_countDownTimer("3");
    if (endStatus) {
      if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
        giveChangeMoney.value = int.parse(getPutMoney.value) - int.parse(totalPrice.value);
        //gotonewMenuPage();
        //找零
        startOutPutMoney(giveChangeMoney.value);
        //Future.delayed(Duration(milliseconds: 500),()=>startOutPutMoney(giveChangeMoney.value));
      } else {
        //已经结束入金，处理取引终了
        logI("现金机关闭,开始处理取引终了");
        payCubeCloseTransaction(false);
      }
    } else {
      cashErrorHandle();
    }
  }


  cashErrorHandle() {
    //现金机出错处理
    EasyLoading.dismiss();
    Get.dialog(
        DialogUtils.alertOneButton(
            'tag_cash_error'.tr,
            confirm: () {
              Get.back();
              //gotonewBack();
              safeReturnToHome();
            }),
      barrierDismissible: false
    );
  }

  startOutPutMoney(outMoney, {bool isCancel = false}) async {
    await Future.delayed(Duration(milliseconds: 550));
    logI("开始执行出金 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
    //CashStep.value = 3;
    outStringMoney.value = outMoney.toString();
    //await Paycube.setReceiveEvent;
    //_countDownTimer("6");
    bool result = await payCube.outPayCubeMoney(outStringMoney.value, onSuccess: () {
      logI("outPayCubeMoney onSuccess");
    }, catchError: (error) {
      logI("outPayCubeMoney onError $error");
    });

    if (result) {
      //如果打开了现金机，则去掉倒计时监听
      logI("现金机出金耗时 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
      // showCashTimer?.cancel();
      // seconds.value = 180;
      isRepayCash = isCancel;
      await payCube.setReceiveEvent;
      //如果取消不汇报，则出金后直接关闭 ？？？？？？

    } else {
      //出金失败
      cashErrorHandle();
    }
  }

  _getPayCubeOutMoney(String currencyStringResult, bool isCancel) async {
    //_currencyString现金机出款币种:A3 00 00  A1 02 00 A3 01 00
    //OutMoneytimer?.cancel();
    //await Paycube.setReceiveEvent;
    //_countDownTimer("7");

    int queryTimes = 0;
    // 循环一定要记得设置取消条件，手动取消
    //String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;

    //OutMoneytimer = Timer.periodic(Duration(milliseconds: 350), (Timer outMoneyTime) async {

      if(queryTimes>150){
        //如果打开了现金机，则去掉倒计时监听
        // showCashTimer?.cancel();
        // seconds.value = 180;
        getOutMoneyString.value == false;

        //OutMoneytimer?.cancel();
        //汇报出金币种
        reportOutMoney(isCancel);
      }

      if(getOutMoneyString.value == true){
        // 循环一定要记得设置取消条件，手动取消
        //String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;
        if (currencyStringResult.trim().length >= 28) {
          var outtotalAmount = MoneyParser.calculateTotalAmount(currencyStringResult.trim());
          //print("计算现金机出金金额与实际投入是否相等${outtotalAmount.toString()}");
          //print("计算现金机出金金额与实际投入是否相等${currencyStringresult}");

          if(outtotalAmount == int.parse(outStringMoney.value)){
            //如果打开了现金机，则去掉倒计时监听
            // showCashTimer?.cancel();
            // seconds.value = 180;
            currencyString.value = currencyStringResult;
            getOutMoneyString.value == false;

            //OutMoneytimer?.cancel();
            //汇报出金币种
            reportOutMoney(isCancel);
          }

        }
      }
      outMonyNum.value++;
      queryTimes++;
    //});
  }


  //汇报出金币种,请求后台
  reportOutMoney(bool isCancel) {
    //isReportOutMoney.value = true;
    payCubeCloseTransaction(isCancel);
  }

  payCubeCloseTransaction(bool isCancel) async {
    if (int.parse(getPutMoney.value) > 0) {
      //汇报入金币种
      logI("汇报入金币种");
      canReportFromListen = true;
      _getPayCubePutMoneyCurrency(getPutMoneyCurrency.value, true);
    }
    //CashStep.value = 4;
    //取引终了结束交易
    //_countDownTimer("5");
    //await Paycube.setReceiveEvent;
    await Future.delayed(Duration(milliseconds: 550));
    bool result = await payCube.endTrade(onSuccess: () {
      logI("endTrade onSuccess");
    }, catchError: (error) {
      logI("endTrade onError");
    });
    //开启倒计时

    if (result) {
      // showCashTimer?.cancel();
      // seconds.value = 180;
      if (isCancel) {
        if (isPrint.value == true) {
          gotonewBack();
        } else {
          gotonewMenuPage();
        }
      } else {
        //showSuccessAlert(() {
          if (isPrint.value == true) {
            gotonewBack();
          } else {
            gotonewMenuPage();
          }
        //});
      }
    } else {
      //出金失败
      cashErrorHandle();
    }

  }

  _getPayCubePutMoneyCurrency(String putCurrencyString, bool canReport) async {
    logI("putCurrencyString==$putCurrencyString canReport==$canReport");
    //_putcurrencyString现金机出款币种:61 00 00 62 00 00 63 00 00
    // putMoneyCurrencytimer?.cancel();
    // await Paycube.setReceiveEvent;
    // _countDownTimer("8");
    var putQueryNum = 0;
    //putMoneyCurrencytimer = Timer.periodic(Duration(milliseconds: 350),(Timer putMoneyCurrencyTime) async {

      if(putQueryNum >100){
        //showCashTimer?.cancel();
        //putMoneyCurrencyTime.cancel();

        //汇报入金币种
        if (canReport) {
          reportPutMoneyCurrency();
          getputMoneyString.value = false;
        }

      }
      if(getputMoneyString.value == true){
        // 循环一定要记得设置取消条件，手动取消
        //String putcurrencyString = await Paycube.getPayCubePutMoneyCurrency;
        debugPrint("putCurrencyString.trim().length==${putCurrencyString.trim().length}");
        if (putCurrencyString.trim().length > 60) {
          var totalAmount = MoneyParser.calculateTotalAmount(putCurrencyString.trim());
          if(totalAmount == int.parse(getPutMoney.value)){
            // showCashTimer?.cancel();
            // seconds.value = 180;
            getPutMoneyCurrency.value = putCurrencyString;
            //putMoneyCurrencyTime.cancel();

            //汇报入金币种
            if (canReport) {
              reportPutMoneyCurrency();
              getputMoneyString.value = false;
            }

          }
        }
      }
      putQueryNum++;
      putMonyNum.value++;
    //});
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
      if(machineInfo.machineMode == "1") {
        operation = 1;
      }else{
        operation = 2;
      }
    }

    var formData = {
      "paymentInfo": getPutMoneyCurrency.value.trim(),
      "changeInfo": currencyString.value.trim(),
      "machineCode": machineInfo.machineCode,
      "orderId": orderId.value,
      "price": int.parse(getPutMoney.value),
      "operation": operation,
      "coinForbidden":int.parse(machineInfo.is_allow_oneyen)
    };//
    logI("webBootToReportV1==${formData}");
    request('webBootToReportV1', method: 'POST', parameters: formData)
        .then((value) {
          logI("----上报订单成功----");
          isReportCash.value = false;
      //var response = json.decode(value.toString());
      // if (response['code'] == 200) {
      ///if (isReportOutMoney.value == true) {
      //已经结束入金，处理取引终了
      //reportOutMoneyCurrency();
      //}
      //}
    }).catchError((e) {
        //后期优化，上报失败存储本地，下次再上报。
        logI("----上报订单失败----，error: $e");
        if (!retry) {
          FirebaseAnalytics.instance.logEvent(
              name: "cash_report_error", parameters: {
            "machineCode": machineInfo.machineCode,
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



  create491Message() {
    var _queryString =       "2104910001       00497                  000000010231130162425";
    for(var i=0;i<72;i++){
      _queryString += " ";
    }
    var querycode = "0006";
    _queryString += querycode; //

    for(var i=0;i<400;i++){
      _queryString += " ";
    }

    return _queryString;
  }

}
