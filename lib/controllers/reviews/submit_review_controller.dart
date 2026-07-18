import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/reviews_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/reviews/create_review_request.dart';
import 'package:marriage_hall_app/models/reviews/review.dart';

enum SubmitReviewStatus { idle, loading, success, error }

class SubmitReviewState {
  final SubmitReviewStatus status;
  final String? errorMessage;

  const SubmitReviewState({
    this.status = SubmitReviewStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == SubmitReviewStatus.loading;
}

/// There's no endpoint to ask "has this booking been reviewed?", so ids of
/// bookings reviewed during this session are tracked here — enough to hide
/// the "leave a review" prompt right after submitting. Older reviews from
/// previous sessions are caught by the server's 409 instead.
class ReviewedBookingsController extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  void add(int bookingId) => state = {...state, bookingId};
}

final reviewedBookingsProvider =
    NotifierProvider<ReviewedBookingsController, Set<int>>(
      ReviewedBookingsController.new,
    );

class SubmitReviewController extends Notifier<SubmitReviewState> {
  @override
  SubmitReviewState build() => const SubmitReviewState();

  Future<Review?> submit(CreateReviewRequest request) async {
    state = const SubmitReviewState(status: SubmitReviewStatus.loading);

    try {
      final review = await ref.read(reviewsClientProvider).create(request);
      ref.read(reviewedBookingsProvider.notifier).add(request.bookingId);
      state = const SubmitReviewState(status: SubmitReviewStatus.success);
      return review;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        400 => 'You can only review a booking once it has been completed.',
        403 => 'You can only review your own bookings.',
        409 => "You've already reviewed this booking.",
        _ => e.message,
      };
      // A 409 still means the goal state is reached — remember it so the
      // prompt disappears.
      if (e.statusCode == 409) {
        ref.read(reviewedBookingsProvider.notifier).add(request.bookingId);
      }
      state = SubmitReviewState(
        status: SubmitReviewStatus.error,
        errorMessage: message,
      );
      return null;
    } catch (_) {
      state = const SubmitReviewState(
        status: SubmitReviewStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

/// Keyed by booking id so a fresh form never shows another booking's state.
final submitReviewControllerProvider = NotifierProvider.autoDispose
    .family<SubmitReviewController, SubmitReviewState, int>(
      (bookingId) => SubmitReviewController(),
    );
