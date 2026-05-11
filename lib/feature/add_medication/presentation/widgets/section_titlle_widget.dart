import 'package:flutter/material.dart';
import 'package:reminder/core/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final double verticalPadding;

  // تأكدي من وجود الأقواس { } هنا
  const SectionTitle({
    super.key, 
    required this.title, 
    this.verticalPadding = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: AppColors.primary,
        ),
      ),
    );
  }
}