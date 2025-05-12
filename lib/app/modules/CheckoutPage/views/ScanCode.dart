import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/config/localString.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/checkout_page_controller.dart';

class ScanCodeView extends GetView  {
  final CheckoutPageController controller = Get.find();
  // ScanCodeView({Key? key}) : super(key: key);
  final localKey = Get.locale?.languageCode.toUpperCase() ?? "JP";


  get backBotton => InkWell(
                          onTap: () {
                            controller.backCheckHome();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(120),
                            height: ScreenAdapter.height(60),
                            //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              //设置圆角
                              borderRadius: new BorderRadius.circular((5.0)),
                            ),
                            child: Text(
                              GString.getToString(
                                  localKey, "settlement_back"),
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: ScreenAdapter.fontSize(32.0)),
                            ),
                          ),
                        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CheckoutPageController>(builder: (controller) {
        return controller.obx(
          (state) => AnnotatedRegion(
            value: SystemUiOverlayStyle.light,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    height: 0,
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          showCursor: true, // 显示光标
                          //readOnly: true,
                          controller: controller.scanQrCode2Controller,
                          focusNode: controller.scanQrCode2FocusNode,
                          decoration: InputDecoration(
                            hintText: "请扫码",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(11.0)),
                          onChanged: (value) {
                            //print(value);
                            if (value.length == 1) {
                              controller.showOrderEasyLoading();
                            }
                          },
                          onSubmitted: (value) {
                            Future.delayed(Duration(milliseconds: 150), () {
                              if (Platform.isAndroid) {
                                controller.doNextPay();
                              } else {
                                controller.submitOrderFlow();
                              }
                            });
                          },

                          /// 扫码密码
                        )),
                      ],
                    ),
                  ),
                  Container(
                    width: ScreenAdapter.getScreenWidth(),
                    height: ScreenAdapter.height(115),
                    decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#ffffff"),
                        border: Border(
                          bottom: BorderSide(
                              color: ColorsUtil.hexToColor("#e5e5e5"),
                              width: 5.0),
                        )
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ScreenAdapter.width(20),
                        ),
                        backBotton,
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_top_qr"),
                              width: ScreenAdapter.width(40),
                              color: Colors.black87,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(20),
                            ),
                            Text(
                              GString.getToString(
                                  localKey, "checkoutScanTitle"),
                              style: TextStyle(
                                  //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: ScreenAdapter.fontSize(44.0)),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(180),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: ScreenAdapter.height(40),
                  ),


                  Container(
                    //height: ScreenAdapter.height(940),
                    child: Image.asset(
                      GImage.getImageString("imgpublic", "jingsuantag"),
                      height: ScreenAdapter.height(970),
                      fit: BoxFit.fitWidth,
                    ),
                  ),

                  //Tips
                  //checkoutScanTips 请把二维码放在扫描框内 日语：QRコードをスキャンボックスに置いてください
                  Spacer(),
                  Container(
                    padding: EdgeInsets.only(
                        left: ScreenAdapter.width(20),
                        right: ScreenAdapter.width(20)),
                    child: Text(
                      "checkoutScanTips".localized(),
                      style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.w600,
                          fontFamily: GFont.getFontFamily(),
                          fontSize: ScreenAdapter.fontSize(42.0)),
                    ),
                  ),

                  SizedBox(
                    height: ScreenAdapter.height(40),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      AnimatedBuilder(
                        animation: controller.animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, controller.animation.value), // 动态调整纵轴偏移
                            child: Icon(
                              Icons.keyboard_double_arrow_down,
                              color: Colors.green[900],
                              size: 120,
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        width: ScreenAdapter.width(280),
                      ),
                    ],
                  ),
                  
                  
                  SizedBox(
                    height: ScreenAdapter.height(40),
                  ),

                  

                  Container(
                    //height: ScreenAdapter.height(940),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Image.asset(
                      GImage.getImageString("imgpublic", "scan_camera"),
                      width: ScreenAdapter.width(500),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  
                  
                  Spacer(),
                  SizedBox(
                    height: ScreenAdapter.height(40),
                  ),

                ],
              ),
            ),
          ),
          onLoading: Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  ColorsUtil.hexToColor("#80B646")),
            ),
          ),
        );
      }),
    );
  }
}
