
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/modules/menuPage/views/components/CarItemView.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_category.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_checkout.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_shopingcar.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_sideBar.dart';
import 'package:get/get.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';

import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/menu_page_controller.dart';

class MenuPageView extends GetView {
  final MenuPageController controller = Get.put(MenuPageController());
  MenuPageView({Key? key}) : super(key: key);

  //中间分类页面
  showMiddleMenuList(BuildContext context) {
    for (var item in controller.topMenu.value) {
      if (controller.classTag.value == item['categoryCode']) {
        if (item['showType'] == "featured") {
          return showCategoryOne(
              controller.showItem.value[controller.classTag.value], context);
        } else if (item['showType'] == "table") {
          //350.0, 350.0
          return showCategoryTwo(
              controller.showItem.value[controller.classTag.value], context);
          //return _showCategoryEight(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "table_v1") {
          //350.0, 350.0
          return showCategoryTwo(
              controller.showItem.value[controller.classTag.value], context,
              popupType: "v1");
          //return _showCategoryEight(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "block") {
          //350.0, 350.0
          return showCategoryThree(
              controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "grid") {
          //260.0, 400.0
          return showCategoryFour(
              controller.showItem.value[controller.classTag.value], context);
        } else if (item['showType'] == "grid_v1") {
          //260.0, 400.0
          return showCategoryFour(
              controller.showItem.value[controller.classTag.value], context,
              popupType: "v1");
        } else if (item['showType'] == "waterfall") {
          //400.0, 260.0
          return showCategoryFive(
              controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "double_column") {
          //530.0, 530.0
          return showCategorySix(
              controller.showItem.value[controller.classTag.value], context);
        } else if (item['showType'] == "double_column_v1") {
          //530.0, 530.0
          return showCategorySix(
              controller.showItem.value[controller.classTag.value], context,
              popupType: "v1");
        } else if (item['showType'] == "three_column") {
          //350.0, 440.0
          return showCategorySeven(
              controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "three_column_v1") {
          //350.0, 440.0
          return showCategorySeven(
              controller.showItem.value[controller.classTag.value],
              popupType: "v1");
        } else if (item['showType'] == "mixed_column") {
          //混合模式 底部一行3列710.0, 710.0 350.0, 310.0 350.0, 350.0
          return showCategoryEight(
              controller.showItem.value[controller.classTag.value], context);
          //return _showCategoryNine(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "mixed_column_v1") {
          //混合模式 底部一行3列710.0, 710.0 350.0, 310.0 350.0, 350.0
          return showCategoryEight(
              controller.showItem.value[controller.classTag.value], context,
              popupType: "v1");
          //return _showCategoryNine(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "mixed_two_column") {
          //混合模式 底部一行2列 710.0, 710.0 350.0, 310.0 530.0, 530.0
          return showCategoryNine(
              controller.showItem.value[controller.classTag.value], context);
        } else if (item['showType'] == "mixed_two_column_v1") {
          //混合模式 底部一行2列 710.0, 710.0 350.0, 310.0 530.0, 530.0
          return showCategoryNine(
              controller.showItem.value[controller.classTag.value], context,
              popupType: "v1");
        } else {
          return showCategoryTwo(
              controller.showItem.value[controller.classTag.value], context);
        }
      }
    }
  }

  showCategoryTwoItemList(items, context, {popupType: "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(menuItemView(item, context, popupType: popupType));
    }
    return GridMenuView(children: children);
  }

  menuItemView(item, context, {popupType: "old"}) {
    return GridItemView(
      title: item['mainTitle'],
      subtitle: "${item['price']}",
      image: CachedNetworkImageProvider(item['homeImageHttp']),
      option: item['optionGroupVoList']?.length > 0 ? "选规格" : "",
      onTap: () async {
        if (item['qtyBounds'] == 0) {
              return;
        } else if (item['qtyBounds'] > 0) {
          //请求限定接口
          controller.checkQtyBoundsCount(item, "",popupType,context);

        }else{
          //如果option 存在，则弹出option
          if(item['optionGroupVoList']?.length > 0){
            if(popupType == "v1"){
              controller.publicShowOneItemWidgetv1(item);
            }else{
              controller.publicShowOneItemWidget(item);
            }

          }else{
            controller.publicAddCart(context,item);
          }
        }
      },
      cover: controller.publicShowMenuSellOut(item['qtyBounds']),
    );
  }

  showCategoryFourItemList(items, context, {popupType: "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(menuItemView(item, context, popupType: popupType));
    }

    return GridMenuView(children: children, crossAxisCount: 2);
  }

  menuItemListView(context) {
    return Expanded(
        child: RepaintBoundary(
      child: Container(
        //color: ColorsUtil.hexToColor(Gcolor.mainBackground),
        //height: ScreenAdapter.height(1480),
        padding: EdgeInsets.only(
            left: ScreenAdapter.width(20), right: ScreenAdapter.width(20)),
        alignment: Alignment.topCenter,
        child: showMiddleMenuList(context),
      ),
    ));
  }

  

  publicCartView() {
    return ListView(
      shrinkWrap: true,
      children: controller.showCartItems
          .map((d) => CarItemView(
              title: d.mainTitle,
              image: CachedNetworkImageProvider(d.image),
              onReduce: (value) {
                  controller.publicChangeCartItemCreate(d,false);
              },
              onIncrease: (value) {
                  controller.publicChangeCartItemCreate(d,true);
              },
              price: "${d.unitPrice}",
              quantity: d.goodsNum,))
          .toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MenuPageController>(builder: (controller) {
        return controller.obx(
          (state) => AnnotatedRegion(
              value: SystemUiOverlayStyle.light,
              child: Stack(
                children: [
                  Column(
                    children: [
                      //顶部导航
                      Container(
                        width: ScreenAdapter.getScreenWidth(),
                        height: ScreenAdapter.height(400),
                        padding: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(20)),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          //color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                          image: new DecorationImage(
                            image:
                                AssetImage('assets/images/gongcha/home2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        //child: showTopCategoryMenu(),
                      ),

                      SizedBox(height: ScreenAdapter.height(30)),

                      Expanded(
                        child: Row(
                          children: [
                            //侧栏
                            sideBarMenu(),
                            Expanded(
                                child: Column(
                              children: [
                                menuItemListView(context),
                                Container(
                                  height: ScreenAdapter.height(200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 3,
                                        blurRadius: 3,
                                        offset: Offset(
                                            0, 1), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //购物车
                  shoppingCar(),

                  Positioned(
                    height: ScreenAdapter.height(200),
                    width: ScreenAdapter.getScreenWidth() -
                        ScreenAdapter.width(180),
                    child: checkOutButton(),
                    right: ScreenAdapter.width(0),
                    bottom: ScreenAdapter.height(0),
                  )
                ],
              )),
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
