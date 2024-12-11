import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/GetxStorage.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/Storage.dart';
import '../../../services/showToast.dart';

class ActivationController extends GetxController {
  //TODO: Implement ActivationController
  TextEditingController machineCodeController=TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void onInit() {
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
    Future.delayed(Duration(milliseconds: 300), () {
      Get.toNamed("/transit-page", arguments: {"loadActive": true, "machineCode":machineCodeController.text});
    });
  }

  //把机器码保存到本地
  sendActivationCode() async {
    if (machineCodeController.text == null || machineCodeController.text.length != 18) {
      showToast('コードを入力してください。');
      //Get.snackbar("お知らせ","コードを入力してください。",maxWidth: ScreenAdapter.width(500),duration: const Duration(milliseconds: 1500));
    }else {
      _goMain();

    }
  }

}
