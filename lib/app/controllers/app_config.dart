import 'package:foodorder/app/plugins/paycube/lib/paycube.dart';
import 'package:foodorder/app/plugins/paycube_old/lib/paycube.dart';
import 'package:get/get.dart';

import '../config/app_variant.dart';

class AppConfig extends GetxController {
  bool get machineType => AppVariantConfig.isAndroid11;

  get payCube => machineType ? Paycube() : PayCube();
  get isAndroid11 => machineType;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
