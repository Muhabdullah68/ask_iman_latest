import 'package:flutter/material.dart';

class TooltipArrowPainter extends CustomPainter {
  final Color color;
  final AxisDirection direction;

  TooltipArrowPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();

    switch (direction) {
      case AxisDirection.up:
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
      case AxisDirection.down:
        path.moveTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        path.lineTo(0, 0);
        break;
      case AxisDirection.left:
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case AxisDirection.right:
        path.moveTo(size.width, size.height / 2);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
