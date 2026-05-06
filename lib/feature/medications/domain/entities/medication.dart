import 'package:equatable/equatable.dart';

class MedicationEntity extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String unit;
  final String frequency;
  final int stock;
  final List<String> reminderTimes; // قائمة الأوقات كنصوص
  final bool isTaken;

  const MedicationEntity({
    required this.id,
    required this.name,
    required this.dosage,
    required this.unit,
    required this.frequency,
    required this.stock,
    required this.reminderTimes,
    this.isTaken = false,
  });

  @override
  List<Object?> get props => [id, name, dosage, unit, frequency, stock, reminderTimes, isTaken];
}