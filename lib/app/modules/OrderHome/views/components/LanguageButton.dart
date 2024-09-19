

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

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
            width: ScreenAdapter.width(260),
            padding: EdgeInsets.only(
              left: ScreenAdapter.width(30),
              right: ScreenAdapter.width(30),
              top: ScreenAdapter.height(10),
              bottom: ScreenAdapter.height(10),
            ),
            decoration: BoxDecoration(
              color: selected ? ColorsUtil.hexToColor(Gcolor.greenThemeColor)  : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey, width: 2),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RectangleImageView(
                    image: icon, radius: 0),
                SizedBox(width: 20,),
                Container(
                  alignment: Alignment.center,
                  child:
                   Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontSize: 24,
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