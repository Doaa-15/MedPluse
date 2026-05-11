import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/localization/cubit/local_cubit.dart'; // تأكدي من مسار الألوان
// تأكدي من مسار الكيوبيت

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  // دالة ثابتة (static) لتسهيل استدعاء الـ Bottom Sheet من أي مكان
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LanguageBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
     
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // خيار اللغة العربية
          _LanguageOption(
            title: "العربية",
            isSelected: currentLocale == 'ar',
            onTap: () {
              context.read<LocaleCubit>().changeLanguage('ar');
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 10),

          // خيار اللغة الإنجليزية
          _LanguageOption(
            title: "English",
            isSelected: currentLocale == 'en',
            onTap: () {
              context.read<LocaleCubit>().changeLanguage('en');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
    );
  }
}