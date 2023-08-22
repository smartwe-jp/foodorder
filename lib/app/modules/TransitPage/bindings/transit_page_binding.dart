import 'package:get/get.dart';

import '../controllers/transit_page_controller.dart';

class TransitPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransitPageController>(
      () => TransitPageController(),
    );
  }
}
