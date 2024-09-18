import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/imageData.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/CheckoutPage/controllers/checkout_page_controller.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

// GString.getToString(
//                                   controller.checkLanguage.value,
//                                   "checkoutScanTitle"
class ScanDetailView extends GetView<CheckoutPageController> {
  _orderItem(title, qty) {
    return Container(
      padding: EdgeInsets.only(
        top: ScreenAdapter.height(10),
        bottom: ScreenAdapter.height(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: ScreenAdapter.width(500),
            child: Text('$title',
                maxLines: 2,
                style: TextStyle(
                  fontFamily: GFont.getFontFamily(),
                  fontSize: ScreenAdapter.fontSize(40),
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                )),
          ),
          SizedBox(width: ScreenAdapter.width(30)),
          Text('x $qty',
              style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(30),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              )),
        ],
      ),
    );
  }

  _publicSplitLine() {
    return Container(
      width: ScreenAdapter.width(500),
      //margin: EdgeInsets.only(top: 5, bottom: 5),
      height: 1,
      color: ColorsUtil.hexToColor("#000000"),
      //width: 375,
    );
  }

  Widget _tableNumber(number) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("桌号：",
            style: TextStyle(
                //color: ColorsUtil.hexToColor("#FFFFFF"),
                fontWeight: FontWeight.w600,
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(34.0))),
        Text(number,
            style: TextStyle(
                color: const Color.fromARGB(255, 161, 17, 6),
                fontWeight: FontWeight.w600,
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(40.0)))
      ],
    ));
  }

  Widget _payCountTitle(int count) {
    return Container(
        padding: EdgeInsets.only(
            left: ScreenAdapter.width(150), right: ScreenAdapter.width(150)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("总额：",
                style: TextStyle(
                    //color: ColorsUtil.hexToColor("#FFFFFF"),
                    fontWeight: FontWeight.w600,
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(40.0))),
            SizedBox(
              width: ScreenAdapter.width(20),
            ),
            Text('¥ ${controller.formatSum(count)}',
                style: TextStyle(
                    color: const Color.fromARGB(255, 161, 17, 6),
                    fontWeight: FontWeight.w600,
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(50.0)))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CheckoutPageController>(builder: (controller) {
        return controller.obx(
          (state) => AnnotatedRegion(
            value: SystemUiOverlayStyle.light,
            child: Container(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    //width: ScreenAdapter.getScreenWidth(),
                    height: ScreenAdapter.height(115),
                    decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#ffffff"),
                        border: Border(
                          bottom: BorderSide(
                              color: ColorsUtil.hexToColor("#e5e5e5"),
                              width: 5.0),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          GImage.getImageString(
                              "imgpublic", "settlement_top_qr"),
                          width: ScreenAdapter.width(40),
                          color: Colors.black87,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(20),
                        ),
                        Text(
                          '注文について',
                          style: TextStyle(
                              //color: ColorsUtil.hexToColor("#FFFFFF"),
                              fontWeight: FontWeight.w600,
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(34.0)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScreenAdapter.height(30),
                  ),
                  _tableNumber(controller.tableNum.value),
                  _publicSplitLine(),
                  SizedBox(
                    height: ScreenAdapter.height(30),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                          left: ScreenAdapter.width(150),
                          right: ScreenAdapter.width(150)),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ...controller.orderInfoMap.entries
                              .map(
                                  (entry) => _orderItem(entry.key, entry.value))
                              .toList()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenAdapter.height(30),
                  ),
                  _payCountTitle(int.parse(controller.totlaPrice.value)),
                  SizedBox(
                    height: ScreenAdapter.height(30),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        right: ScreenAdapter.width(50),
                        left: ScreenAdapter.width(50)),
                    height: ScreenAdapter.height(200),
                    color: ColorsUtil.hexToColor("#DCDCDC"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            try {
                              //showCancelConfirm();
                              //Navigator.pop(context);
                              controller.backCheckHome();
                              //Get.back();
                              //controller.backCheckHome();
                            } catch (_) {}
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(200),
                            height: ScreenAdapter.height(100),
                            //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((5.0)),
                            ),
                            child: Text(
                              GString.getToString(
                                  controller.checkLanguage.value,
                                  "settlement_back"),
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor("#000000"),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: ScreenAdapter.fontSize(34.0)),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            //try {
                              controller.showSelectMealTypeAndPaymentMethodDialog();
                            //} catch (_) {}
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(270),
                            height: ScreenAdapter.height(140),
                            //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              //设置圆角
                              borderRadius: new BorderRadius.circular((5.0)),
                            ),
                            child: Text(
                              GString.getToString(
                                  controller.checkLanguage.value,
                                  "settlement_button"),
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: ScreenAdapter.fontSize(34.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          onLoading: Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  ColorsUtil.hexToColor("#80B646")),
            ),
          ),
        );
      }),
    );
  }
}
