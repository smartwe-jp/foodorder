
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';

import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';

class NumberListView extends StatefulWidget {

  final List<int> numberValues;
  final Function(int) onValueChange;
  final String measureUnit;

  NumberListView({Key? key,
    required this.numberValues ,
    required this.onValueChange,
    required this.measureUnit})
      : super(key: key);

  @override
  _NumberListViewState createState() => _NumberListViewState();

}

class _NumberListViewState extends State<NumberListView> {


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: widget.numberValues.map((e) =>
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: ColorsUtil.hexToColor("#dca550"),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      widget.onValueChange(e);
                    },
                    child: Text(
                      e.toString() + widget.measureUnit,
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(20),
                        color: ColorsUtil.hexToColor("#dca550"),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        ColorsUtil.hexToColor("#f9edde"),
                      ),
                    ),
                  )
                )
            ).toList(),
          ),

    );
  }
}