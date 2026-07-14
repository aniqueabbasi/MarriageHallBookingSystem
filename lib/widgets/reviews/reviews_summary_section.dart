import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/data/dummy/review_dummy_data.dart';
import 'package:marriage_hall_app/screens/reviews/add_review_screen.dart';
import 'package:marriage_hall_app/widgets/reviews/rating_breakdown_bar.dart';
import 'package:marriage_hall_app/widgets/reviews/review_card.dart';

class ReviewsSummarySection extends StatelessWidget {
  final String hallName;
  final num rating;
  final int reviewsCount;
  final Map<int, int> ratingBreakdown;
  final bool canWriteReview;

  const ReviewsSummarySection({
    super.key,
    required this.hallName,
    required this.rating,
    required this.reviewsCount,
    required this.ratingBreakdown,
    this.canWriteReview = false,
  });

  Future<void> openWriteReview(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(hallName: hallName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = dummyReviews
        .where((review) => review['hallName'] == hallName)
        .toList();
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
            "Reviews & Ratings",
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
            child: Column(
              children: [
                Row(
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
                              child: Icon(Icons.star, color: AppColors.star, size: 22),
                            ),
                          ],
                        ),
                        Text(
                          "Based on $reviewsCount reviews",
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
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Customer Reviews",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              if (canWriteReview)
                TextButton.icon(
                  onPressed: () => openWriteReview(context),
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: const Text("Write a Review"),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          if (!canWriteReview)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Text(
                "You can write a review after your booking at this hall is completed.",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Text(
                "No reviews yet for this hall.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...reviews.map((review) => ReviewCard(review: review)),
        ],
      ),
    );
  }
}
