import 'package:intl/intl.dart';

/// "Just now" / "5 min ago" / "2 hours ago" / "3 days ago", falling back
/// to an absolute date once it's over a week old.
String formatRelativeTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time.toLocal());

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }
  return DateFormat('dd MMM yyyy').format(time.toLocal());
}
