import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ستحتاجين حزمة intl لعرض التاريخ

class ScheduleHeader extends StatelessWidget {
  final String title;

  const ScheduleHeader({
    super.key,
    this.title = "Today's Schedule", // قيمة افتراضية
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2D2D2D),
          ),
        ),
        Text(
          DateFormat('MMM dd, yyyy').format(DateTime.now()),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}