import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/menu_shopping_car.dart';
import 'package:foodorder/app/widget/CustomButton.dart';
import 'package:get/get.dart';
import '../../../../config/color.dart';
import '../../../../config/colorsUtil.dart';
import '../../../../config/font.dart';
import '../../../../config/string.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../../../services/formatMoney.dart';
import '../../controllers/menu_page_controller.dart';
import 'grid_item_view.dart';

extension RecommendView on MenuPageController {
  recommendItemView(item, {popupType: "old", aspectRatio: 1.0}) {
    //debugPrint("menuItemView: $item");
    return GridItemView(
      title: item['mainTitle'],
      subtitle: "${item['subtitle'] ?? ""}",
      price: "${item['currentPrice']}",
      image: CachedNetworkImageProvider(item['homeImage'] ?? ""),
      option: item['optionGroupVoList']?.length > 0
          ? GString.getToString(checkLanguage.value, "select_option")
          : "",
      aspectRatio: aspectRatio,
      imageRadius: 15,
      onTap: () async {
        debugPrint("GridItemView onTap");
        if (item['qtyBounds'] == 0) {
          return;
        } else if (item['qtyBounds'] > 0) {
          debugPrint("GridItemView onTap qtyBounds $item");
          //请求限定接口
          //if (canAddCart)
          if (Get.context != null) {
            recommendBookList.add(item);
            update();
            await checkQtyBoundsCount(item, "", popupType, Get.context);
          }
        } else {
          //如果option 存在，则弹出option
          debugPrint("GridItemView onTap option");
          recommendBookList.add(item);
          update();
          if (Get.context != null) publicAddCart(Get.context!, item);
          //}
        }
      },
      cover: publicShowMenuSellOut(item['qtyBounds']),
    );
  }

  showRecommendItemList(items, {popupType = "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(recommendItemView(item, popupType: popupType));
    }
    return GridMenuView(
      children: children,
      padding: EdgeInsets.only(left: 50, right: 50),
    );
  }

  showCarPopView() {
    showCartView = true;
    showModalBottomSheet<void>(
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        context: Get.context!,
        constraints: BoxConstraints(
            minHeight: ScreenAdapter.height(400),
            //maxHeight: ScreenAdapter.height(1000),
            minWidth: double.infinity),
        builder: (BuildContext context) {
          debounce(showCartTotalGoodsNum, (count) {
            if (count == 0 && showCartView) {
              showCartView = false;
              //Navigator.pop(context);
              Get.back();
            }
          });
          return GetBuilder<MenuPageController>(
            builder: (controller) => Container(
                child: Column(
              children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: publicCartView())),
                SizedBox(
                  height: 30,
                ),
                CustomButton(
                    bgColor: Colors.white,
                    titleColor: Colors.black,
                    radius: 20,
                    title: GString.getToString(
                      checkLanguage.value,
                      "settlement_back",
                    ),
                    onTap: () {
                      showCartView = false;
                      Navigator.pop(context);
                    }),
              ],
            )),
          );
        });
  }

  showRecommendView() {
    showRecommend = true;
    showModalBottomSheet<void>(
        isDismissible: false,
        useSafeArea: true,
        context: Get.context!,
        constraints: BoxConstraints(
            minHeight: ScreenAdapter.height(600),
            //maxHeight: ScreenAdapter.height(1200),
            minWidth: double.infinity),
        builder: (BuildContext context) {
          debounce(showCartTotalGoodsNum, (count) {
            if (count == 0 && showRecommend) {
              showRecommend = false;
              //debugPrint('Navigator:$Navigator, context:$context');
              //Navigator.pop(context);
              Get.back();
            }
          });
          return GetBuilder<MenuPageController>(
            builder: (controller) => Container(
                //width: 1080,

                child: recommendView(context)),
          );
        });
  }

  Widget carbutton() {
    return InkWell(
      onTap: () {
        showCarPopView();
      },
      child: Stack(
        children: [
          Container(
              width: ScreenAdapter.width(120),
              height: ScreenAdapter.height(120),
              padding: EdgeInsets.all(15),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/public/shopping-cart.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          if (showCartTotalGoodsNum.value > 0)
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
                  "${showCartTotalGoodsNum}",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget priceText() {
    return Row(children: [
      Text(GString.getToString(checkLanguage.value, "settlement_total_price"),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            fontFamily: GFont.getFontFamily(),
            color: Colors.black,
          )),
      SizedBox(width: 20,),
      Align(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '￥',
                  style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: "${formatMoney(shopCartTotalPrice.value)}",
                  style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          )),
    ]);
  }

  dismissAction(context, {bool isBack = false}) {
    showRecommend = false;
    showCartView = false;
    recommendBookList.clear();
    Navigator.pop(context);
    if (!isBack) doSubmitOrder();
  }

  Widget recommendView(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: const Color.fromARGB(255, 245, 245, 245)),

      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
                height: 60,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      child: Text(
                          GString.getToString(
                              checkLanguage.value, 'suggest_title'),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            fontFamily: GFont.getFontFamily(),
                            color: Colors.black,
                          )),
                    ),
                    Row(children: [
                      SizedBox(width: 20,),
                      GestureDetector(
                        onTap: () {dismissAction(context,isBack: true);},
                        child: Container(
                          height: 50,
                          child: Row(
                            //mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(Icons.arrow_back, color: ColorsUtil.hexToColor(Gcolor.greenThemeColor)),
                              SizedBox(width: 4),
                              Text(
                                GString.getToString(
                                    checkLanguage.value, 'settlement_back'),
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: GFont.getFontFamily(),
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer()
                    ])
                  ],
                )
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: showRecommendItemList(recommendFoods),
            ),
            Container(
              height: ScreenAdapter.height(180),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 223, 223, 223)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  carbutton(),
                  SizedBox(
                    width: 30,
                  ),
                  priceText(),
                  Spacer(),
                  if (recommendBookList.isEmpty)
                    CustomButton(
                        title: GString.getToString(
                            checkLanguage.value, "skip_button"),
                        bgColor: Colors.white,
                        titleColor: Colors.black,
                        onTap: () {
                          dismissAction(context);
                        }),
                  if (recommendBookList.isNotEmpty)
                    CustomButton(
                        title: GString.getToString(
                            checkLanguage.value, "next_button"),
                        bgColor: ColorsUtil.hexToColor(Gcolor.buttonRedColor),
                        onTap: () {
                          dismissAction(context);
                        }),
                  SizedBox(
                    width: 120,
                  )
                ],
              ),
            )
          ],
        ),
      ),
      //skip$next
      //),
    );
  }
}
