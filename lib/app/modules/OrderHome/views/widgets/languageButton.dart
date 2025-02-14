

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

import '../../../menuPage/views/widgets/car_item_view.dart';

class LanguageButton extends StatelessWidget {
  final ImageProvider icon;
  final String title;
  final bool selected;
  final Function? onTap;

  LanguageButton({Key? key, required this.title, required this.selected, this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child:
      // AspectRatio(
      //   aspectRatio: 3,
      //   child:
      Container(
        margin: EdgeInsets.only(
          left: ScreenAdapter.width(8),
          right: ScreenAdapter.width(8),
        ),
        height: ScreenAdapter.height(100),
        width: ScreenAdapter.width(236),
        padding: EdgeInsets.only(
          left: ScreenAdapter.width(30),
          right: ScreenAdapter.width(30),
          top: ScreenAdapter.height(10),
          bottom: ScreenAdapter.height(10),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [selected ? Colors.white : Colors.green, selected ? Colors.white:Colors.lightGreen],
          ),
          //borderRadius: BorderRadius.circular(15),
          //border: Border.all(color: Colors.red, width: 2),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              child: RectangleImageView(
                  image: icon, radius: 0),
            ),

            SizedBox(width: 20,),
            Container(
              alignment: Alignment.center,
              child:
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )

          ],
        ),
        //)
      ),

    );
  }
}