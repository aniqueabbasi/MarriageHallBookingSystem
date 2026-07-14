import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_hall_app/screens/halls/hall_detail_screen.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/screens/photographers/photographer_profile_screen.dart';
import 'package:marriage_hall_app/widgets/photographers/photographer_card.dart';
import 'package:marriage_hall_app/controllers/halls/home_filter_controller.dart';
import 'package:marriage_hall_app/widgets/halls/category_toggle.dart';
import 'package:marriage_hall_app/widgets/halls/city_filter_sheet.dart';
import 'package:marriage_hall_app/widgets/halls/hall_card.dart';
import 'package:marriage_hall_app/widgets/halls/search_bar_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Set<String> favoriteHallIds;
  final Set<String> favoritePhotographerIds;
  final ValueChanged<String> onToggleHallFavorite;
  final ValueChanged<String> onTogglePhotographerFavorite;

  const HomeScreen({
    super.key,
    required this.favoriteHallIds,
    required this.favoritePhotographerIds,
    required this.onToggleHallFavorite,
    required this.onTogglePhotographerFavorite,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final searchController = TextEditingController();

  static const cities = [
    AppStrings.all,
    AppStrings.lahore,
    AppStrings.karachi,
    AppStrings.islamabad,
    'Rawalpindi',
  ];

  Future<void> openCityFilter(String selectedCity) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          CityFilterSheet(selectedCity: selectedCity, cities: cities),
    );

    if (result != null) {
      ref.read(homeFilterControllerProvider.notifier).setCity(result);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(homeFilterControllerProvider);
    final filteredHalls = ref.watch(filteredHallsProvider);
    final filteredPhotographers = ref.watch(filteredPhotographersProvider);
    final isHallCategory = filter.selectedCategory == AppStrings.hallCategory;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              AppSizes.xl,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.radiusXxl),
                bottomRight: Radius.circular(AppSizes.radiusXxl),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Find your perfect venue",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  SearchBarWidget(
                    controller: searchController,
                    hintText: isHallCategory
                        ? AppStrings.searchHint
                        : AppStrings.searchHintPhotographer,
                    isFilterActive: filter.selectedCity != AppStrings.all,
                    onChanged: (value) {
                      ref
                          .read(homeFilterControllerProvider.notifier)
                          .setSearchQuery(value);
                    },
                    onFilterTap: () => openCityFilter(filter.selectedCity),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryToggle(
                    selectedCategory: filter.selectedCategory,
                    onChanged: (category) {
                      ref
                          .read(homeFilterControllerProvider.notifier)
                          .setCategory(category);
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    isHallCategory
                        ? AppStrings.featuredHalls
                        : AppStrings.featuredPhotographers,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Expanded(
                    child: isHallCategory
                        ? _buildHallList(filteredHalls)
                        : _buildPhotographerList(filteredPhotographers),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHallList(List<Map<String, dynamic>> filteredHalls) {
    if (filteredHalls.isEmpty) {
      return const Center(child: Text('No halls found'));
    }

    return ListView(
      children: filteredHalls.map((hall) {
        final isFavourite = widget.favoriteHallIds.contains(hall['id']);

        return HallCard(
          imagePath: hall['imagePath'],
          hallName: hall['hallName'],
          location: hall['location'],
          price: hall['price'],
          capacity: hall['capacity'],
          rating: hall['rating'],
          reviews: hall['reviews'],
          isFavourite: isFavourite,
          onFavouriteTap: () => widget.onToggleHallFavorite(hall['id']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HallDetailScreen(hall: hall),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPhotographerList(
    List<Map<String, dynamic>> filteredPhotographers,
  ) {
    if (filteredPhotographers.isEmpty) {
      return const Center(child: Text('No photographers found'));
    }

    return ListView(
      children: filteredPhotographers.map((photographer) {
        final isFavourite = widget.favoritePhotographerIds.contains(
          photographer['id'],
        );

        return PhotographerCard(
          profileImage: photographer['profileImage'],
          name: photographer['name'],
          specialty: photographer['specialty'],
          city: photographer['city'],
          rating: photographer['rating'],
          reviews: photographer['reviews'],
          startingPrice: photographer['startingPrice'],
          isFavourite: isFavourite,
          onFavouriteTap: () =>
              widget.onTogglePhotographerFavorite(photographer['id']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PhotographerProfileScreen(photographer: photographer),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
