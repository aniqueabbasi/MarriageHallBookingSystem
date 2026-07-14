import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/screens/bookings/my_bookings_screen.dart';
import 'package:marriage_hall_app/screens/favorites/favorites_screen.dart';
import 'package:marriage_hall_app/controllers/favorites/favorites_controller.dart';
import 'package:marriage_hall_app/screens/halls/home_screen.dart';
import 'package:marriage_hall_app/screens/notifications/notifications_screen.dart';
import 'package:marriage_hall_app/screens/profile/profile_menu_screen.dart';

const int _homeTabIndex = 2;

final clientTabIndexProvider = StateProvider<int>((ref) => _homeTabIndex);

class ClientShellScreen extends ConsumerWidget {
  const ClientShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(clientTabIndexProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final favoritesNotifier = ref.read(favoritesControllerProvider.notifier);

    void goToTab(int index) =>
        ref.read(clientTabIndexProvider.notifier).state = index;

    final tabs = [
      const NotificationsScreen(),
      FavoritesScreen(
        favoriteHallIds: favorites.hallIds,
        favoritePhotographerIds: favorites.photographerIds,
        onToggleHallFavorite: favoritesNotifier.toggleHall,
        onTogglePhotographerFavorite: favoritesNotifier.togglePhotographer,
      ),
      HomeScreen(
        favoriteHallIds: favorites.hallIds,
        favoritePhotographerIds: favorites.photographerIds,
        onToggleHallFavorite: favoritesNotifier.toggleHall,
        onTogglePhotographerFavorite: favoritesNotifier.togglePhotographer,
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
