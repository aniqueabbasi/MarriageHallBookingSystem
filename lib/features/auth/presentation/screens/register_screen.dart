import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../user_role.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  void register() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registered Successfully!")),
    );
    context.go('/login', extra: widget.role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("${widget.role.label} Register"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
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
                controller: nameController,
                label: isHallOwner ? "Owner Name" : "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: AppSizes.md),
              if (isHallOwner) ...[
                AuthTextField(
                  controller: hallNameController,
                  label: "Hall Name",
                  icon: Icons.storefront_outlined,
                ),
                const SizedBox(height: AppSizes.md),
              ],
              AuthTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSizes.md),
              AuthTextField(
                controller: phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.md),
              if (isHallOwner) ...[
                AuthTextField(
                  controller: cityController,
                  label: "City",
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: AppSizes.md),
                AuthTextField(
                  controller: addressController,
                  label: "Address",
                  icon: Icons.map_outlined,
                ),
                const SizedBox(height: AppSizes.md),
              ],
              AuthTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: AppSizes.md),
              AuthTextField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: AppSizes.lg),
              GradientButton(label: AppStrings.register, onPressed: register),
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
                      onTap: () => context.go('/login', extra: widget.role),
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
    );
  }
}
