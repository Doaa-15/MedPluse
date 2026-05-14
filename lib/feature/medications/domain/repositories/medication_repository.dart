import 'package:reminder/feature/medications/domain/entities/medication.dart';



abstract class MedicationRepository {
  Future<List<MedicationEntity>> getMedications();
  Future<void> updateMedicationStatus(String id, bool isTaken);
  Future<void> updateMedication(MedicationEntity medication);
  Future<void> addMedication(MedicationEntity medication);
  Future<void> deleteMedication(String id); 
}

