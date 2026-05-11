import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/core/widgets/custom_snack_bar.dart';
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_cubit.dart';
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_state.dart';
import 'package:reminder/feature/add_medication/presentation/widgets/custom_drop_down_menu.dart';
import 'package:reminder/feature/add_medication/presentation/widgets/custom_field.dart';
import 'package:reminder/feature/add_medication/presentation/widgets/interval_dropdown_field.dart';
import 'package:reminder/feature/add_medication/presentation/widgets/section_titlle_widget.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/feature/medications/presentation/cubit/medications_cubit.dart';
import 'package:reminder/feature/medications/presentation/view/main_wrapper.dart';

class AddMedicationPage extends StatefulWidget {
  final bool isInTabs;
  const AddMedicationPage({super.key, this.isInTabs = false});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String _selectedFrequency = 'Daily';
  int _selectedInterval = 8;
  final List<int> _intervalOptions = [4, 6, 8, 12, 24];
  String _selectedUnit = 'Pills';
  List<TimeOfDay> _selectedTimes = [];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && !_selectedTimes.contains(picked)) {
      setState(() {
        _selectedTimes.add(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget pageContent = BlocListener<AddMedicationCubit, AddMedicationState>(
      listener: (context, state) {
        if (state is AddMedicationSuccess) {
          context.read<MedicationCubit>().fetchMedications();

          CustomSnackBar.show(context,
              message: "Medication Added Successfully!", isError: false);

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainWrapper()),
              (route) => false,
            );
          }
        } else if (state is AddMedicationError) {
          print("Add Error: ${state.message}");
          CustomSnackBar.show(context, message: state.message, isError: true);
        }
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            if (widget.isInTabs) const SizedBox(height: 50),

            const SectionTitle(title: "General Information"),
            CustomCardTextField(
              controller: _nameController,
              hint: "Medication Name",
              icon: Icons.medication_rounded,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 15),
            CustomCardTextField(
              controller: _dosageController,
              hint: "Dosage",
              icon: Icons.scale_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            CustomDropdownField(
              label: "Unit",
              value: _selectedUnit,
              items: const ['Pills', 'Syrup', 'Injection', 'Drops'],
              onChanged: (val) => setState(() => _selectedUnit = val!),
            ),
            const SizedBox(height: 15),

            CustomDropdownField(
              label: "Frequency",
              value: _selectedFrequency,
              items: const ['Daily', 'Weekly', 'Interval'],
              onChanged: (val) => setState(() => _selectedFrequency = val!),
            ),

            // يظهر فقط لو اختار Interval
            if (_selectedFrequency == 'Interval') ...[
              const SizedBox(height: 15),
              IntervalDropdownField(
                label: "How often do you take it?",
                value: _selectedInterval,
                items: _intervalOptions,
                onChanged: (val) => setState(() => _selectedInterval = val!),
              ),
            ],

            const SizedBox(height: 25),
            const Text(
              "Reminder Times",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._selectedTimes.map((time) => Chip(
                      label: Text(time.format(context)),
                      onDeleted: () =>
                          setState(() => _selectedTimes.remove(time)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppColors.primary),
                    )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text("Add Time",
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: AppColors.primary,
                  onPressed: () => _selectTime(context),
                ),
              ],
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 58),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_selectedTimes.isEmpty) {
                   
          CustomSnackBar.show(context,
              message: "Please add at least one reminder time", isError: false);
                    return;
                  }

                  final medication = MedicationModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    dosage: _dosageController.text,
                    unit: _selectedUnit,
                    frequency: _selectedFrequency,
                    stock: int.tryParse(_stockController.text) ?? 0,
                    reminderTimes: _selectedTimes.map((t) {
                      final now = DateTime.now();
                      return DateFormat('HH:mm').format(DateTime(
                          now.year, now.month, now.day, t.hour, t.minute));
                    }).toList(),
                    isTaken: false,
                  );

         
                  final settings = Hive.box('users_box');
                  final String boxName = settings.get('current_user_box',
                      defaultValue: 'default_box');

    
                  await context
                      .read<AddMedicationCubit>()
                      .addMedication(medication, boxName: boxName);
                }
              },
              child: const Text("Save Medication",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (widget.isInTabs) {
      return Container(color: Colors.grey[50], child: pageContent);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("New Medication",
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: pageContent,
    );
  }
}
