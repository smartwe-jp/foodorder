import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:foodorder/app/controllers/pos_pay_controller.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_extension.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_ui_extension.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:foodorder/app/services/PrintInfoService.dart';
import 'package:foodorder/app/services/scale_serial_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../../../controllers/app_config.dart';
import '../../../controllers/machine_info.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../plugins/cash_changer/lib/cash_changer.dart';
import '../../../routes/app_pages.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/PosCheckService.dart';
import '../../../services/cash_machine_startup_service.dart';
import '../../../services/cashMoneyParser.dart';
import '../../../services/incident_outbox.dart';
import '../../../services/logUtil.dart';
import '../../../services/machine_runtime_service.dart';
import '../../../services/payment_event_codes.dart';
import '../../../widget/DialogUtils.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../../SelfCheckoutscanningcode/controllers/self_checkoutscanningcode_controller.dart';
import '../../menuPage/controllers/menu_page_controller.dart';

part 'settlement_controller_payment_events.dart';

class SettlementController extends GetxController with StateMixin {

  OrderSqlController ordersqlcontroller = Get.put(OrderSqlController());
  CreatePrintImageController createPrintImageController = Get.find<CreatePrintImageController>();
  final posManager = PosSocketManager();
  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();
  final posCheckService = Get.find<PosCheckService>();

  MachineInfoController machineInfo = Get.find();
  final MachineRuntimeService _machineRuntime = Get.find();
  PrintInfoService saveService = Get.find();

  PrintService printService = Get.find();
  AppConfig appConfig = Get.find();
  get payCube => appConfig.payCube;

  //默认语言包选择
  RxString checkLanguage = "JP".obs;

  RxString orderId = "".obs;
  //RxString scanQrCode = "".obs;
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

  RxInt giveChangeMoney = 0.obs;
  RxString outStringMoney = "0".obs; //找零金额
  RxString currencyString = "".obs; // 出金币种
  RxBool isPrint = true.obs; //是否打印小票，默认打印，如果取消订单则不打印。
  RxBool isPrintClick = false.obs; //是否点击了打印小票。
  RxBool isCancelClick = false.obs; //是否点击了取消。

  RxBool showPrintButton = false.obs; //如果投币金额不足，则不显示打印按钮

  RxString eventReportString = "".obs;

  //60秒内未接收现金机正确通知，则进行下一步操作
  Timer? showCashTimer;
  RxInt seconds = 60.obs;
  //Socket? _socket; //socket对象
  RxBool socketState = false.obs; //连接状态

  RxBool isReportOutMoney = false.obs; //新处理 默认不汇报出金信息  先汇报入金信息在汇报出金信息
  RxBool isCancel = false.obs; //新增加  取消默认为false

  RxBool isPayConfirmOrderId = false.obs; //现金支付后，判断是否需要重新请求confirm orderid

  RxInt CashStep = 1.obs;
  RxInt socketNumberTimes = 0.obs;
  //RxBool socketPosCancel = false.obs;

  int timeOffset = 0;
  bool posTest = false;
  Timer? paymentTimer;
  bool hasStartPayflow = false;
  bool isRepayCash = false; //是否退金
  bool canReportFromListen = false; //是否无找零
  bool isScanCheckOut = false; //扫码支付是否精算模式

  RxMap posResultReportData = {}.obs;
  bool isOutMoney = false; 
  final _SettlementPaymentEventState _paymentEventState =
      _SettlementPaymentEventState();

  //String shopCode = '';

  final logger = Logger('SettlementController');

  @override
  void onInit() {
    readyQueryData();
    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    posCheckService.updateUseStatus(true);
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
    if (Platform.isAndroid) {
      payCube.stopListening();
    } else {
      CashChanger.removeEventsListener();
    }
    posCheckService.updateUseStatus(false);
    paymentTimer?.cancel();
    showCashTimer?.cancel();
    super.onClose();
  }

