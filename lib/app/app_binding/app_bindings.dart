
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/modules/TransitPage/controllers/sse_service.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppConfig());
    Get.lazyPut(() => SseService());
  }
}