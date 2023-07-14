import 'package:flutter/material.dart';
import 'package:foodorder/pages/activation/Activation.dart';
import 'package:foodorder/pages/attendance/attendance.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/pages/menu/Menu.dart';
import 'package:foodorder/pages/menu/MenuZong.dart';
import 'package:foodorder/pages/setting/SettingPage.dart';
import 'package:foodorder/pages/settlement/Settlement.dart';

import 'package:foodorder/pages/attendance/setAttendanceCode.dart';
import 'package:foodorder/pages/setting/SystemSettingPage.dart';
import 'package:foodorder/pages/transitpage/TransitPage.dart';

import 'package:foodorder/pages/checkOut/CheckOut.dart';

import '../pages/checkOut/ScanCode.dart';
import '../pages/selfServiceSettlement/SelfServiceHome.dart';
import '../pages/selfServiceSettlement/SelfServiceScanCode.dart';
import '../pages/setting/MiddlewareSettingPage.dart';

//配置路由
final routes = {
  '/home': (context) => HomePage(),
  '/activation': (context) => ActivationPage(),
  '/menuPage': (context,{arguments}) => MenuPage(arguments:arguments), //菜单
  '/menuZongPage': (context,{arguments}) => MenuZongPage(arguments:arguments), //菜单纵向
  "/settlement": (context,{arguments}) => SettlementPage(arguments:arguments), //结算页面
  "/settingPage": (context,{arguments}) => SettingPage(arguments:arguments), //设置页面
  "/middlewareSettingPage": (context,{arguments}) => MiddlewareSettingPage(arguments:arguments), //中转进入设置页面
  "/systemSettingPage": (context,{arguments}) => SystemSettingPage(arguments:arguments), //系统设置

  '/transitPage': (context) => TransitPage(), //中转页面
  '/checkOutPage': (context) => CheckOutPage(), //精算机页面

  '/selfServiceHomePage': (context) => selfServiceHomePage(), //自助结算机页面
  '/selfServiceScanCodePage': (context,{arguments}) => selfServiceScanCodePage(arguments:arguments), //扫码菜单

  '/scanCodePage': (context,{arguments}) => ScanCodePage(arguments:arguments), //精算扫码页面

  '/attendance': (context,{arguments}) => AttendancePage(arguments:arguments),//打卡
  '/setAttendanceCode': (context,{arguments}) => setAttendanceCodePage(arguments:arguments),//打卡


};

//固定写法
var onGenerateRoute = (RouteSettings settings) {
// 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
      MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
