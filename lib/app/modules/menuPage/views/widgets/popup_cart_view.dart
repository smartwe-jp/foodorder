
import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/menu_shopping_car.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../services/CustomLogerHandler.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../controllers/menu_page_controller.dart';
import 'menu_sheet_views.dart';

extension PopupCartView on MenuPageController {
  showCarPopView() {
    logI("---showCarPopView---");
    final sheetContext = Get.context;
    if (sheetContext == null) return;
    showCartView = true;
    showModalBottomSheet<void>(
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        context: sheetContext,
        constraints: BoxConstraints(
            minHeight: ScreenAdapter.height(400),
            //maxHeight: ScreenAdapter.height(1000),
            minWidth: double.infinity),
        builder: (BuildContext context) {
          return CartSheetView(
            controller: this,
            cartBuilder: (_) => publicCartView(),
          );
        }).whenComplete(() {
      logI("showCarPopView onComplete");
      showCartView = false;
    });
  }
}