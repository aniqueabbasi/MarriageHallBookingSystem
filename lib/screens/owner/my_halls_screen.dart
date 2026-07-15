import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';
import 'package:marriage_hall_app/screens/reviews/owner_reviews_screen.dart';
import 'package:marriage_hall_app/widgets/owner/owner_hall_card.dart';

class MyHallsScreen extends StatelessWidget {
  final AsyncValue<List<HallSummary>> hallsAsync;
  final VoidCallback onAddHall;
  final Future<void> Function() onRefresh;

  const MyHallsScreen({
    super.key,
    required this.hallsAsync,
    required this.onAddHall,
    required this.onRefresh,
  });

  void openReviews(BuildContext context, HallSummary hall) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OwnerReviewsScreen(initialHallFilter: hall.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Halls"), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddHall,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Hall",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: hallsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  "Could not load your halls: ${error.toString()}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.md),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                ),
              ],
            ),
          ),
        ),
        data: (halls) {
          if (halls.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) => RefreshIndicator(
                onRefresh: onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.storefront_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppSizes.md),
                            const Text(
                              "No halls yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            const Text(
                              "You haven't added any halls yet.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSizes.lg),
                            ElevatedButton.icon(
                              onPressed: onAddHall,
                              icon: const Icon(Icons.add),
                              label: const Text("Create your first hall"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                96,
              ),
              itemCount: halls.length,
              itemBuilder: (context, index) {
                final hall = halls[index];
                return OwnerHallCard(
                  hall: hall,
                  onViewReviews: () => openReviews(context, hall),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
