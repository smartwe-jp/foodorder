import 'package:get/get.dart';

import '../controllers/settingback_transit_controller.dart';

class SettingbackTransitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingbackTransitController>(
      () => SettingbackTransitController(),
    );
  }
}
