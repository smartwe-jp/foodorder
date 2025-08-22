
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/modules/TransitPage/controllers/sse_service.dart';
import 'package:foodorder/app/services/PinterCheckService.dart';
import 'package:get/get.dart';

import '../controllers/order_sql_controller.dart';
import '../services/PosCheckService.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppConfig());
    Get.lazyPut(()=> OrderSqlController());
    Get.lazyPut(() => SseService());
    Get.lazyPut(() => PrinterCheckService());
    Get.lazyPut(() => PosCheckService());
  }
}