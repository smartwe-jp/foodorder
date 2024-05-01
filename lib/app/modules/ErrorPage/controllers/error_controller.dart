

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../plugins/appset/lib/appset.dart';

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

  reStartApp() async {
    print("重启app");
    final result =  await Appset.restartApp;
    debugPrint("重启app返回结果：$result");
  }

}