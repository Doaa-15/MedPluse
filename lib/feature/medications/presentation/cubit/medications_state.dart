import 'package:reminder/feature/medications/domain/entities/medication.dart';



abstract class MedicationsState {}

class MedicationsInitial extends MedicationsState {}

class MedicationsLoading extends MedicationsState {}

class MedicationsLoaded extends MedicationsState {
  final List<MedicationEntity> medications;
  MedicationsLoaded(this.medications);
}

class MedicationsError extends MedicationsState {
  final String message;
  MedicationsError(this.message);
}
