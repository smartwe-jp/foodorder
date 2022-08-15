import 'package:flutter/material.dart';
import 'package:foodorder/pages/activation/Activation.dart';
import 'package:foodorder/pages/attendance/attendance.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/pages/menu/Menu.dart';
import 'package:foodorder/pages/menu/MenuZong.dart';
import 'package:foodorder/pages/setting/SettingPage.dart';
import 'package:foodorder/pages/settlement/Settlement.dart';
import 'package:foodorder/pages/showImage/ShowImage.dart';

import 'package:foodorder/pages/setting/SystemSettingPage.dart';
import 'package:foodorder/pages/transitpage/TransitPage.dart';

import 'package:foodorder/pages/checkOut/CheckOut.dart';

//配置路由
final routes = {
  '/home': (context) => HomePage(),
  '/activation': (context) => ActivationPage(),
  '/menuPage': (context,{arguments}) => MenuPage(arguments:arguments), //菜单
  '/menuZongPage': (context,{arguments}) => MenuZongPage(arguments:arguments), //菜单纵向
  "/settlement": (context,{arguments}) => SettlementPage(arguments:arguments), //结算页面
  "/settingPage": (context,{arguments}) => SettingPage(arguments:arguments), //设置页面
  "/systemSettingPage": (context,{arguments}) => SystemSettingPage(arguments:arguments), //系统设置

  '/transitPage': (context) => TransitPage(), //中转页面
  '/checkOutPage': (context) => CheckOutPage(), //精算机页面

  '/showImage': (context) => ShowImagePage(), //查看图片

  '/attendance': (context,{arguments}) => AttendancePage(arguments:arguments),//打卡


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
