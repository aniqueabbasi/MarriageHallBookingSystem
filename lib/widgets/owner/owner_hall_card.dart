import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/shared/network_image_box.dart';

class OwnerHallCard extends StatelessWidget {
  final HallSummary hall;
  final VoidCallback onViewReviews;

  const OwnerHallCard({
    super.key,
    required this.hall,
    required this.onViewReviews,
  });

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$feature isn't available yet.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              NetworkImageBox(
                url: hall.primaryImageUrl,
                height: 160,
                width: double.infinity,
              ),
              if (!hall.isActive)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Text(
                      "Inactive",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hall.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hall.city,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.groups_outlined,
                        label: "Up to ${hall.capacity} Guests",
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.payments_outlined,
                        label: formatPkr(hall.pricePerDay),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.star),
                    const SizedBox(width: 4),
                    Text(
                      hall.averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "(${hall.reviewCount} reviews)",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showComingSoon(context, "Editing"),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("Edit"),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewReviews,
                        icon: const Icon(Icons.reviews_outlined, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("View Reviews"),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          foregroundColor: AppColors.secondary,
                          side: const BorderSide(color: AppColors.secondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    OutlinedButton(
                      onPressed: () => _showComingSoon(context, "Deleting"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Icon(Icons.delete_outline, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
