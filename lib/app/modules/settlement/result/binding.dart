import 'package:get/get.dart';

import 'logic.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultLogic>(() => ResultLogic());
  }
}
