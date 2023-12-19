import 'package:flutter/material.dart';
import 'package:foodorder/app/config/imageData.dart';

import 'package:get/get.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView {
  final HomeController controller = Get.put(HomeController());
  HomeView({Key? key}) : super(key: key);

  Widget testView() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.only(top: ScreenAdapter.height(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.openCashChange();
                      },
                      child: Container(
                        width: ScreenAdapter.width(217),
                        height: ScreenAdapter.height(90),
                        margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                        decoration: BoxDecoration(
                          //color: Color(0x11111111),
                          image: DecorationImage(
                              //alignment: Alignment.topCenter,
                              image: AssetImage(GImage.getImageString(
                                  "imgpublic", "home_button")),
                              fit: BoxFit.fill),
                        ),
                        child: Center(
                          //加上Center让文字居中
                          child: Text(
                            'Open',
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(36.0),
                                color: ColorsUtil.hexToColor("#F9F9F9"),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controller.closeCashChange();
                      },
                      child: Container(
                        width: ScreenAdapter.width(217),
                        height: ScreenAdapter.height(90),
                        margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                        decoration: BoxDecoration(
                          //color: Color(0x11111111),
                          image: DecorationImage(
                              //alignment: Alignment.topCenter,
                              image: AssetImage(GImage.getImageString(
                                  "imgpublic", "home_button")),
                              fit: BoxFit.fill),
                        ),
                        child: Center(
                          //加上Center让文字居中
                          child: Text(
                            'Close',
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(36.0),
                                color: ColorsUtil.hexToColor("#F9F9F9"),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenAdapter.height(30)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.GetCashBalanceInfo();
                      },
                      child: Container(
                        width: ScreenAdapter.width(217),
                        height: ScreenAdapter.height(90),
                        margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                        decoration: BoxDecoration(
                          //color: Color(0x11111111),
                          image: DecorationImage(
                              //alignment: Alignment.topCenter,
                              image: AssetImage(GImage.getImageString(
                                  "imgpublic", "home_button")),
                              fit: BoxFit.fill),
                        ),
                        child: Center(
                          //加上Center让文字居中
                          child: Text(
                            '在高',
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(36.0),
                                color: ColorsUtil.hexToColor("#F9F9F9"),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controller.startDeposit();
                      },
                      child: Container(
                        width: ScreenAdapter.width(217),
                        height: ScreenAdapter.height(90),
                        margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                        decoration: BoxDecoration(
                          //color: Color(0x11111111),
                          image: DecorationImage(
                              //alignment: Alignment.topCenter,
                              image: AssetImage(GImage.getImageString(
                                  "imgpublic", "home_button")),
                              fit: BoxFit.fill),
                        ),
                        child: Center(
                          //加上Center让文字居中
                          child: Text(
                            'Deposit',
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(36.0),
                                color: ColorsUtil.hexToColor("#F9F9F9"),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 11, 87, 100),
                padding: const EdgeInsets.all(16.0),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                controller.isShowTest.value = false;
                controller.requestPermission();
              },
              child: const Text('Dismiss'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Obx(() => 
                Container(
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
                              color:
                                  ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            )),
                        Container(
                          margin: EdgeInsets.only(
                              top: ScreenAdapter.height(5),
                              bottom: ScreenAdapter.height(5)),
                          child: Text("1、インターネットをテスト。",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(25),
                                fontWeight: FontWeight.w600,
                                color: (controller.checkSteeps.value == 1)
                                    ? ColorsUtil.hexToColor(
                                        Gcolor.mainTitleColor)
                                    : ((controller.checkSteeps.value > 1)
                                        ? ColorsUtil.hexToColor("#009c12")
                                        : Colors.black26),
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: ScreenAdapter.height(5),
                              bottom: ScreenAdapter.height(5)),
                          child: Text("2、釣銭機を開けています。",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(25),
                                fontWeight: FontWeight.w600,
                                color: (controller.checkSteeps.value == 2)
                                    ? ColorsUtil.hexToColor(
                                        Gcolor.mainTitleColor)
                                    : ((controller.checkSteeps.value > 2)
                                        ? ColorsUtil.hexToColor("#009c12")
                                        : Colors.black26),
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: ScreenAdapter.height(5),
                              bottom: ScreenAdapter.height(5)),
                          child: Text("3、現金機を閉じています。",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(25),
                                fontWeight: FontWeight.w600,
                                color: (controller.checkSteeps.value == 3)
                                    ? ColorsUtil.hexToColor(
                                        Gcolor.mainTitleColor)
                                    : ((controller.checkSteeps.value > 3)
                                        ? ColorsUtil.hexToColor("#009c12")
                                        : Colors.black26),
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(100),
                              top: ScreenAdapter.height(30)),
                          //width: ScreenAdapter.width(400),
                          height: ScreenAdapter.height(250),
                          child: Image.asset(
                              "assets/images/public/printticketloading.gif",
                              fit: BoxFit.fitHeight),
                        ),
                      ],
                    ),
                  )),
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
