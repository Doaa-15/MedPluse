import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/core/widgets/custom_snack_bar.dart';
import 'package:reminder/feature/auth/cubit/auth_cubit.dart';
import 'package:reminder/feature/auth/cubit/auth_state.dart';
import 'package:reminder/feature/auth/presentation/view/login_page.dart';
import 'package:reminder/core/widgets/custom_text_field_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
final  bool _isAgreed = false; 
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // إضافة مستمعين لتحديث حالة الزرار عند الكتابة
    _emailController.addListener(_updateButtonState);
    _nameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.contains('@') &&
          _nameController.text.isNotEmpty &&
          _passwordController.text.length >= 6 &&
          _confirmPasswordController.text == _passwordController.text &&
          _isAgreed;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.createAccount,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      l10n.accountTitle,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomInputField(
                        controller: _nameController,
                        label: l10n.fullName,
                        hint: l10n.nameHint,
                        suffix: const Icon(Icons.check,
                            size: 18, color: AppColors.primary),
                        validator: (value) => (value == null || value.isEmpty)
                            ? l10n.nameRequired
                            : null,
                      ),
                      const SizedBox(height: 25),
                      CustomInputField(
                        controller: _emailController,
                        label: l10n
                            .gmailLabel, // استخدمنا اللي في ملف Login لتقليل التكرار
                        hint: l10n.emailHint,
                        suffix: const Icon(Icons.check,
                            size: 18, color: AppColors.primary),
                        validator: (value) =>
                            (value == null || !value.contains('@'))
                                ? l10n.invalidEmail
                                : null,
                      ),
                      const SizedBox(height: 25),
                      CustomInputField(
                        controller: _passwordController,
                        label: l10n.passwordLabel,
                        hint: l10n.passwordHint,
                        isPassword: true,
                        isHidden: _isPasswordHidden,
                        onToggleVisibility: () => setState(
                            () => _isPasswordHidden = !_isPasswordHidden),
                        validator: (value) =>
                            (value == null || value.length < 6)
                                ? l10n.minPassword
                                : null,
                      ),
                      const SizedBox(height: 25),
                      CustomInputField(
                        controller: _confirmPasswordController,
                        label: l10n.confirmPassword,
                        hint: l10n.passwordHint,
                        isPassword: true,
                        isHidden: _isConfirmPasswordHidden,
                        onToggleVisibility: () => setState(() =>
                            _isConfirmPasswordHidden =
                                !_isConfirmPasswordHidden),
                        validator: (value) =>
                            (value != _passwordController.text)
                                ? l10n.passwordMismatch
                                : null,
                      ),
                      const SizedBox(height: 30),
                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          } else if (state is AuthError) {
                            CustomSnackBar.show(context,
                                message: state.message, isError: true);
                          }
                        },
                        builder: (context, state) {
                          return InkWell(
                            onTap: (_isButtonEnabled && state is! AuthLoading)
                                ? () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthCubit>().register(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                            _nameController.text.trim(),
                                          );
                                    }
                                  }
                                : null,
                            child: Container(
                              width: double.infinity,
                              height: 55,
                                                              decoration: BoxDecoration(
                                  gradient: _isButtonEnabled
                                      ? AppColors.primaryGradient
                                      : null,
                                  color: _isButtonEnabled
                                      ? null
                                      : AppColors.primary.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              child: Center(
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(
                                        color: AppColors.white)
                                    : Text(
                                        l10n.signUpButton,
                                        style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.alreadyHaveAccount,
                              style: const TextStyle(
                                  color: AppColors.secondary, fontSize: 13)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              l10n.signUpLink.replaceFirst(" Sign up",
                                  " Sign in"), // أو ضيفي key جديد لـ Sign in
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
