import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class LinePainter extends CustomPainter {
  final double width;
  final double height;

  LinePainter({required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    double whiteCircleRadius = 12.0;
    double whiteCircleCenterX = width / 2;
    double whiteCircleCenterY = height / 2;

    Paint whiteCirclePaint = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(whiteCircleCenterX, whiteCircleCenterY),
        whiteCircleRadius, whiteCirclePaint);

    double colorCircleRadius = 10.0;
    double colorCircleCenterX = width / 2;
    double colorCircleCenterY = height / 2;

    Paint colorCirclePaint = Paint()..color = AppColors.buttonColor;

    canvas.drawCircle(Offset(colorCircleCenterX, colorCircleCenterY),
        colorCircleRadius, colorCirclePaint);

    double lineYPosition = height / 2;

    canvas.drawLine(
        Offset(0, lineYPosition), Offset(width, lineYPosition), paint);

    double rectWidth = 30.0;
    double rectHeight = 10.0;
    double rectCenterX = width / 2 - rectWidth / 2;
    double rectCenterY = 0.0;

    Paint rectPaint = Paint()..color = Colors.white;

    Rect rect = Rect.fromLTWH(rectCenterX, rectCenterY, rectWidth, rectHeight);
    canvas.drawRect(rect, rectPaint);

    double rectCenterYBottom = height - rectHeight - 3;

    Rect rectBottom =
        Rect.fromLTWH(rectCenterX, rectCenterYBottom, rectWidth, rectHeight);
    canvas.drawRect(rectBottom, rectPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
