

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
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
      height: ScreenAdapter.height(175),
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(10),
          right: ScreenAdapter.width(10),
          top: ScreenAdapter.width(14),
          bottom: ScreenAdapter.width(14)),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RectangleImageView(image: image, radius: imageRadius),

                SizedBox(width: ScreenAdapter.width(20)),
                Expanded(
                  //width: ScreenAdapter.width(500),
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //title
                      AutoSizeText(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      //subtitle
                      if (subtitle != null &&  subtitle != "")
                        AutoSizeText(
                          subtitle! + subtitle!,
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: GFont.getFontFamily(),
                            fontSize: 32,
                            color: Colors.grey,
                          ),
                        ),
                      // SizedBox(
                      //   height: 10,
                      // ),
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
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 96,98,102),
                            ),),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ],
            ),
          ),

          //Spacer(),

          SizedBox(width: ScreenAdapter.width(20)),

          Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: ScreenAdapter.width(52),
                    height: ScreenAdapter.width(52),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.remove, color: Colors.grey,),
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
                      fontSize: 34,
                      color: Color.fromARGB(255, 70, 69, 69),
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(20)),
                  Container(
                    alignment: Alignment.center,
                    width: ScreenAdapter.width(52),
                    height: ScreenAdapter.width(52),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
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
              )
          ),
        ],
      ),
    );
  }
}

class RectangleImageView extends StatelessWidget {
  final ImageProvider image;
  final double radius;
  final Function? onTap;
  final double aspectRatio;

  RectangleImageView(
      {Key? key, required this.image, this.radius = 10.0, this.onTap, this.aspectRatio = 1.0});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              //color: Colors.green,
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),

            //child: publicShowMenuImage(imgPath:item['homeImageHttp'], imgWidth:350.0, imgHeight:350.0,subTitle:item["subtitle"]),
          )),
    );
  }
}