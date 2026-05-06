abstract class AddMedicationState {}

class AddMedicationInitial extends AddMedicationState {}

class AddMedicationLoading extends AddMedicationState {}

class AddMedicationSuccess extends AddMedicationState {}

class AddMedicationError extends AddMedicationState {
  final String message;
  AddMedicationError(this.message);
}