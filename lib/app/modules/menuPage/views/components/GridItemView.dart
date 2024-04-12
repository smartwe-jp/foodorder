import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

class GridItemView extends StatelessWidget {
  final String title;
  final String subtitle;
  final ImageProvider image;
  final double imageRadius;
  final String option;
  final Function onTap;
  final Widget cover;

  GridItemView(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.image,
      required this.onTap,
      this.option = "",
      this.imageRadius = 10.0,
      this.cover = const SizedBox()});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
          onTap: () => onTap(),
          child: Stack(
            children: [
              Container(
                child: Column(
                  children: [
                    RectangleImageView(
                        image: image, radius: imageRadius, onTap: onTap),
                    ItemInfoArea(
                        title: title,
                        subtitle: subtitle,
                        option: option,
                        onTap: onTap),
                  ],
                ),
              ),
              cover
            ],
          )),
    );
  }
}

class RectangleImageView extends StatelessWidget {
  final ImageProvider image;
  final double radius;
  final Function? onTap;

  RectangleImageView(
      {Key? key, required this.image, this.radius = 10.0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AspectRatio(
          aspectRatio: 1.0,
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

class ItemInfoArea extends StatelessWidget {
  final String title;
  final String subtitle;
  final String option;
  final Function onTap;

  ItemInfoArea(
      {Key? key,
      required this.title,
      required this.subtitle,
      this.option = "",
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //标题
        MainTitle(title: title),
        //价格
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SubTitle(title: subtitle),
          //option button
          (option != "")
              ? OptionButton(title: option, onTap: onTap)
              : Container(),
        ])
      ],
    );
  }
}

class MainTitle extends StatelessWidget {
  final String title;

  MainTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(32),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ),
        ));
  }
}

class SubTitle extends StatelessWidget {
  final String title;

  SubTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(24),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ),
        ));
  }
}

class OptionButton extends StatelessWidget {
  final String title;
  final Function onTap;

  OptionButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.only(
            left: ScreenAdapter.width(10), right: ScreenAdapter.width(10)),
        height: ScreenAdapter.height(30),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorsUtil.hexToColor(Gcolor.greenThemeColor),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(18),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class GridMenuView extends StatelessWidget {
  final List<Widget> children;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final int? crossAxisCount;
  final double? childAspectRatio;

  GridMenuView({
    Key? key,
    required this.children,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.crossAxisCount, 
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives: true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: mainAxisSpacing ?? ScreenAdapter.height(40),
            crossAxisSpacing: crossAxisSpacing ?? ScreenAdapter.width(20),
            crossAxisCount: crossAxisCount ?? 3,
            childAspectRatio: childAspectRatio ?? 0.76),
        itemBuilder: (BuildContext context, int index) {
          return children[index];
        },
        itemCount: children.length,
      ),
    );
  }
}
