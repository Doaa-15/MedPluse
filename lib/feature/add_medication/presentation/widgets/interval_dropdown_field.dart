import 'package:flutter/material.dart';

class IntervalDropdownField extends StatelessWidget {
  final String label;
  final int value;
  final List<int> items;
  final Function(int?) onChanged;

  const IntervalDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        
        // Dropdown Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.access_time_rounded, color: Colors.grey),
              // تحويل القائمة لـ DropdownMenuItem مع إضافة كلمة Hours
              items: items.map((int item) {
                return DropdownMenuItem<int>(
                  value: item,
                  child: Text(
                    "Every $item Hours",
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}