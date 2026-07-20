import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/widgets/auth/auth_text_field.dart';
import 'package:marriage_hall_app/controllers/auth/password_reset_controller.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/screens/auth/verify_otp_screen.dart';

/// Step 1 of the forgot-password flow: collect the email and request an
/// OTP. [role] only tags which login screen to return to at the end.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final UserRole? role;

  const ForgotPasswordScreen({super.key, this.role});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
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

  Future<void> sendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = emailController.text.trim();

    final sent = await ref
        .read(passwordResetControllerProvider.notifier)
        .sendOtp(email);

    if (!mounted) return;
    if (sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('If an account exists, an OTP has been sent.'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VerifyOtpScreen(email: email, role: widget.role),
        ),
      );
    } else {
      final message =
          ref.read(passwordResetControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not send the OTP.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.resetPassword),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
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
                  "Enter the email for your account and we'll send you a "
                  "6-digit code to reset your password.",
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: AppSizes.xl),
                AuthTextField(
                  fieldId: "forgot_password_email",
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: emailValidator,
                ),
                const SizedBox(height: AppSizes.xl),
                GradientButton(
                  label: resetState.isLoading ? "Sending..." : "Send OTP",
                  icon: Icons.send_outlined,
                  onPressed: resetState.isLoading ? null : sendOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
