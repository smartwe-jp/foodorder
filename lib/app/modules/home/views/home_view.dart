import 'package:flutter/material.dart';

import 'package:get/get.dart';


import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView {
  final HomeController controller = Get.put(HomeController());
  HomeView({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Obx(() => Container(
              width: ScreenAdapter.width(550),
              height: ScreenAdapter.height(450),
              padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("テスト中です、しばらくお待ちください。",
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(25),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                    child: Text("1、インターネットをテスト。",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(25),
                          fontWeight: FontWeight.w600,
                          color: (controller.checkSteeps.value == 1)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 1)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                    child: Text("2、釣銭機を開けています。",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(25),
                          fontWeight: FontWeight.w600,
                          color: (controller.checkSteeps.value == 2)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 2)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                    child: Text("3、現金機を閉じています。",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(25),
                          fontWeight: FontWeight.w600,
                          color: (controller.checkSteeps.value == 3)? ColorsUtil.hexToColor(Gcolor.mainTitleColor) :((controller.checkSteeps.value > 3)?ColorsUtil.hexToColor("#009c12"):Colors.black26),
                        )),
                  ),
                  Container(
                    //width: ScreenAdapter.width(400),
                    height: ScreenAdapter.height(250),
                    child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
                  ),
                ],
              ),
            )
            ),
            /*Positioned(
              right: ScreenAdapter.width(0),
              top: ScreenAdapter.height(0),
              child: InkWell(
                highlightColor: Colors.transparent, // 透明色
                splashColor: Colors.transparent, // 透明色
                onTap: (){
                  Get.back();
                },
                child: Icon(
                  Icons.close_outlined,
                  color: ColorsUtil.hexToColor("#000000"),
                  size: 28.0,
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }
}
