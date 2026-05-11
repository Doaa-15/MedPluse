import 'package:hive/hive.dart';
import '../models/medication_model.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationModel>> getCachedMedications();
  Future<void> cacheMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  // 1. حذف الـ Constructor القديم وحذف تعريف medBox الثابت
  MedicationLocalDataSourceImpl();

  // 2. دالة مساعدة لجلب اسم الصندوق الخاص بالمستخدم الحالي من الإعدادات
  Future<Box<MedicationModel>> _getBox() async {
    final settings = Hive.box('users_box');
    // جلب الاسم الذي قمنا بحفظه في AuthCubit عند تسجيل الدخول
    final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
    
    // فتح الصندوق (إذا كان مفتوحاً سيعيده فوراً، وإلا سيفتحه)
    return await Hive.openBox<MedicationModel>(boxName);
  }

  @override
  Future<void> cacheMedication(MedicationModel medication) async {
    final box = await _getBox();
    // حفظ باستخدام الـ ID كمفتاح لضمان عدم التكرار وسهولة التحديث
    await box.put(medication.id, medication);
    print(" تم الحفظ : ${medication.name}");
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
    print(" تم حذف الدواء من صندوق المستخدم الحالي");
  }
}