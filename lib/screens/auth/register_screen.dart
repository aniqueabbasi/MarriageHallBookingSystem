import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/widgets/auth/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final hallNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool get isHallOwner => widget.role == UserRole.hallOwner;

  @override
  void dispose() {
    nameController.dispose();
    hallNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }
    return null;
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

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<void> register() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          fullName: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          phoneNumber: phoneController.text.trim(),
          role: widget.role,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered Successfully!")),
      );
      context.go('/login', extra: widget.role);
    } else {
      final message = ref.read(authControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Registration failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("${widget.role.label} Register"),
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
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  margin: const EdgeInsets.only(bottom: AppSizes.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        child: Icon(
                          isHallOwner ? Icons.storefront : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Text(
                          isHallOwner
                              ? "Register your hall to start receiving bookings"
                              : "Create an account to start booking halls",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AuthTextField(
                  fieldId: "register_name",
                  controller: nameController,
                  label: isHallOwner ? "Owner Name" : "Full Name",
                  icon: Icons.person_outline,
                  validator: requiredValidator,
                ),
                const SizedBox(height: AppSizes.md),
                if (isHallOwner) ...[
                  AuthTextField(
                    fieldId: "register_hall_name",
                    controller: hallNameController,
                    label: "Hall Name",
                    icon: Icons.storefront_outlined,
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                AuthTextField(
                  fieldId: "register_email",
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: emailValidator,
                ),
                const SizedBox(height: AppSizes.md),
                AuthTextField(
                  fieldId: "register_phone",
                  controller: phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: requiredValidator,
                ),
                const SizedBox(height: AppSizes.md),
                if (isHallOwner) ...[
                  AuthTextField(
                    fieldId: "register_city",
                    controller: cityController,
                    label: "City",
                    icon: Icons.location_city_outlined,
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: AppSizes.md),
                  AuthTextField(
                    fieldId: "register_address",
                    controller: addressController,
                    label: "Address",
                    icon: Icons.map_outlined,
                    validator: requiredValidator,
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                AuthTextField(
                  fieldId: "register_password",
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: requiredValidator,
                ),
                const SizedBox(height: AppSizes.md),
                AuthTextField(
                  fieldId: "register_confirm_password",
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: confirmPasswordValidator,
                ),
                const SizedBox(height: AppSizes.lg),
                GradientButton(
                  label: isLoading ? "Registering..." : AppStrings.register,
                  onPressed: isLoading ? null : register,
                ),
                const SizedBox(height: AppSizes.lg),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        AppStrings.alreadyHaveAccount,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.go('/login', extra: widget.role),
                        child: const Text(
                          AppStrings.login,
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
      ),
    );
  }
}
