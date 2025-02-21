import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_controller.dart';
import 'package:foodorder/app/modules/menuPage/views/components/TrianglePainter.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

extension Shoppingcar on MenuPageView {
  shoppingCar() {
    return //全屏蒙版
        GetBuilder<MenuPageController>(
            id: 'shopping_cart',
            builder: (logic) {
              return //全屏蒙版
                  Visibility(
                      visible: controller.showShopCart.value,
                      //duration: Duration(milliseconds: 300),
                      child: Container(
                        width: ScreenAdapter.getScreenWidth(),
                        height: ScreenAdapter.getScreenHeight(),
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.showShopCart.value = false;
                                controller.update(['shopping_cart']);
                              },
                              child: Container(
                                width: ScreenAdapter.getScreenWidth(),
                                height: ScreenAdapter.getScreenHeight(),
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                              ),
                            ),
                            Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(
                                    bottom: ScreenAdapter.height(180)),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxHeight: ScreenAdapter.height(1000),
                                          maxWidth: ScreenAdapter.width(900),
                                          minWidth: ScreenAdapter.width(500),
                                          //minHeight: ScreenAdapter.height(500),
                                        ),
                                        //margin: EdgeInsets.only(left: ScreenAdapter.width(100),right: ScreenAdapter.width(100)),
                                        padding: EdgeInsets.only(
                                            left: ScreenAdapter.width(10),
                                            right: ScreenAdapter.width(10),
                                            top: ScreenAdapter.width(14),
                                            bottom: ScreenAdapter.width(14)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: controller.publicCartView(),
                                      ),
                                      CustomPaint(
                                        size: Size(ScreenAdapter.width(60),
                                            ScreenAdapter.height(20)),
                                        painter: TrainglePainter(),
                                      ),
                                    ]))
                          ],
                        ),
                      ));
            });
  }
}
