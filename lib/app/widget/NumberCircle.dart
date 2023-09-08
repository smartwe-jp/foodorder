import 'package:flutter/material.dart';

import '../config/colorsUtil.dart';

class NumberCircle extends StatelessWidget {
  final int number;
  final Color circleColor;
  final double circleSize;
  final TextStyle numberStyle;

  NumberCircle({
    required this.number,
    this.circleColor = Colors.red,
    this.circleSize = 30.0,
    this.numberStyle = const TextStyle(color: Colors.white, fontSize: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            //color: circleColor,
            shape: BoxShape.circle,
            border: Border(
              top: BorderSide(color: circleColor, width: 1.5),
              left: BorderSide(color: circleColor, width: 1.5),
              bottom: BorderSide(color: circleColor, width: 1.5),
              right: BorderSide(color: circleColor, width: 1.5),
            ),
          ),
        ),
        Text(
          '$number',
          style: numberStyle,
        ),
      ],
    );
  }
}