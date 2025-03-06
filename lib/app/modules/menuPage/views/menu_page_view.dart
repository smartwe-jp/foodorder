import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_extension.dart';
import 'package:foodorder/app/modules/menuPage/views/LoadingFailPage.dart';
import 'package:foodorder/app/modules/menuPage/views/publicShowCart.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/check_out_view.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/menu_page_sideBar.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/menu_shopping_car.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/page_view.dart';

import 'package:get/get.dart';
import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/menu_page_controller.dart';

class MenuPageView extends GetView {
  final MenuPageController controller = Get.put(MenuPageController());

  MenuPageView({Key? key}) : super(key: key);

  //顶部分类导航
  showTopCategoryMenu() {
    List<Widget> categoryMenus = []; //先建一个数组用于存放循环生成的widget
    for (var item in controller.topMenu) {
      categoryMenus.add(InkWell(
        //enableFeedback: false,
        onTap: () {
          //controller.changeCategory(item['categoryCode']);
          controller.pageController.animateToPage(
            item['index'],
            duration: const Duration(milliseconds: 30),
            curve: Curves.easeInOut,
          );
          //controller.classTag.value = item['categoryCode'];
        },
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                  right: ScreenAdapter.width(6), top: ScreenAdapter.height(5)),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
              width: ScreenAdapter.width(165),
              //height: (classTag == item['categoryCode']) ? ScreenAdapter.height(75) : ScreenAdapter.height(65),
              //height: ScreenAdapter.height(90),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                //背景颜色
                color: ColorsUtil.hexToColor(item['showColor']),
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Center(
                //加上Center让文字居中
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: ScreenAdapter.width(20),
                    maxWidth: ScreenAdapter.width(165),
                    minHeight: ScreenAdapter.height(30),
                    maxHeight: ScreenAdapter.height(65),
                  ),
                  child: AutoSizeText(
                    "${item['categoryName']}",
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(30),
                        color: ColorsUtil.hexToColor(
                            Gcolor.categoryTitleSelected),
                        fontWeight: FontWeight.w600
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            (controller.classTag.value == item['categoryCode'])
                ? Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    padding: EdgeInsets.zero,
                    //width: ScreenAdapter.width(10),
                    //color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                    child: Image.asset(
                      GImage.getImageString("imgpublic", "menu_up"),
                      height: ScreenAdapter.width(20),
                      fit: BoxFit.fitHeight,
                      color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                    )
                ),
              ),
            )
                : Container(
              height: 0,
            ),
          ],
        ),
      )
      );
    }

    //categoryMenus.add();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(
            width: ScreenAdapter.width(900),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: categoryMenus,
                )
              ],
            ),
          ),
        ),
        Container(
          //alignment: Alignment.centerRight,
          child: InkWell(
            enableFeedback: false,
            onTap: () {
              //controller.ordersqlcontroller.removeAllFromCart();
              controller.gotoLanguageHome();
            },
            child: Container(
              padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
              margin: EdgeInsets.only(left: ScreenAdapter.width(10),
                top: ScreenAdapter.height(10),
                right: ScreenAdapter.width(5),),
              width: ScreenAdapter.width(95),
              height: ScreenAdapter.height(85),
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage("assets/images/public/language.png"),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
            Swiper(
              //itemHeight: 200,
              itemBuilder: (BuildContext context, int index) {
                // 配置图片地址
                return Container(
                  decoration: BoxDecoration(
                    //color: Colors.green,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          controller.machineInfo.headImageList[index] ?? ""),
                      fit: BoxFit.cover,
                    ),
                  ),
                  //child: publicShowMenuImage(imgPath:item['homeImageHttp'], imgWidth:350.0, imgHeight:350.0,subTitle:item["subtitle"]),
                );
              },
              // 配置图片数量
              itemCount: controller.machineInfo.headImageList.length,
              // 底部分页器
              //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
              // 左右箭头
              //control: new SwiperControl(),
              // 无限循环
              loop: (controller.machineInfo.headImageList.length > 1) ? true : false,
              duration: 1000,
              autoplayDelay: 12000,
              // 自动轮播
              autoplay: (controller.machineInfo.headImageList.length > 1)
                  ? true
                  : false,
            ),
          ],
        ));
  }

  bottomCart() {
    return GetBuilder<MenuPageController>(
        id: 'shopping_cart',
        builder: (logic) {
          return AnimatedContainer(
            duration: const Duration(
                milliseconds: 300),
            height:
            controller.showCartTotalGoodsNum
                .value >
                0
                ? ScreenAdapter.height(200)
                : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey
                      .withOpacity(
                      0.3),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(
                      0,
                      1), // changes position of shadow
                ),
              ],
            ),
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MenuPageController>(builder: (controller) {
        return controller.obx((state) =>
            AnnotatedRegion(
              value: SystemUiOverlayStyle.light,
              child: Stack(
                children: [
                  Column(
                    children: [
                      if (controller.machineInfo.machineType == MachineType.new_panel_max && controller.machineInfo.menu_direction != "1")
                        topArea(),
                      //顶部导航
                      if (controller.machineInfo.menu_direction == "1")
                      GetBuilder<MenuPageController>(
                          id: 'side_bar',
                          builder: (logic) {
                        return Container(
                          width: ScreenAdapter.getScreenWidth(),
                          height: ScreenAdapter.height(95),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(20)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                          ),
                          child: showTopCategoryMenu(),
                        );
                      }),

                      SizedBox(height: ScreenAdapter.height(30)),

                      Expanded(
                        child: Row(
                          children: [
                            //侧栏
                            if (controller.machineInfo.menu_direction != '1')
                            sideBarMenu(),
                            Expanded(
                                child:
                                Column(
                                  children: [
                                    Expanded(
                                        child: MenuView(state: controller)),

                                    if (controller.machineInfo.menu_direction != '1')
                                      bottomCart()
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),

                      if (controller.machineInfo.menu_direction == '1')
                      bottomCart()


                    ],
                  ),

                  controller.shoppingCar(),

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
                          child: controller.machineInfo.menu_direction != '1' ? checkOutButton() : publicShowCartView(),
                        );
                      }),
                ],
              ),
            ),
          onLoading: Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  ColorsUtil.hexToColor("#80B646")),
            ),
          ),
          onError: (error) =>
              LoadingFailedWidget(onBack: () {
                controller.backToNewHome();
              },),
        );
      }),
    );
  }
}
