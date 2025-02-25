import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/modules/CheckoutPage/controllers/checkout_page_controller.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

class ScanDetailController extends GetxController with StateMixin {
  String languageKey = Get.locale?.languageCode.toUpperCase() ?? 'JP';
  String orderId = "";
  String totlaPrice = "0";
  String tableNum = "0";
  Map orderInfoMap = {};

  final CheckoutPageController checkoutPageController = Get.find();

  @override
  void onInit() {
    // final machineCode = Get.arguments['machineCode'] ?? "";
    // final orderKey = Get.arguments['orderKey'] ?? "";

    super.onInit();

    //requestOrderList(orderKey, machineCode);
  }

  @override
  void onReady() {
    super.onReady();
    change(null, status: RxStatus.success());
  }

  @override
  void onClose() {
    super.onClose();
  }

  requestOrderList(orderKey, machineCode) {
    debugPrint('requestOrderList');
    var formData = {
      "orderKey": orderKey,
      "language": languageKey,
      "machineCode": machineCode
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
          orderId = response["data"]["orderId"].toString();
          totlaPrice = response["data"]["totalPrice"].toString();
          tableNum = response["data"]["tableNum"].toString();
          orderInfoMap = response["data"]["orderInfoMap"] ?? {};
          change(null, status: RxStatus.success());
        } else {

          Get.dialog(
            barrierDismissible: false,
            DialogUtils.alertOneButton(response['msg'], confirm: () {
              Get.back();
              Get.back();
            }));
        }
      } else {
        Get.dialog(
            barrierDismissible: false,
            DialogUtils.alertOneButton(response['msg'], confirm: () {
              Get.back();
              Get.back();
            }));
        //debugPrint(response['msg']);
      }
    }).catchError((error) {
      debugPrint('webBootCalculateV2 error:${error.toString()}');
      Get.dialog(
            barrierDismissible: false,
            DialogUtils.alertOneButton(error.toString(), confirm: () {
              Get.back();
              Get.back();
            }));
    });
  }

  checkOut() {
    //checkoutPageController.detaiCheckPayment(orderId, totlaPrice, tableNum);
    checkoutPageController.showSelectMealTypeAndPaymentMethodDialog();
  }

  returnBack() {
    debugPrint("---returnBack---");
    checkoutPageController.backCheckHome();
  }
}
