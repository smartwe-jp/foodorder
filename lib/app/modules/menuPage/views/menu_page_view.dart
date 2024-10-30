
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/menuPage/views/components/CarItemView.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_category.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_checkout.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_shopingcar.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_sideBar.dart';
import 'package:foodorder/app/modules/menuPage/views/LoadingFailPage.dart';
import 'package:get/get.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';

import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/menu_page_controller.dart';

class MenuPageView extends GetView<MenuPageController> {
  final MenuPageController controller = Get.find<MenuPageController>();
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
              controller.showItem.value[controller.classTag.value], context);
        } else if (item['showType'] == "three_column_v1") {
          //350.0, 440.0
          return showCategorySeven(
              controller.showItem.value[controller.classTag.value],context,
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

  menuItemView(item, context, {popupType: "old", aspectRatio:1.0}) {
    //debugPrint("menuItemView: $item");
    return GridItemView(
      title: item['mainTitle'],
      subtitle: "${item['subtitle'] ?? ""}",
      price: "${item['currentPrice']}",
      image: CachedNetworkImageProvider(item['homeImage'] ?? ""),
      option: item['optionGroupVoList']?.length > 0 ? GString.getToString(
                          controller.checkLanguage.value,"select_option") : "",
      aspectRatio: aspectRatio,
      onTap: () async {
        debugPrint("GridItemView onTap");
        if (item['qtyBounds'] == 0) {
              return;
        } else if (item['qtyBounds'] > 0) {
          //debugPrint("GridItemView onTap qtyBounds $item");
          //请求限定接口
          if (controller.canAddCart.value)
          await controller.checkQtyBoundsCount(item, "",popupType,context);

        }else{
          //如果option 存在，则弹出option
          debugPrint("GridItemView onTap option");
          if(item['optionGroupVoList']?.length > 0){
            if(popupType == "v1"){
              debugPrint("GridItemView onTap option 1");
              controller.publicShowOneItemWidgetv1(item);
            }else{
              debugPrint("GridItemView onTap option 0");
              controller.publicShowOneItemWidget(item);
            }

          }else{
            if (controller.canAddCart.value)
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
                        height: ScreenAdapter.height(400),
                        alignment: Alignment.center,
                        child: Swiper(
                            //itemHeight: 200,
                            itemBuilder: (BuildContext context,int index){
                              // 配置图片地址
                              return Container(
                                        decoration: BoxDecoration(
                                          //color: Colors.green,
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                controller.homeImages.value[index] ?? ""),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        //child: publicShowMenuImage(imgPath:item['homeImageHttp'], imgWidth:350.0, imgHeight:350.0,subTitle:item["subtitle"]),
                                      );
                            },
                            // 配置图片数量
                            itemCount: controller.homeImages.value.length,
                            // 底部分页器
                            //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
                            // 左右箭头
                            //control: new SwiperControl(),
                            // 无限循环
                            loop: (controller.homeImages.value.length >1) ?true :false,
                            duration: 1000,
                            autoplayDelay:12000,
                            // 自动轮播
                            autoplay: (controller.homeImages.value.length >1) ?true :false,
                          ),
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
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: controller.showCartTotalGoodsNum.value > 0 ? ScreenAdapter.height(200): 0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 3,
                                        blurRadius: 3,
                                        offset: Offset(0, 1), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  
                                )
                                //if (controller.showCartTotalGoodsNum.value > 0)
                                // Container(
                                //   height: ScreenAdapter.height(200),
                                //   decoration: BoxDecoration(
                                //     color: Colors.white,
                                //     boxShadow: [
                                //       BoxShadow(
                                //         color: Colors.grey.withOpacity(0.3),
                                //         spreadRadius: 3,
                                //         blurRadius: 3,
                                //         offset: Offset(
                                //             0, 1), // changes position of shadow
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //购物车
                  shoppingCar(),
                  
                  //if (controller.showCartTotalGoodsNum.value > 0)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    height: controller.showCartTotalGoodsNum.value > 0
                        ? ScreenAdapter.height(200)
                        : 0,
                    width: ScreenAdapter.getScreenWidth() - ScreenAdapter.width(180),
                    right: ScreenAdapter.width(0),
                    bottom: controller.showCartTotalGoodsNum.value > 0
                        ? ScreenAdapter.height(0)
                        : -ScreenAdapter.height(200),
                    child: checkOutButton(),
                  ),
                ],
              )),
          onLoading: Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  ColorsUtil.hexToColor("#80B646")),
            ),
          ),
          onError: (error) => LoadingFailedWidget(onBack: (){
            controller.backToNewHome();
          },),
        );
      }),
    );
  }
}
