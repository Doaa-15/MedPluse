import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reminder/core/theme/app_colors.dart';
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
                     dropdownColor: AppColors.lightGray,
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.access_time_rounded, color: Colors.grey),
              // تحويل القائمة لـ DropdownMenuItem مع إضافة كلمة Hours
             items: items.map((int item) {
  return DropdownMenuItem<int>(
    value: item,
    child: Text(
      // مثال: Every 4 hours / كل 4 ساعات
      "${AppLocalizations.of(context)!.every} $item ${AppLocalizations.of(context)!.hours}",
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