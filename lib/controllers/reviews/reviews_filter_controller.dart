import 'package:flutter_riverpod/flutter_riverpod.dart';

const String allHallsFilter = 'All Halls';

class ReviewsFilterState {
  final String selectedHall;
  final int selectedRating;

  const ReviewsFilterState({
    required this.selectedHall,
    this.selectedRating = 0,
  });

  ReviewsFilterState copyWith({String? selectedHall, int? selectedRating}) {
    return ReviewsFilterState(
      selectedHall: selectedHall ?? this.selectedHall,
      selectedRating: selectedRating ?? this.selectedRating,
    );
  }
}

class ReviewsFilterController extends Notifier<ReviewsFilterState> {
  final String? initialHallFilter;

  ReviewsFilterController(this.initialHallFilter);

  @override
  ReviewsFilterState build() {
    return ReviewsFilterState(
      selectedHall: initialHallFilter ?? allHallsFilter,
    );
  }

  void setSelectedHall(String hall) =>
      state = state.copyWith(selectedHall: hall);

  void setSelectedRating(int rating) =>
      state = state.copyWith(selectedRating: rating);
}

final reviewsFilterControllerProvider = NotifierProvider.autoDispose
    .family<ReviewsFilterController, ReviewsFilterState, String?>(
      ReviewsFilterController.new,
    );
