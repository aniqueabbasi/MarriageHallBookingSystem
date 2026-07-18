/// Body for `POST /api/reviews` — only allowed for the booking's own
/// customer, only once per booking, and only after the booking is
/// `Completed`.
class CreateReviewRequest {
  final int bookingId;
  final int rating;
  final String? comment;

  const CreateReviewRequest({
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'rating': rating,
    if (comment != null && comment!.isNotEmpty) 'comment': comment,
  };
}
