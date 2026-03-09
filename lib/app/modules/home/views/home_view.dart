import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/font.dart';

import 'package:get/get.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(
        builder: (controller) {
        return PrintImageGenerateWidget(
            contentBuilder: (context) {
              return Center(
                    child: Stack(
                      children: [
                        Container(
                          width: ScreenAdapter.width(550),
                          height: ScreenAdapter.height(450),
                          padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("テスト中です、しばらくお待ちください。",
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(25),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                  )),
                              Container(
                                margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                                child: Text("1、インターネットをテストしています",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(25),
                                      fontWeight: FontWeight.w600,
                                      color: (controller.checkSteeps.value == 1)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 1)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                                    )),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                                child: Text("2、釣銭機を開けています。",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(25),
                                      fontWeight: FontWeight.w600,
                                      color: (controller.checkSteeps.value == 2)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 2)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                                    )),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                                child: Text("3、現金機を閉じています。",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(25),
                                      fontWeight: FontWeight.w600,
                                      color: (controller.checkSteeps.value == 3)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 3)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                                    )),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: ScreenAdapter.width(100),top: ScreenAdapter.height(30)),
                                //width: ScreenAdapter.width(400),
                                height: ScreenAdapter.height(250),
                                child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
                              ),
                            ],
                          ),
                        )
                        
                      ],
                    ),
                  );
              //return WindewsTestView();

            },
            onPictureGenerated: controller.onPictureGenerated,
          );
        
         
      }
    ));
  }
}
