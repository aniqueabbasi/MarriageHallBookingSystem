import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/payments_client.dart';
import 'package:marriage_hall_app/models/payments/payment.dart';

/// Payment history for one booking, keyed by booking id. Invalidate after
/// submitting or verifying a payment.
final bookingPaymentsProvider = FutureProvider.autoDispose
    .family<List<Payment>, int>(
      (ref, bookingId) =>
          ref.watch(paymentsClientProvider).listForBooking(bookingId),
    );
