import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/machine_info_controller.dart';
import 'package:foodorder/app/services/CashChangerService.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/DialogUtils.dart';
import '../../menuPage/views/SelectPayment.dart';

class CheckoutPageController extends GetxController
    with StateMixin, GetTickerProviderStateMixin {

  TextEditingController scanQrCodeController = new TextEditingController();
  FocusNode scanQrCodeFocusNode = FocusNode();

  TextEditingController scanQrCode2Controller = new TextEditingController();
  FocusNode scanQrCode2FocusNode = FocusNode();

  MachineInfoController machineInfo = Get.find();

  RxString isReservation = "0".obs;
  RxBool showOpenPayment = false.obs;

  String get selectLanguage {
    return Get.locale?.languageCode.toUpperCase() ?? 'JP';
  }

  RxString orderId = "".obs;
  RxString totlaPrice = "0".obs;
  RxString tableNum = "0".obs;
  RxMap orderInfoMap = {}.obs;

  late AnimationController animationController;
  late Animation<double> animation;

  final logger = Logger('CheckoutPageController');

  @override
  void onInit() {
    logger.info("CheckoutPageController new init");
    //logger.info("localkey = $localkey");
    super.onInit();
    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    _createAnimation();
  }

  @override
  void onReady() {
    logger.info("CheckoutPageController onReady");
    super.onReady();
  }

  @override
  void onClose() {
    //stopRepeatingAnimation();
    logger.info("CheckoutPageController onClose");
    animationController.dispose();
    super.onClose();
  }

  _createAnimation() {
    logger.info("createAnimation");

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // 循环动画，反向重复

    animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    change(null, status: RxStatus.success());
  }


  showOrderEasyLoading() {
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

  _showDialogError(msg) {
    debugPrint("showDialogError $msg & $selectLanguage");
    Get.dialog(DialogUtils.alertOneButton(msg,
        title: GString.getToString(selectLanguage, "tag_title"),
        confirmtitle: GString.getToString(selectLanguage, "tag_button_yes"),
        contentTagImg: "error_public", confirm: () {
      Get.back();
    }));
  }

  _getOrderKey(qrCodeString) {
    RegExp regExp = new RegExp(r"\?p=(.*)");
    return regExp.stringMatch(qrCodeString).toString().substring(3);
  }

  String formatSum(int sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }

  

  requestOrderList({goDetail = true}) async {
    debugPrint('qrCodeString: ${scanQrCode2Controller.text}');

    String orderKey = scanQrCode2Controller.text;
    if (orderKey.isEmpty) return;

    if (orderKey.contains('?p=') == true) {
      //正则实现截取'?p='之后的字符串
      orderKey = _getOrderKey(scanQrCode2Controller.text);
    }

    debugPrint('orderKey : $orderKey');
    // textController.text = "";
    // focus.requestFocus();

    // debugPrint('/scan-detail');
    // Get.toNamed('/scan-detail',
    //     arguments: {'machineCode': machineCode.value, 'orderKey': orderKey});

    // return;
    var formData = {
      "orderKey": orderKey,
      "language": selectLanguage,
      "machineCode": machineInfo.machineCode
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
          response["data"]["orderId"] != null) {
        if (response["data"]["totalPrice"] >= 0) {
          // scanQrCodeController.text = "";
          // scanQrCodeFocusNode.requestFocus();
          orderId.value = response["data"]["orderId"].toString();
          totlaPrice.value = response["data"]["totalPrice"].toString();
          tableNum.value = response["data"]["tableNum"].toString();
          orderInfoMap.value = response["data"]["orderInfoMap"] ?? {};

          if (goDetail) {
            debugPrint('/scan-detail');
            Get.toNamed('/scan-detail');
          } else {
            update();
          }

          // scanQrCode2Controller.text = "";
          // scanQrCode2FocusNode.requestFocus();
        } else {
          scanQrCode2Controller.text = "";
          scanQrCode2FocusNode.requestFocus();
        }
      } else {
        scanQrCode2Controller.text = "";

        _showDialogError(response['msg']);
        scanQrCode2FocusNode.requestFocus(); // 获取焦点
      }
    }).catchError((error) {
      print('webBootCalculateV2 error:${error.toString()}');
    });
  }


  submitOrderFlow() async {
    if (machineInfo.isAllowCash == true && machineInfo.cashOn == false) {
      showOrderEasyLoading();
      bool result = await Cashchangerservice.checkMachineFlow();
      EasyLoading.dismiss();
      if (result) {
        machineInfo.cashOn = true;
        machineInfo.showCash = true;
        update();
      }
    }
    showSelectMealTypeAndPaymentMethodDialog();
  }

  doNextPay() {
    var _orderkey = scanQrCodeController.text; //print(_orderkey);
    if (scanQrCodeController.text != "") {
      //_showOrderEasyLoading();
      if (scanQrCodeController.text.contains('?p=') == true) {
        //正则实现截取'?p='之后的字符串
        _orderkey = _getOrderKey(scanQrCodeController.text);
      }
      //自定义声音
      //playQRScannerSound();

      var formData = {"orderKey": _orderkey};
      request('webBootCalculate', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();
        //print(response);
        if (response['code'] == 200 &&
            response["data"] != null &&
            response["data"].isNotEmpty) {
          if (response["data"]["totalPrice"] > 0) {
            orderId.value = response["data"]["orderId"].toString();
            totlaPrice.value = response["data"]["totalPrice"].toString();
            tableNum.value = response["data"]["tableNum"].toString();
            showSelectMealTypeAndPaymentMethodDialog();
          } else {
            scanQrCodeController.text = "";
            scanQrCodeFocusNode.requestFocus();
          }
        } else {
          scanQrCodeController.text = "";

          _showDialogError(response['msg']);
          scanQrCodeFocusNode.requestFocus(); // 获取焦点
        }
      });
    }
  }

  doNextHomePay() {
    var _orderkey = scanQrCodeController.text; //print(_orderkey);
    if (scanQrCodeController.text != "") {
      //_showOrderEasyLoading();
      if (_orderkey.contains('?p=') == true) {
        //正则实现截取'?p='之后的字符串
        _orderkey = _getOrderKey(scanQrCodeController.text);
      }
      //自定义声音
      //playQRScannerSound();

      var formData = {"orderKey": _orderkey};
      request('webBootCalculate', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();
        //print(response);
        if (response['code'] == 200 &&
            response["data"] != null &&
            response["data"].isNotEmpty) {
          if (response["data"]["totalPrice"] > 0) {
            orderId.value = response["data"]["orderId"].toString();
            totlaPrice.value = response["data"]["totalPrice"].toString();
            tableNum.value = response["data"]["tableNum"].toString();
            showSelectMealTypeAndPaymentMethodDialog();
          } else {
            scanQrCodeController.text = "";
            scanQrCodeFocusNode.requestFocus();
          }
        } else {
          scanQrCodeController.text = "";

          _showDialogError(response['msg']);
          scanQrCodeFocusNode.requestFocus(); // 获取焦点
        }
      });
    }
  }

  detaiCheckPayment(iOrderId, iTotlaPrice, iTableNum) {
    orderId.value = iOrderId;
    totlaPrice.value = iTotlaPrice;
    tableNum.value = iTableNum;
    showSelectMealTypeAndPaymentMethodDialog();
  }

  //选择食用方式和支付方式
  showSelectMealTypeAndPaymentMethodDialog() async {
    scanQrCodeFocusNode.requestFocus();
    debugPrint('localkey = $selectLanguage');
    //scanQrCodeHomeFocusNode.requestFocus();
    machineInfo.showReceiptPage = machineInfo.isReceiptPageShow;
    debugPrint('showReceiptPage = ${machineInfo.showReceiptPage}');
    Get.to(
      () => SelectPaymentPage(
          checkLanguage: selectLanguage, //padding and need improve
          menuCount: 0,
          //mealType:_mealType,
          shopCartTotalPrice: totlaPrice.value,
          tableNum: tableNum.value,
          onConfrimClick: () async {
            //checkLanguage.value = "JP";
            scanQrCodeController.text = "";
            //scanQrCodeHomeController.text = "";
            showOpenPayment.value = true;

            goToSettlement();
          },
          onCancelClick: (String isBack) {
            if (isBack == "back") {
              scanQrCodeController.text = "";
              //scanQrCodeHomeController.text = "";
            }
            scanQrCodeFocusNode.requestFocus(); // 获取焦点
            //scanQrCodeHomeFocusNode.requestFocus(); // 获取焦点
          }),
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
      "machineCode": machineInfo.machineCode,
    };
    request('webBootToPayConfirm', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200 &&
          response['data'] != null &&
          response['data']['orderId'] != null) {
        orderId.value = response['data']["orderId"];
        print(orderId.value);
        //goToSettlement();
      } else {
        //showToast(response['data']["message"]);
        Get.dialog(DialogUtils.alertOneButton("${response['data']["message"]}",
            title: GString.getToString(selectLanguage, "tag_title"),
            confirmtitle: GString.getToString(selectLanguage, "tag_button_yes"),
            confirm: () {
          Get.back();
        }));
      }
    });
  }

  getPosSettingInfo() async {
    // Map posSettingInfo = await HomeServices.getPosSettingInfo();
    // pos_ip.value = posSettingInfo['posIp'];
    // pos_port.value = posSettingInfo['posPort'];
    //postNewOrderId();
    goToSettlement();
  }

  goToSettlement() async {
    scanQrCodeController.text = "";
    //scanQrCodeHomeController.text = "";
    final result =
        await Get.toNamed('/settlement', preventDuplicates: false, arguments: {
      "checkLanguage": selectLanguage, //padding and need improve,
      "orderId": orderId.value,
      "totalPrice": totlaPrice.value,
      "machineMode": "2",
      "showOpenPayment": showOpenPayment.value
    });
    if (result == true) {
      debugPrint('settlement back');
      Get.back();
      requestOrderList(goDetail: false);
    }
  }

  backCheckHome() {
    debugPrint("---backCheckHome---");
    Get.back();
    scanQrCodeController.text = "";
    scanQrCodeFocusNode.requestFocus();
    scanQrCode2Controller.text = "";
    scanQrCode2FocusNode.requestFocus();
  }
}
