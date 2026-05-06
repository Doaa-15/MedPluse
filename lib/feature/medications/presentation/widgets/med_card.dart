import 'package:flutter/material.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/feature/medications/presentation/cubit/medications_cubit.dart';
import 'package:reminder/notification/service/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedCard extends StatelessWidget {
  final MedicationModel med;

  const MedCard({super.key, required this.med});

  // ميثود لإظهار نافذة تأكيد الحذف لضمان أفضل تجربة مستخدم (UX)
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Medication?"),
        content: const Text(
          "Are you sure you want to remove this medication from your schedule?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // استدعاء ميثود الحذف من الـ Cubit باستخدام الـ ID
              context.read<MedicationCubit>().deleteMedication(med.id);
              Navigator.pop(dialogContext);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(med.id),
      direction: DismissDirection.endToStart,
      // خلفية الحذف عند السحب
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
          SnackBar(content: Text("${med.name} deleted")),
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
                // أيقونة الدواء
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
                // بيانات الدواء
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
                // توقيت آخر إشعار
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
                // زر حذف إضافي (اختياري بجانب الأزرار)
               
                const Spacer(),
                // زر التأجيل
                TextButton(
                  onPressed: () {
                    NotificationService.snoozeNotification(med);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Remind you in 5 minutes")),
                    );
                  },
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text("Snooze",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 8),
                // زر تأكيد أخذ الدواء
                ElevatedButton(
                  onPressed: med.isTaken
                      ? null
                      : () {
                          context.read<MedicationCubit>().markAsTaken(med);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: med.isTaken
                        ? Colors.green.withOpacity(0.7)
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (med.isTaken) ...[
                        const Icon(Icons.check_circle_outline, size: 18),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        med.isTaken ? "Done" : "Take",
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