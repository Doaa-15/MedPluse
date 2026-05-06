import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder/core/theme/app_colors.dart'; // استدعاء ملف الألوان الخاص بك
import 'package:reminder/feature/auth/cubit/auth_cubit.dart';
import 'package:reminder/feature/auth/cubit/auth_state.dart';
import 'package:reminder/feature/auth/presentation/view/register_page.dart';
import 'package:reminder/feature/medications/presentation/view/home_page.dart';
import 'package:reminder/feature/medications/presentation/view/main_wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استخدام اللون الأساسي من ملف AppColors كخلفية احتياطية
      backgroundColor: AppColors.background, 
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainWrapper()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.third, // استخدام لون الـ accent للخطأ بدلاً من الأحمر العادي
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // استخدام التدرج اللوني المعرف في AppColors
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
                        "Hello",
                        style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "Sign in!",
                        style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.white, // استخدام متغير white من الملف
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _emailController,
                          label: "Gmail",
                          hint: "name@gmail.com",
                          suffix: const Icon(Icons.check, size: 18, color: AppColors.primary),
                          validator: (value) {
                            if (value == null || !value.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildInputField(
                          controller: _passwordController,
                          label: "Password",
                          hint: "..........",
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.length < 6) return 'Password too short';
                            return null;
                          },
                        ),
                       
                        const SizedBox(height: 60),
                        
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return InkWell(
                              onTap: (_isButtonEnabled && state is! AuthLoading) ? () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                }
                              } : null,
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  // التدرج من الملف عند التفعيل، والرمادي الفاتح عند التعطيل
                                  gradient: _isButtonEnabled ? AppColors.primaryGradient : null,
                                  color: _isButtonEnabled ? null : AppColors.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: state is AuthLoading
                                      ? const CircularProgressIndicator(color: AppColors.primary)
                                      : const Text(
                                          "SIGN IN",
                                          style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Don't have account?", style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                              child: const Text("Sign up", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // استخدام لون الـ accent للـ Label
        Text(label, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _isPasswordHidden : false,
          validator: validator,
          style: const TextStyle(color: AppColors.primary, fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius:  BorderRadius.circular(12), borderSide: BorderSide.none),
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.black, fontSize: 13),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                      color: AppColors.primary, 
                      size: 18
                    ),
                    onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
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