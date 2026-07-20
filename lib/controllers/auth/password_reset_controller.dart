import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/auth_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';

class PasswordResetState {
  final bool isLoading;
  final String? errorMessage;

  const PasswordResetState({this.isLoading = false, this.errorMessage});
}

/// Drives the three-step forgot-password flow. One shared controller for
/// all three screens — they're stacked during the flow, so the autoDispose
/// provider lives exactly as long as the flow does, which also keeps the
/// reset token in memory only.
class PasswordResetController extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState();

  Future<bool> sendOtp(String email) async {
    final result = await _guard(() async {
      await ref.read(authClientProvider).forgotPassword(email);
      return true;
    });
    return result ?? false;
  }

  /// Returns the reset token, or null on failure with the error in state.
  Future<String?> verifyOtp({required String email, required String otp}) {
    return _guard(
      () => ref.read(authClientProvider).verifyResetOtp(email: email, otp: otp),
    );
  }

  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final result = await _guard(() async {
      await ref
          .read(authClientProvider)
          .resetPassword(
            email: email,
            resetToken: resetToken,
            newPassword: newPassword,
          );
      return true;
    });
    return result ?? false;
  }

  Future<T?> _guard<T>(Future<T> Function() action) async {
    if (state.isLoading) return null;
    state = const PasswordResetState(isLoading: true);
    try {
      final result = await action();
      state = const PasswordResetState();
      return result;
    } on ApiException catch (e) {
      state = PasswordResetState(errorMessage: e.message);
      return null;
    } catch (_) {
      state = const PasswordResetState(
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

final passwordResetControllerProvider =
    NotifierProvider.autoDispose<PasswordResetController, PasswordResetState>(
      PasswordResetController.new,
    );
