import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanDetailPageState {

  late String checkLanguage;

  ScanDetailPageState() {
    debugPrint('ScanDetailPageState');
    checkLanguage = Get.locale?.languageCode.toUpperCase() ?? 'JP';

  }
}
