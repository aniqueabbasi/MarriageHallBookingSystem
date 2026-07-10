import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../owner/data/owner_hall_dummy_data.dart';
import '../../data/review_dummy_data.dart';
import '../widgets/owner_review_card.dart';

const String _allHallsFilter = 'All Halls';

class OwnerReviewsScreen extends StatefulWidget {
  final String? initialHallFilter;

  const OwnerReviewsScreen({super.key, this.initialHallFilter});

  @override
  State<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends State<OwnerReviewsScreen> {
  late String selectedHall = widget.initialHallFilter ?? _allHallsFilter;
  int selectedRating = 0;

  List<String> get _ownerHallNames =>
      dummyOwnerHalls.map((hall) => hall['hallName'] as String).toList();

  List<Map<String, dynamic>> get _filteredReviews {
    return dummyReviews.where((review) {
      final hallName = review['hallName'];
      final isOwnerHall = _ownerHallNames.contains(hallName);
      final matchesHall = selectedHall == _allHallsFilter || hallName == selectedHall;
      final matchesRating = selectedRating == 0 || review['rating'] == selectedRating;
      return isOwnerHall && matchesHall && matchesRating;
    }).toList();
  }

  double get _summaryRating {
    if (selectedHall != _allHallsFilter) {
      final hall = dummyOwnerHalls.firstWhere(
        (h) => h['hallName'] == selectedHall,
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
          sum + ((hall['rating'] as num?) ?? 0) * ((hall['reviews'] as int?) ?? 0),
    );
    return weightedSum / totalReviews;
  }

  int get _summaryReviewCount {
    if (selectedHall != _allHallsFilter) {
      final hall = dummyOwnerHalls.firstWhere(
        (h) => h['hallName'] == selectedHall,
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
  Widget build(BuildContext context) {
    final reviews = _filteredReviews;

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
                  _summaryRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.star, color: AppColors.star, size: 22),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    selectedHall == _allHallsFilter
                        ? "Average across all your halls\n$_summaryReviewCount total reviews"
                        : "$selectedHall\n$_summaryReviewCount total reviews",
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
                  initialValue: selectedHall,
                  decoration: const InputDecoration(isDense: true),
                  items: [_allHallsFilter, ..._ownerHallNames]
                      .map(
                        (name) => DropdownMenuItem(value: name, child: Text(name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedHall = value);
                  },
                ),
                const SizedBox(height: AppSizes.md),
                const Text("Filter by Rating", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  children: [0, 5, 4, 3, 2, 1].map((star) {
                    final isSelected = selectedRating == star;
                    return ChoiceChip(
                      label: Text(star == 0 ? "All" : "$star ★"),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedRating = star),
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
