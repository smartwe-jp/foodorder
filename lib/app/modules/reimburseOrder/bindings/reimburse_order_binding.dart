import 'package:get/get.dart';

import '../controllers/reimburse_order_controller.dart';

class ReimburseOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReimburseOrderController>(
      () => ReimburseOrderController(),
    );
  }
}
