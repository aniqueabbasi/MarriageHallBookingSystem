import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class PhotographerInfoSection extends StatelessWidget {
  final String name;
  final String specialty;
  final String city;
  final String experience;
  final double rating;
  final int reviews;
  final String startingPrice;

  const PhotographerInfoSection({
    super.key,
    required this.name,
    required this.specialty,
    required this.city,
    required this.experience,
    required this.rating,
    required this.reviews,
    required this.startingPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            specialty,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                "$rating",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                "($reviews reviews)",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.location_on_outlined,
                  title: "City",
                  value: city,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _InfoCard(
                  icon: Icons.workspace_premium_outlined,
                  title: "Experience",
                  value: experience,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          _InfoCard(
            icon: Icons.account_balance_wallet_outlined,
            title: "Starting Price",
            value: startingPrice,
            fullWidth: true,
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
  final bool fullWidth;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
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
      child: fullWidth
          ? Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 26),
                const SizedBox(width: AppSizes.sm),
                Text(title, style: const TextStyle(color: AppColors.textSecondary)),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 26),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
    );
  }
}
