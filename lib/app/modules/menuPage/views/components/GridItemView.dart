import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_controller.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

class GridItemView extends StatelessWidget {
  final String title;
  final String subtitle;
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
                child: Column(
                  children: [

                    Container(
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          RectangleImageView(
                        image: image, radius: imageRadius, onTap: onTap, aspectRatio: aspectRatio),
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
                                fontSize: ScreenAdapter.fontSize(20),
                                fontWeight: FontWeight.w500,
                                fontFamily: GFont.getFontFamily(),
                                color: ColorsUtil.hexToColor(Gcolor.itemSubTitleColor),
                              ),
                            ),
                          ),


                        ],
                      ),
                    ),
                    
                    ItemInfoArea(
                        title: title,
                        subtitle: price,
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
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          SubTitle(title: subtitle),
          //SizedBox(width: ScreenAdapter.width(20)),
          //option button
          // (option != "")
          //     ? OptionButton(title: option, onTap: onTap)
          //     : Container(),
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
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w500,
            fontFamily: GFont.getFontFamily(),
            color: ColorsUtil.hexToColor(Gcolor.itemTitleColor),
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
            title,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(28),
              fontWeight: FontWeight.w500,
              fontFamily: GFont.getFontFamily(),
              color: ColorsUtil.hexToColor(Gcolor.itemTitleColor),
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
  final bool canScroll;

  GridMenuView({
    Key? key,
    required this.children,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.crossAxisCount, 
    this.childAspectRatio,
    this.canScroll = true
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(0), bottom: ScreenAdapter.height(0)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: canScroll ? ScrollPhysics() : NeverScrollableScrollPhysics(),
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

