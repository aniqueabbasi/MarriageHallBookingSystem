import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesState {
  final Set<String> hallIds;
  final Set<String> photographerIds;

  const FavoritesState({
    this.hallIds = const {},
    this.photographerIds = const {},
  });

  FavoritesState copyWith({
    Set<String>? hallIds,
    Set<String>? photographerIds,
  }) {
    return FavoritesState(
      hallIds: hallIds ?? this.hallIds,
      photographerIds: photographerIds ?? this.photographerIds,
    );
  }
}

class FavoritesController extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => const FavoritesState();

  void toggleHall(String id) {
    final ids = {...state.hallIds};
    if (!ids.remove(id)) ids.add(id);
    state = state.copyWith(hallIds: ids);
  }

  void togglePhotographer(String id) {
    final ids = {...state.photographerIds};
    if (!ids.remove(id)) ids.add(id);
    state = state.copyWith(photographerIds: ids);
  }
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, FavoritesState>(
      FavoritesController.new,
    );
