import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/common/Extension/color_extension.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

import '../../../menuPage/views/widgets/car_item_view.dart';

class LanguageButton extends StatefulWidget {
  final ImageProvider icon;
  final String title;
  final bool selected;
  final Function? onTap;
  final Color startColor;
  final Color textColor;

  LanguageButton({
    Key? key,
    required this.title,
    this.selected = false,
    this.onTap,
    required this.icon,
    this.startColor = Colors.green,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
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
    final bgColor = widget.startColor.lightThemeColor();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _handleTapUp(),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Container(
          height: ScreenAdapter.height(120),
          width: ScreenAdapter.width(220),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
            //border: Border.all(color: Colors.red, width: 2),
            boxShadow: [
              BoxShadow(
                color: bgColor.adaptiveGrayShadowColor(),
                offset: const Offset(4, 4),
                blurRadius: 1,
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: AutoSizeText(
              widget.title,
              style: TextStyle(
                color: widget.selected ? Colors.black : widget.startColor,
                fontSize: 36,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
