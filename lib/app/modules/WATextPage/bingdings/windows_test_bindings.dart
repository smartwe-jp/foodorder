import 'package:foodorder/app/modules/WATextPage/controllers/windows_test_controller.dart';
import 'package:get/get.dart';

class WindowsTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WindowsTestController>(
      () => WindowsTestController(),
    );
  }
}
