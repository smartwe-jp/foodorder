import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/localString.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';
class PayResultView extends StatefulWidget {
  const PayResultView({super.key});

  @override
  State<StatefulWidget> createState() => PayResultViewState();
}

class PayResultViewState extends State<PayResultView> {
  Timer? hideTimer;

  @override
  void initState() {
    super.initState();
    hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop(true); // 只返回，业务不写这里
    });
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: ScreenAdapter.height(60)),
          Container(
            height: ScreenAdapter.height(100),
            width: ScreenAdapter.width(100),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/public/checked_green.png"),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(60),
              vertical: ScreenAdapter.height(30),
            ),
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
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                hideTimer?.cancel();
                Navigator.of(context).pop(true);
              },
              child: Container(
                width: ScreenAdapter.width(180),
                margin: EdgeInsets.only(
                  top: ScreenAdapter.height(20),
                  bottom: ScreenAdapter.height(40),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: ScreenAdapter.height(20),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(
                  "settlement_back".localized(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(28),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
