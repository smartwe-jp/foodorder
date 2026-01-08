

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

class RecycleButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  RecycleButton({required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 80,
      child: InkWell(
        highlightColor: Colors.transparent, // 透明色
        splashColor: Colors.transparent, // 透明色
        onTap: (){
          // controller.showCashDetail(_detail);
          onPressed();
        },
        child: Container(
          alignment: Alignment.center,
          //width: ScreenAdapter.width(180),
          height: ScreenAdapter.height(60),
          margin: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(20),
          ),

          //边框设置
          decoration: new BoxDecoration(
            //背景
            color: ColorsUtil.hexToColor("#dca550"),
            //设置四周圆角 角度
            borderRadius: BorderRadius.all(Radius.circular(10)),
            //设置四周边框
            //border: new Border.all(width: 1, color: Colors.red),
          ),
          child: Text(
              title,
              style: TextStyle(
                fontFamily: 'NotoSansJP',
                fontSize: ScreenAdapter.fontSize(22),
                color: ColorsUtil.hexToColor("#FFFFFF"),
              )
          ),
        ),
      ),
    );
  }
}