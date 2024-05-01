

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../controllers/error_controller.dart';

class ErrorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ErrorPageController>(() => ErrorPageController());
  }
}