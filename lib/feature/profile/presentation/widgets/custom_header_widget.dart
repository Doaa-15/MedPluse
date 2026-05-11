import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reminder/core/theme/app_colors.dart'; 
import 'package:reminder/feature/profile/presentation/cubit/profile_cubit.dart';

class ProfileHeader extends StatelessWidget {
  final dynamic user; // استقبلنا بيانات المستخدم هنا

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              // اختيار الصورة من المعرض
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              
              if (image != null && context.mounted) {
                // استدعاء الميثود من الـ Cubit
                context.read<ProfileCubit>().updateProfilePicture(File(image.path));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: (user.profileUrl != null && user.profileUrl!.isNotEmpty)
                    ? NetworkImage(user.profileUrl!)
                    : null,
                child: (user.profileUrl == null || user.profileUrl!.isEmpty)
                    ? const Icon(
                        Icons.camera_alt_rounded,
                        size: 40,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}