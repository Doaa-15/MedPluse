import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/notification/service/notification_service.dart';
import 'medications_state.dart';
import '../../domain/usecases/get_medications_usecase.dart';
import '../../domain/repositories/medication_repository.dart';

class MedicationCubit extends Cubit<MedicationsState> {
  final GetMedicationsUseCase getMedicationsUseCase;
  final MedicationRepository medicationRepository;

  MedicationCubit({
    required this.getMedicationsUseCase,
    required this.medicationRepository,
  }) : super(MedicationsInitial()) {
    _setupDatabaseListener();
  }

  void _setupDatabaseListener() async {
    final settings = Hive.box('users_box');
    final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
    final box = await Hive.openBox<MedicationModel>(boxName);
    box.watch().listen((event) {
      print("Database changed for box: $boxName! Refreshing UI...");
      fetchMedications(); 
    });
  }

Future<void> fetchMedications() async {
  if (state is! MedicationsLoaded) emit(MedicationsLoading());

  try {
    final result = await getMedicationsUseCase.call(); 
    final now = DateTime.now();
    bool needsUpdate = false;

    for (var med in result) {
      if (med.isTaken && med is MedicationModel && med.lastTakenDate != null) {
        
        if (med.frequency == 'Interval') {
        
          final difference = now.difference(med.lastTakenDate!).inHours;
          
          int interval = int.tryParse(med.frequency.replaceAll(RegExp(r'[^0-9]'), '')) ?? 6;
          if (difference >= interval) {
             await medicationRepository.updateMedicationStatus(med.id, false);
             needsUpdate = true;
          }
        } 
     
        else if (med.lastTakenDate!.day != now.day) {
           await medicationRepository.updateMedicationStatus(med.id, false);
           needsUpdate = true;
        }
      }
    }

    if (needsUpdate) {
      final updatedResult = await getMedicationsUseCase.call();
      emit(MedicationsLoaded(updatedResult));
    } else {
      emit(MedicationsLoaded(result));
    }
  } catch (e) {
    emit(MedicationsError("فشل في جلب البيانات"));
  }
}
  Future<void> toggleStatus(String id, bool currentStatus) async {
    try {
      await medicationRepository.updateMedicationStatus(id, !currentStatus);
    } catch (e) {
      emit(MedicationsError("فشل في تحديث الحالة"));
    }
  }

 Future<void> markAsTaken(MedicationModel med) async {
  try {
    final updatedMed = med.copyWith(isTaken: true, lastTakenDate: DateTime.now());
    await medicationRepository.updateMedication(updatedMed); 
  } catch (e) {
    emit(MedicationsError("حدث خطأ أثناء تحديث الحالة"));
  }
}

Future<void> deleteMedication(String id) async {
  try {
    await NotificationService.cancelNotification(id.hashCode);

    await medicationRepository.deleteMedication(id);
  } catch (e) {
    emit(MedicationsError("فشل في حذف الدواء"));
  }
}

}