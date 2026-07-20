import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/users_client.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/profile/user_profile.dart';

/// The logged-in user's profile, null when logged out. Session-scoped so
/// it refetches per login and never shows the previous user's data.
final myProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final session = ref.watch(authControllerProvider.select((s) => s.session));
  if (session != SessionStatus.authenticated) return null;
  return ref.watch(usersClientProvider).getMe();
});

enum UpdateProfileStatus { idle, loading, success, error }

class UpdateProfileState {
  final UpdateProfileStatus status;
  final String? errorMessage;

  const UpdateProfileState({
    this.status = UpdateProfileStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == UpdateProfileStatus.loading;
}

/// Drives `PUT /api/users/me`; refreshes [myProfileProvider] on success.
class UpdateProfileController extends Notifier<UpdateProfileState> {
  @override
  UpdateProfileState build() => const UpdateProfileState();

  Future<UserProfile?> submit(UpdateProfileRequest request) async {
    if (state.isLoading) return null;
    state = const UpdateProfileState(status: UpdateProfileStatus.loading);

    try {
      final profile = await ref.read(usersClientProvider).updateMe(request);
      ref.invalidate(myProfileProvider);
      state = const UpdateProfileState(status: UpdateProfileStatus.success);
      return profile;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        409 => 'This email is already in use by another account.',
        404 => 'Your account no longer exists.',
        _ => e.message,
      };
      state = UpdateProfileState(
        status: UpdateProfileStatus.error,
        errorMessage: message,
      );
      return null;
    } catch (_) {
      state = const UpdateProfileState(
        status: UpdateProfileStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

final updateProfileControllerProvider =
    NotifierProvider.autoDispose<UpdateProfileController, UpdateProfileState>(
      UpdateProfileController.new,
    );
