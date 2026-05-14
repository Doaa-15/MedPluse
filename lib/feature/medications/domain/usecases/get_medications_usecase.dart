 // تأكدي من اسم الملف
import 'package:reminder/feature/medications/domain/entities/medication.dart';

import '../repositories/medication_repository.dart';

class GetMedicationsUseCase {
  final MedicationRepository repository;

  GetMedicationsUseCase(this.repository);


  Future<List<MedicationEntity>> call() async {
    return await repository.getMedications();
  }
}