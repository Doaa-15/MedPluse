import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScheduleHeader extends StatelessWidget {
  final String? title; // خليناه Nullable عشان لو متبعتش نستخدم الترجمة

  const ScheduleHeader({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    // لجلب لغة الأبلكيشن الحالية (ar أو en) عشان التاريخ يتبعها
    final String currentLocale = Localizations.localeOf(context).languageCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title ?? AppLocalizations.of(context)!.todaySchedule, // لو مفيش title، استخدم "جدول اليوم"
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20, // كبرت الفونت شوية عشان يبقى أوضح كـ Header
            color: Color(0xFF2D2D2D),
          ),
        ),
        Text(
          // تمرير الـ locale هنا بيخلي التاريخ يتكتب بلغة اليوزر
          DateFormat('MMM dd, yyyy', currentLocale).format(DateTime.now()),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}