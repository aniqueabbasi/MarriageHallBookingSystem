import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/profile/user_dummy_data.dart';
import 'package:marriage_hall_app/screens/profile/edit_profile_screen.dart';

class ViewProfileScreen extends ConsumerWidget {
  const ViewProfileScreen({super.key});

  void openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Your Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
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
                child: Icon(Icons.person, size: 60, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(user['name'], style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSizes.xl),
            _InfoTile(
              icon: Icons.email_outlined,
              label: "Email",
              value: user['email'],
            ),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: "Phone",
              value: user['phone'],
            ),
            _InfoTile(
              icon: Icons.location_city_outlined,
              label: "City",
              value: user['city'],
            ),
            const SizedBox(height: AppSizes.lg),
            OutlinedButton.icon(
              onPressed: () => openEditProfile(context),
              icon: const Icon(Icons.edit_outlined),
              label: const Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
