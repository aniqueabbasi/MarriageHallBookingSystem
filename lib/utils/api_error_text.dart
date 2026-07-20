import 'package:marriage_hall_app/exceptions/api_exception.dart';

/// User-facing message for a provider/controller error, mapping the
/// common auth-ish status codes; network errors already carry a friendly
/// message from the API layer.
String friendlyErrorMessage(Object error) {
  if (error is ApiException) {
    return switch (error.statusCode) {
      401 => 'Your session has expired. Please log in again.',
      403 => 'You do not have permission to view this.',
      404 => 'The requested record was not found.',
      _ => error.message,
    };
  }
  return 'Something went wrong. Please try again.';
}
