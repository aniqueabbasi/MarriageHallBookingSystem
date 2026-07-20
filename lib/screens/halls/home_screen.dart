import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_hall_app/screens/halls/hall_detail_screen.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';
import 'package:marriage_hall_app/screens/photographers/photographer_profile_screen.dart';
import 'package:marriage_hall_app/widgets/photographers/photographer_card.dart';
import 'package:marriage_hall_app/controllers/halls/halls_list_controller.dart';
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
    final filteredHallsAsync = ref.watch(filteredHallsProvider);
    final filteredPhotographers = ref.watch(filteredPhotographersProvider);
    final isHallCategory = filter.selectedCategory == AppStrings.hallCategory;

    // A single CustomScrollView so the gradient header scrolls away with
    // the rest of the page instead of staying pinned while only the list
    // beneath it scrolls in its own Expanded region.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, filter, isHallCategory),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              0,
            ),
            sliver: SliverToBoxAdapter(
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
                ],
              ),
            ),
          ),
          ...isHallCategory
              ? _hallSlivers(filteredHallsAsync)
              : _photographerSlivers(filteredPhotographers),
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    HomeFilterState filter,
    bool isHallCategory,
  ) {
    return Container(
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
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: Colors.white),
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
    );
  }

  List<Widget> _hallSlivers(AsyncValue<List<HallSummary>> filteredHallsAsync) {
    return filteredHallsAsync.when(
      loading: () => const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (error, stack) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Could not load halls: $error')),
        ),
      ],
      data: (filteredHalls) {
        if (filteredHalls.isEmpty) {
          return const [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No halls found')),
            ),
          ];
        }

        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final hall = filteredHalls[index];
                final hallIdString = hall.id.toString();
                final isFavourite = widget.favoriteHallIds.contains(
                  hallIdString,
                );

                return HallCard(
                  imageUrl: hall.primaryImageUrl,
                  hallName: hall.name,
                  location: hall.city,
                  pricePerDay: hall.pricePerDay,
                  capacity: hall.capacity,
                  rating: hall.averageRating,
                  reviews: hall.reviewCount,
                  isFavourite: isFavourite,
                  onFavouriteTap: () =>
                      widget.onToggleHallFavorite(hallIdString),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HallDetailScreen(hallId: hall.id),
                      ),
                    );
                  },
                );
              }, childCount: filteredHalls.length),
            ),
          ),
        ];
      },
    );
  }

  List<Widget> _photographerSlivers(
    List<Map<String, dynamic>> filteredPhotographers,
  ) {
    if (filteredPhotographers.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('No photographers found')),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final photographer = filteredPhotographers[index];
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
          }, childCount: filteredPhotographers.length),
        ),
      ),
    ];
  }
}
