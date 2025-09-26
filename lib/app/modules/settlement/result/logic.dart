import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/CustomLogerHandler.dart';
import 'state.dart';

class ResultLogic extends GetxController {
  final ResultState state = ResultState();
  final MachineInfoController machineInfo = Get.find();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
  }

  void onReady() {
    super.onReady();
    _checkToCloseLoading();
  }

  void _checkToCloseLoading() async {
    if (EasyLoading.isShow) {
      logI('--Dismissing EasyLoading--');
      try {
        await EasyLoading.dismiss();
      } catch (e) {
        logW('EasyLoading.dismiss error: $e');
      }
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final v = state.secondsLeft.value - 1;
      if (v <= 0) {
        state.secondsLeft.value = 0;
        //state.countdownMessage.value = "ありがとうございました！";
        _cancelTimer();
        if (Get.isOverlaysClosed == false && Get.routing.isBack == false) {
          returnToHome();
        } else {
          if (Get.key.currentState?.canPop() == true) {
            returnToHome();
          }
        }
      } else {
        state.secondsLeft.value = v;
      }
    });
  }

  void manualBack() {
    _cancelTimer();
    if (Get.key.currentState?.canPop() == true) {
      returnToHome();
    } else {
      returnToHome();
    }
  }

  void returnToHome() async {
    logI('---returnToHome--- machineInfo.currentMode = ${machineInfo.currentMode}， is_back_home = ${machineInfo.isBackHome}');
    switch (machineInfo.currentMode) {
      case MachineMode.sell:
      case MachineMode.takeout:
        if (machineInfo.isBackHome == "0") {
          await Get.offNamedUntil(Routes.CHECKOUT_PAGE, (route) => route.settings.name == Routes.TRANSIT_PAGE);
        } else {
          await Get.offNamedUntil(Routes.MENU_PAGE, (route) => route.settings.name == Routes.CHECKOUT_PAGE);
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

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onClose() {
    _cancelTimer();
    super.onClose();
  }
}
