import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddReviewState {
  final int selectedRating;
  final List<String> uploadedImages;

  const AddReviewState({
    this.selectedRating = 0,
    this.uploadedImages = const [],
  });

  AddReviewState copyWith({int? selectedRating, List<String>? uploadedImages}) {
    return AddReviewState(
      selectedRating: selectedRating ?? this.selectedRating,
      uploadedImages: uploadedImages ?? this.uploadedImages,
    );
  }
}

class AddReviewController extends Notifier<AddReviewState> {
  @override
  AddReviewState build() => const AddReviewState();

  void setRating(int value) => state = state.copyWith(selectedRating: value);

  void addImage(String path) {
    state = state.copyWith(uploadedImages: [...state.uploadedImages, path]);
  }

  void removeImageAt(int index) {
    final updated = [...state.uploadedImages]..removeAt(index);
    state = state.copyWith(uploadedImages: updated);
  }
}

/// Keyed by hall name so a fresh review form always starts blank.
final addReviewControllerProvider = NotifierProvider.autoDispose
    .family<AddReviewController, AddReviewState, String>(
      (hallName) => AddReviewController(),
    );
