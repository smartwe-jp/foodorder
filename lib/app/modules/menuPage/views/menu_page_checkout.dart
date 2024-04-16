import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/services/formatMoney.dart';
import 'package:get/get.dart';

import '../../../widget/DialogUtils.dart';

extension CheckoutButton on MenuPageView {
  checkOutButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: ScreenAdapter.width(200),
        ),
        Expanded(
          child: Container(
            height: ScreenAdapter.height(150),
            margin: EdgeInsets.only(
                //top: ScreenAdapter.width(15),
                //bottom: ScreenAdapter.width(15),
                right: ScreenAdapter.width(40)),
            decoration: BoxDecoration(
              color: ColorsUtil.hexToColor(Gcolor.greenThemeColor),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  flex: 9,
                  child:                 InkWell(
                    onTap: () {
                      print("controller.shopCartTotalPrice.value");
                      if (int.parse(controller.shopCartTotalPrice.value) <= 0) {
                        _showEmptyTips();
                        return;
                      }
                      controller.showShopCart.value = true;
                      controller.update();
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: ScreenAdapter.width(10),
                        ),
                        Stack(
                          children: [
                            Container(
                                width: ScreenAdapter.width(120),
                                height: ScreenAdapter.height(120),
                                padding: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                child: 
                                 Container(
                                  decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/public/home_shoppingcar.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                )
                            ),
                            

                            if (controller.showCartTotalGoodsNum.value > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: ScreenAdapter.width(40),
                                  height: ScreenAdapter.width(40),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    "${controller.showCartTotalGoodsNum}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(20),
                        ),
                        if (controller.showCartTotalGoodsNum.value > 0)
                          Text("共计",
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: GFont.getFontFamily(),
                                color: Colors.white,
                              )),
                        SizedBox(
                          width: ScreenAdapter.width(20),
                        ),
                        if (controller.showCartTotalGoodsNum.value > 0)
                        Align(
                          alignment: Alignment.center,
                          child: 
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(text: '￥', style: TextStyle(
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),),
                                TextSpan(text: "${formatMoney(controller.shopCartTotalPrice.value)}",style: TextStyle(
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: 38,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),),
                              ],
                            ),
                          )
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(40),
                        ),
                      ],
                    )),
                ),
                
                VerticalDivider(
                  color: Colors.white,
                  indent: 10,
                  endIndent: 10,
                  thickness: 2.0,
                ),

                Expanded(
                  flex: 4,
                  child: 
                    InkWell(
                      onTap: () {
                        if (int.parse(controller.shopCartTotalPrice.value) <= 0) {
                          _showEmptyTips();
                          return;
                        }
                        controller.doSubmitOrder();
                      },
                      child: Container(
                          alignment: Alignment.center,
                          // padding: EdgeInsets.only(
                          //     left: ScreenAdapter.width(30),
                          //     right: ScreenAdapter.width(30)),
                          child: Text("去结算",
                              style: TextStyle(
                                  fontSize: 48,
                                  color: Colors.white,
                                  fontFamily: GFont.getFontFamily(),
                                  fontWeight: FontWeight.w500))),
                    ),
                  ),

                
              ],
            ),
          ),
        ),
      ],
    );
  }

  _showEmptyTips() {
    Get.dialog(DialogUtils.alertOneButton("购物车空空如也",
        title: GString.getToString(controller.checkLanguage.value, "tag_title"),
        confirmtitle: GString.getToString(
            controller.checkLanguage.value, "show_del_cart_item_yes"),
        confirm: () {
      Get.back();
    }));
  }
}
