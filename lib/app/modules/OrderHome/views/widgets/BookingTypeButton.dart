
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

import '../../../menuPage/views/widgets/car_item_view.dart';

class BookingTypeButton extends StatelessWidget {
  final Icon icon;
  final String title;
  final bool selected;
  final Function? onTap;
  final double width;

  BookingTypeButton(
      {Key? key,
        required this.icon,
        required this.title,
        this.width = 400,
        this.onTap, required this.selected,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onTap?.call(),
        // child: AspectRatio(
        //   aspectRatio: 2.5,
        child:
        Container(
          padding: EdgeInsets.all(10),
          height:ScreenAdapter.height(280),
          width: ScreenAdapter.width(width),
          decoration: BoxDecoration(
            color: selected ? ColorsUtil.hexToColor(Gcolor.greenThemeColor) : Colors.green[900],
            borderRadius: BorderRadius.circular(10),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.2),
            //     offset: Offset(6, 5),
            //     blurRadius: 5,
            //   ),
            // ],
          ),

          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                height: ScreenAdapter.height(140),
                child: icon,
              ),

              Expanded(child:
              Container(
                padding: EdgeInsets.only(bottom: 40),
                alignment: Alignment.bottomCenter,
                child: AutoSizeText(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white,//const Color.fromARGB(255, 53,59,80),
                    fontSize: 60,
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )

              )
            ],
          ),
        )
      //),
    );
  }
}