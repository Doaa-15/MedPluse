import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ستحتاجين حزمة intl لمقارنة الوقت
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
    // نظهر الـ Loading فقط لو الحالة مش Loaded (عشان الـ Refresh ميعملش فليكر)
    if (state is! MedicationsLoaded) emit(MedicationsLoading());

    try {
      // 1. استلام البيانات (هتكون List<MedicationEntity>)
      final result = await getMedicationsUseCase.call(); 
      
      final now = DateTime.now();
      bool needsUpdate = false;

      // 2. فحص الـ Reset اليومي
      for (var med in result) {
        if (med.isTaken) {
          // إذا كنا في بداية يوم جديد (أول 10 دقائق بعد منتصف الليل)
          if (now.hour == 0 && now.minute < 10) { 
              // نحدث الحالة في المستودع مباشرة
              await medicationRepository.updateMedicationStatus(med.id, false);
              needsUpdate = true;
          }
        }
      }

      // 3. إرسال البيانات للـ UI
      if (needsUpdate) {
        // لو حدثنا حاجة، نجيب النسخة الجديدة ونعرضها
        final updatedResult = await getMedicationsUseCase.call();
        emit(MedicationsLoaded(updatedResult));
      } else {
        // نبعت الـ result زي ما هي لأن نوعها يتوافق مع MedicationsLoaded
        emit(MedicationsLoaded(result));
      }

    } catch (e) {
      print("Error in fetchMedications: $e");
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
      await medicationRepository.updateMedicationStatus(med.id, true);
      // fetchMedications() ستعمل تلقائياً بسبب الـ Listener
    } catch (e) {
      emit(MedicationsError("حدث خطأ أثناء تحديث الحالة"));
    }
  }

Future<void> deleteMedication(String id) async {
  try {
    // السطر ده هو اللي هيشغل الميثود اللي لسه ضايفينها
    await NotificationService.cancelNotification(id.hashCode);

    // بعدين بيمسح من الداتا بيز عادي
    await medicationRepository.deleteMedication(id);
  } catch (e) {
    emit(MedicationsError("فشل في حذف الدواء"));
  }
}

}