import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_extension.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/menu_shopping_car.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/popup_cart_view.dart';
import 'package:foodorder/app/widget/CustomButton.dart';
import 'package:get/get.dart';
import '../../../../config/color.dart';
import '../../../../config/colorsUtil.dart';
import '../../../../config/font.dart';
import '../../../../services/CustomLogerHandler.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../../../services/formatMoney.dart';
import '../../controllers/menu_page_controller.dart';
import 'grid_item_view.dart';
import 'menu_sheet_views.dart';

extension RecommendView on MenuPageController {
  recommendItemView(item, {popupType: "old", aspectRatio: 1.0}) {
    //debugPrint("menuItemView: $item");
    final menuCode = '${item['menuCode']}';
    final isLimited = (item['qtyBounds'] ?? -1) > 0;
    return GridItemView(
      title: item['mainTitle'],
      subtitle: publicMenuSubtitle(item['subtitle'] ?? []),
      price: "${item['currentPrice']}",
      originalPrice: "${item['price'] ?? 0}",
      image: itemImage(item['homeImage']),
      option: item['optionGroupVoList']?.length > 0 ? "select_option".tr : "",
      aspectRatio: aspectRatio,
      imageRadius: 15,
      debounceDuration: isLimited
          ? const Duration(milliseconds: 400)
          : Duration.zero,
      onTap: () async {
        debugPrint("GridItemView onTap");
        if (isMenuAddLocked(menuCode)) {
          return;
        }
        if (item['qtyBounds'] == 0) {
          return;
        } else if (isLimited) {
          debugPrint("GridItemView onTap qtyBounds $item");
          if (Get.context != null) {
            recommendBookList.add(item);
            await checkQtyBoundsCount(item, "", popupType, Get.context);
          }
        } else {
          debugPrint("GridItemView onTap option");
          recommendBookList.add(item);
          if (Get.context == null) {
            return;
          }
          if (item['optionGroupVoList']?.length > 0) {
            if (popupType == "v1") {
              publicShowOneItemWidgetv1(item);
            } else {
              publicShowOneItemWidget(item);
            }
          } else if (canAddCart.value) {
            await publicAddCart(Get.context!, item);
          }
        }
      },
      cover: publicShowMenuSellOut(item['qtyBounds']),
    );
  }

  showRecommendItemList(items, {popupType = "old"}) {
    return GridMenuView(
      itemCount: items.length,
      itemBuilder: (ctx, index) =>
          recommendItemView(items[index], popupType: popupType),
      padding: const EdgeInsets.only(left: 50, right: 50),
    );
  }

  showRecommendView() {
    logI("---showRecommendView---");
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
          return RecommendSheetView(
            controller: this,
            recommendBuilder: recommendView,
          );
        }).whenComplete(() {
      logI("showRecommendView onComplete");
      showRecommend = false;
    });
  }

  Widget carButton() {
    return Stack(
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
    );
  }

  Widget priceText() {
    return Row(children: [
      Text("settlement_total_price".tr,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            fontFamily: GFont.getFontFamily(),
            color: Colors.black,
          )),
      SizedBox(
        width: 20,
      ),
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
                  text: "${formatMoney(displayCartPayable)}",
                  style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text:
                      "（${machineInfo.taxSystem ? "show_price_front".tr : "tax_out".tr}）",
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
                      child: Text('suggest_title'.tr,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            fontFamily: GFont.getFontFamily(),
                            color: Colors.black,
                          )),
                    ),
                    Row(children: [
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          dismissAction(context, isBack: true);
                        },
                        child: Container(
                          height: 50,
                          child: Row(
                            //mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(Icons.arrow_back_ios,
                                  size: 35,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.greenThemeColor)),
                              Text(
                                'settlement_back'.tr,
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
                )),
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
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showCarPopView();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 223, 223, 223)),
                        child: Row(children: [
                          SizedBox(
                            width: 50,
                          ),
                          carButton(),
                          SizedBox(
                            width: 30,
                          ),
                          priceText(),
                          Spacer(),
                          Icon(
                            Icons.edit,
                            color:
                                ColorsUtil.hexToColor(Gcolor.greenThemeColor),
                            size: 40,
                          ),
                        ]),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  if (recommendBookList.isEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      height: double.infinity,
                      child: CustomButton(
                          title: "skip_button".tr,
                          bgColor:
                              ColorsUtil.hexToColor(Gcolor.greenThemeColor),
                          titleColor: Colors.white,
                          onTap: () {
                            dismissAction(context);
                          }),
                    ),
                  if (recommendBookList.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      height: double.infinity,
                      child: CustomButton(
                          title: "next_button".tr,
                          bgColor: ColorsUtil.hexToColor(Gcolor.priceColor),
                          onTap: () {
                            dismissAction(context);
                          }),
                    ),
                  SizedBox(
                    width: 60,
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
