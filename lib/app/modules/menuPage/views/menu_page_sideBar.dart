

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

extension MenuPageSideBar on MenuPageView {
  sideBarMenu() {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(30),
          right: ScreenAdapter.width(10),
          top: ScreenAdapter.height(20)),
      width: ScreenAdapter.width(200),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 244, 240, 240),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: controller.topMenu.value.length,
                itemBuilder: (context, index) {
                  var item = controller.topMenu.value[index];

                  return Column(
                    children: [
                      SizedBox(
                        height: ScreenAdapter.height(20),
                      ),
                      InkWell(
                        onTap: () {
                          controller.changeCategory(item['categoryCode']);
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              right: ScreenAdapter.width(6),
                              top: ScreenAdapter.height(5)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(5),
                              right: ScreenAdapter.width(5)),
                          width: ScreenAdapter.width(165),
                          //height: (classTag == item['categoryCode']) ? ScreenAdapter.height(75) : ScreenAdapter.height(65),
                          //height: ScreenAdapter.height(90),
                          alignment: Alignment.center,
                          // decoration: BoxDecoration(
                          //   //背景颜色
                          //   color: ColorsUtil.hexToColor(item['showColor']),
                          //   borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                          // ),
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
                                    fontSize: ScreenAdapter.fontSize(30),
                                    color: item['categoryCode'] ==
                                            controller.classTag.value
                                        ? Colors.black
                                        : Color.fromARGB(255, 139, 137,
                                            137), //ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                                    fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenAdapter.height(20),
                      ),
                    ],
                  );
                }),
          ),
          //Spacer(),
          Row(
            children: [
              InkWell(
                onTap: () {
                  controller.gotoLanguageHome();
                },
                child: Column(
                  children: [
                    Container(
                      width: ScreenAdapter.width(60),
                      height: ScreenAdapter.height(60),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/public/home_icon.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Text(
                      "首页",
                      style: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 3, 139, 114)),
                    )
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
          SizedBox(
            height: ScreenAdapter.height(50),
          ),
        ],
      ),
    );
  }
}