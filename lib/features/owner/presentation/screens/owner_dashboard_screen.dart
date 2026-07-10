import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../reviews/presentation/screens/owner_reviews_screen.dart';
import '../../data/owner_hall_dummy_data.dart';
import '../widgets/dashboard_home_tab.dart';
import 'add_edit_hall_screen.dart';
import 'my_halls_screen.dart';
import 'owner_bookings_screen.dart';
import 'owner_profile_menu_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int currentIndex = 0;
  late List<Map<String, dynamic>> halls = List<Map<String, dynamic>>.from(
    dummyOwnerHalls,
  );

  void goToTab(int index) => setState(() => currentIndex = index);

  Future<void> openAddHall() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditHallScreen()),
    );

    if (result != null) {
      setState(() {
        halls.add(result);
        currentIndex = 1;
      });
    }
  }

  Future<void> openEditHall(int index) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditHallScreen(initialHall: halls[index]),
      ),
    );

    if (result != null) {
      setState(() => halls[index] = result);
    }
  }

  void deleteHall(int index) => setState(() => halls.removeAt(index));

  void openReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OwnerReviewsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DashboardHomeTab(
        totalHalls: halls.length,
        onAddHall: openAddHall,
        onNavigateToTab: goToTab,
        onOpenReviews: openReviews,
      ),
      MyHallsScreen(
        halls: halls,
        onAddHall: openAddHall,
        onEditHall: openEditHall,
        onDeleteHall: deleteHall,
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
