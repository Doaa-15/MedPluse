import 'package:flutter/material.dart';
import 'package:reminder/core/theme/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String hint;
  final bool isPassword;
  final bool? isHidden;
  final VoidCallback? onToggleVisibility;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.controller,
    this.label,
    required this.hint,
    this.isPassword = false,
    this.isHidden,
    this.onToggleVisibility,
    this.suffix,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? (isHidden ?? true) : false,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.primary, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              
              // الأيقونة لو باسوورد
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        (isHidden ?? true)
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : suffix,

              // التصميم الخارجي للـ Input
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              filled: true,
              fillColor: AppColors.lightGray,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}