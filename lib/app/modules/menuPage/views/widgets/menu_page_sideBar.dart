import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../controllers/menu_page_controller.dart';

extension MenuPageSideBar on MenuPageView {
  sideBarMenu() {
    return GetBuilder<MenuPageController>(
       id: 'side_bar',
        builder: (logic) {
      return Container(
        width: ScreenAdapter.width(200),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 245, 247, 247),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: controller.topMenu.length,
                  itemBuilder: (context, index) {
                    var item = controller.topMenu[index];

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            //controller.changeCategory(item['categoryCode']);

                            // controller.classTag.value = item['categoryCode'];
                            // controller.selectIndex = index;
                            // controller.update(['side_bar']);
                            controller.pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 30),
                              curve: Curves.easeInOut,
                            );

                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: item['categoryCode'] ==
                                  controller.classTag.value
                                  ? ColorsUtil.hexToColor(Gcolor.priceColor)
                                  : Color.fromARGB(255, 245, 247, 247),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(
                                      index == 0 ? 40 : 0)),
                            ),
                            padding: EdgeInsets.only(
                                left: ScreenAdapter.width(30),
                                right: ScreenAdapter.width(20),
                                top: ScreenAdapter.height(30),
                                bottom: ScreenAdapter.height(30)
                            ),

                            child: Container(
                              //加上Center让文字居中
                              alignment: Alignment.centerLeft,
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
                                      fontSize: ScreenAdapter.fontSize(32),
                                      color: item['categoryCode'] ==
                                          controller.classTag.value
                                          ? Colors.white
                                          : Color.fromARGB(255, 144, 147, 153),
                                      //ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                                      fontWeight: FontWeight.w400),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),

            //Spacer(),

            InkWell(
              onTap: () {
                controller.gotoLanguageHome();
              },
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    left: ScreenAdapter.width(10),
                    right: ScreenAdapter.width(10),
                  ),
                  padding: EdgeInsets.only(
                      left: ScreenAdapter.width(10),
                      right: ScreenAdapter.width(10),
                      top: ScreenAdapter.height(10),
                      bottom: ScreenAdapter.height(10)
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    //阴影
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: ScreenAdapter.width(65),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                            AssetImage('assets/images/public/language.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(10),),
                      // Text(
                      //   GString.getToString(
                      //       controller.checkLanguage.value,
                      //       "main_page"),
                      //   style: TextStyle(
                      //       fontSize: 26,
                      //       fontWeight: FontWeight.w600,
                      //       fontFamily: GFont.getFontFamily(),
                      //       color: ColorsUtil.hexToColor(Gcolor.greenThemeColor)),
                      // )
                    ],
                  )),
            ),

            SizedBox(
              height: ScreenAdapter.height(50),
            ),

          ],
        ),


      );
    });
  }
}