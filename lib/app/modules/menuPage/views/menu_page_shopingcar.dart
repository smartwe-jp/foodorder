import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/views/components/TrianglePainter.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

extension Shoppingcar on MenuPageView {
  shoppingCar() {
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
                      print("点击了全屏蒙版");
                      controller.showShopCart.value = false;
                      controller.update();
                    },
                    child: Container(
                      width: ScreenAdapter.getScreenWidth(),
                      height: ScreenAdapter.getScreenHeight(),
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                    ),
                  ),
                  Container(
                      alignment: Alignment.bottomCenter,
                      margin:
                          EdgeInsets.only(bottom: ScreenAdapter.height(180)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: ScreenAdapter.height(1000),
                                maxWidth: ScreenAdapter.width(800),
                                minWidth: ScreenAdapter.width(500),
                                //minHeight: ScreenAdapter.height(500),
                              ),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: publicCartView(),
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
  }
}
