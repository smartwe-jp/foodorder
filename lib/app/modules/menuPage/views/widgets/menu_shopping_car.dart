
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/Extension/StringExtension.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

import '../../../../config/color.dart';
import '../../../../config/colorsUtil.dart';
import '../../../../config/font.dart';
import '../../../../config/string.dart';
import '../../../../widget/CustomButton.dart';
import '../../controllers/menu_page_controller.dart';
import 'car_item_view.dart';

extension Shoppingcar on MenuPageController {

  publicCartView() {
    return ListView(
      shrinkWrap: true,
      children: showCartItems
          .map((d) => CarItemView(
        title: d.mainTitle,
        subtitle: d.optionVoListMsg,
        image: CachedNetworkImageProvider(d.image),
        onReduce: (value) {
          publicChangeCartItemCreate(d,false);
        },
        onIncrease: (value) {
          publicChangeCartItemCreate(d,true);
        },
        price: "${d.unitPrice}".formatSum(),
        quantity: d.goodsNum,))
          .toList(),
    );
  }
  shoppingCar() {
    return //全屏蒙版
      Visibility(
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
                    update();
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
                    EdgeInsets.only(bottom: ScreenAdapter.height(200)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Container(
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
                          child: Column(
                            children: [
                              Container(
                                child: Row(children: [
                                  SizedBox(width: 20,),
                                  GestureDetector(
                                    onTap: () {
                                      showShopCart = false;
                                      update();
                                    },
                                    child: Container(
                                      height: 60,
                                      child: Row(
                                        //mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(Icons.arrow_back,
                                              size: 40,
                                              color: ColorsUtil.hexToColor(Gcolor.greenThemeColor)),
                                          SizedBox(width: 4),
                                          Text(
                                            GString.getToString(
                                                checkLanguage.value, 'settlement_back'),
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: GFont.getFontFamily(),
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Spacer()
                                ]),
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight: ScreenAdapter.width(1000),
                                  maxWidth: double.infinity,
                                  minWidth: ScreenAdapter.width(500),
                                  //minHeight: ScreenAdapter.height(500),
                                ),
                                child: publicCartView(),
                              )

                            ],
                          ),
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