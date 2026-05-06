import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/feature/add_medication/domain/usecases/add_medication_usecase.dart';
import 'package:reminder/feature/medications/domain/entities/medication.dart';
import 'medications_state.dart';
import '../../domain/usecases/get_medications_usecase.dart';
import '../../domain/repositories/medication_repository.dart';

class MedicationCubit extends Cubit<MedicationsState> {
  final GetMedicationsUseCase getMedicationsUseCase;
  final MedicationRepository repository; // للاستخدام المباشر في التحديث

  MedicationCubit({
    required this.getMedicationsUseCase,
    required this.repository,
  }) : super(MedicationsInitial());

  Future<void> fetchMedications() async {
    emit(MedicationsLoading());
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
      await fetchMedications(); // إعادة جلب البيانات لتحديث الـ UI
    } catch (e) {
      emit(MedicationsError("فشل في تحديث الحالة"));
    }
  }
  // زودي الـ AddMedicationUseCase في الـ Constructor

}