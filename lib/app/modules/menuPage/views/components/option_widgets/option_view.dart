

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/common/NumberFormat.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/fontSize.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/menuPage/views/components/option_widgets/widgets/PriceLabel.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

import 'option_list.dart';

class OptionView extends StatefulWidget {
  OptionView({
    Key? key,
    required this.languageKey,
    required this.isLabel,
    required this.itemPrice,
    required this.originalPrice,
    required this.optionInfo,
    required this.mainTitle,
    required this.subtitle,
    required this.addToCartCallback,
  }) : super(key: key);

  final bool isLabel;
  final String languageKey;
  final int itemPrice;
  final int originalPrice;
  final String mainTitle;
  final List subtitle;
  final List<dynamic> optionInfo;
  final Function(int, List, String) addToCartCallback;



  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OptionViewState();
  }
}

class OptionGroup {
  String groupCode;
  String groupName;
  List selectedOptionCodes;
  List<String> selectedOptionNames;
  String maxNum;
  String minNum;
  OptionGroup({
    required this.groupCode,
    required this.groupName,
    required this.selectedOptionCodes,
    required this.selectedOptionNames,
    required this.maxNum,
    required this.minNum,
  });

  get maxNumInt => int.parse(maxNum);
  get minNumInt => int.parse(minNum);

  get canAdd => selectedOptionCodes.length >= minNumInt;

  get optionTitle {

    if (selectedOptionNames.isEmpty) {
      return '';
    }

    Map<String, int> counts = {};
    List<String> resultParts = [];

    for (String name in selectedOptionNames) {
      counts[name] = (counts[name] ?? 0) + 1;
    }

    for (var entry in counts.entries) {
      if (entry.value > 1) {
        resultParts.add("'${entry.key}x${entry.value}'");
      } else {
        resultParts.add("'${entry.key}'");
      }
    }

    return groupName + ':' + resultParts.join('+').replaceAll("'", "");
  }
}

class _OptionViewState extends State<OptionView> {

  late int _currentPrice;
  late String _mainTitle;
  late List _subtitle;
  List<OptionGroup> _optionGroupList = [];
  List<String> _selectOptionCodes = [];
  String get _optionTitle => _optionGroupList.map((e) => e.optionTitle).join("　");

  @override
  void initState() {
    super.initState();
    _initData();
    _initOptionGroup();
  }

  _initOptionGroup() {
    //初始化选项组
    for (var optionItem in widget.optionInfo) {
      String groupCode = optionItem['groupCode'] ?? "";
      List selectedOptionCodes = [];
      List<String> selectedOptionNames = [];
      String maxNum = optionItem['multipleState'] ?? 0;
      String minNum = optionItem['smallest'] ?? 0;
      List<dynamic> optionVoList = optionItem['optionVoList'] ?? [];
      for (var option in optionVoList) {
        String optionCode = option['optionCode'];
        bool isSelected = option['checked'] ?? false;
        if (isSelected && optionCode.isNotEmpty) {
          final int optionPrice = option['currentPrice'] ?? 0;
          _currentPrice += optionPrice;
          selectedOptionCodes.add(optionCode);
          _selectOptionCodes.add(optionCode);
          selectedOptionNames.add(option['mainTitle'] ?? "");
        }
      }

      _optionGroupList.add(OptionGroup(
        groupCode: groupCode,
        groupName: optionItem['groupName'] ?? "",
        selectedOptionCodes: selectedOptionCodes,
        selectedOptionNames: selectedOptionNames,
        maxNum: maxNum,
        minNum: minNum,
      ));
    }
  }

  _initData() {
    _currentPrice = widget.itemPrice;
    _mainTitle = widget.mainTitle;
    _subtitle = widget.subtitle;
  }

  _updatePrice(String groupCode, String optionCode, String title, int optionPrice, bool isAdd, bool isSelected) {

    if (isSelected) {
      //选中
      if (isAdd) {
        setState(() {
          _currentPrice += optionPrice;
          _selectOptionCodes.add(optionCode);
        });
        _updateOptionList(groupCode, optionCode, title, isAdd);
      } else {
        //
        int index = _selectOptionCodes.indexOf(optionCode);

        setState(() {
          _currentPrice -= optionPrice;
          _selectOptionCodes.removeAt(index);
        });
        _updateOptionList(groupCode, optionCode, title, isAdd);
      }
    } else {

      int price = _currentPrice;
      List<String> optionCodes = _selectOptionCodes;
      for (int i = optionCodes.length - 1; i >= 0; i--) {
        if (optionCodes[i] == optionCode) {
          optionCodes.removeAt(i);
          price -= optionPrice;
        }
      }
      setState(() {
        _currentPrice = price;
        _selectOptionCodes = optionCodes;

      });
      _updateOptionList(groupCode, optionCode, title, false);
    }

  }

