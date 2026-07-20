import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:marriage_hall_app/app_router.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/screens/admin/admin_bookings_screen.dart';
import 'package:marriage_hall_app/screens/admin/admin_halls_screen.dart';
import 'package:marriage_hall_app/screens/admin/admin_users_screen.dart';

final adminTabIndexProvider = StateProvider<int>((ref) => 0);

/// Admin-only shell with Users / Halls / Bookings tabs. Guards itself: a
/// customer or owner who lands here (e.g. via a manual route) is bounced
/// straight to their own dashboard.
class AdminShellScreen extends ConsumerWidget {
  const AdminShellScreen({super.key});

  Future<void> logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go('/roles');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // Route guard — only admins may see this shell.
    if (!authState.isAuthenticated ||
        authState.effectiveRole != UserRole.admin) {
      final target = authState.isAuthenticated
          ? homeRouteForRole(authState.effectiveRole)
          : '/roles';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(target);
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Text(
              'You do not have permission to access the Admin Dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final currentIndex = ref.watch(adminTabIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => logout(context, ref),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          AdminUsersScreen(),
          AdminHallsScreen(),
          AdminBookingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusXl),
            topRight: Radius.circular(AppSizes.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusXl),
            topRight: Radius.circular(AppSizes.radiusXl),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) =>
                ref.read(adminTabIndexProvider.notifier).state = index,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.apartment_outlined),
                activeIcon: Icon(Icons.apartment),
                label: 'Halls',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month),
                label: 'Bookings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
