import 'package:get/get.dart';

import '../controllers/checkout_page_controller.dart';

class CheckoutPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutPageController>(
      () => CheckoutPageController(),
    );
  }
}
