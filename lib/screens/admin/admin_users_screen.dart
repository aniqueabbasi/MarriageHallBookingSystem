import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/admin/admin_users_controller.dart';
import 'package:marriage_hall_app/controllers/admin/update_user_role_controller.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/admin/admin_user.dart';
import 'package:marriage_hall_app/utils/api_error_text.dart';
import 'package:marriage_hall_app/widgets/admin/admin_user_card.dart';
import 'package:marriage_hall_app/widgets/admin/change_role_dialog.dart';
import 'package:marriage_hall_app/widgets/admin/role_badge.dart';

/// Users tab: every registered user with a role badge and a change-role
/// action. Changing your own Admin role gets an extra strong warning and
/// ends with a forced re-login (the old token's role claim is stale).
class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  Future<void> changeRole(
    BuildContext context,
    WidgetRef ref,
    AdminUser user,
  ) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => ChangeRoleDialog(user: user),
    );
    if (newRole == null || newRole == user.role || !context.mounted) return;

    final currentUserId = ref.read(authControllerProvider).effectiveUserId;
    final isSelfDemotion =
        user.id == currentUserId && user.role == 'Admin' && newRole != 'Admin';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSelfDemotion ? 'Change your own role?' : 'Confirm change'),
        content: Text(
          isSelfDemotion
              ? 'You are changing your own Admin role. After this change, '
                    'you will immediately lose access to the Admin Dashboard '
                    'and will be logged out.'
              : "Are you sure you want to change ${user.fullName}'s role "
                    'from ${roleLabel(user.role)} to ${roleLabel(newRole)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isSelfDemotion
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(isSelfDemotion ? 'Change My Role' : 'Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final updated = await ref
        .read(updateUserRoleControllerProvider(user.id).notifier)
        .submit(user.id, newRole);

    if (!context.mounted) return;
    if (updated != null) {
      if (isSelfDemotion) {
        // The stored JWT still carries the Admin role claim, so the only
        // clean path to the new role's dashboard is a fresh login.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your role has changed. Please log in again.'),
          ),
        );
        await ref.read(authControllerProvider.notifier).logout();
        if (context.mounted) context.go('/roles');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${updated.fullName} is now ${roleLabel(updated.role)}.',
            ),
          ),
        );
      }
    } else {
      final message = ref
          .read(updateUserRoleControllerProvider(user.id))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not change the role.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final currentUserId = ref.watch(
      authControllerProvider.select((s) => s.effectiveUserId),
    );

    Future<void> refresh() async {
      ref.invalidate(adminUsersProvider);
      await ref.read(adminUsersProvider.future);
    }

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(friendlyErrorMessage(error), textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.md),
              OutlinedButton(onPressed: refresh, child: const Text('Retry')),
            ],
          ),
        ),
      ),
      data: (users) => RefreshIndicator(
        onRefresh: refresh,
        child: users.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return AdminUserCard(
                    user: user,
                    isCurrentUser: user.id == currentUserId,
                    onChangeRole: () => changeRole(context, ref, user),
                  );
                },
              ),
      ),
    );
  }
}
