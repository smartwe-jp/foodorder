import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/common/Extension/StringExtension.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_controller.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

class GridItemView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String originalPrice;
  final String price;
  final ImageProvider image;
  final double imageRadius;
  final String option;
  final Function onTap;
  final Widget cover;
  final double aspectRatio;

  GridItemView(
      {Key? key,
        required this.title,
        required this.subtitle,
        required this.originalPrice,
        required this.price,
        required this.image,
        required this.onTap,
        this.option = "",
        this.imageRadius = 10.0,
        this.aspectRatio = 1.0,
        this.cover = const SizedBox()});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
          onTap: () => onTap(),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF0F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [

                    Container(
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          RectangleImageView(
                              image: image, radius: imageRadius, onlyTopRadius: true, onTap: onTap, aspectRatio: aspectRatio),
                          //subtitle 底部叠在图片上，限制两行
                          if (subtitle.isNotEmpty)
                            Container(
                              padding: EdgeInsets.only(
                                  left: ScreenAdapter.width(10),
                                  right: ScreenAdapter.width(10),
                                  top: ScreenAdapter.width(5),
                                  bottom: ScreenAdapter.width(5)),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(169, 255, 255, 255),
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: GFont.getFontFamily(),
                                  color: ColorsUtil.hexToColor(Gcolor.itemSubTitleColor),
                                ),
                              ),
                            ),


                        ],
                      ),
                    ),
                    Expanded(child: ItemInfoArea(
                        title: title,
                        subtitle: price,
                        originalPrice: originalPrice,
                        option: option,
                        onTap: onTap),)

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
  final onlyTopRadius;
  final Function? onTap;
  final double aspectRatio;

  RectangleImageView(
      {Key? key, required this.image, this.radius = 10.0, this.onlyTopRadius = false, this.onTap, this.aspectRatio = 1.0});

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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
                bottomLeft: Radius.circular(onlyTopRadius ? 0 : radius),
                bottomRight: Radius.circular(onlyTopRadius ? 0 : radius),
              ),
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
  final String originalPrice;

  ItemInfoArea(
      {Key? key,
        required this.title,
        required this.subtitle,
        required this.originalPrice,
        this.option = "",
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //标题
        MainTitle(title: title),
        //价格
        Row(mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubTitle(title: subtitle, originalPrice: originalPrice),
              //SizedBox(width: ScreenAdapter.width(20)),
              //option button
              // (option != "")
              //     ? OptionButton(title: option, onTap: onTap)
              //     : Container(),
            ]),
        SizedBox(height: 20,)
      ],
    );
  }
}

class MainTitle extends StatelessWidget {
  final String title;

  MainTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 20, left: ScreenAdapter.width(10)),
            alignment: Alignment.topLeft,
            child: AutoSizeText(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(28),
                fontWeight: FontWeight.w600,
                fontFamily: GFont.getFontFamily(),
                color: ColorsUtil.hexToColor(Gcolor.itemTitleColor),
              ),
            ),
          ),
        );
  }
}

class SubTitle extends StatelessWidget {
  final String title;
  final String originalPrice;

  SubTitle({required this.title, required this.originalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(
          right: ScreenAdapter.width(10)),
      child:
      Row(
          children: [
            Text(
                "¥",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(22),
                  fontWeight: FontWeight.w500,
                  fontFamily: GFont.getFontFamily(),
                  color: ColorsUtil.hexToColor(Gcolor.itemTitleColor),
                )
            ),
            SizedBox(width: ScreenAdapter.width(5),),
            Text(
              title.formatSum(),
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(28),
                fontWeight: FontWeight.w600,
                fontFamily: GFont.getFontFamily(),
                color: ColorsUtil.hexToColor(Gcolor.itemTitleColor),
              ),
            ),
            if (originalPrice != title && originalPrice != '0')
            SizedBox(width: ScreenAdapter.width(5),),
            if (originalPrice != title && originalPrice != '0')

                Text(
                  originalPrice.formatSum(),
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(22),
                    fontWeight: FontWeight.w500,
                    fontFamily: GFont.getFontFamily(),
                    color: ColorsUtil.hexToColor("#A9A9A9"),
                    decoration: TextDecoration.lineThrough,
                  ),
                )
          ]
      ),

    );
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
            fontSize: ScreenAdapter.fontSize(16),
            fontFamily: GFont.getFontFamily(),
            fontWeight: FontWeight.w400,
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
  final EdgeInsetsGeometry padding;
  final bool canScroll;

  GridMenuView({
    Key? key,
    required this.children,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.crossAxisCount,
    this.childAspectRatio,
    this.padding = EdgeInsets.zero,
    this.canScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GridView.builder(
        padding: EdgeInsets.only(
            left:ScreenAdapter.width(15),
            right: ScreenAdapter.width(15),
            bottom: ScreenAdapter.height(30)
        ),
        physics: canScroll ? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()) : NeverScrollableScrollPhysics(),
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


class GridMenuViews extends StatefulWidget {
  final MenuPageController controller;
  final List<String> categories; // 每个页面的类别
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final bool canScroll;

  GridMenuViews({
    Key? key,
    required this.categories,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.crossAxisCount,
    this.childAspectRatio,
    this.canScroll = true,
    required this.controller,
  });

  @override
  _GridMenuViewState createState() => _GridMenuViewState();
}

class _GridMenuViewState extends State<GridMenuViews> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Widget>> _fetchData(String category) async {
    // 模拟网络请求，根据类别获取数据
    await Future.delayed(Duration(seconds: 2));
    // 返回模拟数据
    return List.generate(10, (index) => Card(child: Center(child: Text('$category Item $index'))));
  }





  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.categories.length,
      scrollDirection: Axis.vertical,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemBuilder: (context, pageIndex) {
        String category = widget.categories[pageIndex];

        return Padding(
          padding: EdgeInsets.only(
              top: ScreenAdapter.height(0), bottom: ScreenAdapter.height(0)),
          child: FutureBuilder<List<Widget>>(
            future: _fetchData(category),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data available'));
              } else {


                return GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: widget.canScroll ? ScrollPhysics() : NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: widget.mainAxisSpacing ?? ScreenAdapter.height(40),
                      crossAxisSpacing: widget.crossAxisSpacing ?? ScreenAdapter.width(20),
                      crossAxisCount: widget.crossAxisCount ?? 3,
                      childAspectRatio: widget.childAspectRatio ?? 0.76),
                  itemBuilder: (BuildContext context, int index) {
                    return snapshot.data![index];
                  },
                  itemCount: snapshot.data!.length,
                );
              }
            },
          ),
        );
      },
    );
  }
}

