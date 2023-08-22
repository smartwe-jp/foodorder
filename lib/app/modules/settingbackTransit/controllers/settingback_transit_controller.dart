import 'package:get/get.dart';

class SettingbackTransitController extends GetxController {
  //TODO: Implement SettingbackTransitController

  final count = 0.obs;
  @override
  void onInit() {print("setting中转过来跳转");
    _goMain();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _goMain() async {

    Future.delayed(Duration(milliseconds: 100), () {
      Get.toNamed("/transit-page");
    });

  }
}
