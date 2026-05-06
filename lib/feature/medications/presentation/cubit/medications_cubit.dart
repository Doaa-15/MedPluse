import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'medications_state.dart';
import '../../domain/usecases/get_medications_usecase.dart';
import '../../domain/repositories/medication_repository.dart';

class MedicationCubit extends Cubit<MedicationsState> {
  final GetMedicationsUseCase getMedicationsUseCase;
  final MedicationRepository repository;

  MedicationCubit({
    required this.getMedicationsUseCase,
    required this.repository,
  }) : super(MedicationsInitial()) {
    // تشغيل المستمع لمراقبة أي تغييرات في قاعدة البيانات (مثل تغيير الحالة من الإشعار)
    _setupDatabaseListener();
  }

void _setupDatabaseListener() async {
  // 1. نجيب اسم البوكس الحقيقي الخاص باليوزر الحالي (نفس منطق الـ Repository)
  final settings = Hive.box('users_box');
  final String boxName = settings.get('current_user_box', defaultValue: 'default_box');

  // 2. نفتح البوكس ده تحديداً ونراقبه
  final box = await Hive.openBox<MedicationModel>(boxName);
  
  // 3. لما أي حاجة تتغير في البوكس ده (زي ضغطة Take من الإشعار)
  box.watch().listen((event) {
    print("Database changed for box: $boxName! Refreshing UI...");
    fetchMedications(); // هيجيب الداتا الجديدة ويعمل emit لـ MedicationsLoaded
  });
}
  Future<void> fetchMedications() async {
    // نظهر Loading فقط في المرة الأولى، أما التحديثات التلقائية فتتم بهدوء
    if (state is! MedicationsLoaded) emit(MedicationsLoading());
    try {
      final meds = await getMedicationsUseCase();
      emit(MedicationsLoaded(meds));
    } catch (e) {
      emit(MedicationsError("فشل في جلب البيانات"));
    }
  }

  Future<void> toggleStatus(String id, bool currentStatus) async {
    try {
      await repository.updateMedicationStatus(id, !currentStatus);
      // لا داعي لمناداة fetchMedications هنا يدوياً لأن المستمع سيفعل ذلك
    } catch (e) {
      emit(MedicationsError("فشل في تحديث الحالة"));
    }
  }

  Future<void> markAsTaken(MedicationModel medication) async {
    try {
      await repository.updateMedicationStatus(medication.id, true);
      medication.isTaken = true;

      // التحديث سيظهر في الـ UI تلقائياً بفضل الـ Listener
    } catch (e) {
      emit(MedicationsError("فشل في تسجيل أخذ الدواء"));
    }
  }
  // داخل MedicationCubit
Future<void> deleteMedication(String id) async {
  try {
    await repository.deleteMedication(id);
    // بفضل الـ Listener الذي أضفناه سابقاً، سيتم تحديث الواجهة تلقائياً
  } catch (e) {
    emit(MedicationsError("فشل في حذف الدواء"));
  }
}
}