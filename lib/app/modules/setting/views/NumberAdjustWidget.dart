import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../services/ScreenAdapter.dart';
import '../../../widget/NumberKeyboard.dart';

class NumberAdjustWidget extends StatefulWidget {
  final int initialNumber;
  final Function(int) onNumberChanged;
  final int? maxNumber;
  final int? minNumber;
  final String? content;

  NumberAdjustWidget({Key? key,
    required this.initialNumber,
    required this.onNumberChanged,
    this.maxNumber,
    this.minNumber,
    this.content,
  }) : super(key: key);

  @override
  _NumberAdjustWidgetState createState() => _NumberAdjustWidgetState();
}

class _NumberAdjustWidgetState extends State<NumberAdjustWidget> {
  late int _currentNumber;
  int? _maxNumber;
  int? _minNumber;

  @override
  void initState() {
    super.initState();
    _currentNumber = widget.initialNumber;
    _maxNumber = widget.maxNumber;
    _minNumber = widget.minNumber;
  }

  @override
  void didUpdateWidget(covariant NumberAdjustWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _currentNumber = widget.initialNumber;
    _maxNumber = widget.maxNumber;
    _minNumber = widget.minNumber;
  }

  void _increment() {
    setState(() {
      if (_maxNumber != null && _currentNumber >= _maxNumber!) {
        return;
      }
      _currentNumber++;
      widget.onNumberChanged(_currentNumber);
    });
  }

  void _decrement() {
    setState(() {
      if (_minNumber != null && _currentNumber <= _minNumber!) {
        return;
      }
      _currentNumber--;
      widget.onNumberChanged(_currentNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenAdapter.width(200),
      child: Table(
          columnWidths: {
            0: FixedColumnWidth(50),
            1: FlexColumnWidth(100),
            2: FixedColumnWidth(50),
          },
        border: TableBorder.all(color: Colors.grey),
        children: [
          TableRow(

            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _decrement,
                  color: Colors.grey,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child:
                  GestureDetector(
                    onTap: (){
                      Get.dialog(
                        NumberKeyboardDialog(
                          initialValue: '$_currentNumber',
                          title: "${(widget.content ?? '')}数値を入力",
                          onConfirm: (value) {
                            if (value.isEmpty) return;
                            int number = int.parse(value);
                            if (_maxNumber != null && number > _maxNumber!) {
                              number = _maxNumber!;
                            }
                            if (_minNumber != null && number < _minNumber!) {
                              number = _minNumber!;
                            }
                            setState(() {
                              _currentNumber = number;
                            });
                            widget.onNumberChanged(_currentNumber);
                          },
                        ),
                        barrierDismissible: false,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Center(
                        child: Text('$_currentNumber', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),

                // Center(
                //   child: TextField(
                //     controller: TextEditingController(text: '$_currentNumber'),
                //     textAlign: TextAlign.center,
                //     keyboardType: TextInputType.number,
                //     onChanged: (value) {
                //       if (value.isEmpty) {
                //         return;
                //       }
                //       int number = int.parse(value);
                //       if (_maxNumber != null && number > _maxNumber!) {
                //         number = _maxNumber!;
                //       }
                //       if (_minNumber != null && number < _minNumber!) {
                //         number = _minNumber!;
                //       }
                //       _currentNumber = number;
                //       widget.onNumberChanged(_currentNumber);
                //     },
                //   ),
                //   //Text('$_currentNumber', style: TextStyle(fontSize: 20)),
                // ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _increment,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
