import 'package:flutter/material.dart';
import 'package:reminder/core/theme/app_colors.dart';

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = AppColors.white..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0); // حافة دائرية يسار
    path.lineTo(size.width * 0.65, 0); // خط مستقيم لقبل النهاية
    
    // رسمة "الخفسة" أو الانحناء لأسفل
    path.quadraticBezierTo(size.width * 0.75, 0, size.width * 0.78, 20);
    path.arcToPoint(Offset(size.width * 0.92, 20), radius: const Radius.circular(20), clockwise: false);
    path.quadraticBezierTo(size.width * 0.95, 0, size.width, 0);
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawShadow(path, AppColors.black.withOpacity(0.3), 10, true);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}