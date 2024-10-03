import 'package:get/get.dart';

import '../controllers/scan_detail_controller.dart';

class ScanDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanDetailController>(
      () => ScanDetailController(),
    );
  }
}