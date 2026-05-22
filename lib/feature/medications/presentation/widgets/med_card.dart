import 'package:flutter/material.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/feature/medications/presentation/cubit/medications_cubit.dart';
import 'package:reminder/notification/service/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MedCard extends StatelessWidget {
  final MedicationModel med;

  const MedCard({super.key, required this.med});
  bool _shouldShowAsTaken() {
  if (!med.isTaken || med.lastTakenDate == null) return false;

  final now = DateTime.now();
  final lastTaken = med.lastTakenDate!;


  if (med.frequency.contains('Interval')) {
    int intervalHours = int.tryParse(med.frequency.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    
    if (intervalHours > 0) {

      final baseTime = med.reminderTimes.isNotEmpty 
          ? _parseTimeString(med.reminderTimes.last.toString()) 
          : now;

      final int hoursSinceBase = now.difference(baseTime).inHours;
      final int currentSlotIndex = hoursSinceBase ~/ intervalHours;
      final currentSlotDateTime = baseTime.add(Duration(hours: currentSlotIndex * intervalHours));
      return lastTaken.isAfter(currentSlotDateTime) || lastTaken.isAtSameMomentAs(currentSlotDateTime);
    }
  }

  return lastTaken.day == now.day && lastTaken.month == now.month && lastTaken.year == now.year;
}

DateTime _parseTimeString(String timeStr) {
  try {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      final hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].substring(0, 2).trim());
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
  } catch (_) {}
  return DateTime.now();
}
  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(l10n.deleteTitle),
        content: Text(l10n.deleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<MedicationCubit>().deleteMedication(med.id);
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final bool isTakenNow = _shouldShowAsTaken();

    return Dismissible(
      key: Key(med.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        context.read<MedicationCubit>().deleteMedication(med.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deletedMessage(med.name))),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medication_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${med.dosage} ${med.unit} • ${med.frequency}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Text(
                  med.reminderTimes.isNotEmpty
                      ? med.reminderTimes.last.toString()
                      : "",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: isTakenNow 
                      ? null
                      : () {
                          NotificationService.snoozeNotification(med);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.remindIn5)),
                          );
                        },
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: Text(l10n.snooze,
                      style: TextStyle(
                          color: isTakenNow ? Colors.grey.shade300 : Colors.grey, 
                          fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isTakenNow
                      ? null
                      : () {
                          context.read<MedicationCubit>().markAsTaken(med);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTakenNow
                        ? Colors.green.withOpacity(0.7)
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledBackgroundColor: isTakenNow 
                        ? Colors.green.withOpacity(0.5) 
                        : Colors.grey.shade300,
                    disabledForegroundColor: isTakenNow 
                        ? Colors.white 
                        : Colors.grey.shade600,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTakenNow) ...[
                        const Icon(Icons.check_circle_outline, size: 18),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        isTakenNow ? l10n.done : l10n.take,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}