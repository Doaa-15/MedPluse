import 'package:flutter/material.dart';

class EmptyMedicationsState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyMedicationsState({
    super.key,
    this.message = "No medications for today",
    this.icon = Icons.medical_information,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          const SizedBox(height: 40),
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 15),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}