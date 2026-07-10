import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../halls/data/datasource/hall_dummy_data.dart';
import '../../../halls/presentation/widgets/hall_card.dart';
import '../../../../hall_detail/screens/hall_detail_screen.dart';
import '../../../photographers/data/photographer_dummy_data.dart';
import '../../../photographers/presentation/screens/photographer_profile_screen.dart';
import '../../../photographers/presentation/widgets/photographer_card.dart';

class FavoritesScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final favoriteHalls = dummyHalls
        .where((hall) => favoriteHallIds.contains(hall['id']))
        .toList();
    final favoritePhotographers = dummyPhotographers
        .where((p) => favoritePhotographerIds.contains(p['id']))
        .toList();

    final isEmpty = favoriteHalls.isEmpty && favoritePhotographers.isEmpty;

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
                if (favoriteHalls.isNotEmpty) ...[
                  const Text(
                    "Favorite Halls",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ...favoriteHalls.map((hall) {
                    return HallCard(
                      imagePath: hall['imagePath'],
                      hallName: hall['hallName'],
                      location: hall['location'],
                      price: hall['price'],
                      capacity: hall['capacity'],
                      rating: hall['rating'],
                      reviews: hall['reviews'],
                      isFavourite: true,
                      onFavouriteTap: () => onToggleHallFavorite(hall['id']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HallDetailScreen(
                              hall: hall,
                              isFavourite: favoriteHallIds.contains(hall['id']),
                              onFavouriteToggle: () =>
                                  onToggleHallFavorite(hall['id']),
                            ),
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
                              isFavourite: favoritePhotographerIds.contains(
                                photographer['id'],
                              ),
                              onFavouriteToggle: () =>
                                  onTogglePhotographerFavorite(
                                    photographer['id'],
                                  ),
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
