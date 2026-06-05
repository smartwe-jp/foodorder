import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/widget/KioskTap.dart';
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
            topRight: Radius.circular(5),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: controller.topMenu.length,
                  itemBuilder: (context, index) {
                    var item = controller.topMenu[index];

                    return Stack(
                      children: [
                        InkWell(
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
                                  ? ColorsUtil.hexToColor(item['showColor'])
                                  : Color.fromARGB(255, 245, 247, 247),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(
                                      index == 0 ? 5 : 0)),
                            ),
                            padding: EdgeInsets.only(
                                left: ScreenAdapter.width(30),
                                right: ScreenAdapter.width(20),
                                top: ScreenAdapter.height(10),
                                bottom: ScreenAdapter.height(20)
                            ),

                            child: Container(
                              //加上Center让文字居中
                              alignment: Alignment.centerLeft,
                              height: ScreenAdapter.height(80),
                              //child: Expanded(
                                child:
                                Text(
                                  "${item['categoryName']}",
                                  style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(28),
                                      color: item['categoryCode'] ==
                                          controller.classTag.value
                                          ? Colors.white
                                          : Color.fromARGB(255, 144, 147, 153),
                                      //ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                                      fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              //),
                            ),
                          ),
                        ),

                        Container(

                          decoration: BoxDecoration(
                            color: item['categoryCode'] ==
                                controller.classTag.value
                                ? Colors.white:Colors.transparent
                          ),
                          width: ScreenAdapter.width(10),
                          height: ScreenAdapter.height(50),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(30)),
                        )

                      ],
                    );
                  }),
            ),

            //Spacer(),

            KioskTap(
              onTap: () {
                controller.gotoLanguageHome();
              },
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    left: ScreenAdapter.width(20),
                    right: ScreenAdapter.width(20),
                  ),
                  padding: EdgeInsets.only(
                      left: ScreenAdapter.width(10),
                      right: ScreenAdapter.width(10),
                      top: ScreenAdapter.height(10),
                      bottom: ScreenAdapter.height(10)
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                      Container(
                        // width: ScreenAdapter.width(65),
                        // height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        // decoration: BoxDecoration(
                        //   image: DecorationImage(
                        //     image:
                        //     AssetImage('assets/images/public/language.png'),
                        //     fit: BoxFit.contain,
                        //   ),
                        // ),
                        child: Icon(
                          Icons.home,
                          color: ColorsUtil.hexToColor(Gcolor.greenThemeColor),
                          size: 100,
                        ),
                      ),
                  //     SizedBox(width: ScreenAdapter.width(10),),
                  //   ],
                  // )
              ),
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