import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/common/Extension/StringExtension.dart';
import 'package:badges/badges.dart' as badges;
import 'package:foodorder/app/config/localString.dart';
import 'package:get/get.dart';

import '../../../../config/color.dart';
import '../../../../config/colorsUtil.dart';
import '../../../../config/font.dart';
import '../../../../config/string.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../../../widget/DialogUtils.dart';

class OptionWidget extends StatefulWidget {
  final bool isLabelOption;
  final Map optionInfo;
  final ValueChanged<bool> onChanged;
  final ValueChanged<bool> onSelected;
  final bool isSelected;
  final bool canSelect;
  final String languageKey;
  final int maxNum;

  const OptionWidget({
    Key? key,
    required this.isLabelOption,
    required this.optionInfo,
    required this.onChanged,
    required this.onSelected,
    required this.isSelected,
    required this.languageKey,
    this.canSelect = true,
    this.maxNum = 1,
  }) : super(key: key);

  @override
  _PlusMinusWidgetState createState() => _PlusMinusWidgetState();
}

class _PlusMinusWidgetState extends State<OptionWidget> {
  late int _count;
  //late int _min;
  late int _max;
  String? imageUrl;
  late String _mainTitle;
  late bool _isChecked;
  late int _currentPrice;
  late List _buttonColor;


  String get showPrice => _currentPrice.formatIntSum();
  String get showMinusPrice => (-_currentPrice).formatIntSum();

  @override
  void initState() {
    super.initState();
    _count = 1;
    _initOptionInfo(widget.optionInfo);
  }

  @override
  void didUpdateWidget(covariant OptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    //if (oldWidget.optionInfo != widget.optionInfo) {
    _initOptionInfo(widget.optionInfo);
    //}
  }

  _initOptionInfo(Map optionInfo) {
    _max = widget.maxNum;
    imageUrl = optionInfo['homeImage'];
    _mainTitle = optionInfo['mainTitle'];
    _isChecked = widget.isSelected;
    _currentPrice = optionInfo['currentPrice'];
    _buttonColor = (optionInfo['buttonColorValue'] != null) ? optionInfo['buttonColorValue'].split(',') : [];
  }

  void _increment() {
    if (_count < _max + _count) {
      setState(() {
        _count++;
      });
      widget.onChanged(true);
    } else {
      _showOutOfRangeDialog();
    }
    //widget.onChanged(true);
  }

  void _decrement() {
    if (_count > 1) {
      setState(() {
        _count--;
      });
      widget.onChanged(false);
    } else {
      setState(() {
        _count = 1;
        _isChecked = false;
      });
      widget.onSelected(false);
    }
    //widget.onChanged(false);

  }

