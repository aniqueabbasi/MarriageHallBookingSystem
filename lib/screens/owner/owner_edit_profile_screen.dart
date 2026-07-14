import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/controllers/profile/owner_user_dummy_data.dart';

class OwnerEditProfileScreen extends ConsumerStatefulWidget {
  const OwnerEditProfileScreen({super.key});

  @override
  ConsumerState<OwnerEditProfileScreen> createState() =>
      _OwnerEditProfileScreenState();
}

class _OwnerEditProfileScreenState
    extends ConsumerState<OwnerEditProfileScreen> {
  late final user = ref.read(ownerProfileControllerProvider);
  late final nameController = TextEditingController(text: user['name']);
  late final emailController = TextEditingController(text: user['email']);
  late final phoneController = TextEditingController(text: user['phone']);
  late final cityController = TextEditingController(text: user['city']);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void changePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Photo picker isn't wired up in this UI-only build."),
      ),
    );
  }

  void saveChanges() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name is required")),
      );
      return;
    }

    ref
        .read(ownerProfileControllerProvider.notifier)
        .update(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          city: cityController.text.trim(),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Edit Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: changePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "City",
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            GradientButton(
              label: "Save Changes",
              icon: Icons.check_circle_outline,
              onPressed: saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
