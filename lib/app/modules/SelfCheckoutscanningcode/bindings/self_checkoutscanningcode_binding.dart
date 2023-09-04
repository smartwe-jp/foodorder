import 'package:get/get.dart';

import '../../../controllers/order_sql_controller.dart';
import '../controllers/self_checkoutscanningcode_controller.dart';

class SelfCheckoutscanningcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SelfCheckoutscanningcodeController());
    /*Get.lazyPut<SelfCheckoutscanningcodeController>(
      () => SelfCheckoutscanningcodeController(),
    );*/
  }
}
