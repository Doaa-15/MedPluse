
import 'package:reminder/feature/medications/domain/entities/medication.dart';
import 'package:reminder/feature/medications/domain/repositories/medication_repository.dart';

class AddMedicationUseCase {
  final MedicationRepository repository;

  AddMedicationUseCase(this.repository);

  Future<void> call(MedicationEntity medication) async {
    return await repository.addMedication(medication);
  }
}