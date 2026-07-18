import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/reviews/create_review_request.dart';
import 'package:marriage_hall_app/models/reviews/review.dart';

final reviewsClientProvider = Provider<ReviewsClient>(
  (ref) => ReviewsClient(ref.watch(apiClientProvider)),
);

class ReviewsClient {
  final ApiClient _client;

  ReviewsClient(this._client);

  /// 400 if the booking isn't `Completed`, 403 if it isn't the caller's
  /// own booking, 409 if the booking was already reviewed.
  Future<Review> create(CreateReviewRequest request) async {
    final json = await _client.post('/api/reviews', request.toJson());
    return Review.fromJson(json);
  }

  /// Public — no auth needed. The full review list backing the aggregate
  /// `averageRating`/`reviewCount` that `GET /api/halls/{id}` returns.
  Future<List<Review>> listForHall(int hallId) async {
    final response = await _client.getList('/api/reviews/hall/$hallId');
    return response.map(Review.fromJson).toList();
  }
}
