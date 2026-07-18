import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/reviews_client.dart';
import 'package:marriage_hall_app/models/reviews/review.dart';

/// The review list rendered on a hall's detail page, keyed by hall id.
/// Public endpoint — works logged out too.
final hallReviewsProvider = FutureProvider.autoDispose
    .family<List<Review>, int>(
      (ref, hallId) => ref.watch(reviewsClientProvider).listForHall(hallId),
    );
