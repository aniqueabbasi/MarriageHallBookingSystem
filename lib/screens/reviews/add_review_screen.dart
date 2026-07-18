import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/reviews/submit_review_controller.dart';
import 'package:marriage_hall_app/models/reviews/create_review_request.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

/// Review a completed booking (`POST /api/reviews`). Pops with `true`
/// after a successful submission.
class AddReviewScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final String hallName;

  const AddReviewScreen({
    super.key,
    required this.bookingId,
    required this.hallName,
  });

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  final commentController = TextEditingController();
  int selectedRating = 0;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    final review = await ref
        .read(submitReviewControllerProvider(widget.bookingId).notifier)
        .submit(
          CreateReviewRequest(
            bookingId: widget.bookingId,
            rating: selectedRating,
            comment: commentController.text.trim(),
          ),
        );

    if (!mounted) return;
    if (review != null) {
      Navigator.pop(context, true);
    } else {
      final message = ref
          .read(submitReviewControllerProvider(widget.bookingId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not submit your review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(
      submitReviewControllerProvider(widget.bookingId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Write a Review'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hallName,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Star Rating',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  onPressed: () => setState(() => selectedRating = starValue),
                  icon: Icon(
                    starValue <= selectedRating
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
              'Review (Optional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: commentController,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Share your experience with this hall...',
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            GradientButton(
              label: submitState.isLoading ? 'Submitting...' : 'Submit Review',
              icon: Icons.send_outlined,
              onPressed: submitState.isLoading ? null : submitReview,
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}
