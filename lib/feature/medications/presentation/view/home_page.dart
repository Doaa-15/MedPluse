import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_cubit.dart';
import 'package:reminder/feature/add_medication/presentation/view/add_medicine.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/feature/medications/presentation/widgets/med_card.dart';
import 'package:reminder/injection_container.dart';

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

        // --- التعديل هنا: استخدام FutureBuilder لفتح الصندوق بأمان ---
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

            // الحالة الطبيعية بعد التأكد إن الصندوق مفتوح
            return Column(
              children: [
                _buildHeader(AppColors.primary),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(),
                        const SizedBox(height: 20),

                        // عرض قائمة الأدوية باستخدام الـ Box المفتوح فعلياً
                        ValueListenableBuilder(
                          valueListenable: snapshot.data!.listenable(),
                          builder: (context, Box<MedicationModel> box, _) {
                            final medications = box.values.toList();

                            if (medications.isEmpty) {
                              return _buildEmptyState();
                            }

                            return Column(
children: medications.map((m) => MedCard(med: m)).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 25),
                        _buildActionButtons(context, AppColors.primary),
                        const SizedBox(height: 20),
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

  // --- Widgets المساعدة (نفس الكود بتاعك بدون تغيير) ---

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MedPulse",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Ready for your next dose?",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2D2D2D),
          ),
        ),
        Text(
          DateFormat('MMM dd, yyyy').format(DateTime.now()),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.beach_access_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 15),
          Text(
            "No medications for today",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color color) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            context,
            "Add Medicine",
            Icons.add_rounded,
            color,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => sl<AddMedicationCubit>(),
                  child: const AddMedicationPage(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _actionButton(
            context,
            "Schedule",
            Icons.calendar_today_rounded,
            AppColors.primary,
            () {},
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
