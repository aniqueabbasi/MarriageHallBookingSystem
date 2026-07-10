import 'package:flutter/material.dart';
import 'package:marriage_hall_app/hall_detail/screens/hall_detail_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/hall_status.dart';
import '../../../photographers/data/photographer_dummy_data.dart';
import '../../../photographers/presentation/screens/photographer_profile_screen.dart';
import '../../../photographers/presentation/widgets/photographer_card.dart';
import '../../data/datasource/hall_dummy_data.dart';
import '../widgets/category_toggle.dart';
import '../widgets/city_filter_sheet.dart';
import '../widgets/hall_card.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();

  String selectedCity = AppStrings.all;
  String selectedCategory = AppStrings.hallCategory;

  List<Map<String, dynamic>> filteredHalls = [];
  List<Map<String, dynamic>> filteredPhotographers = [];

  final cities = const [
    AppStrings.all,
    AppStrings.lahore,
    AppStrings.karachi,
    AppStrings.islamabad,
    'Rawalpindi',
  ];

  @override
  void initState() {
    super.initState();
    filterResults();
  }

  void filterResults() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredHalls = dummyHalls.where((hall) {
        final isApproved = hall['status'] == HallStatus.approved;

        final matchesCity =
            selectedCity == AppStrings.all || hall['city'] == selectedCity;

        final matchesSearch =
            hall['hallName'].toLowerCase().contains(query) ||
            hall['location'].toLowerCase().contains(query);

        return isApproved && matchesCity && matchesSearch;
      }).toList();

      filteredPhotographers = dummyPhotographers.where((photographer) {
        final matchesCity =
            selectedCity == AppStrings.all ||
            photographer['city'] == selectedCity;

        final matchesSearch =
            photographer['name'].toLowerCase().contains(query) ||
            photographer['specialty'].toLowerCase().contains(query);

        return matchesCity && matchesSearch;
      }).toList();
    });
  }

  Future<void> openCityFilter() async {
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
      selectedCity = result;
      filterResults();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHallCategory = selectedCategory == AppStrings.hallCategory;

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
                    isFilterActive: selectedCity != AppStrings.all,
                    onChanged: (value) {
                      filterResults();
                    },
                    onFilterTap: openCityFilter,
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
                    selectedCategory: selectedCategory,
                    onChanged: (category) {
                      setState(() => selectedCategory = category);
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
                        ? _buildHallList()
                        : _buildPhotographerList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHallList() {
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
                builder: (context) => HallDetailScreen(
                  hall: hall,
                  isFavourite: isFavourite,
                  onFavouriteToggle: () =>
                      widget.onToggleHallFavorite(hall['id']),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPhotographerList() {
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
                builder: (context) => PhotographerProfileScreen(
                  photographer: photographer,
                  isFavourite: isFavourite,
                  onFavouriteToggle: () => widget.onTogglePhotographerFavorite(
                    photographer['id'],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
