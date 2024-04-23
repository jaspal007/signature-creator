import 'package:flutter/material.dart';

class Loader extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 8.0;
  }

  @override
  bool shouldRepaint(Loader oldDelegate) => false;
}
