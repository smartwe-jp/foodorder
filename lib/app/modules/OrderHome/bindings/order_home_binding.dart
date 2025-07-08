import 'package:get/get.dart';

import '../controllers/order_home_controller.dart';

class OrderHomeBinding extends Bindings {
  @override
  void dependencies() {
    //Get.put(OrderHomeController());
    Get.lazyPut<OrderHomeController>(
      () => OrderHomeController(),
    );
  }
}
