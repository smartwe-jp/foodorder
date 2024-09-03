import 'package:flutter/material.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

class WindowsTestController extends GetxController with StateMixin {
  RxString totalPrice = "".obs;
  RxString depositAmount = "".obs;
  RxString changeAmount = "0".obs;
  RxBool openSuccess = false.obs;
  RxInt getPutMoney = 0.obs;

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
    bool result = await CashChanger.openCashChanger(
      onSuccess: () async {
        debugPrint("OpenPayCube 6");
      },
      catchError: (retCode, error) async {
        debugPrint("OpenPayCube error: $error");
      },
    );

    debugPrint("open CashChanger resultCode:  $result");
    if (result) {
      openSuccess.value = true;
    } else {
      openSuccess.value = false;
    }

    Get.dialog(
        DialogUtils.alert("open CashChanger resultCode: $result",
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
      openSuccess.value = false;
    }
    Get.dialog(
        DialogUtils.alert(
            "close CashChanger resultCode:  " + resultCode.toString(),
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  void GetCashBalanceInfo() async {
    debugPrint("  GetCashBalanceInfo  ");
    String? resultCode = ""; //await CashChanger.getCashBalance;
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
    bool result = await CashChanger.startDeposit(
      onSuccess: () {
        _getInputMoney();
      },
      catchError: (error) => {},
    );

    Get.dialog(
        DialogUtils.alert("StartDeposit result:  ${result}",
            title: "CashChanger", confirm: () {
          Get.back();
        }, cancle: () {
          Get.back();
        }),
        barrierDismissible: false);
  }

  _getInputMoney() async {
    //await Paycube.setReceiveEvent;
    debugPrint("getPutInMoney");
    CashChanger.onGetPutMoneyStringChange = (int result) {
      debugPrint("onGetPutMoneyStringChange");
      if (result > 0) {
        debugPrint("getPutMoney.value==${result.toString()}");
        getPutMoney.value = result;
        changeAmount.value = result.toString();
        update();
        //_getInputMoneyInfo();
      }
    };
  }

  void stopDeposit() async {
    debugPrint("  StopDeposit  ");
    int? resultCode = await CashChanger.endDeposit(2);
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
    String? resultCode = "";
    //await CashChanger.getCashBalance;
    debugPrint("getChangeAmount result:  " + resultCode!);

    changeAmount.value = resultCode.toString();
  }

  void stopDepositAndChange() async {
    debugPrint("  stopDepositAndChange  ");
    int? resultCode = await CashChanger.endDeposit(2);
    debugPrint("stopDepositAndChange result:  " + resultCode.toString());

    changeAmount.value = resultCode.toString();
  }

  // void dispenseChange() async {
  //   debugPrint("  dispenseChange  ");
  //   int? resultCode = await CashChanger.dispenseChange;
  //   debugPrint("dispenseChange result:  " + resultCode.toString());
  //   Get.dialog(
  //       DialogUtils.alert("dispenseChange result:  " + resultCode.toString(),
  //           title: "CashChanger", confirm: () {
  //         Get.back();
  //       }, cancle: () {
  //         Get.back();
  //       }),
  //       barrierDismissible: false);
  // }

  void depositRepay() async {
    debugPrint("  depositRepay  ");
    int? resultCode = await CashChanger.depositRepay;
    if (resultCode == 0) {
      depositAmount.value = "0";
    }
    debugPrint("depositRepay result:  " + resultCode.toString());
  }
}
