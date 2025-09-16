import 'package:flutter/material.dart';

import '../modules/systemSettingPage/views/CustomKeyboard.dart';

class NumberKeyboardDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final Function(String) onConfirm;

  const NumberKeyboardDialog({Key? key, required this.title, required this.onConfirm,
    this.initialValue = ""
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
    return SimpleDialog(
      children: [
        SizedBox(height: 30),
        Center(child: Text(widget.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        SizedBox(height: 10),
        Center(child: Container(
          alignment: Alignment.center,
            constraints: BoxConstraints(
              minWidth: 200,
              maxWidth: 300,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(input, style: TextStyle(fontSize: 32)
            ))),
        SizedBox(height: 10),
        SizedBox(
          height: 500, // 限制高度，避免布局溢出
          width: 550,
          child: Column(
            children: [
              CustomKeyboard(
                onKeyPressed: (value) {
                  if (value == '削除') {
                    _onDelete();
                  } else if (value.contains('.')) {

                  } else {
                    _onKeyTap(value);
                  }
                },
              ),
              SizedBox(height: 50),
              // 确认按钮
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
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
                          borderRadius: BorderRadius.zero,
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