
import 'package:flutter/material.dart';
import '../config/color.dart';
import '../config/colorsUtil.dart';
import '../config/font.dart';
import '../services/ScreenAdapter.dart';

class CustomButton extends StatelessWidget {

  final String title;
  final Color titleColor;
  final Color bgColor;
  final Function onTap;

  CustomButton({Key? key,
    required this.title,
    required this.onTap,
    this.bgColor = Colors.blue,
    this.titleColor = Colors.white,
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
        onTap: (){
          onTap();
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.center,
          height: ScreenAdapter.height(120),
          constraints: BoxConstraints(
            minWidth: ScreenAdapter.width(200)
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: new BorderRadius.circular((16.0)),
          ),
          child: Text(
              title,
              style:
              TextStyle(
                fontSize: ScreenAdapter.fontSize(48),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor(
                    Gcolor.settlementBtnColor),
              )
          ),
        )
    );
  }

}