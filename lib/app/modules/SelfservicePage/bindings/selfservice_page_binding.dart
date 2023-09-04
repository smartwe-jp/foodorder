import 'package:get/get.dart';

import '../../../controllers/order_sql_controller.dart';
import '../controllers/selfservice_page_controller.dart';

class SelfservicePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfservicePageController>(
      () => SelfservicePageController(),
    );
  }
}
