
import 'package:foodorder/app/plugins/paycube/lib/paycube.dart';
import 'package:foodorder/app/plugins/paycube_old/lib/paycube.dart';
import 'package:get/get.dart';

class AppConfig extends GetxController {

  bool machineType = true; // true for new_panel, false for old_panel

  get payCube => machineType ? Paycube() : PayCube();
  get isAndroid11 => machineType;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}