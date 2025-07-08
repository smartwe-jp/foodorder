import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class ScanDetailPageLogic extends GetxController {
  final ScanDetailPageState state = ScanDetailPageState();

  @override
  void onReady() {
    // TODO: implement onReady
    debugPrint('ScanDetailPageLogic onReady');
    update();
  }
}