  void _showOutOfRangeDialog() {

    Get.dialog(
        DialogUtils.alertOneButton('menu_option_more_multipleState'.tr.replaceAll("%%", _mainTitle),
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () {
              Get.back();
            })
    );

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text("tag_title".localized()),
    //       content: Text('menu_option_more_multipleState'.localized().replaceAll("%%", _mainTitle)),
    //       actions: <Widget>[
    //         TextButton(
    //           child: Text("tag_button_yes".localized()),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }



  @override
  Widget build(BuildContext context) {
    return widget.isLabelOption
        ? _labelOptionWidget()
        : _imageOptionWidget();
  }


  _imageOptionWidget(){
    return Container(
      width: ScreenAdapter.height(196),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(5),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(5),
                bottom: ScreenAdapter.height(5)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                bool checked = !_isChecked;
                if (widget.canSelect) {
                  setState(() {
                    _isChecked = checked;
                    if (!checked) {
                      _count = 1;
                    }
                  });
                }
                widget.onSelected(checked);
              },
              child:
              Stack(
                children: [
                  Container(
                    height: ScreenAdapter.height(180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //color: ColorsUtil.hexToColor("#FFFFFF"),
                      border: Border.all(
                        color: ColorsUtil.hexToColor("#c9c9c9"),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: ColorsUtil.hexToColor("#F9F9F9"),
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (imageUrl != null && imageUrl != "")
                          CachedNetworkImage(imageUrl:widget.optionInfo['homeImage'],
                              width: ScreenAdapter.width(160),
                              height: ScreenAdapter.height(110),
                              fit: BoxFit.fitHeight),

                        Container(
                            width: ScreenAdapter.width(185),
                            height: ScreenAdapter.height(60),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: ScreenAdapter.width(20),
                                    maxWidth: ScreenAdapter.width(175),
                                    minHeight: ScreenAdapter.height(30),
                                    maxHeight: ScreenAdapter.height(60),
                                  ),
                                  child: AutoSizeText(
                                      _mainTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: GFont.getFontFamily(),
                                        fontSize: ScreenAdapter.fontSize(24.0),
                                        color: ColorsUtil.hexToColor("#914F14"),
                                      ),
                                      softWrap: true,
                                      //minFontSize: 10,
                                      //maxFontSize: 12,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),

                  if (_currentPrice != 0)
                    Positioned(
                      right: ScreenAdapter.width(0),
                      top: ScreenAdapter.height(0),
                      child: Container(
                        //width: ScreenAdapter.width(46),
                          height: ScreenAdapter.height(32),
                          alignment: Alignment.center,
                          //padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                          padding: EdgeInsets.only(
                            //top:ScreenAdapter.height(2),
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)
                          ),
                          // alignment: Alignment.topRight,
                          decoration: BoxDecoration(
                            color: (_currentPrice > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Text(
                              (_currentPrice > 0) ?"¥$showPrice":"-¥$showMinusPrice",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(20),
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(
                                    Gcolor.optionBtnColor),
                              ))),
                    ),

                  if (_isChecked)
                    Positioned(
                      right: ScreenAdapter.width(0),
                      top: ScreenAdapter.height(30),
                      child: Container(
                          width: ScreenAdapter.width(180),
                          height: ScreenAdapter.height(120),
                          alignment: Alignment.center,

                          child: Icon(
                            Icons.check,
                            color: ColorsUtil.hexToColor("#2aa515"),
                            size: 120,
                          )
                      ),
                    )
                ],
              ),
            ),
          ),
          if (_currentPrice > 0 && _isChecked && (_max + _count > 1))
            _plusMinusWidget(),
        ],
      ),
    );
  }

  _labelOptionWidget(){
    return Container(
      width: ScreenAdapter.width(255),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(5),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(5),
                bottom: ScreenAdapter.height(5)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                bool checked = !_isChecked;
                if (widget.canSelect) {
                  setState(() {
                    _isChecked = checked;
                    if (!checked) {
                      _count = 1;
                    }
                  });
                }
                widget.onSelected(checked);
              },
              child: badges.Badge(
                showBadge: (_currentPrice != 0) ? true : false,
                badgeContent: Text(
                    (_currentPrice > 0) ?"¥$showPrice":"-¥$showMinusPrice",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(20),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(
                          Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position:badges.BadgePosition.topEnd(top: -18, end: -7),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding: EdgeInsets.only(left: 5,top: 3,right: 5,bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (_currentPrice > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),

                ),
                child: Container(
                    width: ScreenAdapter.width(245),
                    height: ScreenAdapter.height(70),
                    alignment: Alignment.center,
                    decoration: (_isChecked)
                        ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#C47829"),
                          ColorsUtil.hexToColor("#854610"),
                        ],
                      ),

                    )
                        : (_buttonColor.length>1) ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //color: ColorsUtil.hexToColor(optionVolistSon['buttonColorValue']),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor(_buttonColor[0] ?? "#E9CE9B"),
                          ColorsUtil.hexToColor(_buttonColor[1] ?? "#CEA062"),
                        ],
                      ),

                    ): BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#E9CE9B"),
                          ColorsUtil.hexToColor("#CEA062"),
                        ],
                      ),

                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (imageUrl != null && imageUrl != "")
                        CachedNetworkImage(imageUrl:imageUrl!,
                            width: ScreenAdapter.width(18),
                            height: ScreenAdapter.height(30),
                            color: _isChecked ? ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight),
                        SizedBox(
                          width: ScreenAdapter.width(4),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: ScreenAdapter.width(20),
                            maxWidth: ScreenAdapter.width(220),
                            minHeight: ScreenAdapter.height(30),
                            maxHeight: ScreenAdapter.height(62),
                          ),
                          child: AutoSizeText(
                              _mainTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: GFont.getFontFamily(),
                                fontSize: ScreenAdapter.fontSize(24.0),
                                color: _isChecked ? ColorsUtil.hexToColor(Gcolor.optionBtnColor) : ColorsUtil.hexToColor("#914F14"),
                              ),
                              softWrap: true,
                              //minFontSize: 10,
                              //maxFontSize: 12,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
          ),
          if (_currentPrice > 0 && _isChecked && (_max + _count > 1))
            _plusMinusWidget(),
        ],
      ),
    );
  }


  _plusMinusWidget() {
    return Container(
      // width: ScreenAdapter.height(196),
      margin: const EdgeInsets.only( top: 5), // ScreenAdapter.width/height(5) replaced with const EdgeInsets
      padding: const EdgeInsets.only(
          left: 5, top: 5, right: 5, bottom: 5), // ScreenAdapter.width/height(5) replaced with const EdgeInsets
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: _decrement,
            child: Container(
              padding: const EdgeInsets.only(
                  bottom: 10), // ScreenAdapter.height(5) replaced with const EdgeInsets
              child: const Icon(
                Icons.remove_circle,
                size: 50,
                color: Colors.green, // Replace ColorsUtil and Gcolor if needed
              ),
            ),
          ),
          Container(
            width: 60,  // ScreenAdapter.width(60) replaced with direct value
            height: 60, // ScreenAdapter.height(60) replaced with direct value
            alignment: Alignment.topCenter,
            child: Text(
              "$_count",
              style: const TextStyle( // Replace ScreenAdapter.fontSize and GFont if needed. Also made const
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87), // Replace ColorsUtil and Gcolor if needed. Also made const
            ),
          ),
          InkWell(
            onTap: _increment,
            child: Container(
              padding: const EdgeInsets.only(
                  bottom: 10), // ScreenAdapter.height(5) replaced with const EdgeInsets
              child: const Icon(
                Icons.add_circle_outlined,
                size: 50,
                color: Colors.green, // Replace ColorsUtil and Gcolor if needed. Also made const
              ),
            ),
          ),
        ],
      ),
    );
  }
}
