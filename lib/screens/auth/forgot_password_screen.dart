import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/widgets/auth/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void sendResetLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reset link sent to your email!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.resetPassword),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.md),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                AppStrings.resetPassword,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSizes.sm),
              const Text(
                AppStrings.resetPasswordDescription,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: AppSizes.xl),
              AuthTextField(
                fieldId: "forgot_password_email",
                controller: emailController,
                label: "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSizes.xl),
              GradientButton(
                label: AppStrings.sendResetLink,
                onPressed: sendResetLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
