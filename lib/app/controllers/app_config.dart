import 'package:foodorder/app/plugins/paycube/lib/paycube.dart';
import 'package:foodorder/app/plugins/paycube_old/lib/paycube.dart';
import 'package:get/get.dart';

import '../config/app_variant.dart';

class AppConfig extends GetxController {
  bool get usesAndroid11PayCubePlugin => AppVariantConfig.isAndroid11;

  get payCube => usesAndroid11PayCubePlugin ? Paycube() : PayCube();
  get isAndroid11 => usesAndroid11PayCubePlugin;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
