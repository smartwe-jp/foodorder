import 'package:foodorder/app/controllers/order_sql_controller.dart';
import 'package:get/get.dart';

import '../controllers/menu_page_controller.dart';

class MenuPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OrderSqlController()); //Fix crash when tap takeout
    //Get.put(MenuPageController());
    Get.lazyPut<MenuPageController>(
      () => MenuPageController(),
    );
  }
}
