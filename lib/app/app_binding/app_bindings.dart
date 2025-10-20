
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/services/sse_service.dart';
import 'package:foodorder/app/services/PinterCheckService.dart';
import 'package:foodorder/app/services/PrintInfoService.dart';
import 'package:get/get.dart';

import '../controllers/create_printImage_controller.dart';
import '../controllers/order_sql_controller.dart';
import '../services/PosCheckService.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    //Get.lazyPut(() => AppConfig());
    Get.lazyPut(() => OrderSqlController(), fenix: true);
    Get.lazyPut(() => SseService(), fenix: true);
    Get.lazyPut(() => PrinterCheckService(), fenix: true);
    Get.lazyPut(() => PosCheckService(), fenix: true);
    Get.lazyPut(() => PrintInfoService(), fenix: true);
    Get.lazyPut(() => CreatePrintImageController(), fenix: true);

  }
}