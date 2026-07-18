import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/reviews/hall_reviews_controller.dart';
import 'package:marriage_hall_app/widgets/reviews/rating_breakdown_bar.dart';
import 'package:marriage_hall_app/widgets/reviews/review_card.dart';

/// Reviews block on the hall detail page. The aggregate numbers come from
/// the hall itself (`GET /api/halls/{id}`); the actual review list and the
/// star breakdown come from `GET /api/reviews/hall/{hallId}`.
class ReviewsSummarySection extends ConsumerWidget {
  final int hallId;
  final num rating;
  final int reviewsCount;

  const ReviewsSummarySection({
    super.key,
    required this.hallId,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(hallReviewsProvider(hallId));
    final reviews = reviewsAsync.value ?? const [];

    final ratingBreakdown = <int, int>{};
    for (final review in reviews) {
      ratingBreakdown[review.rating] =
          (ratingBreakdown[review.rating] ?? 0) + 1;
    }
    final maxCount = ratingBreakdown.values.isEmpty
        ? 0
        : ratingBreakdown.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews & Ratings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            width: double.infinity,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 4),
                          child: Icon(
                            Icons.star,
                            color: AppColors.star,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Based on $reviewsCount reviews',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.lg),
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      return RatingBreakdownBar(
                        star: star,
                        count: ratingBreakdown[star] ?? 0,
                        maxCount: maxCount,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'Customer Reviews',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSizes.sm),
          const Padding(
            padding: EdgeInsets.only(bottom: AppSizes.sm),
            child: Text(
              'You can write a review from My Bookings once your booking at '
              'this hall is completed.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          reviewsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Text(
                'Could not load reviews: $error',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            data: (reviews) => reviews.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                    child: Text(
                      'No reviews yet for this hall.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : Column(
                    children: [
                      for (final review in reviews)
                        ReviewCard(review: review),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
