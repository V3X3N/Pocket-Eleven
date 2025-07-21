import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final double width;
  final double height;

  // Cache expensive calculations and objects
  late final double _centerX;
  late final double _centerY;
  late final double _lineY;
  late final double _rectCenterX;
  late final double _rectCenterYBottom;
  late final Offset _whiteCircleCenter;
  late final Offset _colorCircleCenter;
  late final Offset _lineStart;
  late final Offset _lineEnd;
  late final Rect _rectTop;
  late final Rect _rectBottom;

  // Static constants to avoid repeated allocations
  static const double _whiteCircleRadius = 12.0;
  static const double _colorCircleRadius = 10.0;
  static const double _rectWidth = 30.0;
  static const double _rectHeight = 10.0;
  static const double _strokeWidth = 2.0;
  static const double _rectBottomMargin = 3.0;

  // Cache Paint objects to prevent recreation
  static final Paint _linePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = _strokeWidth
    ..style = PaintingStyle.stroke;

  static final Paint _whiteCirclePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  static final Paint _colorCirclePaint = Paint()
    ..color = Colors.lightGreen.shade400
    ..style = PaintingStyle.fill;

  static final Paint _rectPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  LinePainter({required this.width, required this.height}) {
    _precalculateValues();
  }

  void _precalculateValues() {
    _centerX = width * 0.5;
    _centerY = height * 0.5;
    _lineY = _centerY;
    _rectCenterX = _centerX - _rectWidth * 0.5;
    _rectCenterYBottom = height - _rectHeight - _rectBottomMargin;

    // Pre-calculate Offset objects
    _whiteCircleCenter = Offset(_centerX, _centerY);
    _colorCircleCenter = Offset(_centerX, _centerY);
    _lineStart = Offset(0, _lineY);
    _lineEnd = Offset(width, _lineY);

    // Pre-calculate Rect objects
    _rectTop = Rect.fromLTWH(_rectCenterX, 0, _rectWidth, _rectHeight);
    _rectBottom = Rect.fromLTWH(
        _rectCenterX, _rectCenterYBottom, _rectWidth, _rectHeight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw line first (background element)
    canvas.drawLine(_lineStart, _lineEnd, _linePaint);

    // Draw rectangles
    canvas.drawRect(_rectTop, _rectPaint);
    canvas.drawRect(_rectBottom, _rectPaint);

    // Draw circles (foreground elements)
    canvas.drawCircle(
        _whiteCircleCenter, _whiteCircleRadius, _whiteCirclePaint);
    canvas.drawCircle(
        _colorCircleCenter, _colorCircleRadius, _colorCirclePaint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return width != oldDelegate.width || height != oldDelegate.height;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LinePainter &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}

// Optimized wrapper widget with RepaintBoundary
class OptimizedLinePainter extends StatelessWidget {
  final double width;
  final double height;

  const OptimizedLinePainter({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: LinePainter(width: width, height: height),
      ),
    );
  }
}
