import 'package:flutter/material.dart';
// تأكدي من مسار الألوان

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = true,
  }) {
    // إزالة أي سناك بار موجود حالياً عشان ميتراكموش فوق بعض
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Cairo', // لو بتستخدمي خط كايرو للعربي
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating, // يجعله عائماً
        elevation: 0, // بنشيل الـ elevation الافتراضي عشان نتحكم في الشكل
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        // إضافة أنيميشن بسيط
        animation: CurvedAnimation(
          parent: AnimationController(
            vsync: ScaffoldMessenger.of(context),
            duration: const Duration(milliseconds: 400),
          ),
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }
}