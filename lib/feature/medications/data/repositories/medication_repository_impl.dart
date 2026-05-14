import 'package:hive/hive.dart';
import 'package:reminder/core/errors/failures.dart';
import 'package:reminder/feature/medications/data/datasources/medication_local_datasource.dart';
import 'package:reminder/feature/medications/domain/entities/medication.dart';
import 'package:reminder/feature/medications/domain/repositories/medication_repository.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDataSource localDataSource;

MedicationRepositoryImpl({required this.localDataSource});

  Future<Box<MedicationModel>> _getBox() async {
    final settings = Hive.box('users_box');
    final String boxName =
        settings.get('current_user_box', defaultValue: 'default_box');
    return await Hive.openBox<MedicationModel>(boxName);
  }

  @override
  Future<List<MedicationEntity>> getMedications() async {
    final box = await _getBox();
    return box.values.toList().cast<MedicationEntity>();
  }

  @override
  Future<void> addMedication(MedicationEntity medication) async {
    final box = await _getBox();

    final model = MedicationModel(
      id: medication.id,
      name: medication.name,
      dosage: medication.dosage,
      unit: medication.unit,
      frequency: medication.frequency,
      stock: medication.stock,
      reminderTimes: medication.reminderTimes,
      isTaken: medication.isTaken,
    );

    await box.put(model.id, model);
  }

  @override

Future<void> updateMedicationStatus(String id, bool isTaken) async {
  final settings = await Hive.openBox('users_box');
  final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
  final box = await Hive.openBox<MedicationModel>(boxName);

  final med = box.get(id);
  if (med != null) {
    med.isTaken = isTaken; 
    await box.put(id, med); 
  }
}
  @override
  Future<void> deleteMedication(String id) async {
  final box = await _getBox(); 
  await box.delete(id); 
  print("Medication with id $id deleted");
}

@override
Future<void> updateMedication(MedicationEntity medication) async {
  try {
    final model = MedicationModel.fromEntity(medication); 
    await localDataSource.updateMedication(model);
  } catch (e) {
    throw ServerFailure(); 
  }
}
}
