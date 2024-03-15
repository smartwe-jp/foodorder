import 'package:flutter/material.dart';

import '../../../services/ScreenAdapter.dart';

class NumberAdjustWidget extends StatefulWidget {
  final int initialNumber;
  final Function(int) onNumberChanged;
  final int? maxNumber;
  final int? minNumber;

  NumberAdjustWidget({Key? key,
    required this.initialNumber,
    required this.onNumberChanged,
    this.maxNumber,
    this.minNumber}) : super(key: key);

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
                child: Center(
                  child: Text('$_currentNumber', style: TextStyle(fontSize: 20)),
                ),
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
