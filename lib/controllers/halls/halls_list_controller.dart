import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/controllers/halls/home_filter_controller.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';

final hallsListProvider = FutureProvider<List<HallSummary>>(
  (ref) => ref.watch(hallsClientProvider).list(),
);

final filteredHallsProvider = Provider<AsyncValue<List<HallSummary>>>((ref) {
  final filter = ref.watch(homeFilterControllerProvider);
  final hallsAsync = ref.watch(hallsListProvider);
  final query = filter.searchQuery.toLowerCase();

  return hallsAsync.whenData((halls) {
    return halls.where((hall) {
      if (!hall.isActive) return false;

      final matchesCity =
          filter.selectedCity == AppStrings.all ||
          hall.city == filter.selectedCity;

      final matchesSearch = hall.name.toLowerCase().contains(query);

      return matchesCity && matchesSearch;
    }).toList();
  });
});
