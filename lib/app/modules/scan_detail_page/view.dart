import 'package:flutter/material.dart';
import 'package:foodorder/app/Extension/StringExtension.dart';
import 'package:foodorder/app/config/localString.dart';
import 'package:foodorder/app/modules/CheckoutPage/controllers/checkout_page_controller.dart';
import 'package:get/get.dart';

import '../../config/color.dart';
import '../../config/colorsUtil.dart';
import '../../config/font.dart';
import '../../config/fontSize.dart';
import '../../config/imageData.dart';
import '../../config/string.dart';
import '../../services/ScreenAdapter.dart';
import 'logic.dart';

class ScanDetailPagePage extends StatelessWidget {
  ScanDetailPagePage({Key? key}) : super(key: key);

  final logic = Get.put(ScanDetailPageLogic());
  final state = Get.find<ScanDetailPageLogic>().state;
  final checkoutLogic = Get.find<CheckoutPageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanDetailPageLogic>(
        assignId: true,
        builder: (logic) {
          return Container(
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
                      )
                  ),
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
                        GString.getToString(
                            checkoutLogic.selectLanguage, "scan_order_detail_title"),
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
                _tableNumber(checkoutLogic.tableNum.value),
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
                        ...checkoutLogic.orderInfoMap.entries
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
                _payCountTitle(int.parse(checkoutLogic.totalPrice.value)),
                SizedBox(
                  height: ScreenAdapter.height(30),
                ),
                Container(
                    height: 5.0,
                    decoration: BoxDecoration(
                      color: ColorsUtil.hexToColor("#e5e5e5"),
                    )),
                Container(
                  padding: EdgeInsets.only(
                      right: ScreenAdapter.width(50),
                      left: ScreenAdapter.width(50)),
                  height: ScreenAdapter.height(200),
                  color: ColorsUtil.hexToColor("#FFFFFF"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          checkoutLogic.backCheckHome();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenAdapter.width(200),
                          height: ScreenAdapter.height(100),
                          //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#DCDCDC"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((5.0)),
                          ),
                          child: Text(
                            GString.getToString(
                                checkoutLogic.selectLanguage, "settlement_back"),
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
                          checkoutLogic.showSelectMealTypeAndPaymentMethodDialog();
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
                                checkoutLogic.selectLanguage, "settlement_button"),
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
          );
        },
      )
    );
  }


  _publicSplitLine() {
    return Container(
      width: ScreenAdapter.width(500),
      //margin: EdgeInsets.only(top: 5, bottom: 5),
      height: 2,
      color: ColorsUtil.hexToColor("#000000"),
      //width: 375,
    );
  }

  Widget _tableNumber(number) {
    return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(GString.getToString(checkoutLogic.selectLanguage, "show_check_tableno"),
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
            Text(
                GString.getToString(
                    checkoutLogic.selectLanguage, "settlement_total_price") + ' :',
                style: TextStyle(
                  //color: ColorsUtil.hexToColor("#FFFFFF"),
                    fontWeight: FontWeight.w600,
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(40.0))),
            SizedBox(
              width: ScreenAdapter.width(20),
            ),
            RichText(
              text: TextSpan(
                  text: "¥",
                  //GString.getToString(this._checkLanguage, "show_price_front"),
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(
                        GFontSize.menusettlementBottomPriceLeft),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                  ),
                  children: [
                    TextSpan(
                      text: int.parse(checkoutLogic.totalPrice.value).formatSum(),
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(
                            GFontSize.menusettlementBottomPrice),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.priceColor),
                      ),
                    ),
                    TextSpan(
                      text:
                      "（${GString.getToString(
                          checkoutLogic.selectLanguage, "show_price_front")}）", //" 円",
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(
                            GFontSize.menusettlementBottomPriceRight),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                      ),
                    ),
                  ]),
            ),
          ],
        ));
  }


  _orderItem(title, qty) {
    return

      Column(
        children: [
          Container(
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
          ),
          Divider(
            thickness: 1,
            color: const Color.fromARGB(255, 181, 171, 171),
          )
        ],
      );
  }
}
