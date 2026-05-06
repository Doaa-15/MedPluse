import 'package:equatable/equatable.dart';

class DoseLog extends Equatable {
  final String id;
  final String medicationId;
  final DateTime scheduledTime; // الموعد المفترض للجرعة
  final bool isTaken;
  final DateTime? takenTime; // الموعد الفعلي اللي المستخدم ضغط فيه "تم"

  const DoseLog({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.isTaken = false,
    this.takenTime,
  });

  @override
  List<Object?> get props => [id, medicationId, scheduledTime, isTaken, takenTime];
}