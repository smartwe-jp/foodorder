import 'package:flutter/material.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

class WindowsTestController extends GetxController with StateMixin {
  RxString totalPrice = "".obs;
  RxString depositAmount = "".obs;
  RxString changeAmount = "".obs;
  RxBool openSuccess = false.obs;

  @override
  void onInit() {
    debugPrint("  WindowsTestController onInit  ");
    super.onInit();
  }

  @override
  void onReady() {
    debugPrint("  WindowsTestController onReady  ");
    super.onReady();
  }

  @override
  void onClose() {
    debugPrint("  WindowsTestController onClose  ");
    super.onClose();
  }

  void openCashChange() async {
    debugPrint("  openCashChange  ");
    int? resultCode = await CashChanger.openCashChanger;
    debugPrint("open CashChanger resultCode:  " + resultCode.toString());
    if (resultCode == 0) {
      openSuccess.value = true;
    } else {
      openSuccess.value = false;
    }

    Get.dialog(
        DialogUtils.alert(
            "open CashChanger resultCode:  " + resultCode.toString(),
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void closeCashChange() async {
    debugPrint("  closeCashChange  ");
    int? resultCode = await CashChanger.closeCashChanger;
    debugPrint("close CashChanger resultCode:  " + resultCode.toString());
    if (resultCode == 0) {
      openSuccess.value = false;
    } else {
      openSuccess.value = true;
    }
  }

  void GetCashBalanceInfo() async {
    debugPrint("  GetCashBalanceInfo  ");
    String? resultCode = await CashChanger.getCashBalance;
    debugPrint("GetCashBalanceInfo result:  " + resultCode!);
    Get.dialog(
        DialogUtils.alert("GetCashBalanceInfo result:  " + resultCode,
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void startDeposit() async {
    debugPrint("  StartDeposit  ");
    int? resultCode = await CashChanger.startDeposit;
    debugPrint("StartDeposit result:  " + resultCode.toString());
    Get.dialog(
        DialogUtils.alert("StartDeposit result:  " + resultCode.toString(),
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void stopDeposit() async {
    debugPrint("  StopDeposit  ");
    int? resultCode = await CashChanger.stopDeposit;
    debugPrint("StopDeposit result:  " + resultCode.toString());
    Get.dialog(
        DialogUtils.alert("StopDeposit result:  " + resultCode.toString(),
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void getDepositAmount() async {
    debugPrint("  DepositAmount  ");
    int? resultCode = await CashChanger.depositAmount;
    debugPrint("DepositAmount result:  " + resultCode.toString());

    depositAmount.value = resultCode.toString();
  }

  void getChangeAmount() async {
    debugPrint("  getChangeAmount  ");
    String? resultCode = await CashChanger.getCashBalance;
    debugPrint("getChangeAmount result:  " + resultCode!);

    changeAmount.value = resultCode.toString();
  }

  void stopDepositAndChange() async {
    debugPrint("  stopDepositAndChange  ");
    int? resultCode = await CashChanger.stopDeposit;
    debugPrint("stopDepositAndChange result:  " + resultCode.toString());

    changeAmount.value = resultCode.toString();
  }
}
