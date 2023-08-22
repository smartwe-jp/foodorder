import 'package:get/get.dart';

import '../controllers/system_setting_page_controller.dart';

class SystemSettingPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SystemSettingPageController>(
      () => SystemSettingPageController(),
    );
  }
}
