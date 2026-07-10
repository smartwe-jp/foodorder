import 'package:get/get.dart';

import '../controllers/spicy_hot_pot_checkout_controller.dart';

class SpicyHotPotModeBinding extends Bindings {
  @override
  void dependencies() {
    // 每次进入路由都强制重建 controller，确保 onInit 执行、接口重新请求
    //Get.delete<SpicyHotPotCheckoutController>(force: true);
    //Get.put<SpicyHotPotCheckoutController>(SpicyHotPotCheckoutController());
    Get.lazyPut<SpicyHotPotCheckoutController>(
          () => SpicyHotPotCheckoutController(),
    );
  }
}
