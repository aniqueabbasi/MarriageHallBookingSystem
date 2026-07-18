/// Body for `PATCH /api/bookings/{id}/status`.
///
/// [advanceAmount] is required by the server when [status] is `Confirmed`
/// (must be > 0 and <= the booking's total) and must be omitted otherwise.
class UpdateBookingStatusRequest {
  final String status;
  final double? advanceAmount;

  const UpdateBookingStatusRequest({required this.status, this.advanceAmount});

  Map<String, dynamic> toJson() => {
    'status': status,
    if (advanceAmount != null) 'advanceAmount': advanceAmount,
  };
}
