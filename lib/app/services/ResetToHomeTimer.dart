
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodorder/app/controllers/order_sql_controller.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller.dart';
import 'package:foodorder/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../modules/menuPage/controllers/menu_page_controller.dart';
import 'HomeServices.dart';

class ResetToHomeTimer {
  Timer? _timer;
  final int timeSeconds = 180;
  int _timeoutSeconds = 180; // 3分钟

  void startTimer() {
    cancelTimer();
    debugPrint("--startTimer--");
    _timeoutSeconds = timeSeconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      _timeoutSeconds--;
      if (_timeoutSeconds == 0) {
        if (Get.routing.current == Routes.ORDER_HOME ||
            Get.routing.current == Routes.CHECKOUT_PAGE) {
          cancelTimer();
          return;
        } else if (Get.routing.current == Routes.MENU_PAGE) {
          Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
          final isBackHome = systemSettingInfo['isAllowBackHome'] ?? '0';
          if (isBackHome != "0") {
            cancelTimer();

            if (Get.isRegistered<MenuPageController>()) {
              Get.find<MenuPageController>().clearOrderList();
              Get.find<MenuPageController>().resetToFirstPage();
            }

            return;
          }
        } else if (Get.routing.current == Routes.SELECT_PAYMENT_PAGE) {
          Get.back();
          if (Get.isRegistered<MenuPageController>()) {
            Get.find<MenuPageController>().paymentIsShow = false;
            Get.find<MenuPageController>().clearOrderList();
            Get.find<MenuPageController>().resetToFirstPage();
          }
          return;
        }

        Get.updateLocale(Locale('jp', 'JP'));
        //清空购物车
        if (Get.isRegistered<OrderSqlController>()) {
          final ordersqlcontroller = Get.find<OrderSqlController>();
          ordersqlcontroller.removeAllFromCart();
          ordersqlcontroller.getCardList();
        }

        if (Get.currentRoute == Routes.SETTLEMENT) {
          if (Get.isRegistered<SettlementController>()) {
            Get.find<SettlementController>().commonCancel();
            Get.back();
          } else {
            Get.offNamedUntil('/transit-page', (route) => route.isFirst);
          }
        } else {
          debugPrint('--offNamedUntil--');
          Get.offNamedUntil('/transit-page', (route) => route.isFirst);
        }
      }
    });
  }

  void resetTimer() {

    if (_timer == null && Get.routing.current == Routes.MENU_PAGE) {
      debugPrint("event startTimer");
      startTimer();
    } else {
      if (_timer != null) {
        debugPrint("event resetTimer");
        _timeoutSeconds = timeSeconds;
      }
    }
  }

  void cancelTimer() {
    debugPrint("--cancelTimer--");
    _timer?.cancel();
    _timer = null;
  }
}

typedef AppBuilder = Widget Function(
    BuildContext context, ResetToHomeTimer resetTimer);

class GlobalEventListener extends StatefulWidget {
  final AppBuilder appBuilder;

  const GlobalEventListener({Key? key, required this.appBuilder})
      : super(key: key);

  @override
  _GlobalEventListenerState createState() => _GlobalEventListenerState();
}

class _GlobalEventListenerState extends State<GlobalEventListener> {
  final ResetToHomeTimer _resetTimer = ResetToHomeTimer();

  @override
  void initState() {
    super.initState();
    //_resetTimer.startTimer();
  }

  @override
  void dispose() {
    _resetTimer.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer.resetTimer(),
      onPointerMove: (_) => _resetTimer.resetTimer(),
      onPointerUp: (_) => _resetTimer.resetTimer(),
      child: widget.appBuilder(context, _resetTimer),
    );
  }
}