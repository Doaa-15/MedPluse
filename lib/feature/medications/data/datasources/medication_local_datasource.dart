import 'package:hive/hive.dart';
import '../models/medication_model.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationModel>> getCachedMedications();
  Future<void> updateMedication(MedicationModel medication);
  Future<void> cacheMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  MedicationLocalDataSourceImpl();

  Future<Box<MedicationModel>> _getBox() async {
    final settings = Hive.box('users_box');
    final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
    return await Hive.openBox<MedicationModel>(boxName);
  }

  @override
  Future<void> cacheMedication(MedicationModel medication) async {
    final box = await _getBox();
    await box.put(medication.id, medication);
    print(" save: ${medication.name}");
  }

  @override
  Future<List<MedicationModel>> getCachedMedications() async {
    final box = await _getBox();
    final results = box.values.toList();
    return results;
  }

  @override
  Future<void> deleteMedication(String id) async {
    final box = await _getBox();
    await box.delete(id);
    print(" deleted");
  }

@override
Future<void> updateMedication(MedicationModel medication) async {
  final settings = Hive.box('users_box');
  final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
  final box = await Hive.openBox<MedicationModel>(boxName);
  await box.put(medication.id, medication);
}
}