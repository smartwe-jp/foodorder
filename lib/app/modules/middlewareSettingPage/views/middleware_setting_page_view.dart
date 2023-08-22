import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/middleware_setting_page_controller.dart';

class MiddlewareSettingPageView extends GetView{
  final MiddlewareSettingPageController controller = Get.put(MiddlewareSettingPageController());
  MiddlewareSettingPageView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
