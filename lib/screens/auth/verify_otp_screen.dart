import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/controllers/auth/password_reset_controller.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/screens/auth/reset_password_screen.dart';

/// Step 2 of the forgot-password flow: exchange the emailed 6-digit OTP
/// for a reset token. The token never leaves memory.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;
  final UserRole? role;

  const VerifyOtpScreen({super.key, required this.email, this.role});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  String? otpValidator(String? value) {
    final otp = value?.trim() ?? '';
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return "Enter the 6-digit code";
    }
    return null;
  }

  Future<void> verifyOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final resetToken = await ref
        .read(passwordResetControllerProvider.notifier)
        .verifyOtp(email: widget.email, otp: otpController.text.trim());

    if (!mounted) return;
    if (resetToken != null && resetToken.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            resetToken: resetToken,
            role: widget.role,
          ),
        ),
      );
    } else {
      final message =
          ref.read(passwordResetControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not verify the code.')),
      );
    }
  }

  Future<void> resendOtp() async {
    final sent = await ref
        .read(passwordResetControllerProvider.notifier)
        .sendOtp(widget.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'If an account exists, a new OTP has been sent.'
              : ref.read(passwordResetControllerProvider).errorMessage ??
                    'Could not resend the code.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Verify Code"), centerTitle: true),
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
                    Icons.mark_email_read_outlined,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  "Enter the code",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  "We sent a 6-digit code to ${widget.email}. It expires in "
                  "10 minutes.",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                TextFormField(
                  controller: otpController,
                  validator: otpValidator,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                GradientButton(
                  label: resetState.isLoading ? "Verifying..." : "Verify OTP",
                  icon: Icons.verified_outlined,
                  onPressed: resetState.isLoading ? null : verifyOtp,
                ),
                const SizedBox(height: AppSizes.md),
                Center(
                  child: TextButton(
                    onPressed: resetState.isLoading ? null : resendOtp,
                    child: const Text("Didn't get a code? Resend"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
