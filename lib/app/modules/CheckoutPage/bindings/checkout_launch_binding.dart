import 'package:get/get.dart';

import '../controllers/checkout_launch_controller.dart';

class CheckoutLaunchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutLaunchController>(
      () => CheckoutLaunchController(),
    );
  }
}