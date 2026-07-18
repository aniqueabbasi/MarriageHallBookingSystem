import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/screens/reviews/owner_reviews_screen.dart';
import 'package:marriage_hall_app/controllers/halls/my_halls_controller.dart';
import 'package:marriage_hall_app/widgets/owner/dashboard_home_tab.dart';
import 'package:marriage_hall_app/screens/notifications/notifications_screen.dart';
import 'package:marriage_hall_app/screens/owner/add_edit_hall_screen.dart';
import 'package:marriage_hall_app/screens/owner/my_halls_screen.dart';
import 'package:marriage_hall_app/screens/owner/owner_bookings_screen.dart';
import 'package:marriage_hall_app/screens/owner/owner_profile_menu_screen.dart';

final ownerTabIndexProvider = StateProvider<int>((ref) => 0);

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  Future<void> openAddHall(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditHallScreen()),
    );

    if (result == true) {
      ref.invalidate(myHallsProvider);
      ref.read(ownerTabIndexProvider.notifier).state = 1;
    }
  }

  void openReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OwnerReviewsScreen()),
    );
  }

  void openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(ownerTabIndexProvider);
    final hallsAsync = ref.watch(myHallsProvider);

    void goToTab(int index) =>
        ref.read(ownerTabIndexProvider.notifier).state = index;

    Future<void> refreshHalls() async {
      ref.invalidate(myHallsProvider);
      await ref.read(myHallsProvider.future);
    }

    final tabs = [
      DashboardHomeTab(
        totalHalls: hallsAsync.asData?.value.length ?? 0,
        onAddHall: () => openAddHall(context, ref),
        onNavigateToTab: goToTab,
        onOpenReviews: () => openReviews(context),
        onOpenNotifications: () => openNotifications(context),
      ),
      MyHallsScreen(
        hallsAsync: hallsAsync,
        onAddHall: () => openAddHall(context, ref),
        onRefresh: refreshHalls,
      ),
      const OwnerBookingsScreen(),
      const OwnerProfileMenuScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: currentIndex, children: tabs),
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
            onTap: goToTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: "Dashboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined),
                activeIcon: Icon(Icons.storefront),
                label: "My Halls",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note_outlined),
                activeIcon: Icon(Icons.event_note),
                label: "Bookings",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
