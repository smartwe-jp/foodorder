import 'package:get/get.dart';

import '../controllers/cash_machine_check_controller.dart';

class CashMachineCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CashMachineCheckController());
  }
}
