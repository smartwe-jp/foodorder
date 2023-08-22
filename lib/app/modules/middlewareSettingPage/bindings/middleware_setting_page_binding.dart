import 'package:get/get.dart';

import '../controllers/middleware_setting_page_controller.dart';

class MiddlewareSettingPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MiddlewareSettingPageController>(
      () => MiddlewareSettingPageController(),
    );
  }
}
