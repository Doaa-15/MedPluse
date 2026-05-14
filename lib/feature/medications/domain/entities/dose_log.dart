import 'package:equatable/equatable.dart';

class DoseLog extends Equatable {
  final String id;
  final String medicationId;
  final DateTime scheduledTime;
  final bool isTaken;
  final DateTime? takenTime; 

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