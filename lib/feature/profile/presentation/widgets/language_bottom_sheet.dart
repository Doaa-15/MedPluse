import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/feature/profile/presentation/widgets/language_option_widget.dart';
import 'package:reminder/localization/cubit/local_cubit.dart'; 


class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

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
          LanguageOption(
            title: "العربية",
            isSelected: currentLocale == 'ar',
            onTap: () {
              context.read<LocaleCubit>().changeLanguage('ar');
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 10),

      
          LanguageOption(
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

