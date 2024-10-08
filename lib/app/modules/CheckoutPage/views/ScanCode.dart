import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/checkout_page_controller.dart';

class ScanCodeView extends GetView {
  final CheckoutPageController controller = Get.find();
  // ScanCodeView({Key? key}) : super(key: key);
  final localKey = Get.locale?.languageCode.toUpperCase() ?? "JP";

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
                                controller.requestOrderList(
                                    controller.scanQrCode2Controller,
                                    controller.scanQrCode2FocusNode);
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
                          //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                        )
                        /*gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ColorsUtil.hexToColor("#C47829"),
                      ColorsUtil.hexToColor("#854610"),
                    ],
                  ),*/
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                  fontSize: ScreenAdapter.fontSize(34.0)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(
                    //height: ScreenAdapter.height(940),
                    child: Image.asset(
                      GImage.getImageString("imgpublic", "jingsuantag"),
                      width: ScreenAdapter.width(970),
                      fit: BoxFit.fitWidth,
                    ),
                  )),
                  Container(
                    //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                    height: ScreenAdapter.height(200),
                    color: ColorsUtil.hexToColor("#DCDCDC"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            //try {
                            //showCancelConfirm();
                            //Navigator.pop(context);
                            //Get.back();
                            controller.backCheckHome();
                            //} catch (_) {}
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(270),
                            height: ScreenAdapter.height(140),
                            //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((5.0)),
                            ),
                            child: Text(
                              GString.getToString(
                                  localKey, "settlement_back"),
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor("#000000"),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: ScreenAdapter.fontSize(34.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenAdapter.width(180)),
                        Container(
                          margin:
                              EdgeInsets.only(left: ScreenAdapter.width(20)),
                          width: ScreenAdapter.width(270),
                          height: ScreenAdapter.height(100),
                        )
                      ],
                    ),
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
