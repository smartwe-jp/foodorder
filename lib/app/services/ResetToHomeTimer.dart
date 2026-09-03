import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodorder/app/controllers/order_sql_controller.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_controller.dart';
import 'package:foodorder/app/routes/app_pages.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:foodorder/app/services/HomeServices.dart';
import 'package:get/get.dart';

class ResetToHomeTimer {
  Timer? _timer;
  final int timeSeconds = 180;
  int _timeoutSeconds = 180; // 3分钟

  void startTimer() {
    cancelTimer();
    logI("--startTimer--", upload: false);
    _timeoutSeconds = timeSeconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      _timeoutSeconds--;
      if (_timeoutSeconds == 0) {
        logI(
          'Inactivity countdown completed',
          upload: true,
          tag: 'InactivityTimer',
          eventCode: 'INACTIVITY_TIMER_COMPLETED',
          data: <String, Object?>{
            'route': Get.routing.current,
            'timeout_seconds': timeSeconds,
          },
        );

        if (Get.routing.current == Routes.ORDER_HOME ||
            Get.routing.current == Routes.CHECKOUT_PAGE) {
          cancelTimer();
          return;
        } else if (Get.routing.current == Routes.MENU_PAGE) {
          Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
          final isBackHome = systemSettingInfo['isBackHome'] ?? true;
          logI("timer isBackHome:$isBackHome", upload: false);
          if (isBackHome != true) {
            cancelTimer();
            if (Get.isRegistered<OrderSqlController>()) {
              final orderSqlController = Get.find<OrderSqlController>();
              orderSqlController.removeAllFromCart();

              if (Get.isRegistered<MenuPageController>()) {
                Get.find<MenuPageController>().clearOrderList();
                Get.find<MenuPageController>().resetToFirstPage();
              }
            }
            return;
          }
        } else if (Get.routing.current == Routes.SELECT_PAYMENT_PAGE ||
            Get.routing.current == Routes.SCAN_DETAIL) {
          // if (Get.isRegistered<MachineInfoController>()) {
          //   Get.find<MachineInfoController>().showReceiptPage = true;
          // }

          if (Get.isRegistered<MenuPageController>()) {
            Get.find<MenuPageController>().paymentIsShow = false;
          }

          Get.back();
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
            _returnToExistingCheckout();
          }
        } else {
          logI('--offNamedUntil--', upload: false);
          _returnToExistingCheckout();
        }
      }
    });
  }

  void _returnToExistingCheckout() {
    cancelTimer();
    Get.until(
      (route) => route.settings.name == Routes.CHECKOUT_PAGE,
    );
  }

  void resetTimer() {
    if (_timer == null && Get.routing.current == Routes.MENU_PAGE) {
      logI("event startTimer", upload: false);
      startTimer();
    } else {
      if (_timer != null) {
        logI("event resetTimer", upload: false);
        _timeoutSeconds = timeSeconds;
      }
    }
  }

  void cancelTimer() {
    logI("--cancelTimer--", upload: false);
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
