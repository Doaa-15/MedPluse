import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_state.dart';
import 'package:reminder/feature/add_medication/domain/usecases/add_medication_usecase.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/notification/service/notification_service.dart';

class AddMedicationCubit extends Cubit<AddMedicationState> {
  final AddMedicationUseCase addMedicationUseCase;

  AddMedicationCubit({required this.addMedicationUseCase}) : super(AddMedicationInitial());


Future<void> addMedication(MedicationModel medication, {required String boxName}) async {
  emit(AddMedicationLoading());
  try {
    Box<MedicationModel> box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box<MedicationModel>(boxName);
    } else {
      box = await Hive.openBox<MedicationModel>(boxName);
    }
    await box.put(medication.id, medication);
    scheduleMedicationNotifications(medication);
  
    emit(AddMedicationSuccess());
  } catch (e) {
    emit(AddMedicationError("Failed to save: ${e.toString()}"));
  }
}
void scheduleMedicationNotifications(MedicationModel medication) {
  final now = DateTime.now();
  for (int i = 0; i < medication.reminderTimes.length; i++) {
  
final String timeString = medication.reminderTimes[i].replaceAll(RegExp(r'[a-zA-Z\s]'), ''); 
final timeParts = timeString.split(':');

// التأكد من الساعات (لو كانت PM بنزود 12 ساعة عشان نظام الـ 24 ساعة)
int hour = int.parse(timeParts[0]);
int minute = int.parse(timeParts[1]);

if (medication.reminderTimes[i].toLowerCase().contains('pm') && hour < 12) {
  hour += 12;
} else if (medication.reminderTimes[i].toLowerCase().contains('am') && hour == 12) {
  hour = 0;
}

DateTime scheduledDate = DateTime(
  now.year,
  now.month,
  now.day,
  hour,
  minute,
);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }


    
    final int notificationId = medication.id.hashCode + i;


NotificationService.scheduleNotification(
  medicationId: medication.id, 
  id: notificationId,
  medicationName: medication.name,
  dosage: "${medication.dosage} ${medication.unit}",
  scheduledTime: scheduledDate,
  frequency: medication.frequency, 
  intervalHours: medication.frequency == 'Interval' ? medication.stock : null, 
);
  }
}
}