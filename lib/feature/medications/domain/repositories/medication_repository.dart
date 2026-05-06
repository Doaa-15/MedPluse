import 'package:reminder/feature/medications/domain/entities/medication.dart';



abstract class MedicationRepository {
  Future<List<MedicationEntity>> getMedications();
  Future<void> updateMedicationStatus(String id, bool isTaken);
  Future<void> addMedication(MedicationEntity medication);
 
 // Future<void> updateMedicationStatus(String id, bool isTaken);
  // ضيفي السطر ده هنا
  Future<void> deleteMedication(String id); 
}

