
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';


class OptionTitle extends StatelessWidget {
  final String title;
  final String subTitle;
  const OptionTitle({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left:ScreenAdapter.width(5),top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
                text: title,
                //GString.getToString(this._checkLanguage, "show_price_front"),
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(24.0),
                  fontFamily: GFont.getFontFamily(),
                  fontWeight: FontWeight.w500,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                ),
                children: [
                  TextSpan(
                    text: subTitle,
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(18.0),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w200,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                  ),
                ]),
          )
        ],
      ),
    );
  }
}