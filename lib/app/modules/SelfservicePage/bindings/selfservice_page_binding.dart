import 'package:get/get.dart';

import '../controllers/selfservice_page_controller.dart';

class SelfservicePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfservicePageController>(
      () => SelfservicePageController(),
    );
  }
}
