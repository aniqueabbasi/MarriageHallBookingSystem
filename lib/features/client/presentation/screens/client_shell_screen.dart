import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../bookings/presentation/screens/my_bookings_screen.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../../../halls/presentation/screens/home_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_menu_screen.dart';

class ClientShellScreen extends StatefulWidget {
  const ClientShellScreen({super.key});

  @override
  State<ClientShellScreen> createState() => _ClientShellScreenState();
}

class _ClientShellScreenState extends State<ClientShellScreen> {
  static const int homeTabIndex = 2;

  int currentIndex = homeTabIndex;

  final Set<String> favoriteHallIds = {};
  final Set<String> favoritePhotographerIds = {};

  void goToTab(int index) => setState(() => currentIndex = index);

  void toggleHallFavorite(String id) {
    setState(() {
      if (favoriteHallIds.contains(id)) {
        favoriteHallIds.remove(id);
      } else {
        favoriteHallIds.add(id);
      }
    });
  }

  void togglePhotographerFavorite(String id) {
    setState(() {
      if (favoritePhotographerIds.contains(id)) {
        favoritePhotographerIds.remove(id);
      } else {
        favoritePhotographerIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const NotificationsScreen(),
      FavoritesScreen(
        favoriteHallIds: favoriteHallIds,
        favoritePhotographerIds: favoritePhotographerIds,
        onToggleHallFavorite: toggleHallFavorite,
        onTogglePhotographerFavorite: togglePhotographerFavorite,
      ),
      HomeScreen(
        favoriteHallIds: favoriteHallIds,
        favoritePhotographerIds: favoritePhotographerIds,
        onToggleHallFavorite: toggleHallFavorite,
        onTogglePhotographerFavorite: togglePhotographerFavorite,
      ),
      const MyBookingsScreen(),
      const ProfileMenuScreen(),
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
                icon: Icon(Icons.notifications_none),
                activeIcon: Icon(Icons.notifications),
                label: "Alerts",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: "Favorites",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home",
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
