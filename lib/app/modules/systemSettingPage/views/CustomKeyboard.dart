import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final double borderRadius;

  CustomKeyboard({
    required this.onKeyPressed,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        String keyLabel;
        if (index < 9) {
          keyLabel = (index + 1).toString();
        } else if (index == 9) {
          keyLabel = '.';
        } else if (index == 10) {
          keyLabel = '0';
        } else {
          keyLabel = '削除';
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onKeyPressed(keyLabel),
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              margin: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              alignment: Alignment.center,
              child: Text(
                keyLabel,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
