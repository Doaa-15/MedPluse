import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2C3930);
  static const Color secondary = Color(0xFF3F4F44);
  static const Color third = Color(0xFFA27B5C);
   static const Color background = Color(0xFFDCD7C9);
  static const Color lightGray = Color(0xFFD3DAD9);
  static const Color white = Color(0xFFD3DAD9);
    static const Color black = Color.fromARGB(255, 4, 4, 4);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2C3930), Color(0xFF1A1A1D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}