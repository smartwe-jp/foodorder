import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/popup_cart_view.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/recommend_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/services/formatMoney.dart';
import 'package:foodorder/app/widget/KioskTap.dart';
import 'package:get/get.dart';

import '../../../../widget/DialogUtils.dart';


extension CheckoutButton on MenuPageView {
  checkOutButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: ScreenAdapter.width(240),
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
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  flex: 9,
                  child: KioskTap(
                      onTap: () {
                        print("controller.showCartTotalGoodsNum.value = ${controller.showCartTotalGoodsNum.value}");
                        if (controller.showCartTotalGoodsNum.value <= 0) {
                          _showEmptyTips();
                          return;
                        }
                        // controller.showShopCart = true;
                        controller.showCarPopView();
                        //controller.update(['shopping_cart']);
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
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
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
                            Text("tag_amount".tr,
                                style: TextStyle(
                                  fontSize: 24,
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
                                      TextSpan(text: "${formatMoney(controller.displayCartPayable)}",style: TextStyle(
                                        fontFamily: GFont.getFontFamily(),
                                        fontSize: 38,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),),
                                      TextSpan(
                                        text: "（${controller.machineInfo.taxSystem ? "show_price_front".tr : "tax_out".tr}）",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontFamily: GFont.getFontFamily(),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                          textBaseline: TextBaseline.alphabetic,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          Spacer(),
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 50,

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
                  KioskTap(
                    onTap: () {
                      if (controller.showCartTotalGoodsNum.value <= 0) {
                        _showEmptyTips();
                        return;
                      }

                      if (controller.recommendFoods.isNotEmpty) {
                        controller.showRecommendView();
                      } else {
                        controller.submitOrderFlow();
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
                        // padding: EdgeInsets.only(
                        //     left: ScreenAdapter.width(30),
                        //     right: ScreenAdapter.width(30)),
                        child: Text("tag_checkout".tr,
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
    Get.dialog(DialogUtils.alertOneButton("show_empty_cart_item_title".tr,
        title: "tag_title".tr,
        confirmtitle: "show_del_cart_item_yes".tr,
        confirm: () {
          Get.back();
        }));
  }
}
