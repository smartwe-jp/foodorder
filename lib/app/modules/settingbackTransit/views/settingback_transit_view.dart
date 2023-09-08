import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/settingback_transit_controller.dart';

class SettingbackTransitView extends GetView {
  final SettingbackTransitController controller = Get.put(SettingbackTransitController());
   SettingbackTransitView({Key? key}) : super(key: key);
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
