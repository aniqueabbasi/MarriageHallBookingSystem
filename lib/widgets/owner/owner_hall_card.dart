import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/constants/hall_status.dart';

class OwnerHallCard extends StatelessWidget {
  final Map<String, dynamic> hall;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewReviews;

  const OwnerHallCard({
    super.key,
    required this.hall,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onViewReviews,
  });

  @override
  Widget build(BuildContext context) {
    final String status = hall['status'] ?? HallStatus.pending;
    final bool isRejected = status == HallStatus.rejected;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.lg),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  hall['imagePath'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.hallStatusColor,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Text(
                      status.hallStatusLabel,
                      style: const TextStyle(
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
                    hall['hallName'],
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
                        hall['city'],
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
                          label: hall['capacity'],
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.payments_outlined,
                          label: hall['price'],
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
                        ((hall['rating'] as num?) ?? 0).toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${hall['reviews'] ?? 0} reviews)",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (isRejected && (hall['rejectionReason'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSizes.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hall['rejectionReason'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(isRejected ? "Edit & Resubmit" : "Edit"),
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
                        onPressed: onDelete,
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
