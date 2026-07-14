import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/owner/dashboard_stat_card.dart';
import 'package:marriage_hall_app/widgets/owner/quick_action_button.dart';

class DashboardHomeTab extends StatelessWidget {
  final int totalHalls;
  final VoidCallback onAddHall;
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onOpenReviews;

  const DashboardHomeTab({
    super.key,
    required this.totalHalls,
    required this.onAddHall,
    required this.onNavigateToTab,
    required this.onOpenReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.md,
            AppSizes.md,
            AppSizes.xl,
          ),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppSizes.radiusXxl),
              bottomRight: Radius.circular(AppSizes.radiusXxl),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back 👋",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Owner Dashboard",
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: const Icon(Icons.storefront, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSizes.md,
                  crossAxisSpacing: AppSizes.md,
                  childAspectRatio: 1.3,
                  children: [
                    DashboardStatCard(
                      icon: Icons.storefront,
                      label: "Total Halls",
                      value: "$totalHalls",
                      color: AppColors.primary,
                    ),
                    const DashboardStatCard(
                      icon: Icons.event_available,
                      label: "Total Bookings",
                      value: "128",
                      color: AppColors.success,
                    ),
                    const DashboardStatCard(
                      icon: Icons.calendar_month,
                      label: "Upcoming Events",
                      value: "6",
                      color: AppColors.secondary,
                    ),
                    const DashboardStatCard(
                      icon: Icons.payments,
                      label: "Revenue",
                      value: "PKR 2.4M",
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  "Quick Actions",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSizes.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      QuickActionButton(
                        icon: Icons.add_business_outlined,
                        label: "Add Hall",
                        onTap: onAddHall,
                      ),
                      QuickActionButton(
                        icon: Icons.storefront_outlined,
                        label: "My Halls",
                        onTap: () => onNavigateToTab(1),
                      ),
                      QuickActionButton(
                        icon: Icons.event_note_outlined,
                        label: "Bookings",
                        onTap: () => onNavigateToTab(2),
                      ),
                      QuickActionButton(
                        icon: Icons.person_outline,
                        label: "Profile",
                        onTap: () => onNavigateToTab(3),
                      ),
                      QuickActionButton(
                        icon: Icons.reviews_outlined,
                        label: "Reviews",
                        onTap: onOpenReviews,
                      ),
                      const SizedBox(width: AppSizes.sm),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  "Recent Bookings",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSizes.md),
                ...List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.sm),
                    padding: const EdgeInsets.all(AppSizes.sm),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.chipBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Booking #${1000 + index}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Grand Palace Marriage Hall",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusLg,
                            ),
                          ),
                          child: const Text(
                            "Confirmed",
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
