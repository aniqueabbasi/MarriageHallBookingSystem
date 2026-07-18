import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/controllers/halls/delete_hall_controller.dart';
import 'package:marriage_hall_app/controllers/halls/hall_detail_controller.dart';
import 'package:marriage_hall_app/controllers/halls/my_halls_controller.dart';
import 'package:marriage_hall_app/controllers/halls/update_hall_controller.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';
import 'package:marriage_hall_app/models/halls/update_hall_request.dart';
import 'package:marriage_hall_app/screens/owner/add_edit_hall_screen.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/shared/network_image_box.dart';

class OwnerHallCard extends ConsumerWidget {
  final HallSummary hall;
  final VoidCallback onViewReviews;

  const OwnerHallCard({
    super.key,
    required this.hall,
    required this.onViewReviews,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Hall"),
        content: Text(
          'Permanently delete "${hall.name}"? This deletes the hall '
          "entirely and cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final result = await ref
        .read(deleteHallControllerProvider(hall.id).notifier)
        .submit(hall.id);

    if (!context.mounted) return;

    switch (result.status) {
      case DeleteHallStatus.success:
        ref.invalidate(myHallsProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Hall deleted.")));
        break;

      case DeleteHallStatus.conflict:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ??
                  "This hall has bookings and can't be deleted.",
            ),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: "Deactivate instead",
              onPressed: () => _deactivateInstead(context, ref),
            ),
          ),
        );
        break;

      case DeleteHallStatus.error:
        if (result.statusCode == 404) {
          ref.invalidate(myHallsProvider);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? "Could not delete hall")),
        );
        break;

      case DeleteHallStatus.idle:
      case DeleteHallStatus.loading:
        break;
    }
  }

  Future<void> _deactivateInstead(BuildContext context, WidgetRef ref) async {
    final hallId = hall.id;

    try {
      final current = await ref.read(hallsClientProvider).detail(hallId);

      final updated = await ref
          .read(updateHallControllerProvider(hallId).notifier)
          .submit(
            hallId,
            UpdateHallRequest(
              name: current.name,
              description: current.description,
              address: current.address,
              city: current.city,
              capacity: current.capacity,
              pricePerDay: current.pricePerDay,
              isActive: false,
              foodPackages: current.foodPackages
                  .map((p) => p.toCreateRequest())
                  .toList(),
              extraServices: current.extraServices
                  .map((s) => s.toCreateRequest())
                  .toList(),
            ),
          );

      if (!context.mounted) return;

      if (updated == null) {
        final message = ref
            .read(updateHallControllerProvider(hallId))
            .errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? "Could not deactivate hall")),
        );
        return;
      }

      ref.invalidate(myHallsProvider);
      ref.invalidate(hallDetailProvider(hallId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hall deactivated.")));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not deactivate hall")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting = ref.watch(
      deleteHallControllerProvider(hall.id).select((s) => s.isLoading),
    );
    // Watched (not just read) so the autoDispose provider survives the
    // async PUT triggered by "Deactivate instead" — without a live
    // listener here, Riverpod tears it down mid-flight since nothing else
    // on this screen watches it, and the notifier throws after the
    // request has already reached the server.
    final isDeactivating = ref.watch(
      updateHallControllerProvider(hall.id).select((s) => s.isLoading),
    );
    final isBusy = isDeleting || isDeactivating;

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
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditHallScreen(hallId: hall.id),
                          ),
                        ),
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
                      onPressed: isBusy
                          ? null
                          : () => _confirmDelete(context, ref),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(Icons.delete_outline, size: 18),
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
