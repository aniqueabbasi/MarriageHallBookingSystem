import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/favorites_client.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/favorites/favorite.dart';
import 'package:marriage_hall_app/models/user_role.dart';

/// Server-backed hall favorites. The list is fetched once per session and
/// then kept in sync locally: toggles mutate [state] optimistically and
/// roll back if the API call fails, so hearts never flicker waiting on a
/// refetch. Only fetched for an authenticated Customer session — the
/// endpoints 403 for owners.
class FavoritesListController extends AsyncNotifier<List<Favorite>> {
  @override
  Future<List<Favorite>> build() async {
    final auth = ref.watch(
      authControllerProvider.select((s) => (s.session, s.effectiveRole)),
    );
    if (auth.$1 != SessionStatus.authenticated || auth.$2 != UserRole.client) {
      return const [];
    }
    return ref.watch(favoritesClientProvider).list();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(favoritesClientProvider).list(),
    );
  }

  Future<void> toggleHall(int hallId) async {
    final current = state.value;
    if (current == null) return;

    final isFavorite = current.any((f) => f.hallId == hallId);
    if (isFavorite) {
      await _remove(current, hallId);
    } else {
      await _add(current, hallId);
    }
  }

  Future<void> _remove(List<Favorite> current, int hallId) async {
    state = AsyncData(current.where((f) => f.hallId != hallId).toList());
    try {
      await ref.read(favoritesClientProvider).remove(hallId);
    } on ApiException catch (e) {
      // 404 = wasn't favorited server-side anyway — end state matches.
      if (e.statusCode != 404) state = AsyncData(current);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  Future<void> _add(List<Favorite> current, int hallId) async {
    // Placeholder until the server returns the real dto; the favorites
    // screen prefers the public halls list for display data, so the empty
    // fields are never user-visible in practice.
    final placeholder = Favorite(
      id: -1,
      hallId: hallId,
      hallName: '',
      city: '',
      pricePerDay: 0,
      primaryImageUrl: null,
      createdAt: DateTime.now(),
    );
    state = AsyncData([...current, placeholder]);
    try {
      final favorite = await ref.read(favoritesClientProvider).add(hallId);
      final latest = state.value ?? const <Favorite>[];
      state = AsyncData([
        for (final f in latest) f.hallId == hallId ? favorite : f,
      ]);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        // Already favorited server-side — resync to pick up the real row.
        await refresh();
      } else {
        state = AsyncData(current);
      }
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final favoritesListProvider =
    AsyncNotifierProvider<FavoritesListController, List<Favorite>>(
      FavoritesListController.new,
    );

/// Photographer favorites stay local-only — there's no backend for
/// photographers at all yet.
class PhotographerFavoritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) {
    final ids = {...state};
    if (!ids.remove(id)) ids.add(id);
    state = ids;
  }
}

final photographerFavoritesProvider =
    NotifierProvider<PhotographerFavoritesController, Set<String>>(
      PhotographerFavoritesController.new,
    );

class FavoritesState {
  final Set<String> hallIds;
  final Set<String> photographerIds;

  const FavoritesState({
    this.hallIds = const {},
    this.photographerIds = const {},
  });
}

/// Compatibility facade over [favoritesListProvider] +
/// [photographerFavoritesProvider], keeping the `Set<String>` + toggle
/// interface the home/favorites/detail screens were already built around.
class FavoritesController extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => FavoritesState(
    hallIds:
        ref
            .watch(favoritesListProvider)
            .value
            ?.map((f) => f.hallId.toString())
            .toSet() ??
        const {},
    photographerIds: ref.watch(photographerFavoritesProvider),
  );

  Future<void> toggleHall(String id) async {
    final hallId = int.tryParse(id);
    if (hallId == null) return;
    await ref.read(favoritesListProvider.notifier).toggleHall(hallId);
  }

  void togglePhotographer(String id) =>
      ref.read(photographerFavoritesProvider.notifier).toggle(id);
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, FavoritesState>(
      FavoritesController.new,
    );
