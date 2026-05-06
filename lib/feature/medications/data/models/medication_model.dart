import 'package:hive/hive.dart';

import 'package:reminder/feature/medications/domain/entities/medication.dart';

part 'medication_model.g.dart';

@HiveType(typeId: 0)
class MedicationModel extends MedicationEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final String dosage;

  @HiveField(3)
  @override
  final String unit;

  @HiveField(4)
  @override
  final String frequency;

  @HiveField(5)
  @override
  final int stock;

  @HiveField(6)
  @override
  final List<String> reminderTimes;

  @HiveField(7)
  @override
  final bool isTaken;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.unit,
    required this.frequency,
    required this.stock,
    required this.reminderTimes,
    this.isTaken = false,
  }) : super(
          id: id,
          name: name,
          dosage: dosage,
          unit: unit,
          frequency: frequency,
          stock: stock,
          reminderTimes: reminderTimes,
          isTaken: isTaken,
        );

  MedicationModel copyWith({bool? isTaken}) {
    return MedicationModel(
      id: id,
      name: name,
      dosage: dosage,
      unit: unit,
      frequency: frequency,
      stock: stock,
      reminderTimes: reminderTimes,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}