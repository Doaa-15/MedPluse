import 'package:hive/hive.dart';
import 'package:reminder/feature/medications/domain/entities/medication.dart';
import 'package:reminder/feature/medications/domain/repositories/medication_repository.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  // 1. حذف الـ Constructor القديم الذي كان يطلب medBox كـ Required
  MedicationRepositoryImpl();

  // دالة مساعدة خاصة لجلب البوكس الخاص بالمستخدم الحالي
  Future<Box<MedicationModel>> _getBox() async {
    final settings = Hive.box('users_box');
    final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
    
    // إذا كان البوكس مفتوحاً مسبقاً سيعيده فوراً، وإلا سيفتحه
    return await Hive.openBox<MedicationModel>(boxName);
  }

  @override
  Future<List<MedicationEntity>> getMedications() async {
    final box = await _getBox();
    return box.values.toList(); 
  }

  @override
  Future<void> addMedication(MedicationEntity medication) async {
    final box = await _getBox();

    // تحويل الـ Entity إلى Model ليتمكن Hive من حفظه
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

    // الحفظ داخل البوكس الديناميكي باستخدام الـ ID كـ Key
    await box.put(model.id, model);
  }

  @override
  Future<void> updateMedicationStatus(String id, bool isTaken) async {
    final box = await _getBox();
    final model = box.get(id);
    
    if (model != null) {
      // تحديث الحالة فقط مع الحفاظ على باقي البيانات
      final updatedModel = MedicationModel(
        id: model.id,
        name: model.name,
        dosage: model.dosage,
        unit: model.unit,
        frequency: model.frequency,
        stock: model.stock,
        reminderTimes: model.reminderTimes,
        isTaken: isTaken,
      );
      await box.put(id, updatedModel);
    }
  }
}