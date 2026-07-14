import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/controllers/reviews/add_review_controller.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  final String hallName;

  const AddReviewScreen({super.key, required this.hallName});

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  final reviewTextController = TextEditingController();

  static const _placeholderImages = [
    'assets/images/hall1.jpg',
    'assets/images/hall2.jpg',
    'assets/images/hall3.jpg',
  ];

  @override
  void dispose() {
    reviewTextController.dispose();
    super.dispose();
  }

  void addImage() {
    final provider = addReviewControllerProvider(widget.hallName);
    final uploadedImages = ref.read(provider).uploadedImages;

    final next = _placeholderImages.firstWhere(
      (path) => !uploadedImages.contains(path),
      orElse: () => '',
    );

    if (next.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image picker isn't wired up in this UI-only build."),
        ),
      );
      return;
    }

    ref.read(provider.notifier).addImage(next);
  }

  void submitReview() {
    final selectedRating = ref
        .read(addReviewControllerProvider(widget.hallName))
        .selectedRating;

    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a star rating")),
      );
      return;
    }

    if (reviewTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a review before submitting")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Review submitted! (UI only — not saved anywhere yet)"),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = addReviewControllerProvider(widget.hallName);
    final reviewState = ref.watch(provider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Write a Review"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hallName,
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              "Star Rating",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  onPressed: () =>
                      ref.read(provider.notifier).setRating(starValue),
                  icon: Icon(
                    starValue <= reviewState.selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    color: AppColors.star,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              "Review Text",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: reviewTextController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Share your experience with this hall...",
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              "Upload Images (Optional)",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...reviewState.uploadedImages.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSizes.sm),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            child: Image.asset(
                              entry.value,
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  ref.read(provider.notifier).removeImageAt(entry.key),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: addImage,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            GradientButton(
              label: "Submit Review",
              icon: Icons.send_outlined,
              onPressed: submitReview,
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}
