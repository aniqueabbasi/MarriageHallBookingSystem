import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/gradient_button.dart';

class AddReviewScreen extends StatefulWidget {
  final String hallName;

  const AddReviewScreen({super.key, required this.hallName});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int selectedRating = 0;
  final reviewTextController = TextEditingController();
  final List<String> uploadedImages = [];

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

    setState(() => uploadedImages.add(next));
  }

  void submitReview() {
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
                  onPressed: () => setState(() => selectedRating = starValue),
                  icon: Icon(
                    starValue <= selectedRating ? Icons.star : Icons.star_border,
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
                  ...uploadedImages.asMap().entries.map((entry) {
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
                              onTap: () => setState(
                                () => uploadedImages.removeAt(entry.key),
                              ),
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
