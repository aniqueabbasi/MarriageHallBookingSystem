import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class HallInfoSection extends StatelessWidget {
  final String hallName;
  final String location;
  final double rating;
  final int reviews;
  final String capacity;
  final String price;

  const HallInfoSection({
    super.key,
    required this.hallName,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.capacity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Hall Name
          Text(hallName, style: Theme.of(context).textTheme.headlineMedium),

          const SizedBox(height: 8),

          /// Location
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Rating
          Row(
            children: [
              const Icon(Icons.star_border, color: Colors.amber),
              const SizedBox(width: 5),
              Text(
                "$rating",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "($reviews reviews)",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Capacity & Price Cards
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.groups_outlined,
                  title: "Capacity",
                  value: capacity,
                ),
              ),

              const SizedBox(width: AppSizes.md),

              Expanded(
                child: _InfoCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Starting",
                  value: price,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),

          const SizedBox(height: 12),

          Text(title, style: const TextStyle(color: AppColors.textSecondary)),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
