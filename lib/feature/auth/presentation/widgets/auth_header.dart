import 'package:flutter/material.dart';
import 'package:reminder/core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      color: AppColors.primary, // اللون الأخضر بتاعنا
      child: Stack(
        children: [
          // هنا ممكن تحطي صورة الكبسولات اللي في التصميم
          Center(child: Icon(Icons.medication_liquid, size: 100, color: Colors.white.withOpacity(0.3))),
        ],
      ),
    );
  }
}