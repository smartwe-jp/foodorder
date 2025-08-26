
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/font.dart';
import '../services/ScreenAdapter.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color bgColor;
  final Function onTap;
  final double radius;

  CustomButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.bgColor = Colors.blue,
    this.titleColor = Colors.white,
    this.radius = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
        onTap: () {
          onTap();
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.center,
          //height: ScreenAdapter.height(80),
          constraints: BoxConstraints(minWidth: ScreenAdapter.width(260), maxHeight: 60),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: new BorderRadius.circular((radius)),
          ),
          child: Text(title,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(34),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w500,
                color: titleColor,
              )),
        ));
  }
}
