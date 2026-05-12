import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/feature/add_medication/presentation/cubit/add_medicne_cubit.dart';

import 'package:reminder/feature/add_medication/presentation/view/add_medicine.dart';
import 'package:reminder/feature/medications/presentation/view/home_page.dart';
import 'package:reminder/feature/profile/presentation/view/profile_page.dart';
import 'package:reminder/injection_container.dart';
// import 'package:med_reminder/feature/profile/presentation/view/profile_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;


  final List<Widget> _pages = [
    const HomePage(),     
  BlocProvider(
    create: (context) => sl<AddMedicationCubit>(),
    child: const AddMedicationPage(),
  ),  // صفحة إضافة الدواء
    const ProfilePage(),       
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(AppColors.primary),
    );
  }

  Widget _buildBottomNav(Color color) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: color,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 28), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.medical_services_rounded, size: 28), label: 'Meds'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 28), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}