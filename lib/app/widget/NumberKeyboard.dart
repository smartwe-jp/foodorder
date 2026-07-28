import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/colorsUtil.dart';
import '../config/font.dart';
import '../modules/systemSettingPage/views/CustomKeyboard.dart';
import '../services/ScreenAdapter.dart';

/// 数字软键盘弹窗（样式对齐 SetPosIpPage / SimpleInputAlert）
class NumberKeyboardDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final Function(String) onConfirm;

  /// 兼容旧参数（称重页曾加大字号）；新样式以 SetPosIp 为准，可忽略
  final double inputFontSize;
  final double inputMinHeight;
  final double borderRadius;

  const NumberKeyboardDialog({
    Key? key,
    required this.title,
    required this.onConfirm,
    this.initialValue = "",
    this.inputFontSize = 32,
    this.inputMinHeight = 48,
    this.borderRadius = 10,
  }) : super(key: key);

  @override
  _NumberKeyboardDialogState createState() => _NumberKeyboardDialogState();
}

class _NumberKeyboardDialogState extends State<NumberKeyboardDialog> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue ?? '';
    _controller = TextEditingController.fromValue(
      TextEditingValue(
        text: initial,
        selection: TextSelection.collapsed(offset: initial.length),
      ),
    );
    // 避免系统软键盘弹出，只用自定义数字键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(String key) {
    if (key == '削除') {
      if (_controller.text.isNotEmpty) {
        _controller.text =
            _controller.text.substring(0, _controller.text.length - 1);
        _controller.selection =
            TextSelection.collapsed(offset: _controller.text.length);
        setState(() {});
      }
      return;
    }
    // 重量/皮重按克整数输入，忽略小数点
    if (key.contains('.')) return;

    if (_controller.text == '0') {
      _controller.text = key;
    } else {
      _controller.text = _controller.text + key;
    }
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Colors.white,
      // 去掉默认上下灰边留白，让白底内容撑满弹窗
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(40),
        vertical: ScreenAdapter.height(40),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      children: [
        Container( 
          alignment: Alignment.center,
          color: Colors.white,
          width: ScreenAdapter.width(550),
          padding: EdgeInsets.only(
            left: ScreenAdapter.width(20),
            right: ScreenAdapter.width(20),
            top: ScreenAdapter.height(30),
            bottom: ScreenAdapter.height(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(30),
                  fontFamily: GFont.getFontFamily(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ScreenAdapter.height(40)),
              Container(
                height: 50,
                padding: const EdgeInsets.all(5),
                child: TextField(
                  focusNode: _focusNode,
                  controller: _controller,
                  readOnly: true,
                  showCursor: true,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(30.0),
                    fontFamily: GFont.getFontFamily(),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(height: ScreenAdapter.height(20)),
              CustomKeyboard(onKeyPressed: _handleKeyPress),
              SizedBox(height: ScreenAdapter.height(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // キャンセル（SetPosIp 无此按钮；皮重/重量弹窗需可关闭）
                  Container(
                    alignment: Alignment.center,
                    width: ScreenAdapter.width(180),
                    height: ScreenAdapter.height(85),
                    margin: EdgeInsets.only(top: ScreenAdapter.height(35)),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: TextButton(
                      child: Text(
                        'キャンセル',
                        style: TextStyle(
                          color: ColorsUtil.hexToColor('#333333'),
                          fontFamily: GFont.getFontFamily(),
                          fontSize: ScreenAdapter.fontSize(28.0),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: ScreenAdapter.width(180),
                    height: ScreenAdapter.height(85),
                    margin: EdgeInsets.only(top: ScreenAdapter.height(35)),
                    decoration: BoxDecoration(
                      color: ColorsUtil.hexToColor('#409eff'),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: TextButton(
                      child: Text(
                        'はい',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: GFont.getFontFamily(),
                          fontSize: ScreenAdapter.fontSize(32.0),
                        ),
                      ),
                      onPressed: () {
                        widget.onConfirm(_controller.text);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenAdapter.height(10)),
            ],
          ),
        ),
      ],
    );
  }
}
