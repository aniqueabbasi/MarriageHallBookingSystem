import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/favorites/favorites_controller.dart';
import 'package:marriage_hall_app/controllers/halls/halls_list_controller.dart';
import 'package:marriage_hall_app/models/favorites/favorite.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';
import 'package:marriage_hall_app/widgets/halls/hall_card.dart';
import 'package:marriage_hall_app/screens/halls/hall_detail_screen.dart';
import 'package:marriage_hall_app/data/dummy/photographer_dummy_data.dart';
import 'package:marriage_hall_app/screens/photographers/photographer_profile_screen.dart';
import 'package:marriage_hall_app/widgets/photographers/photographer_card.dart';

/// Favorite halls come from `GET /api/favorites` (server truth); the
/// public halls list is only used to enrich cards with rating/capacity,
/// with the favorite's own denormalized fields as fallback for halls that
/// dropped out of the public list. Photographers remain local-only.
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
    final favoritesAsync = ref.watch(favoritesListProvider);
    final hallsAsync = ref.watch(hallsListProvider);
    final favoritePhotographers = dummyPhotographers
        .where((p) => favoritePhotographerIds.contains(p['id']))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Favorites'), centerTitle: true),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Could not load favorites: $error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.md),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(favoritesListProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (favorites) {
          final isEmpty = favorites.isEmpty && favoritePhotographers.isEmpty;

          return RefreshIndicator(
            onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
            child: isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Padding(
                        padding: EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppSizes.md),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppSizes.sm),
                            Text(
                              'Tap the heart icon on a hall or photographer '
                              'to save it here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSizes.md),
                    children: [
                      if (favorites.isNotEmpty) ...[
                        const Text(
                          'Favorite Halls',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        ...favorites.map(
                          (favorite) => _buildHallCard(
                            context,
                            favorite,
                            hallsAsync.value ?? const [],
                          ),
                        ),
                      ],
                      if (favoritePhotographers.isNotEmpty) ...[
                        const Text(
                          'Favorite Photographers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                            onFavouriteTap: () => onTogglePhotographerFavorite(
                              photographer['id'],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PhotographerProfileScreen(
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
        },
      ),
    );
  }

  Widget _buildHallCard(
    BuildContext context,
    Favorite favorite,
    List<HallSummary> halls,
  ) {
    final summary = halls
        .where((hall) => hall.id == favorite.hallId)
        .firstOrNull;

    return HallCard(
      imageUrl: summary?.primaryImageUrl ?? favorite.primaryImageUrl,
      hallName: summary?.name ?? favorite.hallName,
      location: summary?.city ?? favorite.city,
      pricePerDay: summary?.pricePerDay ?? favorite.pricePerDay,
      capacity: summary?.capacity ?? 0,
      rating: summary?.averageRating ?? 0,
      reviews: summary?.reviewCount ?? 0,
      isFavourite: true,
      onFavouriteTap: () => onToggleHallFavorite(favorite.hallId.toString()),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HallDetailScreen(hallId: favorite.hallId),
          ),
        );
      },
    );
  }
}
