import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_cubit.dart';
import 'package:reminder/feature/add_medication/presentation/view/add_medicine.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/feature/medications/presentation/widgets/empty_medications_state.dart';
import 'package:reminder/feature/medications/presentation/widgets/home_action_button.dart';
import 'package:reminder/feature/medications/presentation/widgets/med_card.dart';
import 'package:reminder/feature/medications/presentation/widgets/med_pulse_header.dart';
import 'package:reminder/feature/medications/presentation/widgets/schedule_header.dart';
import 'package:reminder/injection_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return ValueListenableBuilder(
      valueListenable: Hive.box('users_box').listenable(),
      builder: (context, Box settingsBox, _) {
        final String? currentUserBox = settingsBox.get('current_user_box');

        if (currentUserBox == null) {
          return const Center(child: Text("No User Found"));
        }
        return FutureBuilder<Box<MedicationModel>>(
          future: Hive.openBox<MedicationModel>(currentUserBox),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 15),
                    Text(
                      "Setting up your dashboard...",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text("Error loading medications"));
            }

            return Column(
              children: [
                const MedPulseHeader(AppColors.primary,),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                     const   ScheduleHeader(),
                        const SizedBox(height: 20),
                        ValueListenableBuilder(
                          valueListenable: snapshot.data!.listenable(),
                          builder: (context, Box<MedicationModel> box, _) {
                            final medications = box.values.toList();

                            if (medications.isEmpty) {
                              return const EmptyMedicationsState();
                            }

                            return Column(
children: medications.map((m) => MedCard(med: m)).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 25),
                      Row(
  children: [
    Expanded(
      child: HomeActionButton(
        label: AppLocalizations.of(context)!.addMedicine,
        icon: Icons.add_rounded,
        color: AppColors.primary, 
        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => sl<AddMedicationCubit>(),
                child: const AddMedicationPage(),
              ),
            ),
          );
        },
      ),
    ),
   
  ],
),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
