
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppConfig());
  }
}