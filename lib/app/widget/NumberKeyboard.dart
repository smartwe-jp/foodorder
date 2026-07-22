import 'package:flutter/material.dart';

import '../modules/systemSettingPage/views/CustomKeyboard.dart';

class NumberKeyboardDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final Function(String) onConfirm;

  /// 重量数字字号（称重页可加大）
  final double inputFontSize;

  /// 输入框最小高度
  final double inputMinHeight;

  /// 输入框 / 按键圆角
  final double borderRadius;

  const NumberKeyboardDialog({
    Key? key,
    required this.title,
    required this.onConfirm,
    this.initialValue = "",
    this.inputFontSize = 32,
    this.inputMinHeight = 48,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  _NumberKeyboardDialogState createState() => _NumberKeyboardDialogState();
}

class _NumberKeyboardDialogState extends State<NumberKeyboardDialog> {
  String input = "";

  @override
  void initState() {
    super.initState();
    input = widget.initialValue ?? "";
  }

  void _onKeyTap(String value) {
    setState(() {
      if (input == '0') {
        input = value;
      } else {
        input += value;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius;
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      children: [
        const SizedBox(height: 30),
        Center(
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(
              minWidth: 200,
              maxWidth: 300,
              minHeight: widget.inputMinHeight,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Text(
              input.isEmpty ? '0' : input,
              style: TextStyle(
                fontSize: widget.inputFontSize,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 500,
          width: 550,
          child: Column(
            children: [
              CustomKeyboard(
                borderRadius: radius,
                onKeyPressed: (value) {
                  if (value == '削除') {
                    _onDelete();
                  } else if (value.contains('.')) {
                    // 重量按克整数输入，忽略小数点
                  } else {
                    _onKeyTap(value);
                  }
                },
              ),
              const SizedBox(height: 50),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        minimumSize: const Size(160, 68),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('キャンセル', style: TextStyle(fontSize: 20)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        minimumSize: const Size(160, 68),
                      ),
                      onPressed: () {
                        widget.onConfirm(input);
                        Navigator.of(context).pop();
                      },
                      child: const Text('確認', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
