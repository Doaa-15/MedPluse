import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScheduleHeader extends StatelessWidget {
  final String? title; 

  const ScheduleHeader({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
  
    final String currentLocale = Localizations.localeOf(context).languageCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title ?? AppLocalizations.of(context)!.todaySchedule, 
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20, 
            color: Color(0xFF2D2D2D),
          ),
        ),
        Text(
      
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