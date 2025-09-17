
import 'package:flutter/cupertino.dart';
import 'package:foodorder/app/plugins/paycube/lib/paycube.dart';
import 'package:foodorder/app/plugins/paycube_old/lib/paycube.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppConfig extends GetxController {

  bool isFx = false; // whether it's a franchise store
  bool machineType = true; // true for new_panel, false for old_panel
  //get android version
  String androidVersion = '7';

  get payCube => machineType ? Paycube() : PayCube();
  get isAndroid11 => machineType;

  @override
  Future<void> onInit() async {
    super.onInit();
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    androidVersion = androidInfo.version.release;
    final majorVersion = int.tryParse(androidVersion.split('.').first) ?? 7;
    machineType = majorVersion >= 11;
    debugPrint("Android version: $androidVersion, machineType: $machineType");
  }

  @override
  void onClose() {
    super.onClose();
  }
}