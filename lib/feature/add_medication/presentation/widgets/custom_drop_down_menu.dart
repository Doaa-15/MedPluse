import 'package:flutter/material.dart';
import 'package:reminder/core/theme/app_colors.dart';

class CustomDropdownField extends StatelessWidget {
  final String? label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final String Function(String)? itemBuilder; // إضافة المتغير هنا

  const CustomDropdownField({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemBuilder, // إضافته في الـ constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: AppColors.lightGray,
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey),
              items: items
                  .map((item) => DropdownMenuItem(
                    
                        value: item,
                        child: Text(
                          // هنا التعديل: لو الـ itemBuilder موجود استخدمه، لو لأ اعرض النص العادي
                          itemBuilder != null ? itemBuilder!(item) : item,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}