import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/Extension/StringExtension.dart';
import 'package:foodorder/app/modules/menuPage/views/option_widgets/widgets/OptionTitle.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../config/color.dart';
import '../../../../config/colorsUtil.dart';
import '../../../../config/font.dart';
import '../../../../config/string.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../../../widget/DialogUtils.dart';
import 'option_item.dart';

class OptionListWidget extends StatefulWidget {
  final bool isLabel;
  final String languageKey;
  final List<dynamic> optionListInfo;
  final String optionSelectMaxNum;
  final String title;
  final String subTitle;
  final String outOfRangeMessage;
  final Function(String, String, String, int, bool, bool) onSelected;

  const OptionListWidget({
    Key? key,
    required this.isLabel,
    required this.optionListInfo,
    this.outOfRangeMessage = '超出范围',
    required this.title,
    this.subTitle = '',
    required this.optionSelectMaxNum,
    required this.onSelected, required this.languageKey,
  }) : super(key: key);

  @override
  _OptionListWidgetState createState() => _OptionListWidgetState();
}

class _OptionListWidgetState extends State<OptionListWidget> {

  late int _optionSelectMaxNum;
  final int _optionMaxNum = 100;
  Set<String> _selectedOptions = Set<String>();


  @override
  void initState() {
    _optionSelectMaxNum = int.parse(widget.optionSelectMaxNum);
    for (final option in widget.optionListInfo) {
      if (option['checked']) {
        _selectedOptions.add(option['optionCode']);
      }
    }
    super.initState();
  }


  _onSelected(Map optionInfo, bool isAdd, bool isSelected) {
    Set<String> selectedOptions = Set<String>.from(_selectedOptions);


    if (isAdd) {
      selectedOptions.add(optionInfo['optionCode']);
    } else {
      selectedOptions.remove(optionInfo['optionCode']);
    }

    if (selectedOptions.length > _optionSelectMaxNum && isAdd) {
      final showTag = GString.getToString(widget.languageKey, "menu_option_more_multipleState");
      Get.dialog(
          DialogUtils.alertOneButton("${showTag.replaceAll("%%", widget.title)}",
              title: GString.getToString(widget.languageKey, "tag_title"),
              confirmtitle: GString.getToString(widget.languageKey,"tag_button_yes"),
              confirm: () {
                Get.back();
              })
      );
      return;
    }

    final String groupCode = optionInfo['group'] ?? '';
    final String optionCode = optionInfo['optionCode'] ?? '';
    final int price = optionInfo['currentPrice'] ?? 0;
    final String optionName = optionInfo['mainTitle'] ?? '';

    setState(() {
      _selectedOptions = selectedOptions;
    });

    widget.onSelected(groupCode, optionCode, optionName, price, isAdd, isSelected);
  }

  bool get _canSelect {
    if (_selectedOptions.length == _optionSelectMaxNum) {
      return false;
    } else {
      return true;
    }
  }



  @override
  void dispose() {
    super.dispose();
    _selectedOptions.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        spacing: ScreenAdapter.width(10), // set spacing here
        runSpacing: ScreenAdapter.height(20),
        alignment: WrapAlignment.start,
        children: [
          OptionTitle(title: widget.title, subTitle: widget.subTitle),
          //使用optionList创建option 需要考虑数量不大于optionMaxNum

          for (int i = 0; i < widget.optionListInfo.length; i++)
            if (i < _optionMaxNum)
              OptionWidget(
                  isLabelOption: widget.isLabel,
                  canSelect: _canSelect,
                  optionInfo: widget.optionListInfo[i],
                  onChanged: (isAdd){
                    _onSelected(widget.optionListInfo[i], isAdd, true);
                  },
                  onSelected: (isSelected){
                    _onSelected(widget.optionListInfo[i], isSelected, isSelected);
                  }
              )

        ],
      ),
    );
  }


}
