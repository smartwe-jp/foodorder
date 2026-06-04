

// 放在文件末尾(或单独文件)：
import 'package:flutter/material.dart';

class PressScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double borderRadius;
  final Color color;
  final double pressedScale;      // 按下缩放比例
  final Duration duration;
  final Color borderColor;
  final double borderWidth;

  const PressScaleButton({
    Key? key,
    required this.child,
    required this.width,
    required this.height,
    required this.color,
    this.onTap,
    this.borderRadius = 6,
    this.pressedScale = 0.94,
    this.duration = const Duration(milliseconds: 110),
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
  }) : super(key: key);

  @override
  State<PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<PressScaleButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
    if (!v) widget.onTap?.call();
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
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: widget.borderColor, width: widget.borderWidth)
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}