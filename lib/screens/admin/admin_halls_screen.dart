import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/admin/admin_halls_controller.dart';
import 'package:marriage_hall_app/utils/api_error_text.dart';
import 'package:marriage_hall_app/widgets/halls/hall_card.dart';
import 'package:marriage_hall_app/widgets/shared/status_chip.dart';

const _hallFilters = ['All', 'Active', 'Inactive'];

/// Halls tab: every hall on the platform, inactive ones included and
/// clearly badged (never hidden).
class AdminHallsScreen extends ConsumerStatefulWidget {
  const AdminHallsScreen({super.key});

  @override
  ConsumerState<AdminHallsScreen> createState() => _AdminHallsScreenState();
}

class _AdminHallsScreenState extends ConsumerState<AdminHallsScreen> {
  String selectedFilter = 'All';

  Future<void> refresh() async {
    ref.invalidate(adminHallsProvider);
    await ref.read(adminHallsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final hallsAsync = ref.watch(adminHallsProvider);

    return hallsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(friendlyErrorMessage(error), textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.md),
              OutlinedButton(onPressed: refresh, child: const Text('Retry')),
            ],
          ),
        ),
      ),
      data: (halls) {
        final filtered = switch (selectedFilter) {
          'Active' => halls.where((h) => h.isActive).toList(),
          'Inactive' => halls.where((h) => !h.isActive).toList(),
          _ => halls,
        };

        return Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                children: [
                  for (final filter in _hallFilters)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.sm),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selectedFilter == filter,
                        onSelected: (_) =>
                            setState(() => selectedFilter = filter),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: refresh,
                child: filtered.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              halls.isEmpty
                                  ? 'No halls found.'
                                  : 'No ${selectedFilter.toLowerCase()} halls.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.md),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final hall = filtered[index];
                          final card = HallCard(
                            imageUrl: hall.primaryImageUrl,
                            hallName: hall.name,
                            location: hall.city,
                            pricePerDay: hall.pricePerDay,
                            capacity: hall.capacity,
                            rating: hall.averageRating,
                            reviews: hall.reviewCount,
                          );
                          if (hall.isActive) return card;
                          return Stack(
                            children: [
                              card,
                              const Positioned(
                                top: 12,
                                left: 12,
                                child: StatusChip(
                                  label: 'Inactive',
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
