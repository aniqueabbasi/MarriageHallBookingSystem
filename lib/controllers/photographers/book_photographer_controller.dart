import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookPhotographerState {
  final String selectedEvent;
  final DateTime? selectedDate;

  const BookPhotographerState({
    this.selectedEvent = 'Engagement',
    this.selectedDate,
  });

  BookPhotographerState copyWith({
    String? selectedEvent,
    DateTime? selectedDate,
  }) {
    return BookPhotographerState(
      selectedEvent: selectedEvent ?? this.selectedEvent,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class BookPhotographerController extends Notifier<BookPhotographerState> {
  @override
  BookPhotographerState build() => const BookPhotographerState();

  void setEvent(String event) => state = state.copyWith(selectedEvent: event);

  void setDate(DateTime date) => state = state.copyWith(selectedDate: date);
}

/// Keyed by photographer name so each booking sheet starts fresh.
final bookPhotographerControllerProvider = NotifierProvider.autoDispose
    .family<BookPhotographerController, BookPhotographerState, String>(
      (photographerName) => BookPhotographerController(),
    );