  _updateOptionList(groupCode, String optionCode, String optionName, bool isAdd) {
    List<OptionGroup> optionGroupMap = _optionGroupList;

    for (var optionGroup in optionGroupMap) {
      if (optionGroup.groupCode == groupCode) {
        if (isAdd) {
            optionGroup.selectedOptionCodes.add(optionCode);
            optionGroup.selectedOptionNames.add(optionName);
        } else {
          optionGroup.selectedOptionCodes.remove(optionCode);
          optionGroup.selectedOptionNames.remove(optionName);
        }
      }
    }

    setState(() {
      _optionGroupList = optionGroupMap;
    });

  }

  _addToCart() {
    //添加到购物车
    bool canAdd = true;
    for (var optionGroup in _optionGroupList) {
      if (!optionGroup.canAdd) {
        canAdd = false;
        final showTag = GString.getToString(widget.languageKey, "menu_option_less_smallest");
        Get.dialog(
            DialogUtils.alertOneButton("${showTag.replaceAll("%%", optionGroup.groupName)}",
                title: GString.getToString(widget.languageKey, "tag_title"),
                confirmtitle: GString.getToString(widget.languageKey,"tag_button_yes"),
                confirm: () {
                  Get.back();
                })
        );
        break;
      }
    }
    if (canAdd)
    widget.addToCartCallback(_currentPrice, _selectOptionCodes, _optionTitle);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _optionGroupList = [];
    _selectOptionCodes = [];
    _currentPrice = 0;
    
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: UnconstrainedBox(
        child: Container(
          width: ScreenAdapter.width(1060),
          //height: ScreenAdapter.height(1000),
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            child: Container(
              // width: ScreenAdapter.width(1060),
              width: ScreenAdapter.width(1060),
              padding: EdgeInsets.only(top: ScreenAdapter.height(20)),
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //标题价格
                      _titleArea(_currentPrice, widget.originalPrice, _mainTitle, _subtitle),
                      Divider(
                        height: 1,
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),

                      if(widget.optionInfo.length > 0)
                        Container(
                          constraints: BoxConstraints(minHeight: ScreenAdapter.height(400),maxHeight: ScreenAdapter.height(1500),),
                          padding: EdgeInsets.only(left: ScreenAdapter.width(15),top: ScreenAdapter.height(10),right: ScreenAdapter.width(15),bottom: ScreenAdapter.height(10)),
                          child: Scrollbar(
                              child: SingleChildScrollView(
                                physics: ClampingScrollPhysics(),
                                child: _publicShowOneItemOptionGroup(widget.optionInfo),
                              )
                          ),
                        ),

                      Divider(
                        height: 1,
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),
                      //标题价格
                      Container(
                        //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                        height: ScreenAdapter.height(200),
                        color: ColorsUtil.hexToColor("#DCDCDC"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            _returnButton(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //价格展示 item['currentPrice']
                                _priceLabel(),
                                //确认按钮
                                _buttonArea(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }


  _publicShowOneItemOptionGroup(optionGroupInfo) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5),
          right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...optionGroupInfo.map((optionItem) => OptionListWidget(
            isLabel: widget.isLabel,
            languageKey: widget.languageKey,
            optionSelectMaxNum: optionItem['multipleState'] ?? '1',
            optionListInfo: optionItem['optionVoList'] ?? [],
            title: optionItem['groupName'] ?? "",
            subTitle: optionItem['remark'] ?? "",
            onSelected: (group, option, title, price, isAdd, isSelected) {
              //选中回调
              _updatePrice(group, option, title, price, isAdd, isSelected);
            },
          ))
        ]
      ),
    );
  }



  Widget _buttonArea() {
    return InkWell(
      enableFeedback: false,
      onTap: () {
        _addToCart();
      },
      child: Container(
        margin:EdgeInsets.only(right: ScreenAdapter.width(20),),
        width: ScreenAdapter.width(260),
        height: ScreenAdapter.height(140),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorsUtil.hexToColor("#078E42"),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Text(
            GString.getToString(
                widget.languageKey, "add_option_cart"),
            style: TextStyle(
              fontFamily: GFont.getFontFamily(),
              fontSize: ScreenAdapter.fontSize(40),
              fontWeight: FontWeight.w500,
              color: ColorsUtil.hexToColor(
                  Gcolor.optionBtnColor),
            )),
      ),
    );
  }

  _returnButton() {
    return InkWell(
      onTap: (){
        // controller.paymentIsShow = false;
         Get.back();
      },
      child: Container(
        margin: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(20)),
        alignment: Alignment.center,
        width: ScreenAdapter.width(240),
        height: ScreenAdapter.height(120),
        //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
        decoration: BoxDecoration(

          color: ColorsUtil.hexToColor("#FFFFFF"),
          //设置圆角
          borderRadius: new BorderRadius.circular((5.0)),
        ),
        child: Text(
          GString.getToString(widget.languageKey, "settlement_back"),
          style: TextStyle(
              color: ColorsUtil.hexToColor("#000000"),
              fontFamily: GFont.getFontFamily(),
              fontWeight: FontWeight.w500,
              fontSize: ScreenAdapter.fontSize(34.0)),
        ),
      ),
    );
  }

  _priceLabel() {
    return Container(
      padding: EdgeInsets.only(right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(30)),
      //width: ScreenAdapter.width(260),
      alignment: Alignment.bottomRight,
      child: Container(
        //color: Colors.blueGrey,
        alignment: Alignment.bottomRight,
        child: RichText(
          text: TextSpan(
              text: "¥",//¥GString.getToString(this._checkLanguage, "show_price_front"),
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(50),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                textBaseline: TextBaseline.alphabetic,
              ),

              children: [
                TextSpan(
                  text: _currentPrice.formatIntSum(),
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(70),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor(Gcolor.priceColor),
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
                TextSpan(
                  text: "（${GString.getToString(widget.languageKey, "show_price_front")}）",
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(70)/2.5,
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor(Gcolor.priceColor),
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ]),
        ),
      ),
    );
  }


  Widget _titleArea(itemPrice, originalPrice, mainTitle, subtitle) {
    return Container(
      padding: EdgeInsets.only(bottom: ScreenAdapter.height(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                          child: publicShowMenuTitle(
                              mainTitle,
                              GFontSize.cartListTitleCount,
                              Gcolor.mainTitleColor),
                        )
                    ),
                  ],
                ),

                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(10)),
                  child: Row(
                    children: [
                      Expanded(child: publicShowMenuSubtitle(subtitle)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //价格展示 item['currentPrice']
          Container(
            padding: EdgeInsets.only(right: ScreenAdapter.width(20)),
            //width: ScreenAdapter.width(260),
            alignment: Alignment.bottomRight,
            child: PrinceLabel(
                  price: itemPrice.toString(),
                  originalPrice: originalPrice.toString(),
                  languageKey: widget.languageKey,
                  priceFrontFontSize: GFontSize.menuTwopriceLift,
                  priceFrontFontColor: Gcolor.mainTitleColor,
                  priceFontSize: GFontSize.mainPrice,
                  priceFontColor: Gcolor.mainTitleColor,
                  priceBackFontSize: GFontSize.menuTwopriceRight,
                  priceBackFontColor: Gcolor.mainTitleColor,
                ),
          ),
        ],
      ),
    );
  }



  publicShowMenuSubtitle(subtitleList) {
    //标签循环相关
    if (subtitleList != null && subtitleList.length > 0) {
      var subtitle ="";
      if (subtitleList != null && subtitleList?.length > 0) {
        for (var i = 0; i < subtitleList.length; i++) {
          subtitle += subtitleList[i];
        }
      }
      return Container(
        padding: EdgeInsets.only(left:ScreenAdapter.width(5),top:ScreenAdapter.height(5),right:ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),

        child: Text(subtitle,
          style: TextStyle(
              fontFamily: GFont.getFontFamily(),
              fontSize: ScreenAdapter.fontSize(GFontSize.menuTwoTitleTag),
              color: ColorsUtil.hexToColor("#000000")),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  publicShowMenuTitle(mainTitle, mainTitleFontSize, mainTitleFontColor) {
    return AutoSizeText(
      mainTitle,
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis, //长度溢出后显示省略号
      maxLines: 2,
      style: TextStyle(
          fontFamily: GFont.getFontFamily(),
          fontSize: ScreenAdapter.fontSize(mainTitleFontSize),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(mainTitleFontColor)),
    );
  }

}