import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/core/theme/app_colors.dart';
import 'package:reminder/feature/auth/cubit/auth_cubit.dart';
import 'package:reminder/feature/auth/cubit/auth_state.dart';
import 'package:reminder/feature/auth/presentation/view/login_page.dart';
import 'package:reminder/feature/medications/presentation/view/home_page.dart';
import 'package:reminder/feature/medications/presentation/view/main_wrapper.dart';

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
  bool _isAgreed = false; // المتغير المسؤول عن تعطيل/تفعيل الزرار
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
      // شروط تفعيل الزرار: الحقول غير فارغة، البريد يحتوي @، كلمة السر >= 6، وتطابق كلمتي السر، والموافقة على الشروط
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Your",
                      style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "Account",
                      style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // حقل الاسم الكامل
                      _buildInputField(
                        controller: _nameController,
                        label: "Full Name",
                        hint: " Your Name",
                        suffix: const Icon(Icons.check, size: 18, color: AppColors.primary),
                        validator: (value) => (value == null || value.isEmpty) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 25),

                      // حقل البريد الإلكتروني
                      _buildInputField(
                        controller: _emailController,
                        label: "Gmail",
                        hint: "name@gmail.com",
                        suffix: const Icon(Icons.check, size: 18, color: AppColors.primary),
                        validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                      ),
                      const SizedBox(height: 25),

                      // حقل كلمة السر
                      _buildInputField(
                        controller: _passwordController,
                        label: "Password",
                        hint: "..........",
                        isPassword: true,
                        isHidden: _isPasswordHidden,
                        onToggleVisibility: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                        validator: (value) => (value == null || value.length < 6) ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 25),

                      // حقل تأكيد كلمة السر
                      _buildInputField(
                        controller: _confirmPasswordController,
                        label: "Confirm Password",
                        hint: "..........",
                        isPassword: true,
                        isHidden: _isConfirmPasswordHidden,
                        onToggleVisibility: () => setState(() => _isConfirmPasswordHidden = !_isConfirmPasswordHidden),
                        validator: (value) => (value != _passwordController.text) ? 'Passwords do not match' : null,
                      ),

                      const SizedBox(height: 20),

                      // خانة الموافقة على الشروط (مهمة لتفعيل الزرار)
                      Row(
                        children: [
                          Checkbox(
                            value: _isAgreed,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                _isAgreed = value ?? false;
                                _updateButtonState();
                              });
                            },
                          ),
                          const Text(
                            "I agree to the Terms and Conditions",
                            style: TextStyle(color: AppColors.secondary, fontSize: 13),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // زر التسجيل مع BlocConsumer لمتابعة الحالات
                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            // النجاح: الانتقال للهوم وتفريغ الستاك
                        Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
                          } else if (state is AuthError) {
                            // الخطأ: عرض رسالة من السوبر بيز
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message), 
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          return InkWell(
                            onTap: (_isButtonEnabled && state is! AuthLoading)
                                ? () {
                                    if (_formKey.currentState!.validate()) {
                                      // نداء دالة register من الكيوبيت
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
                                gradient: _isButtonEnabled ? AppColors.primaryGradient : null,
                                color: _isButtonEnabled ? null : Colors.grey[300],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(color: AppColors.white)
                                    : const Text(
                                        "SIGN UP",
                                        style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // العودة لتسجيل الدخول
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?", style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "  Sign in",
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
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

  // ميثود بناء الحقول الموحدة
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    bool? isHidden,
    VoidCallback? onToggleVisibility,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? (isHidden ?? true) : false,
          validator: validator,
          style: const TextStyle(color: AppColors.primary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.lightGray, fontSize: 13),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (isHidden ?? true) ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : suffix,
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightGray, width: 1)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}