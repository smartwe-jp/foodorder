import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/common/Extension/StringExtension.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/imageData.dart';
import 'package:foodorder/app/modules/edit_page/logic.dart';
import 'package:foodorder/app/modules/edit_page/widgets/menu_side_bar.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

import '../../menuPage/views/widgets/car_item_view.dart';

class MenuListView extends StatelessWidget {
  final List menuItems;

  MenuListView({Key? key, required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: menuItems
          .map((item) => MenuCellView(
        tag: item['menuCode'],
        title: item['mainTitle'],
        subtitle: _publicMenuSubtitle(item['subtitle'] ?? []),
        image: item['homeImage'].toString().urlImage(),
        price: "${item['currentPrice']}",
        bounds: item['qtyBounds'],
        cover: _publicShowMenuSellOut(item['qtyBounds']),
      ))
          .toList(),
    );
  }


  _publicMenuSubtitle(subtitleList) {
    var subtitle = "";
    if (subtitleList != null && subtitleList.length > 0) {
      if (subtitleList != null && subtitleList?.length > 0) {
        for (var i = 0; i < subtitleList.length; i++) {
          subtitle += subtitleList[i];
        }
      }
    }
    return subtitle;
  }

  _publicShowMenuSellOut(bounds) {
    if (bounds == 0) {
      return Positioned(
        left: ScreenAdapter.width(5),
        top: ScreenAdapter.height(8),
        child: Image.asset(
          //"assets/images/public/shouqing${randomNum.value.toString()}.png",
          GImage.getImageString(
              "imgpublic", "shouqing_png_JP"),
          width: ScreenAdapter.width(105),
          fit: BoxFit.fitWidth,
        ),
      );
    } else if (bounds > 0) {
      var showString = "show_product_restrictions".tr
          .replaceAll('%%', bounds.toString());
      return Positioned(
        left: ScreenAdapter.width(5),
        top: ScreenAdapter.height(8),
        child: Container(
          //width: ScreenAdapter.width(230),
          height: ScreenAdapter.height(55),
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(5),
              top: ScreenAdapter.height(5),
              right: ScreenAdapter.width(5),
              bottom: ScreenAdapter.height(5)),
          decoration: BoxDecoration(
            color: ColorsUtil.hexToColor("#A61C1C"),
            //borderRadius: BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(
              color: ColorsUtil.hexToColor("#A61C1C"),
              width: 1,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text("${showString}",
                style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(24),
                    color: ColorsUtil.hexToColor("#FFFFFF"))),
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }
}

class MenuCellView extends StatelessWidget {
  final String tag;
  final String title;
  final String? subtitle;
  final String price;
  final ImageProvider image;
  final int bounds;
  final Function? onTap;
  final Widget? cover;

  final logic = Get.find<EditPageLogic>();

  MenuCellView(
      {Key? key,
        required this.tag,
        required this.title,
        this.subtitle,
        required this.price,
        required this.image,
        this.onTap,
        this.cover,
        required this.bounds})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Container(
            height: ScreenAdapter.height(188),
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(10),
                right: ScreenAdapter.width(10),
                top: ScreenAdapter.width(14),
                bottom: ScreenAdapter.width(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RectangleImageView(image: image),
                      SizedBox(width: ScreenAdapter.width(20)),
                      Expanded(
                        //width: ScreenAdapter.width(500),
                        child: Column(
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
                            if (subtitle != null)
                              Expanded(
                                child: AutoSizeText(
                                  subtitle!,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '￥',
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 96, 98, 102),
                                    ),
                                  ),
                                  TextSpan(
                                    text: price,
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 96, 98, 102),
                                    ),
                                  ),
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
                  //alignment: Alignment.center,
                  width: 200.dp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          logic.showSetSelloutAlert(tag, title, bounds);
                        },
                        child: Container(
                            alignment: Alignment.center,
                            height: 52.dp,
                            decoration: BoxDecoration(
                              color: bounds == 0
                                  ? ColorsUtil.hexToColor("#67c23a")
                                  : ColorsUtil.hexToColor("#f56c6c"),
                              borderRadius:
                              BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Text(bounds == 0 ? '完売取消' : '完売',
                                style: TextStyle(
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ))),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          if (cover != null) cover!,
        ],
      ),
    );
  }
}
