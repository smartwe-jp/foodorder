import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/localString.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

class PayResultView extends StatefulWidget {
  final Function dismiss;

  const PayResultView({super.key, required this.dismiss});

  @override
  State<StatefulWidget> createState() {
    return PayResultViewState();
  }
}

class PayResultViewState extends State<PayResultView> {
  Timer? hideTimer;

  String _localKey = "JP";

  @override
  void initState() {
    _localKey = Get.locale?.languageCode.toUpperCase() ?? "JP";
    super.initState();
    _delayHide();
  }

  _delayHide() async {
    hideTimer = Timer(Duration(seconds: 5), () {
      widget.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          top: ScreenAdapter.height(100),
        ),
        child: SimpleDialog(
          insetPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Container(
              width: ScreenAdapter.width(600),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: ScreenAdapter.height(60),
                  ),
                  Container(
                    height: ScreenAdapter.height(100),
                    width: ScreenAdapter.width(100),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/images/public/checked_green.png"),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: ScreenAdapter.width(60),
                      right: ScreenAdapter.width(60),
                      bottom: ScreenAdapter.height(30),
                      top: ScreenAdapter.height(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'pay_success_title'.localized(),
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(28),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )),
          children: [
            // Divider(
            //   height: 1,
            //   color: Colors.black,
            // ),
            Container(
                padding: EdgeInsets.only(
                  top: ScreenAdapter.height(20),
                ),
                //decoration: BoxDecoration(color: Colors.grey),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        hideTimer?.cancel();

                        widget.dismiss();
                      },
                      child: Container(
                        width: 150,
                        padding: EdgeInsets.only(
                          left: ScreenAdapter.width(20),
                          right: ScreenAdapter.width(20),
                          bottom: ScreenAdapter.height(20),
                          top: ScreenAdapter.height(20),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.blue,
                          // border: Border.all(
                          //   color: Colors.black,
                          //   width: 2,
                          // ),
                        ),
                        child: Text(
                          GString.getToString(_localKey, "settlement_back"),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GFont.getFontFamily(),
                            fontSize: ScreenAdapter.fontSize(28),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ));
  }
}
