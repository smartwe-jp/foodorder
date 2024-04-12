

import 'package:flutter/material.dart';

class TrainglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 255, 255, 255)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    // var path = Path();
    // path.moveTo(size.width / 2, 0); // 顶点
    // path.lineTo(0, size.height); // 左下角
    // path.lineTo(size.width, size.height); // 右下角
    // path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}