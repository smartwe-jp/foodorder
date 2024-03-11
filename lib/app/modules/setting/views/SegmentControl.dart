import 'package:flutter/material.dart';

import '../../../config/colorsUtil.dart';

class SegmentControl extends StatefulWidget {
  final List<String> values;
  final String initialValue;
  final ValueChanged<String> onValueChanged;

  SegmentControl({
    Key? key,
    required this.values,
    required this.initialValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  _SegmentControlState createState() => _SegmentControlState();
}

class _SegmentControlState extends State<SegmentControl> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _onValueChanged(int index) {
    setState(() {
      _selectedValue = widget.values[index];
      widget.onValueChanged(_selectedValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<bool> isSelected = widget.values.map((item) => item == _selectedValue).toList();

    return ToggleButtons(
      isSelected: isSelected,
      onPressed: _onValueChanged,
      selectedColor: ColorsUtil.hexToColor("#ffffff"),
      fillColor: ColorsUtil.hexToColor("#dca550"),
      children: widget.values.map((item) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(item),
        );
      }).toList(),
    );
  }
}
