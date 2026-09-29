

import 'package:get/get.dart';

class ErrorPageController extends GetxController with StateMixin {

  RxString language = "jp".obs;

@override
  void onInit() {
    super.onInit();
    language.value = Get.locale?.languageCode.toUpperCase() ?? "JP";
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
