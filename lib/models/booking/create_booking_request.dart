import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateBookingRequest {
  final int hallId;
  final int foodPackageId;
  final DateTime eventDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int guestCount;
  final List<int> extraServiceIds;

  const CreateBookingRequest({
    required this.hallId,
    required this.foodPackageId,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.guestCount,
    required this.extraServiceIds,
  });

  static String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  Map<String, dynamic> toJson() => {
    'hallId': hallId,
    'foodPackageId': foodPackageId,
    'eventDate': DateFormat('yyyy-MM-dd').format(eventDate),
    'startTime': _formatTime(startTime),
    'endTime': _formatTime(endTime),
    'guestCount': guestCount,
    'extraServiceIds': extraServiceIds,
  };
}
