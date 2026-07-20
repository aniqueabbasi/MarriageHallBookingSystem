import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/widgets/auth/auth_text_field.dart';
import 'package:marriage_hall_app/controllers/auth/password_reset_controller.dart';
import 'package:marriage_hall_app/models/user_role.dart';

/// Step 3 of the forgot-password flow: set the new password using the
/// in-memory reset token, then return to login.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String resetToken;
  final UserRole? role;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
    this.role,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? passwordValidator(String? value) {
    final password = value ?? '';
    if (password.length < 8) {
      return "Must be at least 8 characters";
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "Must contain an uppercase letter";
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return "Must contain a lowercase letter";
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return "Must contain a number";
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<void> resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref
        .read(passwordResetControllerProvider.notifier)
        .resetPassword(
          email: widget.email,
          resetToken: widget.resetToken,
          newPassword: passwordController.text,
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully.')),
      );
      // go() rebuilds the router stack, clearing the whole pushed flow.
      context.go('/login', extra: widget.role ?? UserRole.client);
    } else {
      final message =
          ref.read(passwordResetControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not reset the password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("New Password"), centerTitle: true),
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
                    Icons.password_outlined,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  "Set a new password",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  "Your new password must be at least 8 characters and "
                  "include an uppercase letter, a lowercase letter and a "
                  "number.",
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: AppSizes.xl),
                AuthTextField(
                  fieldId: "reset_new_password",
                  controller: passwordController,
                  label: "New Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: passwordValidator,
                ),
                const SizedBox(height: AppSizes.md),
                AuthTextField(
                  fieldId: "reset_confirm_password",
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: confirmPasswordValidator,
                ),
                const SizedBox(height: AppSizes.xl),
                GradientButton(
                  label: resetState.isLoading ? "Resetting..." : "Reset Password",
                  icon: Icons.check_circle_outline,
                  onPressed: resetState.isLoading ? null : resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
