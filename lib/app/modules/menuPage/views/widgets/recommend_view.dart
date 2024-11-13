import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/widget/CustomButton.dart';
import 'package:get/get.dart';
import '../../../../config/color.dart';
import '../../../../config/colorsUtil.dart';
import '../../../../config/font.dart';
import '../../../../config/string.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../controllers/menu_page_controller.dart';
import 'grid_item_view.dart';

extension RecommendView on MenuPageController {

  recommendItemView(item, {popupType: "old", aspectRatio:1.0}) {
    //debugPrint("menuItemView: $item");
    return GridItemView(
      title: item['mainTitle'],
      subtitle: "${item['subtitle'] ?? ""}",
      price: "${item['currentPrice']}",
      image: CachedNetworkImageProvider(item['homeImage'] ?? ""),
      option: item['optionGroupVoList']?.length > 0 ? GString.getToString(
          checkLanguage.value,"select_option") : "",
      aspectRatio: aspectRatio,
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
            await checkQtyBoundsCount(item, "",popupType, Get.context);
          }
        }else{
          //如果option 存在，则弹出option
          debugPrint("GridItemView onTap option");
          // if(item['optionGroupVoList']?.length > 0){
          //   if(popupType == "v1"){
          //     publicShowOneItemWidgetv1(item);
          //   }else{
          //     publicShowOneItemWidget(item);
          //   }
          //
          // }else{
            //if (canAddCart)
            recommendBookList.add(item);
            update();
            if (Get.context != null)
              publicAddCart(Get.context!,item);
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
    return GridMenuView(children: children);
  }


  showRecommendView() {
    Get.dialog(
        GetBuilder<MenuPageController>(
          builder: (controller) => recommendView(),
        ),
        //Obx(() => recommendView()),
      barrierDismissible: false
    );
  }

  Widget recommendView() {
    return Dialog(
      insetPadding: EdgeInsets.only(
          left: 20, right: 20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0)),
      ),
      child: Container(
        //title area
        // height: ,
        padding: EdgeInsets.only(left: 30, right: 30),
        constraints: BoxConstraints(
          minHeight: ScreenAdapter.height(600),
          maxHeight: ScreenAdapter.height(1400),
        ),
        //item area
        //height: ScreenAdapter.height(1200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Container(
              child: Text(
                'ご一緒にいかがですか',
                  style:
                  TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    fontFamily: GFont.getFontFamily(),
                    color: Colors.black,
                  )
              ),
            ),

            SizedBox(height: 20,),

            Expanded(
                child:
                showRecommendItemList(recommendFoods)
            ),

            Container(
              height: ScreenAdapter.height(180),
              alignment: Alignment.center,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (recommendBookList.isEmpty)
                  CustomButton(title: "スキップ", onTap: (){
                    recommendBookList.clear();
                    Get.back();
                    doSubmitOrder();
                  }),
                  if (recommendBookList.isNotEmpty)
                  CustomButton(title: "戻る", bgColor:Colors.grey, onTap: (){
                    recommendBookList.clear();
                    Get.back();
                  }),
                  if (recommendBookList.isNotEmpty)
                    CustomButton(title: "進む", bgColor: ColorsUtil.hexToColor(Gcolor.buttonRedColor), onTap: (){
                      recommendBookList.clear();
                      Get.back();
                      doSubmitOrder();
                  })
                ],
              ),
            )

          ],
        ),
        //skip$next


      ),
    );
  }
}