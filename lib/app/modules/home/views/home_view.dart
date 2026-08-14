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
      body: PrintImageGenerateWidget(
        contentBuilder: (context) {
          return GetBuilder<HomeController>(
            builder: (controller) {
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
                          Text(
                            "起動しています。しばらくお待ちください。",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(25),
                              fontWeight: FontWeight.w600,
                              color:
                                  ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: ScreenAdapter.width(100),
                              top: ScreenAdapter.height(30),
                            ),
                            //width: ScreenAdapter.width(400),
                            height: ScreenAdapter.height(250),
                            child: Image.asset(
                              "assets/images/public/printticketloading.gif",
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        onPictureGenerated: controller.onPictureGenerated,
      ),
    );
  }
}
