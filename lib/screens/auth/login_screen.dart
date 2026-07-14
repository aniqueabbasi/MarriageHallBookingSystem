import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marriage_hall_app/resources/app_assets.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/widgets/auth/auth_text_field.dart';
import 'package:marriage_hall_app/widgets/auth/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const LoginScreen({super.key, required this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    return null;
  }

  Future<void> login() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must fill in all fields before continuing"),
        ),
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      final loggedInRole = ref.read(authControllerProvider).user?.role;
      if (loggedInRole == UserRole.hallOwner) {
        context.go('/owner-dashboard');
      } else {
        context.go('/home');
      }
    } else {
      final message = ref.read(authControllerProvider).errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message ?? "Login failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.sm,
                  AppSizes.sm,
                  AppSizes.sm,
                  AppSizes.md,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/roles'),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72),
                child: Image.asset(AppAssets.logo),
              ),
              const SizedBox(height: AppSizes.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.xl,
                  AppSizes.lg,
                  AppSizes.xl,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusXxl),
                    topRight: Radius.circular(AppSizes.radiusXxl),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.chipBackground,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                            child: Icon(
                              widget.role == UserRole.client
                                  ? Icons.person
                                  : Icons.storefront,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            "${widget.role.label} Login",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),
                      const Text(
                        "Welcome back, please login to continue.",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      AuthTextField(
                        fieldId: "login_email",
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: emailValidator,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AuthTextField(
                        fieldId: "login_password",
                        controller: passwordController,
                        label: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: passwordValidator,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      GradientButton(
                        label: isLoading ? "Logging in..." : AppStrings.login,
                        onPressed: isLoading ? null : login,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                            ),
                            child: Text(
                              "OR",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),
                      SocialLoginButton(onPressed: () {}),
                      const SizedBox(height: AppSizes.lg),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              AppStrings.dontHaveAccount,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.push('/register', extra: widget.role),
                              child: const Text(
                                AppStrings.register,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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
