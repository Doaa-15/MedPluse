import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_cubit.dart';
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_state.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
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
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

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
    // 1. تعريف المحتوى الأساسي
    Widget pageContent = BlocListener<AddMedicationCubit, AddMedicationState>(
      listener: (context, state) {
        if (state is AddMedicationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Medication Added Successfully!"), backgroundColor: Colors.green),
          );
          if (!widget.isInTabs) {
            Navigator.pop(context);
          } else {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapper()));
          }
        } else if (state is AddMedicationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            if (widget.isInTabs) const SizedBox(height: 50),
            
            _buildSectionTitle("General Information"),
            _buildCustomTextField(
              controller: _nameController,
              hint: "Medication Name",
              icon: Icons.medication_rounded,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 15),
            _buildCustomTextField(
              controller: _dosageController,
              hint: "Dosage",
              icon: Icons.scale_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            
            _buildDropdown(
              label: "Unit",
              value: _selectedUnit,
              items: ['Pills', 'Syrup', 'Injection', 'Drops'],
              onChanged: (val) => setState(() => _selectedUnit = val!),
            ),
            const SizedBox(height: 15),

            _buildDropdown(
              label: "Frequency",
              value: _selectedFrequency,
              items: ['Daily', 'Weekly', 'Interval'],
              onChanged: (val) => setState(() => _selectedFrequency = val!),
            ),

            // يظهر فقط لو اختار Interval
            if (_selectedFrequency == 'Interval') ...[
              const SizedBox(height: 15),
              _buildIntervalDropdown(
                label: "How often do you take it?",
                value: _selectedInterval,
                items: _intervalOptions,
                onChanged: (val) => setState(() => _selectedInterval = val!),
              ),
            ],

            const SizedBox(height: 25),
            const Text(
              "Reminder Times",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._selectedTimes.map((time) => Chip(
                  label: Text(time.format(context)),
                  onDeleted: () => setState(() => _selectedTimes.remove(time)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.primary),
                )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text("Add Time", style: TextStyle(color: Colors.white)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_selectedTimes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please add at least one reminder time")),
                    );
                    return;
                  }

                  final settings = Hive.box('users_box');
                  final boxName = settings.get('current_user_box', defaultValue: 'default_box');

                  final medication = MedicationModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    dosage: _dosageController.text,
                    unit: _selectedUnit,
                    frequency: _selectedFrequency,
                    // لو الموديل بتاعك فيه حقل interval السطر الجاي مهم:
                    // intervalHours: _selectedFrequency == 'Interval' ? _selectedInterval : null,
                    stock: int.tryParse(_stockController.text) ?? 0,
                    reminderTimes: _selectedTimes.map((t) {
                      final now = DateTime.now();
                      return DateFormat('HH:mm').format(DateTime(now.year, now.month, now.day, t.hour, t.minute));
                    }).toList(),
                    isTaken: false,
                  );

                  context.read<AddMedicationCubit>().addMedication(medication, boxName: boxName);
                }
              },
              child: const Text("Save Medication", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    // 2. اختيار التغليف (Scaffold أو Container)
    if (widget.isInTabs) {
      return Container(color: Colors.grey[50], child: pageContent);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("New Medication", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: pageContent,
    );
  }

  // --- ميثودات المساعدة ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildCustomTextField({required TextEditingController controller, required String hint, required IconData icon, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown({String? label, required String value, required List<String> items, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalDropdown({required String label, required int value, required List<int> items, required Function(int?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              items: items.map((int item) => DropdownMenuItem<int>(value: item, child: Text("Every $item Hours"))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}