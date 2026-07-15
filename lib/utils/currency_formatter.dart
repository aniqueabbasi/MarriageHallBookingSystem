import 'package:intl/intl.dart';

String formatPkr(num amount) {
  return 'Rs. ${NumberFormat('#,##0').format(amount)}';
}
