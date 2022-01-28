import 'package:flutter/material.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/pages/menu/Menu.dart';
import 'package:foodorder/pages/scanPay/ScanPay.dart';
import 'package:foodorder/pages/showImage/ShowImage.dart';

//配置路由
final routes = {
  '/home': (context) => HomePage(),
  '/menuPage': (context) => MenuPage(), //菜单
  '/scanPay': (context) => ScanPayPage(), //扫描二维码
  '/showImage': (context) => ShowImagePage(), //查看图片

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
