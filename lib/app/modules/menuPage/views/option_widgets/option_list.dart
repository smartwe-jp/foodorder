import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/views/option_widgets/widgets/OptionTitle.dart';
import 'package:get/get.dart';

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
  final bool deferImages;
  final Function(String, String, String, int, bool, bool) onSelected;

  const OptionListWidget({
    Key? key,
    required this.isLabel,
    required this.optionListInfo,
    this.outOfRangeMessage = '超出范围',
    required this.title,
    this.subTitle = '',
    required this.optionSelectMaxNum,
    required this.onSelected,
    required this.languageKey,
    this.deferImages = false,
  }) : super(key: key);

  @override
  _OptionListWidgetState createState() => _OptionListWidgetState();
}

class _OptionListWidgetState extends State<OptionListWidget> {

  late int _optionSelectMaxNum;
  final int _optionMaxNum = 100;
  //List<String> _selectedOptions = <String>[];
  List<String> _addedOptions = <String>[];
  late List<dynamic> _optionListInfo;


  @override
  void initState() {
    _optionSelectMaxNum = int.parse(widget.optionSelectMaxNum);
    _optionListInfo = widget.optionListInfo;
    for (final option in _optionListInfo) {
      if (option['checked'] ?? false) {
        //_selectedOptions.add(option['optionCode']);
        _addedOptions.add(option['optionCode']);
      }
    }
    super.initState();
  }


  _onSelected(Map optionInfo, bool isAdd, bool isSelected) {
    //List<String> selectedOptions = List<String>.from(_selectedOptions);
    List<String> addedOptions = List<String>.from(_addedOptions);


    if (isAdd) {
      if (_optionSelectMaxNum == 1 && addedOptions.isNotEmpty && isSelected) {
        // 如果是单选模式，且已经有选项被选中，则清除之前的选项
        //找到已选项的Option
        final selectedOption  = _optionListInfo.firstWhere(
              (option) => option['optionCode'] == addedOptions.first,
          orElse: () => {},
        );
        if (selectedOption['optionCode'] != optionInfo['optionCode']) {
          widget.onSelected(selectedOption['group'], selectedOption['optionCode'], selectedOption['mainTitle'], selectedOption['currentPrice'], false, false);
          //selectedOptions.clear();
          addedOptions.clear();
        }
      }
      //selectedOptions.add(optionInfo['optionCode']);
      addedOptions.add(optionInfo['optionCode']);
    } else {
      addedOptions.remove(optionInfo['optionCode']);
      // if (!addedOptions.contains(optionInfo['optionCode'])) {
      //   selectedOptions.remove(optionInfo['optionCode']);
      // }
    }

    if (addedOptions.length > _optionSelectMaxNum && isAdd) {
      final showTag = "menu_option_more_multipleState".tr;
      Get.dialog(
          DialogUtils.alertOneButton("${showTag.replaceAll("%%", widget.title)}",
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr,
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
      //_selectedOptions = selectedOptions;
      _addedOptions = addedOptions;
    });

    widget.onSelected(groupCode, optionCode, optionName, price, isAdd, isSelected);
  }

  bool get _canSelect {
    if (_addedOptions.length == _optionSelectMaxNum && _optionSelectMaxNum > 1) {
      return false;
    } else {
      return true;
    }
  }

  bool isOptionSelected(String optionCode) {
    return _addedOptions.contains(optionCode);
  }


  @override
  void dispose() {
    super.dispose();
    //_selectedOptions.clear();
    _addedOptions.clear();
    //_optionListInfo.clear();
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

          for (int i = 0; i < _optionListInfo.length; i++)
            if (i < _optionMaxNum)
              OptionWidget(
                  isLabelOption: widget.isLabel,
                  canSelect: _canSelect,
                  deferImages: widget.deferImages,
                  optionInfo: _optionListInfo[i],
                  maxNum: _optionSelectMaxNum - _addedOptions.length,
                  isSelected: isOptionSelected(_optionListInfo[i]['optionCode']),
                  languageKey: widget.languageKey,
                  onChanged: (isAdd){
                    _onSelected(_optionListInfo[i], isAdd, true);
                  },
                  onSelected: (isSelected){
                    _onSelected(_optionListInfo[i], isSelected, isSelected);
                  }
              )

        ],
      ),
    );
  }


}
