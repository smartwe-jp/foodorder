import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/Extension/StringExtension.dart';

import '../../../../config/color.dart';
import '../../../../config/colorsUtil.dart';
import '../../../../config/font.dart';
import '../../../../services/ScreenAdapter.dart';

class OptionWidget extends StatefulWidget {
  final Map optionInfo;
  final ValueChanged<bool> onChanged;
  final ValueChanged<bool> onSelected;
  final String outOfRangeMessage;
  final bool canSelect;

  const OptionWidget({
    Key? key,
    required this.optionInfo,
    required this.onChanged,
    required this.onSelected,
    this.canSelect = true,
    this.outOfRangeMessage = '超出范围',
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

  String get showPrice => _currentPrice.formatIntSum();

  @override
  void initState() {
    super.initState();
    _count = 1;
    _initOptionInfo(widget.optionInfo);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initOptionInfo(widget.optionInfo);
  }

  _initOptionInfo(Map optionInfo) {
    _max = optionInfo['max'] ?? 10;
    imageUrl = optionInfo['homeImage'];
    _mainTitle = optionInfo['mainTitle'];
    _isChecked = optionInfo['checked'] ?? false;
    _currentPrice = optionInfo['currentPrice'];
  }

  void _increment() {
    if (_count < _max) {
      setState(() {
        _count++;
      });
      widget.onChanged(true);
    } else {
      _showOutOfRangeDialog();
    }
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

  }

  void _showOutOfRangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text(widget.outOfRangeMessage),
          actions: <Widget>[
            TextButton(
              child: Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
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
                if (widget.canSelect || _isChecked) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (imageUrl != null)
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
                            (_currentPrice > 0) ?"¥$showPrice":"-¥$showPrice",
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
          if (_currentPrice > 0 && _isChecked)
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
