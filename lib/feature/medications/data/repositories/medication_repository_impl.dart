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
    final String boxName =
        settings.get('current_user_box', defaultValue: 'default_box');

    // إذا كان البوكس مفتوحاً مسبقاً سيعيده فوراً، وإلا سيفتحه
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
  // افتحي البوكس اللي متخزن فيه الأدوية
  final settings = await Hive.openBox('users_box');
  final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
  final box = await Hive.openBox<MedicationModel>(boxName);

  final med = box.get(id);
  if (med != null) {
    med.isTaken = isTaken; // تحديث الحالة
    await box.put(id, med); // حفظ التعديل
  }
}
  @override
  Future<void> deleteMedication(String id) async {
  final box = await _getBox(); // جلب البوكس الديناميكي للمستخدم
  await box.delete(id); // الحذف باستخدام الـ ID كـ Key
  print("Medication with id $id deleted");
}
}
