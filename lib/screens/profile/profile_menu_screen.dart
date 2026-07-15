import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/controllers/profile/user_dummy_data.dart';
import 'package:marriage_hall_app/widgets/profile/profile_menu_tile.dart';
import 'package:marriage_hall_app/screens/profile/help_support_screen.dart';
import 'package:marriage_hall_app/screens/profile/privacy_policy_screen.dart';
import 'package:marriage_hall_app/screens/profile/terms_conditions_screen.dart';
import 'package:marriage_hall_app/screens/profile/view_profile_screen.dart';

class ProfileMenuScreen extends ConsumerWidget {
  const ProfileMenuScreen({super.key});

  void openViewProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewProfileScreen()),
    );
  }

  Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Log Out",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) context.go('/roles');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.lg,
                  AppSizes.lg,
                  AppSizes.xl,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSizes.radiusXxl),
                    bottomRight: Radius.circular(AppSizes.radiusXxl),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['email'],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileMenuTile(
                      icon: Icons.person_outline,
                      label: "View Your Profile",
                      onTap: () => openViewProfile(context),
                    ),
                    ProfileMenuTile(
                      icon: Icons.description_outlined,
                      label: "Terms & Conditions",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TermsConditionsScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.privacy_tip_outlined,
                      label: "Privacy Policy",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.help_outline,
                      label: "Help & Support",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    ProfileMenuTile(
                      icon: Icons.logout,
                      label: "Log Out",
                      isDestructive: true,
                      onTap: () => confirmLogout(context, ref),
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
