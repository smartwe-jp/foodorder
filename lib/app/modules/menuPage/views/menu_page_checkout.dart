

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/services/formatMoney.dart';

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
                top: ScreenAdapter.width(25),
                bottom: ScreenAdapter.width(25),
                right: ScreenAdapter.width(40)),
            decoration: BoxDecoration(
              color: ColorsUtil.hexToColor(Gcolor.greenThemeColor),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      print("controller.shopCartTotalPrice.value");
                      if (int.parse(controller.shopCartTotalPrice.value) <= 0) {
                        return;
                      }
                      controller.showShopCart.value = true;
                      controller.update();
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: ScreenAdapter.width(40),
                        ),
                        Container(
                          width: ScreenAdapter.width(100),
                          height: ScreenAdapter.height(100),
                          padding: EdgeInsets.all(30),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/public/shopping.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(20),
                        ),
                        Text("共计",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            )),
                        SizedBox(
                          width: ScreenAdapter.width(20),
                        ),
                        Text(
                            "¥${formatMoney(controller.shopCartTotalPrice.value)}",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            )),
                        SizedBox(
                          width: ScreenAdapter.width(40),
                        ),
                      ],
                    )),
                Spacer(),
                VerticalDivider(
                  color: Colors.white,
                  indent: 10,
                  endIndent: 10,
                  thickness: 2.0,
                ),
                InkWell(
                  onTap: () {
                    if (int.parse(controller.shopCartTotalPrice.value) <= 0) {
                      return;
                    }
                    controller.doSubmitOrder();
                  },
                  child: Container(
                      padding: EdgeInsets.only(
                          left: ScreenAdapter.width(60),
                          right: ScreenAdapter.width(60)),
                      child: Text("去结算",
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.w600))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}