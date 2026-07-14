import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/screens/virtual_tour/virtual_tour_screen.dart';

class VirtualTourCard extends StatelessWidget {
  final String hallName;
  final String panoramaImage;

  const VirtualTourCard({
    super.key,
    required this.hallName,
    required this.panoramaImage,
  });

  void openTour(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VirtualTourScreen(
          hallName: hallName,
          panoramaImage: panoramaImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.threesixty, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    "360° Virtual Tour",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    panoramaImage,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.threesixty,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            OutlinedButton.icon(
              onPressed: () => openTour(context),
              icon: const Icon(Icons.vrpano_outlined, size: 18),
              label: const Text("View 360° Tour"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
