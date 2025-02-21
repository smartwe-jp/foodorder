import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_extension.dart';
import 'package:foodorder/app/modules/menuPage/views/components/CarItemView.dart';
import 'package:foodorder/app/modules/menuPage/views/components/PageVew.dart';
import 'package:foodorder/app/modules/menuPage/views/components/recommendView.dart';
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


  menuItemListView(context) {
    return Expanded(
        child: RepaintBoundary(
      child: Container(
        //color: ColorsUtil.hexToColor(Gcolor.mainBackground),
        //height: ScreenAdapter.height(1480),
        padding: EdgeInsets.only(
            left: ScreenAdapter.width(20), right: ScreenAdapter.width(20)),
        alignment: Alignment.topCenter,
        child: controller.showMiddleMenuList(context),
      ),
    ));
  }

  topArea() {
    return Container(
        height: ScreenAdapter.height(400),
        alignment: Alignment.center,
        child: Stack(
          children: [
            if (!controller.machinInfo.editMode)
              Swiper(
                //itemHeight: 200,
                itemBuilder: (BuildContext context, int index) {
                  // 配置图片地址
                  return Container(
                    decoration: BoxDecoration(
                      //color: Colors.green,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            controller.homeImages[index] ?? ""),
                        fit: BoxFit.cover,
                      ),
                    ),
                    //child: publicShowMenuImage(imgPath:item['homeImageHttp'], imgWidth:350.0, imgHeight:350.0,subTitle:item["subtitle"]),
                  );
                },
                // 配置图片数量
                itemCount: controller.homeImages.length,
                // 底部分页器
                //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
                // 左右箭头
                //control: new SwiperControl(),
                // 无限循环
                loop: (controller.homeImages.length > 1) ? true : false,
                duration: 1000,
                autoplayDelay: 12000,
                // 自动轮播
                autoplay: (controller.homeImages.length > 1) ? true : false,
              ),
          ],
        ));
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
                      topArea(),

                      SizedBox(height: ScreenAdapter.height(30)),

                      Expanded(
                        child: Row(
                          children: [
                            //侧栏
                            sideBarMenu(),
                            Expanded(
                                child: 
                                Column(
                                  children: [
                                    //menuItemListView(context),
                                    Expanded(child: MenuView(state: controller)),

                                    GetBuilder<MenuPageController>(
                                    id: 'shopping_cart',
                                    builder: (logic) {
                                      return
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          height:
                                              controller.showCartTotalGoodsNum.value > 0
                                                  ? ScreenAdapter.height(200)
                                                  : 0,
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
                                        );
                                    })
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //购物车
                  shoppingCar(),

                  //if (controller.showCartTotalGoodsNum.value > 0)
                  GetBuilder<MenuPageController>(
                      id: 'shopping_cart',
                      builder: (logic) {
                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          height: controller.showCartTotalGoodsNum.value > 0
                              ? ScreenAdapter.height(200)
                              : 0,
                          width: ScreenAdapter.getScreenWidth(),
                          right: ScreenAdapter.width(0),
                          bottom: controller.showCartTotalGoodsNum.value > 0
                              ? ScreenAdapter.height(0)
                              : -ScreenAdapter.height(200),
                          child: checkOutButton(),
                        );
                      }),
                ],
              )),
          onLoading: Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  ColorsUtil.hexToColor("#80B646")),
            ),
          ),
          onError: (error) => LoadingFailedWidget(
            onBack: () {
              controller.backToNewHome();
            },
          ),
        );
      }),
    );
  }
}
