
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/services/sse_service.dart';
import 'package:foodorder/app/services/PinterCheckService.dart';
import 'package:foodorder/app/services/PrintInfoService.dart';
import 'package:foodorder/app/services/print_failed_service.dart';
import 'package:foodorder/app/services/print_task_service.dart';
import 'package:foodorder/app/services/scale_serial_service.dart';
import 'package:foodorder/app/controllers/print_task_controller.dart';
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
    Get.lazyPut(() => PrintTaskService(), fenix: true);
    Get.lazyPut(() => PrintTaskController(), fenix: true);
    Get.lazyPut(() => PrintFailedService(), fenix: true);
    // 电子秤串口（麻辣烫称重页进入时再 connect）
    Get.lazyPut(() => ScaleSerialService(), fenix: true);
  }
}