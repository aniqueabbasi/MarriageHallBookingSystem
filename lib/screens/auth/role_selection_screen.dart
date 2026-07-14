import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/widgets/auth/role_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void selectRole(BuildContext context, UserRole role) {
    context.go('/login', extra: role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.xl,
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
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(
                      Icons.waving_hand_rounded,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    AppStrings.chooseRole,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    "Select how you'd like to continue",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoleCard(
                    icon: Icons.person,
                    title: AppStrings.clientTitle,
                    description: AppStrings.clientDescription,
                    onTap: () => selectRole(context, UserRole.client),
                  ),
                  RoleCard(
                    icon: Icons.storefront,
                    title: AppStrings.hallOwnerTitle,
                    description: AppStrings.hallOwnerDescription,
                    onTap: () => selectRole(context, UserRole.hallOwner),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
