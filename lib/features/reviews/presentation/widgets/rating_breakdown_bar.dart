import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class RatingBreakdownBar extends StatelessWidget {
  final int star;
  final int count;
  final int maxCount;

  const RatingBreakdownBar({
    super.key,
    required this.star,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              "$star",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.star, size: 12, color: AppColors.star),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: AppColors.chipBackground,
                valueColor: const AlwaysStoppedAnimation(AppColors.star),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          SizedBox(
            width: 32,
            child: Text(
              "$count",
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
