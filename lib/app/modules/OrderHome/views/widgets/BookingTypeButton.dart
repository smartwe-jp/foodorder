
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/common/Extension/color_extension.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

import '../../../menuPage/views/widgets/car_item_view.dart';

class BookingTypeButton extends StatefulWidget {
  final Icon icon;
  final String title;
  final bool selected;
  final Function? onTap;
  final double width;
  final Color bgColor;
  final Color textColor;

  BookingTypeButton(
      {Key? key,
        required this.icon,
        required this.title,
        this.width = 400,
        this.bgColor = const Color(0xFF1B5E20),
        this.textColor = Colors.white,
        this.onTap, required this.selected,}) : super(key: key);

  @override
  State<BookingTypeButton> createState() => _BookingTypeButtonState();
}

class _BookingTypeButtonState extends State<BookingTypeButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  void _handleTapUp() {
    _setPressed(false);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _handleTapUp(),
        // child: AspectRatio(
        //   aspectRatio: 2.5,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: ScreenAdapter.height(320),
            width: ScreenAdapter.width(widget.width),
            decoration: BoxDecoration(
              color: widget.selected ? widget.bgColor : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: widget.bgColor,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.bgColor.adaptiveGrayShadowColor(),
                  offset: const Offset(4, 4),
                  blurRadius: 1,
                ),
              ],
            ),

            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //   alignment: Alignment.center,
                //   height: ScreenAdapter.height(140),
                //   child: icon,
                // ),

                Expanded(
                    child: Container(
                  // padding: EdgeInsets.only(bottom: 40),
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    widget.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.selected ? widget.textColor : widget.bgColor, //const Color.fromARGB(255, 53,59,80),
                      fontSize: 80,
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ))
              ],
            ),
          ),
        )
      //),
    );
  }
}