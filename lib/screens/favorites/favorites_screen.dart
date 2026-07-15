import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/halls/halls_list_controller.dart';
import 'package:marriage_hall_app/widgets/halls/hall_card.dart';
import 'package:marriage_hall_app/screens/halls/hall_detail_screen.dart';
import 'package:marriage_hall_app/data/dummy/photographer_dummy_data.dart';
import 'package:marriage_hall_app/screens/photographers/photographer_profile_screen.dart';
import 'package:marriage_hall_app/widgets/photographers/photographer_card.dart';

class FavoritesScreen extends ConsumerWidget {
  final Set<String> favoriteHallIds;
  final Set<String> favoritePhotographerIds;
  final ValueChanged<String> onToggleHallFavorite;
  final ValueChanged<String> onTogglePhotographerFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteHallIds,
    required this.favoritePhotographerIds,
    required this.onToggleHallFavorite,
    required this.onTogglePhotographerFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallsAsync = ref.watch(hallsListProvider);
    final favoriteHalls =
        hallsAsync.asData?.value
            .where((hall) => favoriteHallIds.contains(hall.id.toString()))
            .toList() ??
        const [];
    final favoritePhotographers = dummyPhotographers
        .where((p) => favoritePhotographerIds.contains(p['id']))
        .toList();

    final isLoadingHalls = hallsAsync.isLoading;
    final isEmpty =
        !isLoadingHalls && favoriteHalls.isEmpty && favoritePhotographers.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Favorites"), centerTitle: true),
      body: isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSizes.md),
                    Text(
                      "No favorites yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    Text(
                      "Tap the heart icon on a hall or photographer to save it here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                if (isLoadingHalls)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (favoriteHalls.isNotEmpty) ...[
                  const Text(
                    "Favorite Halls",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ...favoriteHalls.map((hall) {
                    return HallCard(
                      imageUrl: hall.primaryImageUrl,
                      hallName: hall.name,
                      location: hall.city,
                      pricePerDay: hall.pricePerDay,
                      capacity: hall.capacity,
                      rating: hall.averageRating,
                      reviews: hall.reviewCount,
                      isFavourite: true,
                      onFavouriteTap: () =>
                          onToggleHallFavorite(hall.id.toString()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HallDetailScreen(hallId: hall.id),
                          ),
                        );
                      },
                    );
                  }),
                ],
                if (favoritePhotographers.isNotEmpty) ...[
                  const Text(
                    "Favorite Photographers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ...favoritePhotographers.map((photographer) {
                    return PhotographerCard(
                      profileImage: photographer['profileImage'],
                      name: photographer['name'],
                      specialty: photographer['specialty'],
                      city: photographer['city'],
                      rating: photographer['rating'],
                      reviews: photographer['reviews'],
                      startingPrice: photographer['startingPrice'],
                      isFavourite: true,
                      onFavouriteTap: () =>
                          onTogglePhotographerFavorite(photographer['id']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotographerProfileScreen(
                              photographer: photographer,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
