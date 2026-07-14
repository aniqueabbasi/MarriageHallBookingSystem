import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/data/dummy/owner_hall_dummy_data.dart';
import 'package:marriage_hall_app/data/dummy/review_dummy_data.dart';
import 'package:marriage_hall_app/controllers/reviews/reviews_filter_controller.dart';
import 'package:marriage_hall_app/widgets/reviews/owner_review_card.dart';

class OwnerReviewsScreen extends ConsumerWidget {
  final String? initialHallFilter;

  const OwnerReviewsScreen({super.key, this.initialHallFilter});

  List<String> get _ownerHallNames =>
      dummyOwnerHalls.map((hall) => hall['hallName'] as String).toList();

  List<Map<String, dynamic>> _filteredReviews(ReviewsFilterState filter) {
    return dummyReviews.where((review) {
      final hallName = review['hallName'];
      final isOwnerHall = _ownerHallNames.contains(hallName);
      final matchesHall =
          filter.selectedHall == allHallsFilter ||
          hallName == filter.selectedHall;
      final matchesRating =
          filter.selectedRating == 0 ||
          review['rating'] == filter.selectedRating;
      return isOwnerHall && matchesHall && matchesRating;
    }).toList();
  }

  double _summaryRating(ReviewsFilterState filter) {
    if (filter.selectedHall != allHallsFilter) {
      final hall = dummyOwnerHalls.firstWhere(
        (h) => h['hallName'] == filter.selectedHall,
        orElse: () => const {},
      );
      return ((hall['rating'] as num?) ?? 0).toDouble();
    }

    final totalReviews = dummyOwnerHalls.fold<int>(
      0,
      (sum, hall) => sum + ((hall['reviews'] as int?) ?? 0),
    );
    if (totalReviews == 0) return 0;

    final weightedSum = dummyOwnerHalls.fold<double>(
      0,
      (sum, hall) =>
          sum +
          ((hall['rating'] as num?) ?? 0) * ((hall['reviews'] as int?) ?? 0),
    );
    return weightedSum / totalReviews;
  }

  int _summaryReviewCount(ReviewsFilterState filter) {
    if (filter.selectedHall != allHallsFilter) {
      final hall = dummyOwnerHalls.firstWhere(
        (h) => h['hallName'] == filter.selectedHall,
        orElse: () => const {},
      );
      return (hall['reviews'] as int?) ?? 0;
    }

    return dummyOwnerHalls.fold<int>(
      0,
      (sum, hall) => sum + ((hall['reviews'] as int?) ?? 0),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterProvider = reviewsFilterControllerProvider(initialHallFilter);
    final filter = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);
    final reviews = _filteredReviews(filter);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Reviews & Ratings"), centerTitle: true),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppSizes.md),
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  _summaryRating(filter).toStringAsFixed(1),
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.star, color: AppColors.star, size: 22),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    filter.selectedHall == allHallsFilter
                        ? "Average across all your halls\n${_summaryReviewCount(filter)} total reviews"
                        : "${filter.selectedHall}\n${_summaryReviewCount(filter)} total reviews",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filter by Hall", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSizes.sm),
                DropdownButtonFormField<String>(
                  initialValue: filter.selectedHall,
                  decoration: const InputDecoration(isDense: true),
                  items: [allHallsFilter, ..._ownerHallNames]
                      .map(
                        (name) => DropdownMenuItem(value: name, child: Text(name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) filterNotifier.setSelectedHall(value);
                  },
                ),
                const SizedBox(height: AppSizes.md),
                const Text("Filter by Rating", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  children: [0, 5, 4, 3, 2, 1].map((star) {
                    final isSelected = filter.selectedRating == star;
                    return ChoiceChip(
                      label: Text(star == 0 ? "All" : "$star ★"),
                      selected: isSelected,
                      onSelected: (_) => filterNotifier.setSelectedRating(star),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Expanded(
            child: reviews.isEmpty
                ? const Center(child: Text("No reviews match your filters"))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      0,
                      AppSizes.md,
                      AppSizes.md,
                    ),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      return OwnerReviewCard(review: reviews[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
