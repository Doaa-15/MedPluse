import 'package:flutter/material.dart';
import 'package:reminder/core/theme/app_colors.dart'; 
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MedPulseHeader extends StatelessWidget {
  final Color ?backgroundColor;
  final VoidCallback? onNotificationPressed;

  const MedPulseHeader(Color primary, {
    super.key,
     this.backgroundColor,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      width: double.infinity,
      decoration:const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
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
               Text(
                AppLocalizations.of(context)!.appTitle,
                style:const TextStyle(
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
                  onPressed: onNotificationPressed ?? () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
           Text(
            AppLocalizations.of(context)!.readyDose,
            style:const TextStyle(
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
}