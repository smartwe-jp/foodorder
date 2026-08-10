import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_extension.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

import '../../../../models/ItemModel.dart';
import '../../controllers/menu_page_controller.dart';
import 'car_item_view.dart';

extension Shoppingcar on MenuPageController {

  publicCartView() {
    return Obx(() {
      final discount = cartDiscountYen.value;
      return ListView(
        shrinkWrap: true,
        children: [
          for (final d in showCartItems)
            CarItemView(
              key: ValueKey((d as ShopItemModel).id),
              title: d.mainTitle,
              subtitle: d.optionVoListMsg,
              image: itemImage(d.image),
              onReduce: (value) {
                publicChangeCartItemCreate(d, false);
              },
              onIncrease: (value) {
                publicChangeCartItemCreate(d, true);
              },
              // spicy 条目 currentPrice 已是算好的总价，quantity 固定 1 避免重复乘算
              price: d.itemType == 'spicy'
                  ? "${d.currentPrice}"
                  : "${d.unitPrice}",
              quantity: d.itemType == 'spicy' ? 1 : d.goodsNum,
              showQtyControls: d.itemType != 'spicy',
            ),
          if (discount > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenAdapter.width(16),
                vertical: ScreenAdapter.height(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'settlement_discount'.tr,
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(32),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE64340),
                      ),
                    ),
                  ),
                  Text(
                    '-¥$discount',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(36),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE64340),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  shoppingCar() {
    return //全屏蒙版
      GetBuilder<MenuPageController>(
          id: 'shopping_cart',
          builder: (logic) {
        return Visibility(
            visible: showShopCart,
            //duration: Duration(milliseconds: 300),
            child: Container(
              width: ScreenAdapter.getScreenWidth(),
              height: ScreenAdapter.getScreenHeight(),
              color: Color.fromRGBO(0, 0, 0, 0.5),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      showShopCart = false;
                      update(['shopping_cart']);
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
                      EdgeInsets.only(bottom: ScreenAdapter.height(220)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: ScreenAdapter.height(1000),
                                maxWidth: ScreenAdapter.width(1000),
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
                                borderRadius: BorderRadius.circular(15),
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
      });
  }
}

class TrainglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 255, 255, 255)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    // var path = Path();
    // path.moveTo(size.width / 2, 0); // 顶点
    // path.lineTo(0, size.height); // 左下角
    // path.lineTo(size.width, size.height); // 右下角
    // path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}