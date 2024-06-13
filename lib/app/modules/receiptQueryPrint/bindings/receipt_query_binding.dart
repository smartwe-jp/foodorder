
import 'package:get/get.dart';
import '../controllers/receipt_query_controller.dart';

class ReceiptQueryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReceiptQueryController>(() => ReceiptQueryController());
  }
}