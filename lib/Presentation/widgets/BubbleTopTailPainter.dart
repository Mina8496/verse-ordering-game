import 'package:flutter/material.dart';

class BubbleTopTailPainter extends CustomPainter {
  final Color color;

  BubbleTopTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // مثلث بسيط يشير للأسفل
    path.moveTo(0, 0); // النقطة اليسرى العلوية
    path.lineTo(size.width / 2, size.height); // الرأس السفلي (منتصف)
    path.lineTo(size.width, 0); // النقطة اليمنى العلوية
    path.close();
    // path.moveTo(0, 0); // البداية من الأعلى
    // path.quadraticBezierTo(
    //   size.width / 2, size.height, // منحنى للأسفل
    //   size.width, 0,
    // );
    // path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
