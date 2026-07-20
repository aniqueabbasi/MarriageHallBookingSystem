import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/models/admin/admin_user.dart';
import 'package:marriage_hall_app/widgets/admin/role_badge.dart';

class AdminUserCard extends StatelessWidget {
  final AdminUser user;

  /// Whether this row is the logged-in admin themselves.
  final bool isCurrentUser;
  final VoidCallback? onChangeRole;

  const AdminUserCard({
    super.key,
    required this.user,
    this.isCurrentUser = false,
    this.onChangeRole,
  });

  @override
  Widget build(BuildContext context) {
    final initials = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.chipBackground,
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentUser ? '${user.fullName} (you)' : user.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (user.phoneNumber != null &&
                          user.phoneNumber!.isNotEmpty)
                        Text(
                          user.phoneNumber!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                RoleBadge(role: user.role),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onChangeRole,
                icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                label: const Text('Change Role'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
