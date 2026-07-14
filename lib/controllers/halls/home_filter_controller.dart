import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_strings.dart';
import 'package:marriage_hall_app/constants/hall_status.dart';
import 'package:marriage_hall_app/data/dummy/photographer_dummy_data.dart';
import 'package:marriage_hall_app/data/dummy/hall_dummy_data.dart';

class HomeFilterState {
  final String selectedCity;
  final String selectedCategory;
  final String searchQuery;

  const HomeFilterState({
    this.selectedCity = AppStrings.all,
    this.selectedCategory = AppStrings.hallCategory,
    this.searchQuery = '',
  });

  HomeFilterState copyWith({
    String? selectedCity,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return HomeFilterState(
      selectedCity: selectedCity ?? this.selectedCity,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HomeFilterController extends Notifier<HomeFilterState> {
  @override
  HomeFilterState build() => const HomeFilterState();

  void setCity(String city) => state = state.copyWith(selectedCity: city);

  void setCategory(String category) =>
      state = state.copyWith(selectedCategory: category);

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
}

final homeFilterControllerProvider =
    NotifierProvider<HomeFilterController, HomeFilterState>(
      HomeFilterController.new,
    );

final filteredHallsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final filter = ref.watch(homeFilterControllerProvider);
  final query = filter.searchQuery.toLowerCase();

  return dummyHalls.where((hall) {
    final isApproved = hall['status'] == HallStatus.approved;

    final matchesCity =
        filter.selectedCity == AppStrings.all ||
        hall['city'] == filter.selectedCity;

    final matchesSearch =
        hall['hallName'].toLowerCase().contains(query) ||
        hall['location'].toLowerCase().contains(query);

    return isApproved && matchesCity && matchesSearch;
  }).toList();
});

final filteredPhotographersProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  final filter = ref.watch(homeFilterControllerProvider);
  final query = filter.searchQuery.toLowerCase();

  return dummyPhotographers.where((photographer) {
    final matchesCity =
        filter.selectedCity == AppStrings.all ||
        photographer['city'] == filter.selectedCity;

    final matchesSearch =
        photographer['name'].toLowerCase().contains(query) ||
        photographer['specialty'].toLowerCase().contains(query);

    return matchesCity && matchesSearch;
  }).toList();
});
