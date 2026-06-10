import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/recommend_view.dart';
import 'package:foodorder/app/widget/KioskTap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/fontSize.dart';
import '../../../models/ItemModel.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../widget/DialogUtils.dart';
import '../controllers/menu_page_controller.dart';

class publicShowCartView extends GetView {
  final MenuPageController controller = Get.find();
  publicShowCartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MenuPageController>(
        id: 'shopping_cart',
        builder: (controller){
        return Obx(() => RepaintBoundary(
          child: Container(
            child: Container(
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(5),
                  top: ScreenAdapter.height(2),
                  right: ScreenAdapter.width(5),
                  bottom: ScreenAdapter.height(2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 9,
                    child: KioskTap(
                        onTap: () {
                          print("controller.showCartTotalGoodsNum.value = ${controller.showCartTotalGoodsNum.value}");
                          if (controller.showCartTotalGoodsNum.value <= 0) {
                            //_showEmptyTips();
                            return;
                          }
                          controller.showCarPopView();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: ScreenAdapter.width(10),
                            ),
                            Stack(
                              children: [
                                Container(
                                    width: ScreenAdapter.width(160),
                                    height: ScreenAdapter.height(160),
                                    padding: EdgeInsets.all(15),
                                    alignment: Alignment.center,
                                    child:
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/public/shopping-cart.png'),
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
                                      width: ScreenAdapter.width(60),
                                      height: ScreenAdapter.width(60),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: AutoSizeText(
                                        "${controller.showCartTotalGoodsNum}",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 38,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(60),
                            ),
                            if (controller.showCartTotalGoodsNum.value > 0)
                              Text("settlement_total_price".tr,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: GFont.getFontFamily(),
                                    color: Colors.black,
                                  )),

                            if (controller.showCartTotalGoodsNum.value > 0)
                              Align(
                                  alignment: Alignment.center,
                                  child:
                                  RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: '￥', style: TextStyle(
                                          fontFamily: GFont.getFontFamily(),
                                          fontSize: 36,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),),
                                        TextSpan(text: "${formatMoney(controller.shopCartTotalPrice.value)}",style: TextStyle(
                                          fontFamily: GFont.getFontFamily(),
                                          fontSize: 50,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
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
                            SizedBox(
                              width: ScreenAdapter.width(40),
                            ),
                          ],
                        )),
                  ),

                  Container(
                    width: ScreenAdapter.width(340),
                    child:
                        KioskTap(
                          
                          onTap: () {
                            if (int.parse(controller.shopCartTotalPrice.value) < 0) {
                              return;
                            }
                            if (controller.recommendFoods.isNotEmpty) {
                              controller.showRecommendView();
                            } else {
                              controller.submitOrderFlow();
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(300),
                            height: ScreenAdapter.height(145),
                            //margin: EdgeInsets.only(bottom: ScreenAdapter.height(10)),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(

                              color: (int.parse(controller.shopCartTotalPrice.value) >=0) ?ColorsUtil.hexToColor("#A61C1C") :ColorsUtil.hexToColor("#B1B0B0"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            child: Text("settlement_button".tr,
                                style:

                                TextStyle(
                                  fontSize: ScreenAdapter.fontSize(48),
                                  fontFamily: GFont.getFontFamily(),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.settlementBtnColor),
                                )
                            ),
                          ),
                        ),

                  ),
                  SizedBox(width: 20.w,)
                ],
              ),
            ),
          ),
        ));
      }),
    );
  }
}