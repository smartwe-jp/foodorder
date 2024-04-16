

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

class CarItemView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String price;
  final ImageProvider image;
  final double imageRadius;
  final Function(int) onReduce;
  final Function(int) onIncrease;
  final int quantity;

  CarItemView({
    Key? key,
    required this.title,
    this.subtitle,
    required this.image,
    required this.onReduce,
    required this.onIncrease,
    this.imageRadius = 10.0,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenAdapter.height(180),
      padding: EdgeInsets.only(
                    left: ScreenAdapter.width(10), 
                    right: ScreenAdapter.width(10), 
                    top: ScreenAdapter.width(14), 
                    bottom: ScreenAdapter.width(14)),
      child: Row(
        children: [
          RectangleImageView(image: image, radius: imageRadius),
          SizedBox(width: ScreenAdapter.width(20)),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //title
              Text(
                title,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: GFont.getFontFamily(),
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //subtitle
              if (subtitle != null)
              Text(
                subtitle ?? "",
                maxLines: 2,
                style: TextStyle(
                  fontFamily: GFont.getFontFamily(),
                  fontSize: 32,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: '￥', style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 96,98,102),
                    ),),
                    TextSpan(text: price,style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: 38,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 96,98,102),
                    ),),
                  ],
                ),
              )
              
            ],
          ),
          Spacer(),
          SizedBox(width: ScreenAdapter.width(20)),
          Container(
              alignment: Alignment.bottomCenter,
              //margin: EdgeInsets.only(right: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: ScreenAdapter.width(36),
                    height: ScreenAdapter.width(36),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.remove, color: Colors.grey.withOpacity(0.5),),
                      onPressed: () {
                        onReduce(1);   
                      },
                  ),
                ),
                SizedBox(width: ScreenAdapter.width(20)),  
                Text(
                  "$quantity",
                  style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: 20,
                    color: Color.fromARGB(255, 70, 69, 69),
                  ),
                ),
                SizedBox(width: ScreenAdapter.width(20)),  
                Container(
                  alignment: Alignment.center,
                  width: ScreenAdapter.width(36),
                  height: ScreenAdapter.width(36),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: ColorsUtil.hexToColor(Gcolor.greenThemeColor),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.add, 
                                color: Colors.white),
                    onPressed: () {
                      onIncrease(1);
                    },
                  ),
                )
                  
              ],
            )),
        ],
      ),
    );
  }
}
