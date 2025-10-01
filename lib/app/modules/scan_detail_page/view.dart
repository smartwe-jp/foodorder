import 'package:flutter/material.dart';
import 'package:foodorder/app/common/Extension/StringExtension.dart';
import 'package:foodorder/app/modules/CheckoutPage/controllers/checkout_page_controller.dart';
import 'package:get/get.dart';

import '../../config/color.dart';
import '../../config/colorsUtil.dart';
import '../../config/font.dart';
import '../../config/fontSize.dart';
import '../../config/imageData.dart';
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
                      Text("scan_order_detail_title".tr,
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
                _tableNumber(checkoutLogic.tableNumText.value, checkoutLogic.tableNum.value),
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
                        ...checkoutLogic.orderLines
                            .map(
                                (entry) => _orderItem(entry))
                            .toList()
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenAdapter.height(30),
                ),
                _payCountTitle(checkoutLogic.showTotalPrice,
                    checkoutLogic.discount.value, checkoutLogic.containTax),
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
                          child: Text("settlement_back".tr,
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
                          child: Text("settlement_button".tr,
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

  Widget _tableNumber(title,number) {
    return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
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

  Widget _payCountTitle(int count, int discount, bool containTax) {
    // List leftKeys = [
    //   "settlement_original_price".localized(),
    //   "settlement_discount".localized(),
    //   "settlement_total_price".localized()
    // ];
    // List rightValues = [
    //   count,
    //   discount,
    //   count + discount
    // ];
    return Container(
        padding: EdgeInsets.only(
            left: ScreenAdapter.width(150), right: ScreenAdapter.width(100)),
        child:
        //原价
        Row(
          children: [
            Expanded(
              flex: 1, // 右边占 60%
              child: Container(
                // 右边空白
                color: Colors.transparent,
              ),
            ),

            Expanded(
              flex: 1, // 左边占 44%
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //原价显示： 原价：2000
                  if(discount != 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("settlement_original_price".tr,
                          style: TextStyle(
                            //color: ColorsUtil.hexToColor("#FFFFFF"),
                              fontWeight: FontWeight.w600,
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(35.0))),
                      SizedBox(
                        width: ScreenAdapter.width(20),
                      ),
                      Text(
                          "${count.formatIntSum()}",
                          style: TextStyle(
                            fontFamily: GFont.getFontFamily(),
                            fontSize: ScreenAdapter.fontSize(35.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                      )
                    ],
                  ),
                  //折扣显示： 折扣：1000
                  SizedBox(
                    height: ScreenAdapter.height(20),
                  ),
                  if(discount != 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("settlement_discount".tr,
                          style: TextStyle(
                            //color: ColorsUtil.hexToColor("#FFFFFF"),
                              fontWeight: FontWeight.w600,
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(35.0))),
                      SizedBox(
                        width: ScreenAdapter.width(20),
                      ),
                      Text(
                          "${discount.formatIntSum()}",
                          style: TextStyle(
                            fontFamily: GFont.getFontFamily(),
                            fontSize: ScreenAdapter.fontSize(35.0),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(Gcolor.priceColor),
                          )
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenAdapter.height(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "settlement_total_price".tr,
                          style: TextStyle(
                            //color: ColorsUtil.hexToColor("#FFFFFF"),
                              fontWeight: FontWeight.w600,
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(40.0))),



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
                                text: count.formatIntSum(),
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
                                "(${containTax ? "show_price_front".tr : "tax_out".tr})", //" 円",
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
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  //orderLines: [{name: Kanran Beef Noodle, price: 100, qty: 1, bizId: 461188153690226689, options: {麺の型: [{name: 👍🏻平麺, qty: 1}], パクチー: [{name: 無し, qty: 1}], 脂・菜・にん: [{name: あり, qty: 1}]}
  _orderItem(order) {

    final title = order['name'] ?? '';
    final qty = order['qty'] ?? 0;
    final options = order['options'] ?? {};

    return

      Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: ScreenAdapter.height(10),
              bottom: ScreenAdapter.height(10),
            ),
            child: Column(
              children: [
                Row(
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
                //选项
                if (options.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: ScreenAdapter.height(10)),
                    child: Column(
                      children: [
                        ...options.entries.map<Widget>((entry) {
                          final optionName = entry.key;
                          final optionValues = entry.value as List<dynamic>;
                          return Container(
                            margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: ScreenAdapter.width(300),
                                  child: Text('$optionName',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: GFont.getFontFamily(),
                                        fontSize: ScreenAdapter.fontSize(28),
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54,
                                      )),
                                ),
                                SizedBox(width: ScreenAdapter.width(20)),
                                Expanded(
                                  child: Wrap(
                                    spacing: ScreenAdapter.width(10),
                                    runSpacing: ScreenAdapter.height(5),
                                    children: optionValues.map<Widget>((opt) {
                                      final optName = opt['name'] ?? '';
                                      final optQty = opt['qty'] ?? 0;
                                      return Text('$optName x $optQty',
                                          style: TextStyle(
                                            fontFamily: GFont.getFontFamily(),
                                            fontSize: ScreenAdapter.fontSize(28),
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black54,
                                          ));
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  )
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
