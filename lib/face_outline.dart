import 'dart:math';

import 'package:flutter/material.dart';

class FaceOutlinePainter extends CustomPainter {
  BuildContext _context;

  get context => _context;

  set context(value) {
    _context = value;
  }

  FaceOutlinePainter({required dynamic context}) : _context = context;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.yellow
      ..strokeWidth = 4.0;

    final paintSec = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 4.0;

    canvas.drawCircle(
        Offset(MediaQuery.of(context).size.height / 2.5,
            MediaQuery.of(context).size.width / 1.5),
        20,
        paint);

    canvas.drawRRect(
        RRect.fromLTRBR(40, 250, 120, 300, const Radius.circular(10)), paint);

    canvas.drawArc(
        Rect.fromLTRB(
          50,
          300,
          MediaQuery.of(context).size.width - 50,
          MediaQuery.of(context).size.height / 1.5,
        ),
        0,
        pi,
        false,
        paint);

    canvas.drawArc(
        Rect.fromLTRB(
          50,
          365,
          MediaQuery.of(context).size.width - 50,
          MediaQuery.of(context).size.height / 1.7,
        ),
        0,
        pi,
        false,
        paintSec);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}
