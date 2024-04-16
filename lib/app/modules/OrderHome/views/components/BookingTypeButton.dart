
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';

class BookingTypeButton extends StatelessWidget {
  final ImageProvider icon;
  final String title;
  final bool selected;
  final Function? onTap;

  BookingTypeButton(
      {Key? key,
      required this.icon,
      required this.title,
      this.onTap, required this.selected,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: () => onTap?.call(),
          child: AspectRatio(
            aspectRatio: 2.5,
            child:Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: selected ? ColorsUtil.hexToColor(Gcolor.greenThemeColor) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  offset: Offset(6, 5),
                  blurRadius: 5,
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RectangleImageView(
                    image: icon, radius: 0),
                    
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color.fromARGB(255, 53,59,80),
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}