  readyQueryData() async {
    debugPrint("readyQueryData");
    checkLanguage.value = Get.arguments['checkLanguage'];
    orderId.value = Get.arguments['orderId'];
    totalPrice.value = Get.arguments['totalPrice'];
    //showOpenPayment.value = Get.arguments['showOpenPayment'];
    isScanCheckOut = Get.arguments['isScanCheckOut'] ?? false;
    _paymentInfo(
      PaymentEventCode.flowStarted,
      'Payment flow started',
      status: 'started',
      data: const <String, Object?>{'stage': 'settlement'},
    );

    //0 1适用之前旧版本，可适用现金机，同时也可以扫码  2只可扫码，不在打开现金机 3、4只支持刷卡，不在打开现金机
    if (machineInfo.paymentMethod == "0" || machineInfo.paymentMethod == "1") {
      //打开现金机

      if (Platform.isAndroid) {
        //_countDownTimer("1");
        Starttoubi();
      } else {
        CashChanger.setEventsListener();
        String result = await startDeposit();
        if (result != 'success') {
          final recovered = await _recoverCashMachineOnce();
          if (recovered) {
            result = await startDeposit();
          }
        }
        if (result != 'success') {
          _paymentStageFailed(
            'cash_device_open',
            PaymentEventCode.cashDeviceOpenFailed,
            'Glory cash device recovery failed',
            failureType: PaymentFailureType.deviceUnavailable,
            critical: true,
            data: const <String, Object?>{
              'cash_device': 'glory',
              'recovery_exhausted': true,
            },
          );
          _paymentFlowFailed(
            failedStage: 'cash_device_open',
            failureType: PaymentFailureType.deviceUnavailable,
          );
          _markCashMachineUnavailable();
          errorHandleDialog(result, confirm: () {
            Get.back();
            //Get.back();
            Get.toNamed(Routes.ERROR_PAGE);
          });
        }

        if (totalPrice.value == '0') {
          if (isCancel.value == false) {
            showPrintButton.value = true;
          } else {
            showPrintButton.value = false;
          }
          showOutMoney.value = '0';
          update();
        }
      }
    }
      /*else if (payment_method_num.value == "2") {
    //检测是否需要连接socket
    checkpayconnectSocker();

    }*/
    else if (machineInfo.paymentMethod == "3" ||

        machineInfo.paymentMethod == "4" ||
        machineInfo.paymentMethod == "5" ||
        machineInfo.paymentMethod == "6" ||
        machineInfo.paymentMethod == "7" ||
        machineInfo.paymentMethod == "8" ||
        machineInfo.paymentMethod == "9" ||
        machineInfo.paymentMethod == "10") {
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
          //print("精算请求了new order id");
          Get.find<CheckoutPageController>().postNewOrderId(orderIdIfTakeOut: orderId.value);
          Get.find<CheckoutPageController>().resetStateBack();
        }else if(machineInfo.currentMode == MachineMode.scan){
          //print("自助精算请求了new order id");
          Get.find<SelfCheckoutscanningcodeController>().postNewOrderId();
        } else {
          //print("普通支付请求了new order id");
          //Get.find<MenuPageController>().getBookingBootIndexCategory();
          Get.find<MenuPageController>().postNewOrderId();
        }
      }
      posManager.resetState(); // if pos reset
    }
    EasyLoading.dismiss();
    Get.back();
  }


  checkOutModeBack() async {
    logger.info('checkOutModeBack');
    if (Get.isRegistered<CheckoutPageController>() && machineInfo.currentMode == MachineMode.checkout)
    Get.find<CheckoutPageController>().resetStateBack();
  }

  goToNewMyHome() {
    logI('---goToNewMyHome---');

    safeReturnToHome();
    return;
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
        await Get.offNamedUntil(Routes.CHECKOUT_PAGE, (route) => route.settings.name == Routes.TRANSIT_PAGE);
        break;
      case MachineMode.checkout:
        await Get.offNamedUntil(Routes.CHECKOUT_PAGE, (route) => route.settings.name == Routes.TRANSIT_PAGE);
        break;
      case MachineMode.spicyHotPot:
        await Get.offNamedUntil(Routes.CHECKOUT_PAGE, (route) => route.settings.name == Routes.TRANSIT_PAGE);
        break;
    }
  }


  gotonewBack() {
    //debugPrint('---gotonewBack---');
    //logger.info('---gotonewBack--- machineInfo.currentMode = ${machineInfo.currentMode}， is_back_home = ${is_back_home.value}');
    safeReturnToHome(success: true);
  }
  //缺少场景考虑 扫码支付手机端操作异常，但是后续又可以了，但是机器交易流程停止了，订单不正常
  //扫码支付
  doToPay({int retryCount = 0}) {
    //不是扫码支付直接return
    if (machineInfo.paymentMethod != "2") return;
    //print(scanQrCodeController.text);
    if (machineInfo.machineCode != "" && scanQrCodeController.text != "" && orderId.value != null) {
      _qrPaymentAttempt++;
      _paymentStageStarted(
        'qr_payment',
        PaymentEventCode.qrPaymentStarted,
        'QR payment started',
        data: <String, Object?>{'attempt': _qrPaymentAttempt},
      );
      //_showEasyLoading();
      showEasyLoadingScan();
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
          logI(
            'QR payment response received',
            tag: 'ScanPay',
            flowId: paymentFlowId,
            data: <String, Object?>{
              'order_id': orderId.value,
              'has_request_info':
                  resultData["requestInfo"]?.toString().isNotEmpty ?? false,
              'has_exception':
                  resultData["exceptionMessage"]?.toString().isNotEmpty ??
                      false,
              'result': resultData["result"],
            },
          );
          if (resultData["requestInfo"] != "") {
            EasyLoading.dismiss();
            if (resultData["exceptionMessage"] == "") {
              showPosEasyLoading();
              posResultReportData.value = response['data'];
              //检测是否需要连接socket
              checkpayconnectSocker(questData: resultData["requestInfo"]);
            } else {
              _paymentStageFailed(
                'qr_payment',
                PaymentEventCode.qrPaymentFailed,
                'QR payment was rejected by backend',
                failureType: PaymentFailureType.backendRejected,
                data: <String, Object?>{'attempt': _qrPaymentAttempt},
              );
              _showScanCodeNoOpenDialog(3, resultData["exceptionMessage"]);
            }
          }else{
            if(resultData["result"] == true){
              _paymentStageSucceeded(
                'qr_payment',
                PaymentEventCode.qrPaymentSucceeded,
                'QR payment succeeded',
                data: <String, Object?>{'attempt': _qrPaymentAttempt},
              );
              doPrintOrderMenu(machineInfo.receiptPrintType);
            }else{
              _paymentStageFailed(
                'qr_payment',
                PaymentEventCode.qrPaymentFailed,
                'QR payment failed',
                failureType: PaymentFailureType.backendRejected,
                data: <String, Object?>{'attempt': _qrPaymentAttempt},
              );
              _showScanCodeNoOpenDialog(3,resultData["exceptionMessage"]);
            }
          }
        } else {
          //扫码后超时，再继续请求后台，1秒一次 20次
          logger.info("扫码支付失败 2 ${response['code']}");
          _doScanCodeTimeOut();
        }
      }).catchError((e) {
        if (e is TimeoutException) {
            logI("doToPay DioException timeout: $e", tag: "ScanPay");
            _paymentStageFailed(
              'qr_payment',
              PaymentEventCode.qrPaymentTimeout,
              'QR payment request timed out',
              failureType: PaymentFailureType.timeout,
              critical: true,
              error: e,
              data: <String, Object?>{'attempt': _qrPaymentAttempt},
            );
            _showScanCodeTimeOutDialog();
            return;
        }
        logI("doToPay error: $e", tag: "ScanPay");
        _paymentStageFailed(
          'qr_payment',
          PaymentEventCode.qrPaymentFailed,
          'QR payment request failed',
          failureType: PaymentFailureType.network,
          critical: true,
          error: e,
          data: <String, Object?>{'attempt': _qrPaymentAttempt},
        );
        _showScanCodeNoOpenDialog(3,"");
      });
    }
  }

  //三种扫码支付都未开通，弹出dialog
  _showScanCodeNoOpenDialog(checknum, showContent, {payType = "qr"}) async {
    if (EasyLoading.isShow) {
      try {
        await EasyLoading.dismiss();
      } catch (e) {
        logger.warning('EasyLoading.dismiss error: $e');
      }
    }
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
      if (showContent != null && showContent != "") {
        showDialogContent = showContent;
      }else{
        showDialogContent = "settlement_nopayment_error".tr;
      }
    }
    //支付状态

    Get.dialog(
        barrierDismissible: false,
        DialogUtils.alertOneButton(showDialogContent,
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () {
          Get.back();
          if (payType == "pos") {
            Get.back();
          }
        }));
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
          var outMoney =
              int.parse(getPutMoney.value) - int.parse(totalPrice.value); //找零金额
          showOutMoney.value = outMoney < 0 ? '0' : outMoney.toString();
          goNext = false;
        }
      }
    }).catchError((e) {
      debugPrint("webBootCalculateConfirm:$e");
      goNext = true;
    });
    return goNext;
  }

  cashPayCheck() async {
    logger.info('cashPayCheck');
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
      if (Platform.isAndroid) {
        doPrintOrderMenu(machineInfo.receiptPrintType);
      } else {
        gloryPayFlow(machineInfo.receiptPrintType);
      }
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


  //扫码后超时，再继续请求后台，5秒一次 60次
  _doScanCodeTimeOut({int retryCount = 0}) {
    // int queryCount = 0;
    // ScanCodeConfirmTimer?.cancel();
    // ScanCodeConfirmTimer = Timer.periodic(Duration(milliseconds: 5000),
    //     (Timer confirmTimer) async {
    //   queryCount++;
    //   if (queryCount > 60) {
    //     //退出关闭
    //     confirmTimer.cancel();
    //     _showScanCodeTimeOutDialog();
    //   }
      logger.info("扫码异常，重新请求后台 $retryCount");
      var formData = {
        "orderId": orderId.value,
      };
      request('webBootLinePayConfirm', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());

        if (response['code'] == 200 && response['data'] == true) {
          //退出关闭
          //confirmTimer.cancel();
          _paymentStageSucceeded(
            'qr_payment',
            PaymentEventCode.qrPaymentSucceeded,
            'QR payment confirmation succeeded',
            data: <String, Object?>{
              'attempt': _qrPaymentAttempt,
              'confirm_count': retryCount + 1,
            },
          );
          doPrintOrderMenu(machineInfo.receiptPrintType);
        } else {
          if (retryCount < 60) {
            Future.delayed(Duration(seconds: 5), () {
              _doScanCodeTimeOut(retryCount: retryCount + 1);
            });
          } else {
            _paymentStageFailed(
              'qr_payment',
              PaymentEventCode.qrPaymentTimeout,
              'QR payment confirmation timed out',
              failureType: PaymentFailureType.timeout,
              critical: true,
              data: <String, Object?>{
                'attempt': _qrPaymentAttempt,
                'confirm_count': retryCount + 1,
              },
            );
            _showScanCodeTimeOutDialog();
          }
        }
      }).catchError((error) {
        logger.info("扫码支付异常 $error");
        _paymentStageFailed(
          'qr_payment',
          PaymentEventCode.qrPaymentFailed,
          'QR payment confirmation request failed',
          failureType: PaymentFailureType.network,
          critical: true,
          error: error,
          data: <String, Object?>{
            'attempt': _qrPaymentAttempt,
            'confirm_count': retryCount + 1,
          },
        );
        _checkOutErrorHandle('settlement_order_error'.tr,
            confirm: () {
              scanQrCodeController.text = "";
              scanQrCodeFocusNode.requestFocus();
            });
      }).timeout(const Duration(seconds: 30), onTimeout: () {
        logger.info("扫码支付超时 30s");
        if (retryCount < 60) {
          Future.delayed(const Duration(seconds: 1), () {
            _doScanCodeTimeOut(retryCount: retryCount + 1);
          });
        } else {
          _paymentStageFailed(
            'qr_payment',
            PaymentEventCode.qrPaymentTimeout,
            'QR payment confirmation timed out',
            failureType: PaymentFailureType.timeout,
            critical: true,
            data: <String, Object?>{
              'attempt': _qrPaymentAttempt,
              'confirm_count': retryCount + 1,
            },
          );
          _showScanCodeTimeOutDialog();
        }
      });
    //});
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
  checkpayconnectSocker({questData = ""}) async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();
    var showCreditCard = systemSettingInfo['showCreditCard'];
    if (showCreditCard == true) {
      Map posSettingInfo = await HomeServices.getPosSettingInfo();

      if (posSettingInfo.isNotEmpty) {
        machineInfo.pos_ip = posSettingInfo['posIp'];
        machineInfo.pos_port = posSettingInfo['posPort'];
        if (machineInfo.pos_ip != "" && machineInfo.pos_port != "") {
          payConnectSocket(questData: questData);
        } else {
          //提醒未设置POS机 点击返回
          _paymentCritical(
            PaymentEventCode.posConnectFailed,
            'POS connection settings are missing',
            failureType: PaymentFailureType.deviceUnavailable,
            data: const <String, Object?>{'stage': 'pos_configuration'},
          );
          _paymentFlowFailed(
            failedStage: 'pos_configuration',
            failureType: PaymentFailureType.deviceUnavailable,
          );
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
        _paymentCritical(
          PaymentEventCode.posConnectFailed,
          'POS settings are unavailable',
          failureType: PaymentFailureType.deviceUnavailable,
          data: const <String, Object?>{'stage': 'pos_configuration'},
        );
        _paymentFlowFailed(
          failedStage: 'pos_configuration',
          failureType: PaymentFailureType.deviceUnavailable,
        );
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
  payConnectSocket({questData = ""}) async {
    debugPrint('start connect pos');
    _posConnectAttempt++;
    _paymentStageStarted(
      'pos_connect',
      PaymentEventCode.posConnectStarted,
      'POS connection started',
      data: <String, Object?>{'attempt': _posConnectAttempt},
    );

    final canUsePos = await posCheckService.canUsePos().timeout(
      Duration(seconds: 30),
      onTimeout: () {
        debugPrint('POS机连接超时');
        return false;
      },
    );

    if (!canUsePos) {
      debugPrint('POS机繁忙中');
      _paymentWarning(
        PaymentEventCode.posConnectFailed,
        'POS health check reported unavailable',
        failureType: PaymentFailureType.deviceUnavailable,
        data: <String, Object?>{
          'stage': 'pos_health_check',
          'attempt': _posConnectAttempt,
        },
      );
      //当前不处理 待定 只记录
    }

    posCheckService.updateUseStatus(true);
    posManager.payConnectSocket(machineInfo.paymentMethod, machineInfo.pos_ip,
        int.parse(machineInfo.pos_port), machineInfo.machineCode,
        questData: questData,
        onRequestPayData: () {
          debugPrint('onRequestPayData');
          _reportPosConnected();
          _paymentStageStarted(
            'card_payment',
            PaymentEventCode.cardPaymentStarted,
            'Card payment started',
            data: <String, Object?>{'attempt': _posConnectAttempt},
          );
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
        onCancel: (result, msg) {
          _reportPosConnected();
          final isQrPayment = machineInfo.paymentMethod == '2';
          _paymentStageFailed(
            isQrPayment ? 'qr_payment' : 'card_payment',
            isQrPayment
                ? PaymentEventCode.qrPaymentFailed
                : PaymentEventCode.cardPaymentFailed,
            isQrPayment
                ? 'QR payment was rejected'
                : 'Card payment was rejected',
            failureType: PaymentFailureType.deviceRejected,
            data: <String, Object?>{
              'attempt':
                  isQrPayment ? _qrPaymentAttempt : _posConnectAttempt,
              'result_code': result,
              if (msg.isNotEmpty) 'result_sub_code': msg,
            },
          );
          showPosCancelEasyLoading(result, resultPFSString: msg);
        },
        onDone: (action) {
          logI('onDone $action');
          if (action == PosAction.Cancel) {
            cancelOrder();
          }
          else if (action == PosAction.WritePay) {//该处处理不当
            //gotonewMenuPage();
            //goToNewMyHome();
            //show error
            _showScanCodeNoOpenDialog(3,"repay_cash_error".tr, payType: "pos");
          }
        },
        onSuccess: (msg) {
          _reportPosConnected();
          if (machineInfo.paymentMethod == '2') {
            _paymentStageSucceeded(
              'qr_payment',
              PaymentEventCode.qrPaymentSucceeded,
              'QR payment device processing succeeded',
              data: <String, Object?>{'attempt': _qrPaymentAttempt},
            );
          } else {
            _paymentStageSucceeded(
              'card_payment',
              PaymentEventCode.cardPaymentDeviceSucceeded,
              'Card payment device processing succeeded',
              data: <String, Object?>{'attempt': _posConnectAttempt},
            );
          }
          posPayReport(msg);
        },
        onError: (error) {
          EasyLoading.dismiss();
          debugPrint('onError pos $error');
          final connected = _posConnectedAttempt == _posConnectAttempt;
          final isQrPayment = machineInfo.paymentMethod == '2';
          final failedStage = isQrPayment
              ? 'qr_payment'
              : (connected ? 'card_payment' : 'pos_connect');
          final failedEventCode = isQrPayment
              ? PaymentEventCode.qrPaymentFailed
              : (connected
                  ? PaymentEventCode.cardPaymentFailed
                  : PaymentEventCode.posConnectFailed);
          _paymentStageFailed(
            failedStage,
            failedEventCode,
            isQrPayment
                ? 'QR payment failed'
                : (connected ? 'POS payment failed' : 'POS connection failed'),
            failureType: connected || isQrPayment
                ? PaymentFailureType.deviceRejected
                : PaymentFailureType.deviceUnavailable,
            critical: true,
            error: error,
            data: <String, Object?>{
              'attempt': _posConnectAttempt,
              'result_code': error,
            },
          );
          _paymentFlowFailed(
            failedStage: failedStage,
            failureType: connected || isQrPayment
                ? PaymentFailureType.deviceRejected
                : PaymentFailureType.deviceUnavailable,
            error: error,
          );
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
          debugPrint('onTimeOut');
          _paymentStageFailed(
            'pos_connect',
            PaymentEventCode.posConnectTimeout,
            'POS connection timed out',
            failureType: PaymentFailureType.timeout,
            critical: true,
            data: <String, Object?>{'attempt': _posConnectAttempt},
          );
          _paymentFlowFailed(
            failedStage: 'pos_connect',
            failureType: PaymentFailureType.timeout,
          );
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
      "5": "Edy",
      "6": "iD",
      "7": "nanaco",
      "8": "WAON",
      "9": "QUICPay",
      "10": "IC",
    };
    var thincaCloud = ["5", "6", "7", "8", "9", "10"];
    String? _payType = "";
    if (thincaCloud.contains(machineInfo.paymentMethod) == true) {
      _payType = payTypeData[machineInfo.paymentMethod];
    }

    var formData = {
      "auth_code": "0000000088888888",
      "machineCode": machineInfo.machineCode,
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
            //this._socket?.write(resultData["requestInfo"]);
            posManager.posActionWithData(
                PosAction.WritePay, resultData["requestInfo"]);
          } else {
            _paymentStageFailed(
              'card_payment',
              PaymentEventCode.cardPaymentFailed,
              'Card payment request was rejected',
              failureType: PaymentFailureType.backendRejected,
              data: <String, Object?>{'attempt': _posConnectAttempt},
            );
            _showScanCodeNoOpenDialog(3, resultData["exceptionMessage"]);
          }
        } else {
          _paymentStageFailed(
            'card_payment',
            PaymentEventCode.cardPaymentFailed,
            'Card payment request data was missing',
            failureType: PaymentFailureType.invalidResponse,
            data: <String, Object?>{'attempt': _posConnectAttempt},
          );
          _showScanCodeNoOpenDialog(3, resultData["exceptionMessage"]);
        }
      } else {
        _paymentStageFailed(
          'card_payment',
          PaymentEventCode.cardPaymentFailed,
          'Card payment request failed',
          failureType: PaymentFailureType.backendRejected,
          data: <String, Object?>{'attempt': _posConnectAttempt},
        );
        _showScanCodeNoOpenDialog(3,"settlement_scancodenochange_error".tr);
      }

    }).onError((error, stackTrace) {
      debugPrint('_getPaymentPosData : $error');
      _paymentStageFailed(
        'card_payment',
        PaymentEventCode.cardPaymentFailed,
        'Card payment request failed',
        failureType: PaymentFailureType.network,
        critical: true,
        error: error,
        stackTrace: stackTrace,
        data: <String, Object?>{'attempt': _posConnectAttempt},
      );
      _paymentFlowFailed(
        failedStage: 'card_payment',
        failureType: PaymentFailureType.network,
        error: error,
        stackTrace: stackTrace,
      );
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
    logger.info('showPosCancelAlert');
    Future.delayed(Duration(milliseconds: 50), () async {
      Get.dialog(
          DialogUtils.alert("settlement_back_alertcontent".tr,
              title: "tag_title".tr,
              canceltitle: "tag_button_no".tr,
              confirmtitle: "tag_button_yes".tr,
              confirm: () {
            Get.back();
            //socketPosCancel.value = true;
            getPaymentCancelPosData();
          }, cancle: () {
            Get.back();
          }),
          barrierDismissible: false);
    });
  }

  getPaymentCancelPosData() {
    var formData = {
      "machineCode": machineInfo.machineCode,
      "orderId": orderId.value,
    };

    request("webBootCreditCardCancel", method: 'POST', parameters: formData)
        .then((val) async {
      var response = json.decode(val.toString()); //print("发送取消请求");
      LogUtil.d(response);
      if (response['code'] == 200) {
        //var _queryString =       "2101500001       00509                  000000120221114093225";
        //this._socket?.write(response['data']);
//<<<<<<< HEAD
        posManager.posActionWithData(PosAction.Cancel, response['data'],
            backTask: () {
          //stop pos Task
              _paymentFlowCancelled(cancelledStage: 'pos_cancel');
              gotonewMenuPage();//cancelOrder();
// =======
//         posManager.posActionWithData(PosAction.Cancel, response['data'], backTask: (){
//           gotonewMenuPage();
// >>>>>>> 2.7.0-dev
        });
      }
    }).onError((error, stackTrace) {
      _paymentCritical(
        PaymentEventCode.cancelFailed,
        'POS payment cancellation failed',
        failureType: PaymentFailureType.network,
        error: error,
        stackTrace: stackTrace,
        data: const <String, Object?>{'stage': 'pos_cancel'},
      );
      _paymentFlowFailed(
        failedStage: 'pos_cancel',
        failureType: PaymentFailureType.network,
        error: error,
        stackTrace: stackTrace,
      );
      commonErrorAlert("network_error_tips".tr);
    });
  }
//刷卡机nfc支付汇报
  posPayReport(String eventString, {int retryCount = 0}) {
    logger.info('posPayReport retryCount = $retryCount');
    _paymentStageStarted(
      'payment_report',
      PaymentEventCode.paymentReportStarted,
      'Payment result report started',
      data: <String, Object?>{'attempt': retryCount + 1},
    );
    posResultReportData["result"] = true;
    posResultReportData["paymentInfo"] = eventString;//LogUtil.d("huibaohhhhhh===${_posResultReportData}");
    request('webBootPosPayReport',
        method: 'POST',
        parameters: posResultReportData,
        timeout: const Duration(seconds: 30)
    ).then((val) {
      var response = json.decode(val.toString());//print(response);

      if (response['code'] == 200 && response['data'] == true) {
        _paymentStageSucceeded(
          'payment_report',
          PaymentEventCode.paymentReportSucceeded,
          'Payment result report succeeded',
          data: <String, Object?>{'attempt': retryCount + 1},
        );
        doPrintOrderMenu(machineInfo.receiptPrintType);
      } else {
        _paymentStageFailed(
          'payment_report',
          PaymentEventCode.paymentReportFailed,
          'Payment result report was rejected',
          failureType: PaymentFailureType.backendRejected,
          critical: true,
          data: <String, Object?>{
            'attempt': retryCount + 1,
            'response_code': response['code'],
          },
        );
        _paymentFlowFailed(
          failedStage: 'payment_report',
          failureType: PaymentFailureType.backendRejected,
        );
        //扫码后超时，再继续请求后台，1秒一次 20次
        //_doScanCodeTimeOut();
        showPosCancelEasyLoading("900");
      }
    }).catchError((error) {
      logger.info("posPayReport error $error");
      //TODO 默认重试3次
      if (retryCount < 3) {
        _paymentStageFailed(
          'payment_report',
          PaymentEventCode.paymentReportFailed,
          'Payment result report attempt failed',
          failureType: PaymentFailureType.network,
          error: error,
          data: <String, Object?>{
            'attempt': retryCount + 1,
            'will_retry': true,
          },
        );
        Future.delayed(Duration(milliseconds: 500), () {
          posPayReport(eventString, retryCount: retryCount + 1);
        });
      } else {
        _paymentStageFailed(
          'payment_report',
          PaymentEventCode.paymentReportFailed,
          'Payment result report failed after retries',
          failureType: PaymentFailureType.network,
          critical: true,
          error: error,
          data: <String, Object?>{
            'attempt': retryCount + 1,
            'will_retry': false,
          },
        );
        _paymentFlowFailed(
          failedStage: 'payment_report',
          failureType: PaymentFailureType.network,
          error: error,
        );
        // FirebaseAnalytics.instance.logEvent(name: "settlement_report_error",parameters: {
        //   "machineCode": machineInfo.machineCode,
        // });
        logger.info("posPayReport final error $error");
        _checkOutErrorHandle('pos_report_error_tips'.tr);
      }
    });
  }

  _startPaymentTimer() async {
    logI("startResetTimer");
    paymentTimer?.cancel();
    paymentTimer = Timer(Duration(seconds: 180), () async {
      logI("paymentTimer 180s");
      paymentTimer?.cancel();
      if (hasStartPayflow) return;
      commonCancel();
    });
  }

  commonCancel() async {
    logI('commonCancel');
    if (!_cancelRequestReported) {
      _cancelRequestReported = true;
      _paymentInfo(
        PaymentEventCode.cancelRequested,
        'Payment cancellation requested',
        status: 'started',
        data: const <String, Object?>{'stage': 'cancel'},
      );
    }
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
        _paymentFlowCancelled(cancelledStage: 'cancel');
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
        if (Platform.isWindows) {
          await endDeposit(repay: true);
        } else {
          endToubi();
        }
      } else {
        isPrint.value = false;
        totalPrice.value = "0";
        getPutMoney.value = "0";
        showPrintButton.value = false;
        if (Platform.isWindows) {
          await endDeposit();
        } else {
          endToubi();
        }
      }
    } else {
      //返回上一级菜单页面
      _paymentFlowCancelled(cancelledStage: 'cancel');
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
  doPrintOrderMenu(printType, {int times = 0}) async {
    logger.info('-- doPrintOrderMenu --');
    debugPrint("doPrintOrderMenu");
    _paymentStageStarted(
      'order_finalize',
      PaymentEventCode.orderFinalizeStarted,
      'Order finalization started',
      data: <String, Object?>{
        'attempt': times + 1,
        'print_type': printType.toString(),
      },
    );
    //判断全局设置是否强制打印小票
    if (machineInfo.isAllowReceipt == "1") {
      printType = "1";
    }

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
        timeout: const Duration(seconds: 15),
      );
      final response = json.decode(result.toString());
      //debugPrint("doPrintOrderMenu== $response");
      LogUtil.d(response);
      if (response['code'] == 200) {
        _paymentStageSucceeded(
          'order_finalize',
          PaymentEventCode.orderFinalizeSucceeded,
          'Order finalization succeeded',
          data: <String, Object?>{
            'attempt': times + 1,
            'print_type': printType.toString(),
          },
        );
        _paymentStageStarted(
          'print_dispatch',
          PaymentEventCode.printStarted,
          'Print dispatch started',
          data: <String, Object?>{
            'attempt': times + 1,
            'print_type': printType.toString(),
          },
        );
        if (response['data']["printInfo"] != null) {
            printService.printData(response['data']["printInfo"], 
            orderId: response['data']['order'] ?? "", fromSSE: false, shopName: response['data']['shopName'] ?? "");
            saveService.addPrintJob(response['data']);
          }
          if(response['data']["orderType"] == 1 && machineInfo.isPrintReceipt == "1"){
            //debugPrint("response['data']====${response['data']}");
            //_tpPrintnew(response['data'], printType);
            createPrintImageController.tpPrintnew(response['data'], printType);
          }else{
            if (printType == "1") {
              //_tpPrintReceipt(response['data']);
              createPrintImageController.tpPrintReceipt(response['data']);
            }
          }
          _paymentStageSucceeded(
            'print_dispatch',
            PaymentEventCode.printDispatched,
            'Print tasks dispatched',
            data: <String, Object?>{
              'attempt': times + 1,
              'print_type': printType.toString(),
              'has_kitchen_print': response['data']["printInfo"] != null,
            },
          );
          //打印小票
          printGoNext();
          //_sendToDisplayPanel(json.encode(response['data']["printInfo"]));

      } else {
        _lastOrderFinalizeFailureType = PaymentFailureType.backendRejected;
        _paymentStageFailed(
          'order_finalize',
          PaymentEventCode.orderFinalizeFailed,
          'Order finalization was rejected',
          failureType: PaymentFailureType.backendRejected,
          critical: times >= 3,
          data: <String, Object?>{
            'attempt': times + 1,
            'response_code': response['code'],
            'will_retry': times < 3,
          },
        );
        //错误后重新调用一次
        if (times < 3) {
          doPrintOrderMenu(printType, times: times + 1);
        } else {
          //_checkOutErrorHandle("tag_print_content_paper_error".tr);
          _handleOrderResultAlert(printType, times: times);
        }
      }
      
    } catch (e, stackTrace) {
      _lastOrderFinalizeFailureType = e is TimeoutException
          ? PaymentFailureType.timeout
          : PaymentFailureType.network;
      if (e is TimeoutException) {
        logI('-- doPrintOrderMenu -- timeout: $e');
      } else {
        logI('-- doPrintOrderMenu -- error: $e');
      }
      _paymentStageFailed(
        'order_finalize',
        PaymentEventCode.orderFinalizeFailed,
        e is TimeoutException
            ? 'Order finalization timed out'
            : 'Order finalization failed',
        failureType: e is TimeoutException
            ? PaymentFailureType.timeout
            : PaymentFailureType.network,
        critical: times >= 3,
        error: e,
        stackTrace: stackTrace,
        data: <String, Object?>{
          'attempt': times + 1,
          'will_retry': times < 3,
        },
      );
      if (times < 3) {
        doPrintOrderMenu(printType, times: times + 1);
      } else {
        _handleOrderResultAlert(printType, times: times);
      }
    }
  }

  _handleOrderResultAlert(printType,{int times= 0}) {
    EasyLoading.dismiss();
    //if (times > 2) {
      Get.dialog(
          DialogUtils.alert("tag_print_content_paper_error".tr,
              title: "tag_title".tr,
              confirmtitle: "skip_button".tr,
              canceltitle: "cancel_order".tr,
              confirm: () {
                _paymentFlowFailed(
                  failedStage: 'order_finalize',
                  failureType: _lastOrderFinalizeFailureType,
                );
                Get.back();
                printGoNext();
                
                // FirebaseAnalytics.instance.logEvent(name: "settlement_order_error",parameters: {
                //   "machineCode": machineInfo.machineCode,
                // });
              },
              cancle: () {
                _paymentFlowFailed(
                  failedStage: 'order_finalize',
                  failureType: _lastOrderFinalizeFailureType,
                );
                Get.back();
                commonCancel();
                // FirebaseAnalytics.instance.logEvent(name: "settlement_order_error",parameters: {
                //   "machineCode": machineInfo.machineCode,
                // });
                }
              )
      );
      return;
    //}

    Get.dialog(
        DialogUtils.alert("tag_print_content_paper_error".tr,
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
              // FirebaseAnalytics.instance.logEvent(name: "settlement_order_error",parameters: {
              //   "machineCode": machineInfo.machineCode,
              // });
            }
        )
    );
  }


  _checkOutErrorHandle(showDialogContent, {Function? confirm}) async {
    EasyLoading.dismiss();
    //非当前页面不再弹框 MARK:TODO
    Get.dialog(
        DialogUtils.alert(showDialogContent,
            title: "tag_title".tr,
            canceltitle: "cancel_order".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () {
              Get.back();
              if (confirm != null) {
                confirm();
              } else {
                commonCancel();
              }

            },
            cancle: () {
              Get.back();
              commonCancel();
            })
    );
  }


  //
  printGoNext() async {
    debugPrint("printGoNext");
    Future.delayed(Duration(milliseconds: 300),() async {
      // if (machineInfo.currentMode == MachineMode.checkout) {
      // } else
      //   if (machineInfo.currentMode == MachineMode.scan){

      // } else if (machineInfo.currentMode == MachineMode.takeout || machineInfo.currentMode == MachineMode.sell) {
      // }

      //先打印小票，然后在结束入金进行下一步流程,如果扫码则直接取引终了返回，否则进行出金、汇报等操作
      if (machineInfo.paymentMethod == "1") {
        nextOper();
      } else {
        _paymentFlowSucceeded(completionStage: 'order_finalize');
        gotonewBack();
      }
    });
  }

  //现金及支付
  //现金机开始 打开现金机，准备开始投币
  Starttoubi({int connectCount = 1}) async {
    //入金开始
    debugPrint("Starttoubi $connectCount");
    _paymentStageStarted(
      'cash_device_open',
      PaymentEventCode.cashDeviceOpenStarted,
      'Cash device open started',
      data: <String, Object?>{'attempt': connectCount},
    );
    await ScaleSerialService.releaseUsbSafely(reason: 'Starttoubi');
    await Future.delayed(Duration(milliseconds: 500));
    bool result = await payCube.startPayCube(onSuccess: () {
      debugPrint("onSuccess");
    }, catchError: (error) {
      debugPrint("onError");
    });
    debugPrint("startPayCube==$result");
    if (result) {
      _paymentStageSucceeded(
        'cash_device_open',
        PaymentEventCode.cashDeviceOpenSucceeded,
        'Cash device open succeeded',
        data: <String, Object?>{'attempt': connectCount},
      );
      debugPrint("打开现金机成功");
      //调用插件的监听
      _setPayCubeListener();
      //_updatePutMoneyInfo(totalPrice.value);
      showCashTimer?.cancel();
      seconds.value = 120;
    } else {
      //打开失败
      _paymentStageFailed(
        'cash_device_open',
        PaymentEventCode.cashDeviceOpenFailed,
        'Cash device open failed',
        failureType: PaymentFailureType.deviceUnavailable,
        critical: connectCount > 1,
        data: <String, Object?>{
          'attempt': connectCount,
          'will_retry': connectCount == 1,
        },
      );
      // FirebaseAnalytics.instance.logEvent(name: "cash_start_error",parameters: {
      //   "machineCode": machineInfo.machineCode,
      //   "orderId":orderId.value,
      // });
      showCashTimer?.cancel();
      if (connectCount == 1 && await _recoverCashMachineOnce()) {
        await Starttoubi(connectCount: 2);
        return;
      }
      _paymentFlowFailed(
        failedStage: 'cash_device_open',
        failureType: PaymentFailureType.deviceUnavailable,
      );
      _markCashMachineUnavailable();
      Get.toNamed(Routes.ERROR_PAGE);
    }
  }

  Future<bool> _recoverCashMachineOnce() async {
    final result = await Get.find<CashMachineStartupService>()
        .checkForPayment(force: true);
    return result.isReady;
  }

  void _markCashMachineUnavailable() {
    _machineRuntime.markCashMachineFailed();
    machineInfo.update(['selectPayment']);
  }

  _setPayCubeListener() async {
    await payCube.setReceiveEvent;
    payCube.getPayCubeListener();
    payCube.onCashInfoChange = (int type, String value) {
      switch (type) {
        case 0:
          debugPrint("putMoney==$value");
          _paymentInfo(
            PaymentEventCode.cashDepositAmountUpdated,
            'Cash deposit amount updated',
            status: 'received',
            data: <String, Object?>{
              'listener_type': type,
              'listener_value': value,
            },
          );
          _updatePutMoneyInfo(value);
          break;
        case 1:
          debugPrint("putCurrency==$value");
          _paymentInfo(
            PaymentEventCode.cashDepositDenominationsUpdated,
            'Cash deposit denominations updated',
            status: 'received',
            data: <String, Object?>{
              'listener_type': type,
              'listener_value': value,
            },
          );
          _getPayCubePutMoneyCurrency(value, canReportFromListen);
          break;
        case 2:
          debugPrint("currencyString==$value");
          _paymentInfo(
            PaymentEventCode.cashPayoutDenominationsUpdated,
            'Cash payout denominations updated',
            status: 'received',
            data: <String, Object?>{
              'listener_type': type,
              'listener_value': value,
            },
          );
          _getPayCubeOutMoney(value, isRepayCash);
          break;
        default:
          break;
      }
    };
  }

  _updatePutMoneyInfo(String result) {
    debugPrint("_updatePutMoneyInfo==$result");
    if (int.parse(result) >= 0) {
      hasStartPayflow = true;
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
    debugPrint("---endToubi---");
    _paymentStageStarted(
      'cash_deposit_stop',
      PaymentEventCode.cashDepositStopStarted,
      'Cash deposit stop started',
      data: const <String, Object?>{'operation': 'cancel'},
    );
    await Future.delayed(Duration(milliseconds: 500));
    //await Paycube.setReceiveEvent;
    bool endStatus = await payCube.endPayCube(onSuccess: () {
      debugPrint("endPayCube onSuccess");
    }, catchError: (error) {
      debugPrint("endPayCube onError");
    });
    debugPrint("endStatus==$endStatus");
    if (endStatus) {
      _paymentStageSucceeded(
        'cash_deposit_stop',
        PaymentEventCode.cashDepositStopSucceeded,
        'Cash deposit stop succeeded',
        data: const <String, Object?>{'operation': 'cancel'},
      );
      showCashTimer?.cancel();
      seconds.value = 180;
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
      _paymentStageFailed(
        'cash_deposit_stop',
        PaymentEventCode.cashDepositStopFailed,
        'Cash deposit stop failed',
        failureType: PaymentFailureType.deviceUnavailable,
        critical: true,
      );
      _paymentFlowFailed(
        failedStage: 'cash_deposit_stop',
        failureType: PaymentFailureType.deviceUnavailable,
      );
      cashErrorHandle();
    }
  }

  //打印小票之后在关闭现金机，所以不考虑_isPrint
  nextOper() async {
    //await Future.delayed(Duration(milliseconds: 300));
    timeOffset = DateTime.now().millisecondsSinceEpoch;
    await Future.delayed(Duration(milliseconds: 550));
    _paymentStageStarted(
      'cash_deposit_stop',
      PaymentEventCode.cashDepositStopStarted,
      'Cash deposit stop started',
      data: const <String, Object?>{'operation': 'complete'},
    );
    debugPrint("入金禁止开始执行 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
    //var executeCount = 0;
    CashStep.value = 2;
    if (Platform.isWindows) {
      await gloryNextOper();
      return;
    }
    //sleep(Duration(milliseconds: 50));
    //await Paycube.setReceiveEvent;
    bool endStatus = await payCube.endPayCube(onSuccess: () {
      debugPrint("endPayCube onSuccess");
    }, catchError: (error) {
      debugPrint("endPayCube onError");
    });
    debugPrint("endStatus==$endStatus");
    //开启倒计时
    //_countDownTimer("3");
    if (endStatus) {
      _paymentStageSucceeded(
        'cash_deposit_stop',
        PaymentEventCode.cashDepositStopSucceeded,
        'Cash deposit stop succeeded',
        data: const <String, Object?>{'operation': 'complete'},
      );
      if (int.parse(getPutMoney.value) > int.parse(totalPrice.value)) {
        giveChangeMoney.value = int.parse(getPutMoney.value) - int.parse(totalPrice.value);
        //gotonewMenuPage();
        //找零
        startOutPutMoney(giveChangeMoney.value);
        //Future.delayed(Duration(milliseconds: 500),()=>startOutPutMoney(giveChangeMoney.value));
      } else {
        //已经结束入金，处理取引终了
        debugPrint("现金机关闭,开始处理取引终了");
        payCubeCloseTransaction(false);
      }
    } else {
      _paymentStageFailed(
        'cash_deposit_stop',
        PaymentEventCode.cashDepositStopFailed,
        'Cash deposit stop failed',
        failureType: PaymentFailureType.deviceUnavailable,
        critical: true,
      );
      _paymentFlowFailed(
        failedStage: 'cash_deposit_stop',
        failureType: PaymentFailureType.deviceUnavailable,
      );
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
              safeReturnToHome();
            }),
      barrierDismissible: false
    );
  }

  startOutPutMoney(outMoney, {bool isCancel = false}) async {
    await Future.delayed(Duration(milliseconds: 550));
    _paymentStageStarted(
      'cash_change',
      PaymentEventCode.cashChangeStarted,
      'Cash change payout started',
      data: <String, Object?>{
        'change_amount': int.tryParse(outMoney.toString()),
        'operation': isCancel ? 'cancel' : 'complete',
      },
    );
    debugPrint("开始执行出金 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
    CashStep.value = 3;
    outStringMoney.value = outMoney.toString();
    //await Paycube.setReceiveEvent;
    //_countDownTimer("6");
    bool result = await payCube.outPayCubeMoney(outStringMoney.value, onSuccess: () {
      debugPrint("outPayCubeMoney onSuccess");
    }, catchError: (error) {
      debugPrint("outPayCubeMoney onError $error");
    });

    if (result) {
      _paymentInfo(
        PaymentEventCode.cashChangeCommandAccepted,
        'Cash change payout command accepted',
        status: 'accepted',
        data: <String, Object?>{
          'stage': 'cash_change',
          'change_amount': int.tryParse(outMoney.toString()),
          'operation': isCancel ? 'cancel' : 'complete',
        },
      );
      //如果打开了现金机，则去掉倒计时监听
      debugPrint("现金机出金耗时 ${DateTime.now().millisecondsSinceEpoch - timeOffset}毫秒");
      showCashTimer?.cancel();
      seconds.value = 180;
      isRepayCash = isCancel;
      await payCube.setReceiveEvent;
      //如果取消不汇报，则出金后直接关闭 ？？？？？？
      //_getPayCubeOutMoney();

    } else {
      //出金失败
      _paymentStageFailed(
        'cash_change',
        PaymentEventCode.cashChangeFailed,
        'Cash change payout failed',
        failureType: PaymentFailureType.deviceUnavailable,
        critical: true,
        data: <String, Object?>{
          'change_amount': int.tryParse(outMoney.toString()),
          'operation': isCancel ? 'cancel' : 'complete',
        },
      );
      _paymentFlowFailed(
        failedStage: 'cash_change',
        failureType: PaymentFailureType.deviceUnavailable,
      );
      cashErrorHandle();
    }
  }

  _getPayCubeOutMoney(String currencyStringResult, bool isCancel) async {

    int queryTimes = 0;

      if(queryTimes>150){
        //如果打开了现金机，则去掉倒计时监听
        showCashTimer?.cancel();
        seconds.value = 180;
        getOutMoneyString.value == false;

        //OutMoneytimer?.cancel();
        //汇报出金币种
        reportOutMoney(isCancel);
      }

      if (getOutMoneyString.value == true) {
        // 循环一定要记得设置取消条件，手动取消
        //String currencyStringresult = await Paycube.getPayCubeOutMoneyCurrency;
        if (currencyStringResult.trim().length >= 28) {
          var outtotalAmount = MoneyParser.calculateTotalAmount(currencyStringResult.trim());
          //print("计算现金机出金金额与实际投入是否相等${outtotalAmount.toString()}");
          //print("计算现金机出金金额与实际投入是否相等${currencyStringresult}");

          if (outtotalAmount == int.parse(outStringMoney.value)) {
            _paymentStageSucceeded(
              'cash_change',
              PaymentEventCode.cashChangeSucceeded,
              'Cash change payout succeeded',
              data: <String, Object?>{
                'change_amount': outtotalAmount,
                'operation': isCancel ? 'cancel' : 'complete',
              },
            );
            //如果打开了现金机，则去掉倒计时监听
            showCashTimer?.cancel();
            seconds.value = 180;
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
      debugPrint("汇报入金币种");
      canReportFromListen = true;
      _getPayCubePutMoneyCurrency(getPutMoneyCurrency.value, true);
    }
    CashStep.value = 4;
    //取引终了结束交易
    //_countDownTimer("5");
    //await Paycube.setReceiveEvent;
    await Future.delayed(Duration(milliseconds: 550));
    _paymentStageStarted(
      'cash_transaction_close',
      PaymentEventCode.cashTransactionCloseStarted,
      'Cash transaction close started',
      data: <String, Object?>{
        'operation': isCancel ? 'cancel' : 'complete',
      },
    );
    bool result = await payCube.endTrade(onSuccess: () {
      debugPrint("endTrade onSuccess");
    }, catchError: (error) {
      debugPrint("endTrade onError");
    });
    //开启倒计时

    if (result) {
      _paymentStageSucceeded(
        'cash_transaction_close',
        PaymentEventCode.cashTransactionCloseSucceeded,
        'Cash transaction close succeeded',
        data: <String, Object?>{
          'operation': isCancel ? 'cancel' : 'complete',
        },
      );
      if (isCancel) {
        _paymentFlowCancelled(cancelledStage: 'cash_transaction_close');
      } else {
        _paymentFlowSucceeded(completionStage: 'cash_transaction_close');
      }
      showCashTimer?.cancel();
      seconds.value = 180;
      if (isCancel) {
        if (isPrint.value == true) {
          gotonewBack();
        } else {
          gotonewMenuPage();
        }
      } else {
        logger.info('payCubeCloseTransaction showSuccessAlert');
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
      _paymentStageFailed(
        'cash_transaction_close',
        PaymentEventCode.cashTransactionCloseFailed,
        'Cash transaction close failed',
        failureType: PaymentFailureType.deviceUnavailable,
        critical: true,
        data: <String, Object?>{
          'operation': isCancel ? 'cancel' : 'complete',
        },
      );
      _paymentFlowFailed(
        failedStage: 'cash_transaction_close',
        failureType: PaymentFailureType.deviceUnavailable,
      );
      cashErrorHandle();
    }

  }

  _getPayCubePutMoneyCurrency(String putCurrencyString, bool canReport) async {
    debugPrint("putCurrencyString==$putCurrencyString canReport==$canReport");
    var putQueryNum = 0;

      if(putQueryNum >100){
        //showCashTimer?.cancel();
        //putMoneyCurrencyTime.cancel();
        //汇报入金币种
        if (canReport) {
          reportPutMoneyCurrency();
          getputMoneyString.value = false;
        }

      }
      if (getputMoneyString.value == true) {
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
    
  }

  //汇报入金币种,请求后台
  reportPutMoneyCurrency({retry = true}) {
    logger.info('reportPutMoneyCurrency');
    if (isReportCash.value == true) {
      debugPrint("已汇报过");
      return;
    }

    isReportCash.value = true;
    //operation  0 确认支付  1 取消返回(券売機)　2 取消返回(精算機、自助结算)
    var operation = 0;
    if (isCancel.value == true) {
      if (machineInfo.machineMode == "1") {
        operation = 1;
      } else {
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
      "coinForbidden": Platform.isAndroid ? int.parse(machineInfo.is_allow_oneyen) : 1
    };
    final reportAttempt = retry ? 1 : 2;
    _paymentStageStarted(
      'cash_payment_report',
      PaymentEventCode.paymentReportStarted,
      'Cash payment result report started',
      data: <String, Object?>{
        'attempt': reportAttempt,
        'operation': operation,
        'inserted_amount': int.tryParse(getPutMoney.value),
        'change_amount': int.tryParse(outStringMoney.value),
      },
    );
    request('webBootToReportV1', method: 'POST', parameters: formData)
        .then((value) {
          logger.info("----上报订单成功----");
          _paymentStageSucceeded(
            'cash_payment_report',
            PaymentEventCode.paymentReportSucceeded,
            'Cash payment result report succeeded',
            data: <String, Object?>{
              'attempt': reportAttempt,
              'operation': operation,
            },
          );
          isReportCash.value = false;
    }).catchError((e) {
      //后期优化，上报失败存储本地，下次再上报。
      logger.info('reportPutMoneyCurrency error:${e.toString()}');
      debugPrint("----上报订单失败----");
      _paymentStageFailed(
        'cash_payment_report',
        PaymentEventCode.paymentReportFailed,
        retry
            ? 'Cash payment result report attempt failed'
            : 'Cash payment result report failed after retry',
        failureType: PaymentFailureType.network,
        critical: !retry,
        error: e,
        data: <String, Object?>{
          'attempt': reportAttempt,
          'operation': operation,
          'will_retry': retry,
        },
      );
      if (!retry && Platform.isAndroid) {
        // FirebaseAnalytics.instance
        //     .logEvent(name: "cash_report_error", parameters: {
        //   "machineCode": machineInfo.machineCode,
        //   "orderId": orderId.value,
        // });
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
        "machineCode": machineInfo.machineCode,
        "orderId": orderId.value,
        "price": giveChangeMoney.value,
        "coinForbidden": int.parse(machineInfo.is_allow_oneyen)
      }; //print(formData);
      request('webBootToReportV1', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200) {
        } else {}
      });
    }
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
