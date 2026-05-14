import 'package:hive/hive.dart';
import 'package:reminder/feature/medications/domain/entities/medication.dart';
    part 'medication_model.g.dart';
@HiveType(typeId: 0)
class MedicationModel extends MedicationEntity { 
  @HiveField(0)
  @override final String id;
  @HiveField(1)
  @override final String name;
  @HiveField(2)
  @override final String dosage;
  @HiveField(3)
  @override final String unit;
  @HiveField(4)
  @override final String frequency;
  @HiveField(5)
  @override final int stock;
  @HiveField(6)
  @override final List<String> reminderTimes;
  @HiveField(7)
  @override bool isTaken;
  @HiveField(8) 
  @override final DateTime? lastTakenDate; 

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.unit,
    required this.frequency,
    required this.stock,
    required this.reminderTimes,
    this.isTaken = false,
    this.lastTakenDate,
  }) : super(
          id: id,
          name: name,
          dosage: dosage,
          unit: unit,
          frequency: frequency,
          stock: stock,
          reminderTimes: reminderTimes,
          isTaken: isTaken,
          lastTakenDate: lastTakenDate, 
        );

  @override
  MedicationModel copyWith({bool? isTaken, DateTime? lastTakenDate}) {
    return MedicationModel(
      id: id,
      name: name,
      dosage: dosage,
      unit: unit,
      frequency: frequency,
      stock: stock,
      reminderTimes: reminderTimes,
      isTaken: isTaken ?? this.isTaken,
      lastTakenDate: lastTakenDate ?? this.lastTakenDate,
    );
  }
  factory MedicationModel.fromEntity(MedicationEntity entity) {
    return MedicationModel(
      id: entity.id,
      name: entity.name,
      dosage: entity.dosage,
      unit: entity.unit,
      frequency: entity.frequency,
      stock: entity.stock,
      reminderTimes: entity.reminderTimes,
      isTaken: entity.isTaken,
      lastTakenDate: entity.lastTakenDate,
    );
  }
}