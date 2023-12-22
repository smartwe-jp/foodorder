import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isActived;
  final Function(bool) onToggle;

  CustomToggleButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isActived,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        if (isActived)
          {
            onToggle(!isSelected),
          }
      },
      child: Container(
        width: 150,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
          //borderRadius: BorderRadius.circular(0),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isActived ? Colors.black : Colors.grey, fontSize: 16)),
      ),
    );
  }
}
