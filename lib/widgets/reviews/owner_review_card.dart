import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/reviews/star_rating_display.dart';

class OwnerReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const OwnerReviewCard({super.key, required this.review});

  String get _formattedDate {
    final date = DateTime.tryParse(review['date'] ?? '');
    if (date == null) return review['date'] ?? '';
    return DateFormat("dd MMM yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.villa_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  review['hallName'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formattedDate,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Divider(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  review['customerName'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              StarRatingDisplay(rating: review['rating'] as num, size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review['reviewText'] as String,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
